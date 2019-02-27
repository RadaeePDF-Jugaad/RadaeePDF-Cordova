//
//  PDFView.m
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import "PDFView.h"
#import <QuartzCore/QuartzCore.h>

extern int g_def_view;
extern float g_Ink_Width;
extern float g_line_Width;
extern float g_rect_Width;
extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_line_color;
extern uint g_oval_color;
extern bool g_paging_enabled;
extern bool g_double_page_enabled;
extern bool g_curl_enabled;
extern bool g_cover_page_enabled;
extern bool g_execute_annot_JS;
extern NSString *g_author;

#define TEMP_SIGNATURE @"radaee_signature_temp.png"
#define TEMP_SIGNATURE_EMPTY @"radaee_empty_signature_temp.png"

@implementation PDFView

-(void)OnPageRendered:(PDFVCache *)cache
{
    [self refresh];
}

-(void)OnPageChanged:(int)pageno
{
	if( m_delegate )
		[m_delegate OnPageChanged:pageno];
}

-(void)OnFound:(PDFVFinder *)finder
{
    
    [m_view vFindGoto];
    CGPoint pt;
    pt.x = [m_view vGetX]/m_scale;
    pt.y = [m_view vGetY]/m_scale;
    self.contentOffset = pt;
    
    if( m_delegate )
    {
    	int pageno = [finder find_get_page];
        [m_delegate OnFound: (pageno >= 0 && pageno < [m_doc pageCount])];
    }
    
    if ([finder find_get_page] >= 0 && [finder find_get_page] < m_doc.pageCount) {
        [self vGoto:[finder find_get_page]];
    }
}

-(void)OnPageDisplayed :(CGContextRef)ctx : (PDFVPage *)page
{
    //uncomment these lines to get information of PDF page.
    //all values are in physical screen coordinate, use m_scale to translate back to logic screen coordinate
    //int x = [page GetVX:[m_view vGetX]];
    //float logicx = x/m_scale;
    //int y = [page GetVY:[m_view vGetY]];
    //float logicy = y/m_scale;
    //int w = [page GetWidth];
    //float logicw = w/m_scale;
    //int h = [page GetHeight];
    //float logich = h/m_scale;
    //bool finished = [page IsFinished];
}
- (float)getViewWidth
{
    return [m_view getWidth] / m_scale;
}

- (float)getViewHeight
{
    return [m_view getHeight] / m_scale;
}
-(void)vOpen:(PDFDoc *)doc :(id<PDFViewDelegate>)delegate
{
    [self vClose];
    
    // Load global var
    doublePage = g_double_page_enabled;
    
    // Zoom action on double tap
    // 1: default zoom
    // 2: smart zoom
    doubleTapZoomMode = 1;
 
    m_doc = doc;
    
    actionManger = [[ActionStackManager alloc] init];
  
    // Set meta tag UUID with the pdf id
    [self setUUIDMeta];
    
    bool *verts = (bool *)calloc( sizeof(bool), [doc pageCount] );
    bool *horzs = (bool *)calloc( sizeof(bool), [doc pageCount] );
    
    for (int i = 0; i < m_doc.pageCount; i++) {
        if (i > 0) {
            horzs[i] = true;
        }
    }
    
    switch(g_def_view)
    {
            // Horizontal
        case 1:
            g_paging_enabled = NO;
            m_view = [[PDFVHorz alloc] init:false];
            break;
            
            // Horizontal rtol
        case 2:
            g_paging_enabled = NO;
            m_view = [[PDFVHorz alloc] init:true];
            break;
            
            // Single Page (paging enabled)
        case 3:
            doublePage = NO;
            g_paging_enabled = YES;
            m_view = [[PDFVDual alloc] init:false :NULL :0 :verts :doc.pageCount];
            
            break;
            
            // Double Page (paging enabled)
        case 4:
            doublePage = YES;
            g_paging_enabled = YES;
            m_view = [[PDFVDual alloc] init:false :NULL :0 : NULL :doc.pageCount];
            
            break;
            
            // Double Page first page single (paging enabled)
        case 6:
            doublePage = YES;
            g_paging_enabled = YES;
            m_view = [[PDFVDual alloc] init:false :NULL :0 : horzs :doc.pageCount];
            
            break;
        default:
            g_paging_enabled = NO;
            m_view = [[PDFVVert alloc] init];
            break;
    }
    
    free( verts );
    NSLog(@"PDFView rect ：%f %f %f %f ",self.frame.origin.x, self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    self.minimumZoomScale = 1;
    self.maximumZoomScale = g_zoom_level;
    m_delegate = delegate;
    self.delegate = self;
    m_type = g_def_view;
    struct PDFVThreadBack tback;
    tback.OnPageRendered = @selector(OnPageRendered:);
    tback.OnFound = @selector(OnFound:);
    self.backgroundColor = (readerBackgroundColor != 0) ? UIColorFromRGB(readerBackgroundColor) : [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    [m_view vOpen:doc :4 :self: &tback];
    [m_view vResize:m_w :m_h];
    m_status = sta_none;
    m_ink = NULL;
    [self setModified:NO force:NO];
    
    m_lines = NULL;
    m_lines_cnt = 0;
    m_lines_max = 0;
    
    m_rects = NULL;
    m_rects_cnt = 0;
    m_rects_max = 0;
    
    m_ellipse = NULL;
    m_ellipse_cnt = 0;
    m_ellipse_max = 0;
    
    m_cur_page = -1;
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                               target:self selector:@selector(vOnTimer:)
                                             userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
    [m_view vSetScale:1];//set scale to min
    self.zoomScale = 1;//set scale to min
    m_zoom = 1;//set scale to min
    
    self.contentSize = CGSizeMake([m_view vGetDocW]/m_scale, [m_view vGetDocH]/m_scale);
   
    if( m_type == 2)//rtol mode, first page is placed at right side.
    	self.contentOffset = CGPointMake( self.contentSize.width - self.frame.size.width, 0 );
    else
    	self.contentOffset = CGPointMake( 0, 0 );
    
    self.pagingEnabled = NO;
    if ([self paginAvailable]) {
        self.pagingEnabled = g_paging_enabled;
    }
    
    if ([self isCurlEnabled]) {
        //disable scroll to use curl effect
        self.scrollEnabled = NO;
    }

    [self refresh];
}

- (void)centerPage
{
    if( m_type == 3 || m_type == 4 )
    {
        struct PDFV_POS pos;
        [m_view vGetPos:&pos :m_w/2 :m_h/2];
        int dx;
        int dy;
        [m_view vGetDeltaToCenterPage:pos.pageno :&dx :&dy];
        [self scrollRectToVisible:CGRectMake(self.contentOffset.x + dx/m_scale, self.contentOffset.y + dy/m_scale, m_w/m_scale, m_h/m_scale) animated:true];
    }
}

- (void)vUndo
{
    ASItem *item = [actionManger undo];
    if (item) {
        [item undo:m_doc];
        
        // Re-order indexes in case of annot remove
        if ([item isKindOfClass:[ASAdd class]] || item.reorder) {
            if ([item isKindOfClass:[ASMove class]]) {
                item.m_pageno = [(ASMove *)item m_pageno1];
            }
            
            [actionManger orderOnDel:item];
            
            if ([item isKindOfClass:[ASMove class]]) {
                item.m_pageno = [(ASMove *)item m_pageno0];
            }
        }
        
        [actionManger orderIndexes:item];
        [self refreshCurrentPage];
    }
}

- (void)vRedo
{
    ASItem *item = [actionManger redo];
    if (item) {
        [item redo:m_doc];
        
        // Re-order indexes in case of annot remove
        if ([item isKindOfClass:[ASDel class]] || item.reorder) {
            
            if ([item isKindOfClass:[ASMove class]]) {
                item.m_pageno = [(ASMove *)item m_pageno0];
            }
            
            [actionManger orderOnDel:item];
        
            if ([item isKindOfClass:[ASMove class]]) {
                item.m_pageno = [(ASMove *)item m_pageno1];
            }
        }
        
        [actionManger orderIndexes:item];
        [self refreshCurrentPage];
    }
}

-(void)vGoto:(int)pageno
{
    if (pageno < 0 || pageno >= m_doc.pageCount) {
        pageno = 0;
    }
    
    if (doublePage) {
        if (g_paging_enabled && g_def_view == 4 && pageno > 0 && (pageno + 1) < m_doc.pageCount && (pageno % 2 == 0) && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno++;
        }
        
        BOOL checkMod = (coverPage) ? (pageno % 2 == 0) : (pageno % 2 != 0);
        
        if (g_paging_enabled && g_def_view == 4 && pageno > 0 && checkMod && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno--;
        }
    }

    struct PDFV_POS pos;
    
    pos.x = 0;
    pos.y = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    int pages = (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) && doublePage && m_doc.pageCount > 1 && !(coverPage && (pageno < 1 || ((pageno % 2 != 0) && pageno == (m_doc.pageCount - 1))))) ? 2 : 1;
    float gapX;
    
    if (pages > 1 && (pageno + 1) < m_doc.pageCount) {
        gapX = (m_w - (([m_doc pageWidth:pageno] * [m_view vGetScaleMin:pageno]) + ([m_doc pageWidth:pageno + 1]  * [m_view vGetScaleMin:pageno]))) / 2;
    } else {
        gapX = (m_w - ([m_doc pageWidth:pageno] * [m_view vGetScaleMin:pageno])) / 2;
    }
    
    float gapY = (m_h - ([m_doc pageHeight:pageno]*[m_view vGetScaleMin:pageno])) / 2;
    
    if (g_def_view > 1)
        [m_view vSetPos:&pos :gapX :gapY];
    else
        [m_view vSetPos:&pos :0 :0];
    
    CGPoint pt;
    pt.x = [m_view vGetX]/m_scale;
    pt.y = [m_view vGetY]/m_scale;
    
    self.contentOffset = pt;
        
    [self refresh];
}

- (int)vGetCurrentPage
{
    return m_cur_page;
}

-(void)vClose
{
    if( [self isModified] && m_doc != NULL )
    {
        [m_doc save];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"fileStat"];
    }
    if( m_view != nil )
    {
        [m_view vClose];
        m_view = nil;
        [m_timer invalidate];
        m_timer = NULL;
    }
    m_view = NULL;
    m_doc = NULL;
    m_status = sta_none;
    if( m_ink )
    {
        m_ink = NULL;
    }
    if( m_lines )
    {
        free( m_lines );
        m_lines = NULL;
        m_lines_cnt = 0;
        m_lines_max = 0;
    }
    if( m_rects )
    {
        free( m_rects );
        m_rects = NULL;
        m_rects_cnt = 0;
        m_rects_max = 0;
    }
    if(m_ellipse)
    {
        free(m_ellipse);
        m_ellipse = NULL;
        m_ellipse_cnt = 0;
        m_ellipse_max = 0;
    }
    m_cur_page = -1;
    m_delegate = nil;
}

-(void)refresh
{
    [self setNeedsDisplay];
}

- (void)refreshCurrentPage
{
    if (m_cur_page > 0) {
        [m_view vRenderSync:m_cur_page - 1];
    }
    if ((m_cur_page + 1) < [m_doc pageCount]) {
        [m_view vRenderSync:m_cur_page + 1];
    }
    
    [m_view vRenderSync:m_cur_page];
    
    [self refresh];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( m_type == 3 || m_type == 4 ) {
        
        //Vertical block
        if (self.contentOffset.y <= 0)
            self.contentOffset = CGPointMake(self.contentOffset.x, 0);
        if (self.contentOffset.y > 0 && self.contentOffset.y >= self.contentSize.height - self.frame.size.height) {
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentSize.height - self.frame.size.height);
        }
    }
    
    [m_view vMoveTo:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
    [self refresh];

    CGRect rect = CGRectMake( self.contentOffset.x, self.contentOffset.y, m_w/m_scale, m_h/m_scale );
    m_child.frame = rect;
    m_child.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)resetZoomLevel
{
    [self zoomToScale:1.0 atPoint:CGPointMake(m_w/2, m_h/2)];
    [self refresh];
    
    if (self.zoomScale <= 1)
    {
        [self vGoto:m_cur_page];
        
        if ([self isCurlEnabled]) {
            [self OnPageChanged:m_cur_page];
        }
    }
    
    if ([imgAnnot isDescendantOfView:self]) {
        CGPoint center = self.center;
        center.x += self.contentOffset.x;
        center.y += self.contentOffset.y;
        imgAnnot.center = center;
    }
}

- (void)initZoomWithPoint:(CGPoint)point
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] > 6.0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGFloat buffer = point.y;
        point.y = point.x;
        point.x = m_w/m_scale - buffer;
    }
    
    zoomPoint = CGPointMake((point.x - (m_w/m_scale/2)), (point.y - (m_h/m_scale/2)));
    zoomPoint.x = (zoomPoint.x < 0) ? (zoomPoint.x * -1) : zoomPoint.x;
    zoomPoint.y = (zoomPoint.y < 0) ? (zoomPoint.y * -1) : zoomPoint.y;
    [m_view vGetPos:&m_zoom_pos :(point.x - (zoomPoint.x * self.zoomScale)) * m_scale :(point.y - (zoomPoint.y * self.zoomScale)) * m_scale];
}

- (void)zoomToScale:(CGFloat)scale atPoint:(CGPoint)point
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] > 6.0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGFloat buffer = point.y;
        point.y = point.x;
        point.x = m_w/m_scale - buffer;
    }
    
    self.zoomScale = (scale > g_zoom_level) ? g_zoom_level : scale;
    
    m_zoom = scale;
    
    if ([self isCurlEnabled]) {
        if (m_zoom <= 1)
            self.scrollEnabled = NO;
        else
            self.scrollEnabled = YES;
    }
    
    [m_view vSetScale:m_zoom];
    CGSize sz;
    sz.width = [m_view vGetDocW]/m_scale;
    sz.height = [m_view vGetDocH]/m_scale;
    self.contentSize = sz;
    [m_view vSetPos:&m_zoom_pos :(point.x - (zoomPoint.x * scale)) * m_scale :(point.y - (zoomPoint.y * scale)) * m_scale];
    self.contentOffset = CGPointMake([m_view vGetX]/m_scale, [m_view vGetY]/m_scale);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if( m_status == sta_none || m_status == sta_zoom )
		return m_child;
	else
		return NULL;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.pagingEnabled = NO;
    
    if( m_status == sta_none )
    {
        [m_view vZoomStart];
        m_status = sta_zoom;
        [self initZoomWithPoint:[scrollView.pinchGestureRecognizer locationInView:self.window]];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if( m_status == sta_zoom )
    {
        [self zoomToScale:self.zoomScale atPoint:[scrollView.pinchGestureRecognizer locationInView:self.window]];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if( m_status == sta_zoom )
    {
        //[m_view vSetScale:[m_view vGetScaleMin] * scale];
       /*
        CGSize sz;
        sz.width = [m_view vGetDocW]/m_scale;
        sz.height = [m_view vGetDocH]/m_scale;
        self.contentSize = sz;
        [m_view vSetPos:&m_zoom_pos :m_w/2 :m_h/2];
        self.contentOffset = CGPointMake([m_view vGetX]/m_scale, [m_view vGetY]/m_scale);
        */
        m_status = sta_none;
        [self refresh];
    }
    
    if (self.zoomScale <= 1 && m_status != sta_annot)
    {
        [self centerPage];
        
        if (self.zoomScale <= 1 && [self paginAvailable]) {
            self.pagingEnabled = g_paging_enabled;
        }
    }
}

-(void)drawInk:(CGContextRef)context
{
    if( m_status == sta_ink && m_ink )
    {
        NSLog(@"g_ink_color = %d",g_ink_color);
        int cnt = [m_ink nodesCount];
        int cur = 0;
        CGContextSetLineWidth(context, g_Ink_Width);
        float red = ((g_ink_color>>16)&0xFF)/255.0f;
        float green = ((g_ink_color>>8)&0xFF)/255.0f;
        float blue = (g_ink_color&0xFF)/255.0f;
        float alpha = ((g_ink_color>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        CGContextBeginPath( context );
        while( cur < cnt )
        {
            PDF_POINT pt;
            PDF_POINT pt2;
            int type = [m_ink node: cur: &pt];
            switch( type )
            {
                case 1:
                    CGContextAddLineToPoint(context, self.contentOffset.x + pt.x/m_scale, self.contentOffset.y + pt.y/m_scale);
                    cur++;
                    break;
                case 2:
                    [m_ink node: cur + 1: &pt2];
                    CGContextAddCurveToPoint(context, self.contentOffset.x + pt.x/m_scale, self.contentOffset.y + pt.y/m_scale,
                                             self.contentOffset.x + pt.x/m_scale, self.contentOffset.y + pt.y/m_scale,
                                             self.contentOffset.x + pt2.x/m_scale, self.contentOffset.y + pt2.y/m_scale );
                    cur += 2;
                    break;
                default:
                    CGContextMoveToPoint(context, self.contentOffset.x + pt.x/m_scale, self.contentOffset.y + pt.y/m_scale);
                    cur++;
                    break;
            }
        }
        CGContextStrokePath( context );
    }
}

-(void)drawAnnot:(CGContextRef)context
{
    if( m_status == sta_annot )
    {
        int dx = m_tx - m_px;
        int dy = m_ty - m_py;
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGRect rect1 = CGRectMake(self.contentOffset.x + (m_annot_rect.left+dx)/m_scale,
                                  self.contentOffset.y + (m_annot_rect.top+dy)/m_scale,
                                  (m_annot_rect.right - m_annot_rect.left)/m_scale,
                                  (m_annot_rect.bottom - m_annot_rect.top)/m_scale);
        CGContextStrokeRect(context, rect1);
    }
}

-(void)drawLines:(CGContextRef)context
{
    if( m_status == sta_line && (m_lines_cnt || m_lines_drawing) )
    {
        CGContextSetLineWidth(context, g_line_Width);
        float red = ((g_line_color>>16)&0xFF)/255.0f;
        float green = ((g_line_color>>8)&0xFF)/255.0f;
        float blue = (g_line_color&0xFF)/255.0f;
        float alpha = ((g_line_color>>24)&0xFF)/255.0f;
        CGContextSetRGBFillColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_lines;
        PDF_POINT *pt_end = m_lines + (m_lines_cnt<<1);
        if( m_lines_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            CGPoint start = CGPointMake(self.contentOffset.x + pt_cur->x/m_scale, self.contentOffset.y + pt_cur->y/m_scale);
            CGPoint end = CGPointMake(self.contentOffset.x + pt_cur[1].x/m_scale, self.contentOffset.y + pt_cur[1].y/m_scale);
            CGPoint points[2] = {start, end};
            CGContextStrokeLineSegments(context, points, 2);
            pt_cur += 2;
        }
    }
}

-(void)drawRects:(CGContextRef)context
{
    if( m_status == sta_rect && (m_rects_cnt || m_rects_drawing) )
    {
        CGContextSetLineWidth(context, g_rect_Width);
        float red = ((g_rect_color>>16)&0xFF)/255.0f;
        float green = ((g_rect_color>>8)&0xFF)/255.0f;
        float blue = (g_rect_color&0xFF)/255.0f;
        float alpha = ((g_rect_color>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_rects;
        PDF_POINT *pt_end = m_rects + (m_rects_cnt<<1);
        if( m_rects_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            if( pt_cur->x > pt_cur[1].x )
            {
                rect.right = pt_cur->x;
                rect.left = pt_cur[1].x;
            }
            else
            {
                rect.left = pt_cur->x;
                rect.right = pt_cur[1].x;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y;
                rect.top = pt_cur[1].y;
            }
            else
            {
                rect.top = pt_cur->y;
                rect.bottom = pt_cur[1].y;
            }
            CGRect rect1 = CGRectMake(self.contentOffset.x + rect.left/m_scale, self.contentOffset.y + rect.top/m_scale,
                                      (rect.right - rect.left)/m_scale,
                                      (rect.bottom - rect.top)/m_scale);
            CGContextStrokeRect(context, rect1);
            pt_cur += 2;
        }
    }
}

-(void)drawEllipse:(CGContextRef)context
{
    if( m_status == sta_ellipse && (m_ellipse_cnt || m_ellipse_drawing) )
    {
        CGContextSetLineWidth(context, g_rect_Width);
        float red = ((g_oval_color>>16)&0xFF)/255.0f;
        float green = ((g_oval_color>>8)&0xFF)/255.0f;
        float blue = (g_oval_color&0xFF)/255.0f;
        float alpha = ((g_oval_color>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_ellipse;
        PDF_POINT *pt_end = m_ellipse + (m_ellipse_cnt<<1);
        if( m_ellipse_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            if( pt_cur->x > pt_cur[1].x )
            {
                rect.right = pt_cur->x;
                rect.left = pt_cur[1].x;
            }
            else
            {
                rect.left = pt_cur->x;
                rect.right = pt_cur[1].x;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y;
                rect.top = pt_cur[1].y;
            }
            else
            {
                rect.top = pt_cur->y;
                rect.bottom = pt_cur[1].y;
            }
            CGRect rect1 = CGRectMake(self.contentOffset.x + rect.left/m_scale, self.contentOffset.y + rect.top/m_scale,
                                      (rect.right - rect.left)/m_scale,
                                      (rect.bottom - rect.top)/m_scale);
            CGContextStrokeEllipseInRect(context, rect1);
            
            pt_cur += 2;
        }
    }
}

-(void)draw:(CGContextRef)context
{
    PDFVCanvas *canvas = [[PDFVCanvas alloc] init: context: m_scale];
    [m_view vDraw:canvas:(m_status == sta_zoom)];
    canvas = nil;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos : m_w/2 : m_h/2];
    if( m_cur_page != pos.pageno )
    {
        m_cur_page = pos.pageno;
        if( m_delegate )
            [m_delegate OnPageChanged:m_cur_page];
    }
    
    [self drawAnnot:context];
    [self drawInk:context];
    [self drawLines:context];
    [self drawRects:context];
    [self drawEllipse:context];

#ifdef FTS_ENABLED
    [self drawSearchRect:context];
#endif
}

#ifdef FTS_ENABLED
- (void)drawSearchRect:(CGContextRef)context
{
    if (m_cur_page == currentOccurrence.page) {
        PDF_RECT drawRect;
        
        PDFVPage *vpage = [m_view vGetPage:m_cur_page];
        
        drawRect.left = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:currentOccurrence.rect_l];
        drawRect.right = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:currentOccurrence.rect_r];
        drawRect.top = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:currentOccurrence.rect_b];
        drawRect.bottom = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:currentOccurrence.rect_t];
        
        int dx = m_tx - m_px;
        int dy = m_ty - m_py;
        
        CGContextSetRGBFillColor(context, 0.5, 0.0, 0.93, 0.25);
        
        CGRect rect1 = CGRectMake(self.contentOffset.x + (drawRect.left+dx)/m_scale,
                                  self.contentOffset.y + (drawRect.top+dy)/m_scale,
                                  (drawRect.right - drawRect.left)/m_scale,
                                  (drawRect.bottom - drawRect.top)/m_scale);
        CGContextFillRect(context, rect1);
    }
}

- (void)applyFTSOccurrence:(FTSOccurrence *)occurrence
{
    currentOccurrence = occurrence;
}
#endif

-(BOOL)forceSave
{
    if ([m_doc save]) {
        [self setModified:NO force:YES];
        return YES;
    }
    
    return NO;
}

- (void)vOnTimer:(NSTimer *)sender
{
    if( [m_view vNeedRefresh] )
    {
        [self refresh];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_doc = NULL;
        m_view = nil;
        m_scale = [[UIScreen mainScreen] scale];
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
            m_scale = [[UIScreen mainScreen] nativeScale]; //xcode6 ios8 sdk only
        }
        
        //m_scale = [[UIScreen mainScreen] nativeScale]; //xcode6 ios8 sdk only
        //m_scale = 3.0;  //test for iPhone6 Plus
        //m_scale = [[UIScreen mainScreen] scale];
        m_zoom = 1;
        m_w = frame.size.width * m_scale;
        m_h = frame.size.height * m_scale;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        m_child = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:m_child];
        [self resignFirstResponder];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self draw:UIGraphicsGetCurrentContext()];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    struct PDFV_POS pos;
    [self vAnnotEnd];
    [m_view vGetPos:&pos :m_w/2 :m_h/2];
    m_w = size.width * m_scale;
    m_h = size.height * m_scale;
    [m_view vResize:m_w :m_h];
    [m_view vSetScale:1];//set scale to min
    [m_view vSetPos:&pos :m_w/2 :m_h/2];
    self.zoomScale = 1;//set scale to min
    m_zoom = 1;//set scale to min
    self.contentSize = CGSizeMake([m_view vGetDocW]/m_scale, [m_view vGetDocH]/m_scale);
    self.contentOffset = CGPointMake([m_view vGetX]/m_scale, [m_view vGetY]/m_scale);
    [self refresh];
    
    return size;
}

-(bool)OnSelTouchBegin:(CGPoint)point
{
	if( m_status != sta_sel ) return false;
    m_tx = point.x * m_scale;
    m_ty = point.y * m_scale;
	if( m_delegate )
		[m_delegate OnSelStart:point.x: point.y];
    return true;
}

-(bool)OnSelTouchMove:(CGPoint)point
{
	if( m_status != sta_sel ) return false;
	[m_view vSetSel:m_tx: m_ty: point.x * m_scale: point.y * m_scale];
	[self refresh];
	return true;
}

-(bool)OnSelTouchEnd:(CGPoint)point
{
	if( m_status != sta_sel ) return false;
	[m_view vSetSel:m_tx: m_ty: point.x * m_scale: point.y * m_scale];
    
    PDFVPage *vpage = [m_view vGetPage:m_cur_page];
    PDF_RECT rect = [vpage GetSelRect];
    
    rect.left = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:rect.left];
    rect.right = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:rect.right];
    float tmp = rect.top;
    rect.top = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:rect.bottom];
    rect.bottom = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:tmp];
    
    CGRect rect1 = CGRectMake(self.contentOffset.x + rect.left/m_scale, self.contentOffset.y + rect.top/m_scale,
                              (rect.right - rect.left)/m_scale,
                              (rect.bottom - rect.top)/m_scale);

	[self refresh];
    
	if( m_delegate )
		[m_delegate OnSelEnd :rect1.origin.x - self.contentOffset.x: rect1.origin.y - self.contentOffset.y:rect1.origin.x + rect1.size.width - self.contentOffset.x :rect1.origin.y + rect1.size.height - self.contentOffset.y];
	return true;
}

-(bool)OnAnnotTouchBegin:(CGPoint)point
{
	if (m_status != sta_annot) return false;
    if (![m_annot canMoveAnnot]) return false;
    m_px = point.x * m_scale;
    m_py = point.y * m_scale;
    m_tx = m_px;
    m_ty = m_py;
	return true;
}

-(bool)OnAnnotTouchMove:(CGPoint)point
{
	if (m_status != sta_annot) return false;
    if (![m_annot canMoveAnnot]) return false;
    if([self canSaveDocument])
    {
        m_tx = point.x * m_scale;
        m_ty = point.y * m_scale;
    }
    [self refresh];
	return true;
}

-(bool)OnAnnotTouchEnd:(CGPoint)point
{
	if (m_status != sta_annot) return false;
    if (m_annot.type == 20) { // EditText
        if (m_delegate) {
            [m_delegate OnAnnotEnd];
        }
    }
    
    if (![m_annot canMoveAnnot]) {
        [self vAnnotEnd];
        return false;
    }
    
    if([self canSaveDocument])
    {
    	[self setModified:YES force:NO];
        [self setModifyDateForAnnot:m_annot];
        
        if (m_tx == m_px && m_ty == m_py)
        {
            [self vAnnotEnd];
            return true;
        }
        
        m_tx = point.x * m_scale;
        m_ty = point.y * m_scale;
        m_annot_rect.left += m_tx - m_px;
        m_annot_rect.top += m_ty - m_py;
        m_annot_rect.right += m_tx - m_px;
        m_annot_rect.bottom += m_ty - m_py;
        PDFVPage *vpage = [m_view vGetPage:m_annot_pos.pageno];
        struct PDFV_POS pos;
        [m_view vGetPos:&pos :m_annot_rect.left :m_annot_rect.top];
        if( pos.pageno == m_annot_pos.pageno )
        {
	        PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
	        [mat transformRect:&m_annot_rect];
            
            //Action Stack Manger
            PDF_RECT rect;
            [m_annot getRect:&rect];
            [actionManger push:[[ASMove alloc] initWithPage:pos.pageno initRect:rect destPage:pos.pageno destRect:m_annot_rect index:m_annot.getIndex ref:[m_annot getRef]]];
            
	        [m_annot setRect:&m_annot_rect];
	        [m_view vRenderSync:m_annot_pos.pageno];
	        [self vAnnotEnd];
        }
	    else
	    {
        	PDFVPage *vdest = [m_view vGetPage:pos.pageno];
        	PDFPage *dpage = [vdest GetPage];
            if( dpage )
            {
                PDFMatrix *mat = [vdest CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
                [mat transformRect:&m_annot_rect];
                
                //Action Stack Manger
                PDF_RECT rect;
                [m_annot getRect:&rect];
                
                PDF_OBJ_REF ref = [m_annot getRef];
                
                [m_annot MoveToPage:dpage:&m_annot_rect];
                [m_view vRenderSync:m_annot_pos.pageno];
                [m_view vRenderSync:pos.pageno];
                
                ASMove *item = [[ASMove alloc] initWithPage:m_annot_pos.pageno initRect:rect destPage:pos.pageno destRect:m_annot_rect index:([dpage annotCount] - 1) ref:ref];
                [actionManger push:item];
                item.m_pageno = item.m_pageno0;
                [actionManger orderOnDel:item];
                item.m_pageno = item.m_pageno1;
                [actionManger orderIndexes:item];
                
                [self vAnnotEnd];
            }
	    }
    }
    return true;
}

-(bool)OnNoteTouchBegin:(CGPoint)point
{
	if( m_status != sta_note ) return false;
	return true;
}

-(bool)OnNoteTouchMove:(CGPoint)point
{
	if( m_status != sta_note ) return false;
	return true;
}

-(bool)OnNoteTouchEnd:(CGPoint)point
{
	if( m_status != sta_note ) return false;
	struct PDFV_POS pos;
	[m_view vGetPos:&pos :point.x * m_scale :point.y * m_scale];
	PDFVPage *vpage = [m_view vGetPage:pos.pageno];
	if( vpage )
	{
		PDFPage *page = [vpage GetPage];
		if( page )
		{
			[self setModified:YES force:NO];
			PDF_POINT pt;
			pt.x = pos.x;
			pt.y = pos.y;
			[page addAnnotNote:&pt];
            
            //Action Stack Manger
            [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
            
            // Set Author and Modify date
            [self updateLastAnnotInfoAtPage:page];
            
			[m_view vRenderSync:pos.pageno];
			[self refresh];
		}
	}
	return true;
}

-(bool)OnInkTouchBegin:(CGPoint)point
{
	if( m_status != sta_ink ) return false;
    if( !m_ink )
    {
        m_tx = point.x * m_scale;
        m_ty = point.y * m_scale;
        m_ink = [[PDFInk alloc] init:g_Ink_Width * m_scale: g_ink_color];
    }
    [m_ink onDown:point.x * m_scale: point.y * m_scale];
	return true;
}

-(bool)OnInkTouchMove:(CGPoint)point
{
	if( m_status != sta_ink ) return false;
    [m_ink onMove:point.x * m_scale: point.y * m_scale];
    [self refresh];
    return true;
}
-(bool)OnInkTouchEnd:(CGPoint)point
{
	if( m_status != sta_ink ) return false;
	[m_ink onUp:point.x * m_scale: point.y * m_scale];
    [self refresh];
	return true;
}

-(bool)OnLineTouchBegin:(CGPoint)point
{
    if( m_status != sta_line ) return false;
    if( m_lines_cnt >= m_lines_max )
    {
        m_lines_max += 8;
        m_lines = (PDF_POINT *)realloc(m_lines, (m_lines_max<<1) * sizeof(PDF_POINT));
    }
    m_tx = point.x * m_scale;
    m_ty = point.y * m_scale;
    PDF_POINT *pt_cur = &m_lines[m_lines_cnt<<1];
    pt_cur->x = m_tx;
    pt_cur->y = m_ty;
    pt_cur[1].x = m_tx;
    pt_cur[1].y = m_ty;
    m_lines_drawing = true;
    return true;
}

-(bool)OnLineTouchMove:(CGPoint)point
{
    if( m_status != sta_line ) return false;
    PDF_POINT *pt_cur = &m_lines[m_lines_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    [self refresh];
    return true;
}

-(bool)OnLineTouchEnd:(CGPoint)point
{
    if( m_status != sta_line ) return false;
    PDF_POINT *pt_cur = &m_lines[m_lines_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    m_lines_cnt++;
    if( m_lines_drawing )
    {
        m_lines_drawing = false;
        [self refresh];
    }
    return true;
}

-(bool)OnRectTouchBegin:(CGPoint)point
{
	if( m_status != sta_rect ) return false;
    if( m_rects_cnt >= m_rects_max )
    {
        m_rects_max += 8;
        m_rects = (PDF_POINT *)realloc(m_rects, (m_rects_max<<1) * sizeof(PDF_POINT));
    }
    m_tx = point.x * m_scale;
    m_ty = point.y * m_scale;
    PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
    pt_cur->x = m_tx;
    pt_cur->y = m_ty;
    pt_cur[1].x = m_tx;
    pt_cur[1].y = m_ty;
    m_rects_drawing = true;
	return true;
}

-(bool)OnRectTouchMove:(CGPoint)point
{
	if( m_status != sta_rect ) return false;
    PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    [self refresh];
	return true;
}

-(bool)OnRectTouchEnd:(CGPoint)point
{
	if( m_status != sta_rect ) return false;
    PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    m_rects_cnt++;
    if( m_rects_drawing )
    {
        m_rects_drawing = false;
        [self refresh];
    }
    return true;
}

-(bool)OnEllipseTouchBegin:(CGPoint)point
{
	if( m_status != sta_ellipse ) return false;
    if( m_ellipse_cnt >= m_ellipse_max )
    {
        m_ellipse_max += 8;
        m_ellipse = (PDF_POINT *)realloc(m_ellipse, (m_ellipse_max<<1) * sizeof(PDF_POINT));
    }
    m_tx = point.x * m_scale;
    m_ty = point.y * m_scale;
    PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
    pt_cur->x = m_tx;
    pt_cur->y = m_ty;
    pt_cur[1].x = m_tx;
    pt_cur[1].y = m_ty;
    m_ellipse_drawing = true;
	return true;
}

-(bool)OnEllipseTouchMove:(CGPoint)point
{
	if( m_status != sta_ellipse ) return false;
    PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    [self refresh];
	return true;
}

-(bool)OnEllipseTouchEnd:(CGPoint)point
{
	if( m_status != sta_ellipse ) return false;
    PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
    pt_cur[1].x = point.x * m_scale;
    pt_cur[1].y = point.y * m_scale;
    m_ellipse_cnt++;
    if( m_ellipse_drawing )
    {
        m_ellipse_drawing = false;
        [self refresh];
    }
    return true;
}

-(void)OnNoneTouchBegin:(CGPoint)point :(NSTimeInterval)timeStamp
{
    m_tstamp = timeStamp;
    m_tstamp_tap = m_tstamp;
    m_tx = point.x * m_scale;
    m_ty = point.y * m_scale;
    m_px = m_tx;
    m_py = m_ty;
}

-(void)OnNoneTouchMove:(CGPoint)point :(NSTimeInterval)timeStamp
{
    NSTimeInterval del = timeStamp - m_tstamp;
    if( del > 0 )
    {
        float dx = point.x * m_scale - m_px;
        float dy = point.y * m_scale - m_py;
        float vx = dx/del;
        float vy = dy/del;
        dx = 0;
        dy = 0;
        if( vx > 50 || vx < -50 )
            dx = vx;
        if( vy > 50 || vy < -50 )
            dy = vy;
        else if( timeStamp - m_tstamp_tap > 1 )//long pressed
        {
            dx = point.x * m_scale - m_tx;
            dy = point.y * m_scale - m_ty;
            if( dx < 10 && dx > -10 && dy < 10 && dy > -10 )
            {
                m_status = sta_none;
                if( m_delegate )
                    [m_delegate OnLongPressed:point.x :point.y];
            }
        }
    }
    m_px = point.x * m_scale;
    m_py = point.y * m_scale;
}

-(void)OnNoneTouchEnd:(CGPoint)point :(NSTimeInterval)timeStamp
{
    float dx = point.x - m_tx / m_scale;
    float dy = point.y - m_ty / m_scale;
    if( timeStamp - m_tstamp_tap < 0.15 )//single tap
    {
        bool single_tap = true;
        if( dx > 5 || dx < -5 )
            single_tap = false;
        if( dy > 5 || dy < -5 )
            single_tap = false;
        if( single_tap )
        {
            [self onSingleTap:point.x :point.y];
        }
    }
    else
    {
        bool long_press = true;
        if( dx > 5 || dx < -5 )
            long_press = false;
        if( dy > 5 || dy < -5 )
            long_press = false;
        if( long_press )
        {
            if( m_delegate )
                [m_delegate OnLongPressed:point.x :point.y];
        }
        
        if([self paginAvailable])
        {
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :m_w/2 :m_h/2];
            int dx;
            int dy;
            [m_view vGetDeltaToCenterPage:pos.pageno :&dx :&dy];
            [self scrollRectToVisible:CGRectMake(self.contentOffset.x + dx/m_scale, self.contentOffset.y + dy/m_scale, m_w/m_scale, m_h/m_scale) animated:true];
        }
    }
}

- (BOOL)addAttachmentFromPath:(NSString *)path
{
    PDF_RECT rect;
    rect.left = rect.top = rect.right = rect.bottom = 0;
    return [self addAttachmentAtPage:0 fromPath:path inRect:rect];
}

- (BOOL)addAttachmentAtPage:(int)pageno fromPath:(NSString *)path inRect:(PDF_RECT)rect
{
    if ([path containsString:@"file://"])
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        PDFPage *page = [m_doc page:pageno];
        BOOL res = [page addAnnotAttachment:path :0 :&rect];
        
        if(res)
        {
            [self setModified:YES force:NO];
            return YES;
        }
    }
    
    return NO;
}

- (void)OnDoubleTap:(UITouch *)touch
{
    isDoubleTapping = YES;
    
    NSLog(@"double tap");
    
    if (doubleTapZoomMode > 0) {
        if (m_zoom > 1){
            self.pagingEnabled = g_paging_enabled;
            [self resetZoomLevel];
        }else {
            self.pagingEnabled = NO;
            
            if (doubleTapZoomMode == 1) {
                [self defaultZoom:touch];
            } else {
#ifndef SMART_ZOOM
                [self defaultZoom:touch];
#else
                [self initZoomWithPoint:[touch locationInView:self.window]];
                struct PDFV_POS pos;
                CGPoint p = [touch locationInView:self.window];
                
                [m_view vGetPos:&pos :p.x * m_scale :p.y * m_scale];
                PDF_RECT mZoomRect = [ReaderHandler handleAutomaticZoom:m_view withPos:pos forDoc:m_doc containedInWidth:m_w];
                
                float mParagraphWidth = mZoomRect.right - mZoomRect.left;
                
                if ((int)mParagraphWidth == 0) {
                    [self defaultZoom:touch]; // Call defaultZoom as fallback
                    return;
                }
                
                int scale = (int) (m_w / mParagraphWidth); //screen width / paragraph width
                
                pos.x = mZoomRect.right - (mParagraphWidth / 2);
                
                if (scale > 1) {
                    
                    self.zoomScale = (scale > g_zoom_level) ? g_zoom_level : scale;
                    m_zoom = scale;
                    
                    [m_view vSetScale:scale];
                    [m_view vSetPos:&pos :m_w /2 :m_h /2];
                    
                    CGSize sz;
                    sz.width = [m_view vGetDocW]/m_scale;
                    sz.height = [m_view vGetDocH]/m_scale;
                    self.contentSize = sz;
                    //[m_view vSetPos:&m_zoom_pos :(pos.x - (zoomPoint.x * scale)) * m_scale :(pos.y - (zoomPoint.y * scale)) * m_scale];
                    self.contentOffset = CGPointMake([m_view vGetX]/m_scale, [m_view vGetY]/m_scale);
                    
                    [self refresh];
                }
#endif
            }
        }
    }
    
    if (m_delegate) {
        [m_delegate OnDoubleTapped:[touch locationInView:self.window].x :[touch locationInView:self.window].y];
    }
    
    [self performSelector:@selector(delayedDoubleTapping) withObject:nil afterDelay:0.5];
}

- (void)delayedDoubleTapping
{
    isDoubleTapping = NO;
}

- (void)defaultZoom:(UITouch *)touch
{
    [self initZoomWithPoint:[touch locationInView:self.window]];
    [self zoomToScale:2.0 atPoint:[touch locationInView:self.window]];
}

/*
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt > 1 ) return true;
    return false;
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = (int)[allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        
        if ([self isCurlEnabled]) {
            if (m_delegate && m_zoom <= 1) {
                float gap = (self.bounds.size.width - [self getViewWidth]) / 2;
                if ((gap + 40 > point.x && m_cur_page > 0) || (point.x > gap + [self getViewWidth] - 40 && m_cur_page + 1 < m_doc.pageCount)) {
                    [m_delegate touchesOnViewBegan:touches withEvent:event];
                    return;
                }
            }
        }
        
        point.x *= m_zoom;
        point.y *= m_zoom;
        if( [self OnSelTouchBegin:point] ) return;
        if( [self OnAnnotTouchBegin:point] ) return;
        if( [self OnNoteTouchBegin:point] ) return;
        if( [self OnInkTouchBegin:point] ) return;
        if( [self OnLineTouchBegin:point] ) return;
        if( [self OnRectTouchBegin:point] ) return;
        if( [self OnEllipseTouchBegin:point] ) return;
        if( [self OnImageTouchBegin:point] ) return;
        [self OnNoneTouchBegin:point:touch.timestamp];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = (int)[allTouches count];
    
    if( cnt == 1 )
    {
        if ([self isCurlEnabled]) {
            if (m_delegate && m_zoom <= 1) {
                [m_delegate touchesOnViewMoved:touches withEvent:event];
                if (self.isCurling) {
                    return;
                }
            }
        }
        
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        point.x *= m_zoom;
        point.y *= m_zoom;
        
        if( [self OnSelTouchMove:point] ) return;
        if( [self OnAnnotTouchMove:point] ) return;
        if( [self OnNoteTouchMove:point] ) return;
        if( [self OnInkTouchMove:point] ) return;
        if( [self OnLineTouchMove:point] ) return;
        if( [self OnRectTouchMove:point] ) return;
        if( [self OnEllipseTouchMove:point] ) return;
        if( [self OnImageTouchMove:point] ) return;
        
        [self OnNoneTouchMove:point:touch.timestamp];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2 && m_status == sta_none) {
        //this is the double tap action
        [self OnDoubleTap:touch];
    }
    else
    {
        NSSet *allTouches = [event allTouches];
        int cnt = (int)[allTouches count];
        if( cnt == 1 )
        {
            if ([self isCurlEnabled]) {
                if (m_delegate && m_zoom <= 1) {
                    [m_delegate touchesOnViewEnded:touches withEvent:event];
                    //return;
                }
            }
            
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint point=[touch locationInView:[touch view]];
            point.x *= m_zoom;
            point.y *= m_zoom;
            if( [self OnSelTouchEnd:point] ) return;
            if( [self OnAnnotTouchEnd:point] ) return;
            if( [self OnNoteTouchEnd:point] ) return;
            if( [self OnInkTouchEnd:point] ) return;
            if( [self OnLineTouchEnd:point] ) return;
            if( [self OnRectTouchEnd:point] ) return;
            if( [self OnEllipseTouchEnd:point] ) return;
            if( [self OnImageTouchEnd:point] ) return;
            [self OnNoneTouchEnd:point:touch.timestamp];
        }
    }
}
 
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)vSelStart
{
    if( m_status == sta_none )
    {
        m_status = sta_sel;
        self.scrollEnabled = false;
    }
}

-(void)vGetPos:(struct PDFV_POS*)pos
{
    [m_view vGetPos:pos :m_w/2 :m_h/2];
}

- (void)vGetPos:(struct PDFV_POS *)pos x:(int)x y:(int)y
{
    [m_view vGetPos:pos :x * m_scale :y * m_scale];
}

-(void)vSetPos:(const struct PDFV_POS*)pos;
{
	if( !pos ) return;
    [m_view vSetPos:pos :0 :0];
    CGPoint pt;
    pt.x = [m_view vGetX]/m_scale;
    pt.y = [m_view vGetY]/m_scale;
    self.contentOffset = pt;
}

-(void)vSelEnd
{
    if( m_status == sta_sel )
    {
        [self enableScroll];
        
        m_status = sta_none;
        [m_view vClearSel];
        [self refresh];
    }
}

-(NSString *)vSelGetText
{
    if( m_status != sta_sel ) return nil;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos : m_tx: m_ty];
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        return [vpage GetSel];
    }
    return nil;
}

-(BOOL)vSelMarkup:(int)color :(int)type
{
    if( m_status != sta_sel ) return false;
    if(![self canSaveDocument]) return false;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos: m_tx: m_ty];
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        PDFPage *page = [vpage GetPage];
        [self setModified:[vpage SetSelMarkup:type :color] force:NO];
        [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
        
        [m_view vRenderSync:pos.pageno];
        [self refresh];
        return true;

    }
    [self refresh];
    return false;
}

-(void)vLockSide:(bool)lock
{
 
}

-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word
{
    if( !pat ) return false;
    [m_view vFindStart:pat :match_case :whole_word];
    [self refresh];
    return true;
}

-(void)vFind:(int)dir
{
    if( [m_view vFind:dir] < 0 )
        if( m_delegate ) [m_delegate OnFound:false];
    [self refresh];
}
-(void)vFindEnd
{
    [m_view vFindEnd];
    [self refresh];
}

-(bool)vNoteStart
{
    if(![self canSaveDocument]) return false;
	if( m_status == sta_none )
	{
	    self.scrollEnabled = false;
		m_status = sta_note;
	}
    return true;
}

-(void)vNoteEnd
{
    [self setModified:YES force:NO];
    
	if( m_status == sta_note )
	{
        [self enableScroll];
        
	    m_status = sta_none;
		//[m_view vRenderSync:pos.pageno];
		[self refresh];
	}
}

-(bool)vInkStart
{
    if(![self canSaveDocument]) return false;
    if( m_status == sta_none )
    {
        self.scrollEnabled = false;
        
        m_ink = NULL;
        m_status = sta_ink;
        return true;
    }
    return false;
}

-(void)vInkCancel
{
    if( m_status == sta_ink )
    {
        [self enableScroll];
        
        m_status = sta_none;
        m_ink = NULL;
        [self refresh];
    }
}

-(void)vInkEnd
{
    if( m_status == sta_ink )
    {
        if( m_ink )
        {
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :m_tx:m_ty];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
                PDFPage *page = [vpage GetPage];
                [mat transformInk:m_ink];
                [page addAnnotInk:m_ink];
                
                //Action Stack Manger
                [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
                
                // Set Author and Modify date
                [self updateLastAnnotInfoAtPage:page];
                
                [m_view vRenderSync:pos.pageno];
            }
            [self setModified:YES force:NO];
        }
        m_status = sta_none;
        m_ink = NULL;
        [self refresh];
        
        [self enableScroll];
    }
}
-(bool)vEllipseStart
{
    if(![self canSaveDocument]) return false;
    if( m_status == sta_none )
    {
        m_status = sta_ellipse;
        m_ellipse_drawing = false;
        self.scrollEnabled = false;
        return true;
    }
    return false;
}
-(void)vEllipseCancel
{
    if( m_status == sta_ellipse )
    {
        [self enableScroll];
        m_ellipse_cnt = 0;
        m_ellipse_drawing = false;
        m_status = sta_none;
        [self refresh];
    }
}

-(void)vEllipseEnd
{
    if( m_status == sta_ellipse )
    {
        PDFVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_ellipse;
        PDF_POINT *pt_end = pt_cur + (m_ellipse_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :pt_cur->x :pt_cur->y];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                cur = 0;
                end = pages_cnt;
                
                if (cur >= 128) {
                    return;
                }
                
                while( cur < end )
                {
                    if( pages[cur] == vpage ) break;
                    cur++;
                }
                if( cur >= end )
                {
                    pages[cur] = vpage;
                    pages_cnt++;
                }
                if( pt_cur->x > pt_cur[1].x )
                {
                    rect.right = pt_cur->x;
                    rect.left = pt_cur[1].x;
                }
                else
                {
                    rect.left = pt_cur->x;
                    rect.right = pt_cur[1].x;
                }
                if( pt_cur->y > pt_cur[1].y )
                {
                    rect.bottom = pt_cur->y;
                    rect.top = pt_cur[1].y;
                }
                else
                {
                    rect.top = pt_cur->y;
                    rect.bottom = pt_cur[1].y;
                }
                PDFPage *page = [vpage GetPage];
                PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
                [mat transformRect:&rect];
                [page addAnnotEllipse:&rect:g_rect_Width * m_scale / [vpage GetScale]:g_oval_color:0];
                
                //Action Stack Manger
                [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
                
                // Set Author and Modify date
                [self updateLastAnnotInfoAtPage:page];
            }
            pt_cur += 2;
        }
        [self setModified:(m_ellipse_cnt != 0) force:NO];
        m_ellipse_cnt = 0;
        m_ellipse_drawing = false;
        m_status = sta_none;
        
        cur = 0;
        end = pages_cnt;
        while( cur < end )
        {
            [m_view vRenderSync:[pages[cur] GetPageNo]];
            cur++;
        }
        [self refresh];
        [self enableScroll];
    }
}
-(bool)vLineStart
{
    if(![self canSaveDocument]) return false;
    if( m_status == sta_none )
    {
        self.scrollEnabled = false;
        m_status = sta_line;
        m_lines_drawing = false;
        return true;
    }
    return false;
}
-(void)vLineCancel
{
    if( m_status == sta_line )
    {
        [self enableScroll];
        m_lines_cnt = 0;
        m_lines_drawing = false;
        m_status = sta_none;
        [self refresh];
    }
}
-(void)vLineEnd
{
    if( m_status == sta_line )
    {
        PDFVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_lines;
        PDF_POINT *pt_end = pt_cur + (m_lines_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :pt_cur->x :pt_cur->y];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                cur = 0;
                end = pages_cnt;
                //PDFVPage *vpage2;
                while( cur < end )
                {
                    if( pages[cur] == vpage ) break;
                    cur++;
                }
                if( cur >= end )
                {
                    pages[cur] = vpage;
                    pages_cnt++;
                }
                if( pt_cur->x > pt_cur[1].x )
                {
                    rect.right = pt_cur->x;
                    rect.left = pt_cur[1].x;
                }
                else
                {
                    rect.left = pt_cur->x;
                    rect.right = pt_cur[1].x;
                }
                if( pt_cur->y > pt_cur[1].y )
                {
                    rect.bottom = pt_cur->y;
                    rect.top = pt_cur[1].y;
                }
                else
                {
                    rect.top = pt_cur->y;
                    rect.bottom = pt_cur[1].y;
                }
                PDFPage *page = [vpage GetPage];
                PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
                [mat transformPoint:pt_cur];
                [mat transformPoint:&pt_cur[1]];
                [page addAnnotLine:pt_cur :&pt_cur[1] :g_rect_Width :0 :1 :g_rect_color :g_rect_color];
                
                //Action Stack Manger
                [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
                
                // Set Author and Modify date
                [self updateLastAnnotInfoAtPage:page];
            }
            pt_cur += 2;
        }
        [self setModified:(m_lines_cnt != 0) force:NO];
        
        m_lines_cnt = 0;
        m_lines_drawing = false;
        m_status = sta_none;
        
        cur = 0;
        end = pages_cnt;
        while( cur < end )
        {
            [m_view vRenderSync:[pages[cur] GetPageNo]];
            cur++;
        }
        [self refresh];
        
        [self enableScroll];
    }
}
-(bool)vRectStart
{
    if(![self canSaveDocument]) return false;
    if( m_status == sta_none )
    {
        self.scrollEnabled = false;
        m_status = sta_rect;
        m_rects_drawing = false;
        return true;
    }
    return false;
}
-(void)vRectCancel
{
    if( m_status == sta_rect )
    {
        [self enableScroll];
        m_rects_cnt = 0;
        m_rects_drawing = false;
        m_status = sta_none;
        [self refresh];
    }
}
-(void)vRectEnd
{
    if( m_status == sta_rect )
    {
        PDFVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_rects;
        PDF_POINT *pt_end = pt_cur + (m_rects_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :pt_cur->x :pt_cur->y];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                cur = 0;
                end = pages_cnt;
                //PDFVPage *vpage2;
                while( cur < end )
                {
                    if( pages[cur] == vpage ) break;
                    cur++;
                }
                if( cur >= end )
                {
                    pages[cur] = vpage;
                    pages_cnt++;
                }
                if( pt_cur->x > pt_cur[1].x )
                {
                    rect.right = pt_cur->x;
                    rect.left = pt_cur[1].x;
                }
                else
                {
                    rect.left = pt_cur->x;
                    rect.right = pt_cur[1].x;
                }
                if( pt_cur->y > pt_cur[1].y )
                {
                    rect.bottom = pt_cur->y;
                    rect.top = pt_cur[1].y;
                }
                else
                {
                    rect.top = pt_cur->y;
                    rect.bottom = pt_cur[1].y;
                }
                PDFPage *page = [vpage GetPage];
                PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
                [mat transformRect:&rect];
                [page addAnnotRect:&rect: g_rect_Width * m_scale / [vpage GetScale]: g_rect_color: 0];
                
                //Action Stack Manger
                [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
                
                // Set Author and Modify date
                [self updateLastAnnotInfoAtPage:page];
            }
            pt_cur += 2;
        }
        [self setModified:(m_rects_cnt != 0) force:NO];
        
        m_rects_cnt = 0;
        m_rects_drawing = false;
        m_status = sta_none;
        
        cur = 0;
        end = pages_cnt;
        while( cur < end )
        {
            [m_view vRenderSync:[pages[cur] GetPageNo]];
            cur++;
        }
        [self refresh];

        [self enableScroll];
    }
}

- (void)enableScroll
{
    self.scrollEnabled = true;
    if ([self isCurlEnabled] && m_zoom <= 1)
        self.scrollEnabled = false;
}

- (BOOL)setSignatureImageAtIndex:(int)index atPage:(int)pageNum
{
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    //get the PDFVPage
    PDFVPage *vpage = [m_view vGetPage:pageNum];
    if( !vpage ) return NO;
    
    //get the PDFPage
    PDFPage *page = [vpage GetPage];
    if (!page) {
        return NO;
    }
    
    //get the annotation
    PDFAnnot *annot = [page annotAtIndex:index];
    
    //init PDFDocForm and PDFPageContent
    PDFDocForm *form = [m_doc newForm];
    PDFPageContent *content = [[PDFPageContent alloc] init];
    [content gsSave];
    
    //create PDFDocImage with CGImageRef
    CGImageRef ref = [image CGImage];
    PDFDocImage *docImage = [m_doc newImage:ref :YES];
    PDF_PAGE_IMAGE rimg = [form addResImage:docImage];
    
    PDF_RECT rect;
    [annot getRect:&rect];
    
    float width = (rect.right - rect.left);
    float height = (rect.bottom - rect.top);
    float originalWidth = image.size.width;
    float originalHeight = image.size.height;
    float scale = height / originalHeight;
    float scaleW = width / originalWidth;
    if (scaleW < scale) scale = scaleW;
    
    float xTranslation = (width - originalWidth * scale) / 2.0f;
    float yTranslation = (height - originalHeight * scale) / 2.0f;
    
    //set the matrix 20x20
    PDFMatrix *matrix = [[PDFMatrix alloc] init:scale * originalWidth :scale * originalHeight :xTranslation :yTranslation];
    [content gsCatMatrix:matrix];
    matrix = nil;
    
    //draw the image on the PDFPageContent
    [content drawImage:rimg];
    [content gsRestore];
    
    //set the content on the PDFDocForm
    [form setContent:0 :0 :width :height :content];
    
    //set the custom icon
    BOOL success = [annot setIcon2:@"myIcon" :form];
    
    //free objects
    content = nil;
    page = nil;
    
    [m_view vRenderSync:m_cur_page];
    [self refresh];
    
    // Delete temp signature image
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    return success;
}

-(void)vAnnotPerform
{
    if( m_status != sta_annot ) return;
    int pageno = [m_annot getDest];
    if( pageno >= 0 )//goto page
    {
        if( m_delegate )
            [m_delegate OnAnnotGoto:pageno];
	    [self vAnnotEnd];
	    return;
    }
    NSString *nuri = [m_annot getURI];
    if(nuri)//open url
    {
        if( m_delegate )
            [m_delegate OnAnnotOpenURL:nuri];
	    [self vAnnotEnd];
	    return;
    }
    nuri = [m_annot getMovie];
    if( nuri )
    {
        nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
        [m_annot getMovieData:nuri];
        if(m_delegate)
            [m_delegate OnAnnotMovie:nuri];
	    [self vAnnotEnd];
	    return;
    }
    nuri = [m_annot getSound];
    if( nuri )
    {
        int spara[4];
        nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
        [m_annot getSoundData:spara :nuri];
        if(m_delegate)
            [m_delegate OnAnnotSound:nuri];
	    [self vAnnotEnd];
	    return;
    }
    nuri = [m_annot getPopupText];
    if( nuri )
    {
        //popup dialog to show text and subject.
        //nuri is text content.
        //subj is subject string.
        if(m_delegate && (![m_annot isAnnotReadOnly] || m_annot.type == 1))
    		[m_delegate OnAnnotPopup :m_annot: [m_annot getPopupSubject] :nuri];
	    [self vAnnotEnd];
	    return;
    }
    [self vAnnotEnd];
    return;
}

-(void)vAnnotRemove
{
    if (![self canSaveDocument]) {
        [self vAnnotEnd];
        return;
    }
	if( m_status != sta_annot ) return;
    
    if ([m_annot isAnnotLocked]) return;
    
    [self setModified:YES force:NO];
    
    //Action Stack Manger
    PDFPage *page = [m_doc page:m_annot_pos.pageno];
    [actionManger push:[[ASDel alloc] initWithPage:m_annot_pos.pageno page:page index:[m_annot getIndex]]];
    
    [m_annot removeFromPage];
	[self vAnnotEnd];
	[m_view vRenderSync:m_annot_pos.pageno];
	[self refresh];
}

-(void)vAnnotEnd
{
	if( m_status != sta_annot ) return;
    m_status = sta_none;
	
    if (![self isCurlEnabled])
        self.scrollEnabled = true;
    
	m_annot = NULL;
    [self refresh];
    if(m_delegate)
        [m_delegate OnAnnotEnd];
}

- (PDFAnnot *)vGetCurrentAnnot
{
    return m_annot;
}

-(void)onSingleTap:(float)x :(float)y
{
    [self vGetTextFromPoint:CGPointMake(x, y)];

    [m_view vGetPos:&m_annot_pos :x * m_scale :y * m_scale];
    
    if( m_annot_pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:m_annot_pos.pageno];
        if( !vpage )//shall not happen
        {
        	if( m_delegate ) [m_delegate OnSingleTapped:x:y];
        	return;
       	}
        PDFPage *page = [vpage GetPage];
        if( !page ) return;
        m_annot = [page annotAtPoint:m_annot_pos.x: m_annot_pos.y];
        if( m_annot )
        {
            if(m_delegate && [m_delegate respondsToSelector:@selector(didTapAnnot:atPage:atPoint:)])
            {
                [m_delegate didTapAnnot:m_annot atPage:m_cur_page atPoint:CGPointMake(x, y)];
            }
            
            if (![self canSaveDocument] && m_annot.type != 1) {
                if( m_delegate )
                {
                    if (!isDoubleTapping) {
                        NSArray *a = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
                        [self performSelector:@selector(delayedOnSingleTapping:) withObject:a afterDelay:0.3];
                    }
                }
                return;
            }
            
            if ([m_annot isAnnotReadOnly] && !([self isReadOnlyAnnotEnabled:m_annot]))
                return;
            
            self.scrollEnabled = false;
            m_status = sta_annot;
            [m_annot getRect:&m_annot_rect];
            m_annot_rect.left = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:m_annot_rect.left];
            m_annot_rect.right = [vpage GetX] - self.contentOffset.x * m_scale + [vpage ToDIBX:m_annot_rect.right];
            float tmp = m_annot_rect.top;
            m_annot_rect.top = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:m_annot_rect.bottom];
            m_annot_rect.bottom = [vpage GetY] - self.contentOffset.y * m_scale + [vpage ToDIBY:tmp];
            [self refresh];
            
            int nu = [m_annot getCheckStatus];
            if (nu != -1) {
                switch (nu) {
                    case 0:
                        [m_annot setCheckValue:YES];
                        break;
                    case 1:
                        [m_annot setCheckValue:NO];
                    default:
                        //case 2,3 set Radiobox
                        [m_annot setRadio];
                        break;
                }
                [self setModified:YES force:NO];
                [self setModifyDateForAnnot:m_annot];
                
                [self executeAnnotJS];
                
                //need refresh PDFView and save annot status
                [m_view vRenderSync:m_annot_pos.pageno];
                [self vAnnotEnd];
                return;
            }
            
            nu = [m_annot getComboItemCount];
            if (nu != -1){
                NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
                for (int i = 0; i < nu; i++) {
                    NSString *str = [m_annot getComboItem:i];
                    [arr addObject:str];
                }
                
                [self executeAnnotJS];
                
                if (m_delegate){
                    [m_delegate OnAnnotCommboBox:arr selected:[m_annot getComboSel]];
                }
                return;
            }
            
            nu = [m_annot getListItemCount];
            if (nu != -1){
                
                BOOL multi = [m_annot isMultiSel];
                
                NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
                for (int i = 0; i < nu; i++) {
                    NSString *str = [m_annot getListItem:i];
                    [arr addObject:str];
                }
                
                // GET SELECTED ITEMS
                
                int sels[16]; //custom this number of sels
                int count = [m_annot getListSels:sels :16]; //count is how many cell had been selected
                int *cur = sels;
                int *end = sels + count;
                NSMutableArray *selected_items = [NSMutableArray array];
                while(cur < end)
                {
                    [selected_items addObject:[NSNumber numberWithInt:*cur]]; //selected cell index
                    cur++;
                }
                
                if (m_delegate){
                    [m_delegate OnAnnotList:m_annot items:arr selectedIndexes:selected_items]; // Modified method
                }
                return;
            }
            
            NSString *nuri = [m_annot getEditText];
            if (nuri) {
                if (m_delegate) {
                    CGRect annotRect;
                    annotRect.origin.x = m_annot_rect.left / m_scale;
                    annotRect.origin.y = m_annot_rect.top / m_scale;
                    annotRect.size.width = (m_annot_rect.right - m_annot_rect.left)/m_scale;
                    annotRect.size.height = (m_annot_rect.bottom - m_annot_rect.top)/m_scale;
                    [m_delegate OnAnnotEditBox :annotRect : nuri :([m_annot getEditTextSize]/m_scale) * [m_view vGetScale:m_cur_page]];
                }
                return;
            }
            
            if (m_delegate)
                [m_delegate OnAnnotClicked :page:m_annot:x:y];
            
        }
        else
        {
            if( m_delegate )
            {
                NSArray *a = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
                [self performSelector:@selector(delayedOnSingleTapping:) withObject:a afterDelay:0.3];
            }
        }
    }
}

- (BOOL)isReadOnlyAnnotEnabled:(PDFAnnot *)annot
{
    int pageno = [m_annot getDest];
    if( pageno >= 0 )       //is goto annot
        return YES;
    
    NSString *nuri = [m_annot getURI];
    if(nuri)                //is url annot
        return YES;
    
    nuri = [m_annot getMovie];
    if(nuri)                //is movie annot
        return YES;
        
    nuri = [m_annot getSound];
    if(nuri)                //is audio annot
        return YES;
    
    if (m_annot.type == 1)  //is note annot
        return YES;
    
    return NO;
}

- (void)selectListBoxItems:(NSArray *)items
{
    if (m_annot == nil || [m_annot getListItemCount] == -1) { // Check if it is a list box
        return;
    }
    
    // Items contains indexes to select
    if (items.count > 1 && ![m_annot isMultiSel]) {
        return;
    }
    
    int select[items.count];
    
    for (int i = 0; i < items.count; i++) {
        select[i] = [[items objectAtIndex:i] intValue];
    }
    
    [m_annot setListSels:select :(int)items.count];
    
    [self executeAnnotJS];
    
    [m_view vRenderSync:m_cur_page];
    
    [self refresh];
    
    [self setModified:YES force:NO];
    
    [self vAnnotEnd];
    
    // Optional
    // Save the document
    //[m_doc save]; // You can save the document immediately
}

- (void)delayedOnSingleTapping:(NSArray *)a
{
    if (!isDoubleTapping && a) {
        [m_delegate OnSingleTapped:[[a objectAtIndex:0] floatValue]:[[a objectAtIndex:1] floatValue]];
    }
}

-(void)addIcon
{
    BOOL b = [m_doc canSave];
    
    PDFPageContent *content = [[PDFPageContent alloc] init];
    UIImage *img = [UIImage imageNamed:@"image"];
    PDFDocImage *image = [m_doc newImage:img.CGImage :YES];
    
    
    PDFDocForm *form = [m_doc newForm];
    PDF_PAGE_IMAGE rimg = [form addResImage:image];
    [content gsSave];
    PDFMatrix *matrix = [[PDFMatrix alloc] init:20 :20 :0 :0];
    [content gsCatMatrix:matrix];
    matrix = nil;
    
    [content drawImage:rimg];
    [content gsRestore];
    
    [form setContent:0 :0 :20 :20 :content];
    
    BOOL success = [m_annot setIcon2:@"image" :form];
    content = nil;
}

-(PDFAnnot *)vGetTextAnnot :(int)x :(int)y
{
    PDFAnnot *annot;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos:x:y];
    if(pos.pageno>=0)
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return NULL;
        PDFPage *page = [vpage GetPage];
        if( !page ) return NULL;
        annot = [page annotAtPoint :pos.x: pos.y];

    }
    return annot;
}

- (BOOL)setCustomIcon:(CGImageRef)ref forAnnotAtIndex:(int)index atPage:(int)pageNum
{
    //get the PDFVPage
    PDFVPage *vpage = [m_view vGetPage:pageNum];
    
    if( !vpage ) return NO;
    
    //get the PDFPage
    PDFPage *page = [vpage GetPage];
    
    if (!page) {
        return NO;
    }
    
    //get the annotation
    PDFAnnot *annot = [page annotAtIndex:index];
    
    //init PDFDocForm and PDFPageContent
    PDFDocForm *form = [m_doc newForm];
    PDFPageContent *content = [[PDFPageContent alloc] init];

    //create PDFDocImage with CGImageRef
    PDFDocImage *image = [m_doc newImage:ref :YES];
    PDF_PAGE_IMAGE rimg = [form addResImage:image];
    
    //set the matrix 20x20
    PDFMatrix *matrix = [[PDFMatrix alloc] init:20 :20 :0 :0];
    [content gsCatMatrix:matrix];
    matrix = nil;
    
    //draw the image on the PDFPageContent
    [content drawImage:rimg];
    [content gsRestore];
    
    //set the content on the PDFDocForm
    [form setContent:0 :0 :20 :20 :content];
    
    //set the custom icon
    BOOL success = [annot setIcon2:@"myIcon" :form];

    //free objects
    content = nil;
    page = nil;

    return success;
}

-(void)vAddTextAnnot :(int)x :(int)y :(NSString *)text :(NSString *)subject
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :x * m_scale :y * m_scale];
    if(pos.pageno>=0)
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return;
        PDFPage *page = [vpage GetPage];
        if (!page) {
            return;
        }
        [self setModified:YES force:NO];
        
        PDF_POINT pt;
        pt.x = pos.x ;
        pt.y = pos.y ;
        [page addAnnotNote:&pt];
        
        //Action Stack Manger
        [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
        
        PDFAnnot *annot = [page annotAtIndex: [page annotCount] - 1];
        [annot setPopupSubject:subject];
        [annot setPopupText:text];
        
        // Set Author and Modify date
        [self updateLastAnnotInfoAtPage:page];
        
        [m_view vRenderSync:pos.pageno];
    }
}

-(void)vGetTextFromPoint:(CGPoint )point
{
    if (m_status == sta_annot) return;
    m_status = sta_sel;
    [m_view vSetSelWholeWord:m_tx: m_ty: point.x * m_scale: point.y * m_scale];
    NSString *s = [self vSelGetText];
    [m_view vClearSel];
    
    m_status = sta_none;
    
    //check url
    NSRegularExpression *expressionUrl = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    @try {
        NSString *match = [s substringWithRange:[expressionUrl rangeOfFirstMatchInString:s options:NSMatchingCompleted range:NSMakeRange(0, [s length])]];
        //NSLog(@"%@", match);
        
        if (match.length > 0) {
            if( m_delegate )
            {
                if (!([match containsString:@"http://"] || [match containsString:@"https://"]))
                    match = [NSString stringWithFormat:@"http://%@", match];
                    
                [m_delegate OnAnnotOpenURL:match];
                return;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    //check mail
    NSRegularExpression *expressionMail = [NSRegularExpression regularExpressionWithPattern:@"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\[\\x01-\\x09\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    @try {
        NSString *match = [s substringWithRange:[expressionMail rangeOfFirstMatchInString:s options:NSMatchingCompleted range:NSMakeRange(0, [s length])]];
        //NSLog(@"%@", match);
        
        if (match.length > 0) {
            if( m_delegate )
                [m_delegate OnAnnotOpenURL:[NSString stringWithFormat:@"mailto:%@", match]];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

- (void)setCommboItem :(int)item
{
    if ([m_annot getComboSel] != item) {
        [self setModified:YES force:NO];
    }
    [m_annot setComboSel:item];
    [self setModifyDateForAnnot:m_annot];
    [m_view vRenderSync:m_annot_pos.pageno];
    [self vAnnotEnd];
}

- (void)setEditBoxWithText:(NSString *)text
{
    if (m_status != sta_annot) return;
    if (![[m_annot getEditText] isEqualToString:text]) {
        [self setModified:YES force:NO];
        [self setModifyDateForAnnot:m_annot];
    }
    [m_annot setEditText:text];
    
    [self executeAnnotJS];
    
    [m_view vRenderSync:m_annot_pos.pageno];
    [self vAnnotEnd];
}

- (BOOL)paginAvailable
{
    return (g_def_view == 3 || g_def_view == 4 || g_def_view == 6);
}

- (BOOL)canSaveDocument
{
    return ([m_doc canSave] && !readOnlyEnabled);
}

- (void)setReadOnly:(BOOL)enabled
{
    readOnlyEnabled = enabled;
}

- (void)setReaderBackgroundColor:(int)color
{
    readerBackgroundColor = color;
    
    if (readerBackgroundColor != 0) {
        self.backgroundColor = UIColorFromRGB(readerBackgroundColor);
    }
}

- (void)setFirstPageCover:(BOOL)cover
{
    coverPage = cover;
}

- (void)setDoubleTapZoomMode:(int)mode
{
    doubleTapZoomMode = mode;
}

- (BOOL)isModified
{
    return m_modified;
}

- (void)setModified:(BOOL)modified force:(BOOL)force
{
    if (!m_modified) {
        m_modified = modified;
    }
    
    if (force) {
        m_modified = modified;
    }
    
    if (m_modified) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"fileStat"];
    }
}

- (void)updateLastAnnotInfoAtPage:(PDFPage *)page
{
    PDFAnnot *annot = [page annotAtIndex:(page.annotCount - 1)];
    if (annot) {
        [self setAuthorForAnnot:annot];
        [self setModifyDateForAnnot:annot];
    }
}

- (void)setAuthorForAnnot:(PDFAnnot *)annot
{
    [annot setPopupLabel:g_author];
}

- (void)setModifyDateForAnnot:(PDFAnnot *)annot
{
    [annot setModDate:[RDUtils pdfDateFromDate:[NSDate date]]];
}

- (void)setUUIDMeta
{
    if ([m_doc meta:UUID].length == 0) {
        [m_doc setMeta:UUID :[RDUtils getPDFIDForDoc:m_doc]];
    }
}

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size
{
    if ([path containsString:@"file://"])
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    PDFPage *page = [m_doc page:pageno];
    PDFAnnot *annot = [page annotAtIndex:index];

    NSString *annotPath = [self getImageFromAnnot:annot];
    UIImage *img = [UIImage imageWithContentsOfFile:annotPath];
    UIImage *resizedImage = nil;
    
    if (size.width == 0 || size.height == 0) {
        [[NSFileManager defaultManager] moveItemAtPath:annotPath toPath:path error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:annotPath error:nil];
        return YES;
    } else {
        resizedImage = [self imageWithImage:img scaledToSize:size];
    }
    
    if(resizedImage)
    {
        // Save image.
        [UIImagePNGRepresentation(resizedImage) writeToFile:path atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:annotPath error:nil];
        
        return [[NSFileManager defaultManager] fileExistsAtPath:path];
    }
    
    return NO;
}

- (NSString *)getImageFromAnnot:(PDFAnnot *)annot
{
    PDF_RECT rect;
    [m_annot getRect:&rect];
    int width = (rect.right - rect.left) * m_scale;
    int height = (rect.bottom- rect.top) * m_scale;
    PDFDIB *dib = [[PDFDIB alloc] init:width : height];
    Global_setAnnotTransparency(0x00000000);
    [m_annot render:dib :0xffffffff];
    Global_setAnnotTransparency(0x200040FF);
    
    UIImage *img = [UIImage imageWithCGImage:[dib image]];
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];
    
    // Save image.
    [UIImagePNGRepresentation(img) writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (NSString *)emptyAnnotWithSize:(CGSize)size
{
    PDFDIB *emptyDib = [[PDFDIB alloc] init:size.width : size.height];
    [emptyDib erase:0xffffffff];
    UIImage *emptyImg = [UIImage imageWithCGImage:[emptyDib image]];
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE_EMPTY];
    
    // Save image.
    [UIImagePNGRepresentation(emptyImg) writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imageFromPage:(int)index inPDFRect:(CGRect )rect withScale:(float)scale {
    
    // Get the page
    PDFPage *page = [m_doc page:index];
    
    // Initialize the DIB with the annotation size
    float w = rect.size.width * scale;
    float h = rect.size.height * scale;
    PDF_DIB bmp = Global_dibGet(NULL, w, h);
    
    // Create the matrix to render only the correct portion of the page
    PDF_MATRIX mat = Matrix_createScale(scale, -scale, -(rect.origin.x  * scale), (rect.origin.y * scale) + h);
    
    // Render the portion of the page into bmp
    Page_renderPrepare(page.handle, bmp);
    Page_render(page.handle, bmp, mat, false, 2);
    Matrix_destroy(mat);
    page = nil;
    
    // Create the image ref
    void *data = Global_dibGetData(bmp);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, w * h * 4, NULL);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef ref = CGImageCreate(w, h, 8, 32, (int)w<<2, cs, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault);
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    // Save the image
    NSString *filePath = [pdfPath stringByAppendingPathComponent:@"test.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImagePNGRepresentation([UIImage imageWithCGImage:ref]) attributes:nil];
}

#pragma mark - PDFJSDelegate Methods

- (void)executeAnnotJS
{
    if (!m_annot || ! g_execute_annot_JS) {
        return;
    }
    
    NSString *js = [m_annot getJS];
    
    if (js) {
        [self runJS:js];
    }
    
    js = [m_annot getAdditionalJS:1];
    
    if (js) {
        [self runJS:js];
    }
}

- (void)runJS:(NSString *)js
{
    [m_doc runJS:js :self];
}

-(int)OnAlert:(int)nbtn :(NSString *)msg :(NSString *)title
{
    return 1;
}

-(void)OnConsole:(int)ccmd :(NSString *)para
{
    //cmd-> 0:clear, 1:hide, 2:println, 3:show
}

-(bool)OnDocClose
{
    return false;
}

-(NSString *)OnTmpFile
{
    NSString *tp = NSTemporaryDirectory();
    tp = [tp stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.tmp",[[NSDate date] timeIntervalSince1970]]];
    return tp;
}

-(void)OnUncaughtException:(int)code : (NSString *)para
{}

#pragma mark - Stamp
- (BOOL)vImageStart
{
    if( ![m_doc canSave] ) return false;
    if( m_status == sta_none )
    {
        self.scrollEnabled = false;
        m_status = sta_image;
        
        if(!imgAnnot)
            imgAnnot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_add"]];
        
        if (![imgAnnot isDescendantOfView:self]) {
            
            PDFVPage *page = [m_view vGetPage:m_cur_page];
            CGFloat pageWidth = [page GetWidth] / m_scale;
            
            if (pageWidth < imgAnnot.frame.size.width) {
                CGFloat ratio = imgAnnot.frame.size.width / imgAnnot.frame.size.height;
                [imgAnnot setFrame:CGRectMake(0, 0, pageWidth / 2 , (pageWidth / 2) / ratio)];
            } else {
                [imgAnnot setFrame:CGRectMake(0, 0, (imgAnnot.frame.size.width / m_scale) * [page GetScale], (imgAnnot.frame.size.height / m_scale) * [page GetScale])];
            }
            
            CGPoint center = self.center;
            center.x += self.contentOffset.x;
            center.y += self.contentOffset.y;
            
            imgAnnot.center = center;
            imgAnnot.layer.borderWidth = 1;
            imgAnnot.layer.borderColor = [[UIColor blueColor] CGColor];
            [self addSubview:imgAnnot];
        }
        
        return true;
    }
    
    return false;
}

-(void)vImageCancel
{
    if( m_status == sta_image )
    {
        self.scrollEnabled = true;
        m_status = sta_none;
        
        [imgAnnot removeFromSuperview];
        imgAnnot = nil;
        
        [self refresh];
    }
}
- (void)vImageEnd
{
    if( m_status == sta_image )
    {
        m_modified = true;
        m_status = sta_none;
        
        struct PDFV_POS pos1;
        struct PDFV_POS pos2;
        
        [m_view vGetPos:&pos1 :(imgAnnot.frame.origin.x - self.contentOffset.x) * m_scale :(imgAnnot.frame.origin.y - self.contentOffset.y) * m_scale];
        [m_view vGetPos:&pos2 :(imgAnnot.frame.origin.x - self.contentOffset.x + imgAnnot.frame.size.width) * m_scale :(imgAnnot.frame.origin.y - self.contentOffset.y + imgAnnot.frame.size.height) * m_scale];
        
        PDF_RECT rect;
        
        rect.left = pos1.x;
        rect.right = pos2.x;
        rect.top = pos2.y;
        rect.bottom = pos1.y;
        
        [self vAddImageWithImage:imgAnnot.image withRect:rect];
        
        [imgAnnot removeFromSuperview];
        imgAnnot = nil;
        
        [self refresh];
        
        self.scrollEnabled = true;
    }
}

- (BOOL)useTempImage
{
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        tmpImage = [filePath stringByAppendingString:@".tmp"];
        [[NSFileManager defaultManager] removeItemAtPath:tmpImage error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:tmpImage error:nil];
        UIImage *image = [UIImage imageWithContentsOfFile:tmpImage];
        imgAnnot = [[UIImageView alloc] initWithImage:image];
        
        return YES;
    }
    
    return NO;
}

-(bool)OnImageTouchBegin:(CGPoint)point
{
    if( m_status != sta_image ) return false;
    
    CGRect origin = imgAnnot.frame;
    isResizing = !((self.contentOffset.x + point.x) < (origin.origin.x + origin.size.width) && self.contentOffset.y + point.y < (origin.origin.y + origin.size.height) && self.contentOffset.x + point.x > origin.origin.x && self.contentOffset.y + point.y > origin.origin.y);
    /*
    isRotating = !(self.contentOffset.x + point.x > origin.origin.x && self.contentOffset.y + point.y > origin.origin.y);
    */
    return true;
}
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define ANG (M_PI / 2) / 180.0
-(bool)OnImageTouchMove:(CGPoint)point
{
    if( m_status != sta_image ) return false;
    
    if (!isResizing) {
        CGPoint center = point;
        center.x += self.contentOffset.x;
        center.y += self.contentOffset.y;
        imgAnnot.center = center;
    } else {
        
        CGRect origin = imgAnnot.frame;
         
        float deltaMoveX = self.contentOffset.x + point.x - origin.origin.x - origin.size.width;
        float deltaMoveY = self.contentOffset.y + point.y - origin.origin.y - origin.size.height;
        float prop = imgAnnot.frame.size.width / imgAnnot.frame.size.height;
        
        if (!isRotating) {
            float width = (deltaMoveX > deltaMoveY) ? self.contentOffset.x + point.x - origin.origin.x : (self.contentOffset.y + point.y - origin.origin.y) * prop;
            float height = (deltaMoveX < deltaMoveY) ? self.contentOffset.y + point.y - origin.origin.y : (self.contentOffset.x + point.x - origin.origin.x) / prop;
            [imgAnnot setFrame:CGRectMake(origin.origin.x, origin.origin.y, width, height)];
        } else {
            double l1 = point.x - imgAnnot.center.x;
            double l2 = imgAnnot.center.y - point.y;
            double ip = sqrt(pow(l1, 2) + pow(l2, 2));
            double arcsin = asin((double)(l2/ip));
            
            NSLog(@"l1: %f", l1);
            NSLog(@"l2: %f", l2);
            NSLog(@"ip: %f", ip);
            
            
            if (l1 > 0) {
                if (l2 > 0) {
                    arcsin = (M_PI_2 * 2) - arcsin;
                } else {
                    arcsin = -(M_PI_2 * 2) - arcsin;
                }
            }
            NSLog(@"arcsin: %f", arcsin);
            
            imgAnnot.transform = CGAffineTransformMakeRotation(arcsin);
            lastAngle = arcsin;
        }
    }
    
    return true;
}

-(bool)OnImageTouchEnd:(CGPoint)point
{
    if( m_status != sta_image ) return false;
    
    UIImage *tmpImg = imgAnnot.image;
    [[NSFileManager defaultManager] removeItemAtPath:[tmpImage stringByAppendingString:@".bak"] error:nil];
    [[NSFileManager defaultManager] createFileAtPath:[tmpImage stringByAppendingString:@".bak"] contents:[self rotateImage:tmpImg] attributes:nil];
    //[self vImageEnd];
    
    return true;
}

- (NSData *)rotateImage:(UIImage *)img
{
    UIGraphicsBeginImageContext(img.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(context, lastAngle);
    [img drawAtPoint:CGPointMake(0, 0)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(result) ;
}

- (void)vAddImageWithImage:(UIImage *)image withRect:(PDF_RECT)rect
{
    // Create the cache file
    NSString *tp = NSTemporaryDirectory();
    tp = [tp stringByAppendingPathComponent:@"cache.dat"];
    [m_doc setCache:tp];
    
    // Create the PDFPage instance of the current page
    PDFPage *page = [m_doc page:m_cur_page];
    [page objsStart];
    
    // Create the CGImageRef of the image
    CGImageRef ref = [image CGImage];
    
    // Get PDFDocImage instance from CGImageRef (keeping alpha channel)
    PDFDocImage *i = [m_doc newImage:ref :YES];
    
    // Add the image
    [page addAnnotBitmap:i :&rect];
    
    //Action Stack Manger
    [actionManger push:[[ASAdd alloc] initWithPage:m_cur_page page:page index:(page.annotCount - 1)]];
    
    // Re-render the current page
    [m_view vRenderSync:m_cur_page];
    [self refresh];
    
    [self setModified:YES force:NO];
    
    // Set Author and Modify date
    [self updateLastAnnotInfoAtPage:page];
}

#pragma mark - CURL

- (BOOL)isCurlEnabled
{
    return g_curl_enabled;
}

- (CGImageRef )vGetImageForPage:(int)pg withSize:(CGSize)size withBackground:(BOOL)hasBackground
{
    return [m_view vGetImageRefForPage:pg withWidth:size.width andHeight:size.height withBackground:hasBackground];
}

- (void)addEditText:(int)page point:(CGPoint)point size:(CGSize)size
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :point.x * m_scale :point.y * m_scale];
    PDFVPage *vp = [m_view vGetPage:page];
    PDFPage *p = [vp GetPage];

    PDF_RECT rect;
    rect.left = pos.x;
    rect.top = pos.y;
    rect.right = rect.left + (size.width * m_scale);
    rect.bottom = rect.top + (size.height * m_scale);
    
    Page_addAnnotEditbox2([p handle], &rect, 0xFF000000, 1, 0xFFFFFFFF, 10, 0xFF000000);

    [m_view vRenderSync:pos.pageno];
    [self refresh];
}

- (BOOL)mergePDFAtPath:(NSString *)savePath fromPaths: (NSMutableArray *)pdfFilePaths
{
    NSString *cacheFileTmpName = [NSString stringWithFormat:@"cache%lu.dat", (unsigned long)([[NSDate date] timeIntervalSince1970] * 1000)];
    
    NSString *cacheFileFullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:cacheFileTmpName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFileFullPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cacheFileFullPath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])
    {
        return NO;
    }
    
    PDF_ERR dst_err;
    PDF_DOC doc_dst = Document_create([savePath UTF8String], &dst_err);
    BOOL success = Document_setCache(doc_dst, [cacheFileFullPath UTF8String]);
    
    if (success)
    {
        for (NSString *filePath in pdfFilePaths)
        {
            NSString *tmpPath = nil;
            
            PDF_ERR src_err;
            PDF_DOC doc_src = Document_open([filePath UTF8String], NULL, &src_err);
            PDF_PAGE page = Document_getPage(doc_src, 0);
            
            if (success)
            {
                PDF_IMPORTCTX ctx = Document_importStart(doc_dst, doc_src);
                int dstno = Document_getPageCount(doc_dst);
                int srccount = Document_getPageCount(doc_src);
                int srcno = 0;
                while (srcno < srccount)
                {
                    success = success && Document_importPage(doc_dst, ctx, srcno, dstno);
                    dstno++;
                    srcno++;
                }
                Document_importEnd(doc_dst, ctx);
            }
            
            Document_close(doc_src);
            if (success)
            {
                success = Document_save(doc_dst);
            }
            
            if (tmpPath && [[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
            }
            
        }
    }
    
    //PDF_PAGE page0 = Document_getPage(doc_dst, 0);
    //PDF_PAGE page1 = Document_getPage(doc_dst, 1);
    
    Document_close(doc_dst);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] && !success)
    {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFileFullPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cacheFileFullPath error:nil];
    }
    return YES;
}

@end
