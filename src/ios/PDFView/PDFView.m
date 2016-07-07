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
extern float g_rect_Width;
extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_oval_color;
extern bool g_paging_enabled;
extern bool g_double_page_enabled;

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
-(void)vOpen:(PDFDoc *)doc :(id<PDFViewDelegate>)delegate
{
    //GEAR
    [self vClose];
    //END
    m_doc = doc;
    bool *verts = (bool *)calloc( sizeof(bool), [doc pageCount] );
    switch(g_def_view)
    {
        case 1:
            m_view = [[PDFVHorz alloc] init:false];
            break;
        case 2:
            m_view = [[PDFVHorz alloc] init:true];
            break;
        case 3:
            //for dual view, comment/uncomment also doublePage
            doublePage = g_double_page_enabled;
            
            if (doublePage) {
                m_view = [[PDFVDual alloc] init:false :NULL :0 :NULL :0];
            }
            else
            {
                m_view = [[PDFVDual alloc] init:false :NULL :0 :verts :doc.pageCount];
            }
            break;
        case 4:
            //for dual view, comment/uncomment also doublePage
            m_view = [[PDFVDual alloc] init:true :NULL :0 :NULL :0];
            doublePage = g_double_page_enabled;
            //for single view, comment/uncomment also doublePage
            //m_view = [[PDFVDual alloc] init:true :NULL :0 :verts :doc.pageCount];
            //doublePage = NO;
            break;
        default:
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
    self.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    [m_view vOpen:doc :4 :self: &tback];
    [m_view vResize:m_w :m_h];
    m_status = sta_none;
    m_ink = NULL;
    m_modified = false;
    
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
    [m_view vSetScale:[m_view vGetScaleMin]];//set scale to min
    self.zoomScale = 1;//set scale to min
    m_zoom = 1;//set scale to min
    
    self.contentSize = CGSizeMake([m_view vGetDocW]/m_scale, [m_view vGetDocH]/m_scale);
   
    if( m_type == 2 || m_type == 4 )//rtol mode, first page is placed at right side.
    	self.contentOffset = CGPointMake( self.contentSize.width - self.frame.size.width, 0 );
    else
    	self.contentOffset = CGPointMake( 0, 0 );
    
    self.pagingEnabled = NO;
    if (g_def_view == 3 || g_def_view == 4) {
        self.pagingEnabled = g_paging_enabled;
    }

    [self refresh];
}

-(void)vGoto:(int)pageno
{
    if (doublePage) {
        if (g_paging_enabled && g_def_view == 4 && pageno > 0 && (pageno + 1) < m_doc.pageCount && (pageno % 2 == 0) && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno++;
        }
        
        if (g_paging_enabled && g_def_view == 3 && pageno > 0 && (pageno % 2 != 0) && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno--;
        }
    }

    struct PDFV_POS pos;
    
    pos.x = 0;
    pos.y = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    int pages = (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) && doublePage && m_doc.pageCount > 1) ? 2 : 1;
    float gapX = (m_w - (([m_doc pageWidth:pageno] * pages)*[m_view vGetScaleMin])) / 2;
    float gapY = (m_h - ([m_doc pageHeight:pageno]*[m_view vGetScaleMin])) / 2;
    
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
   
    if( m_modified && m_doc != NULL )
    {
        [m_doc save];
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
    
    
    //do not close Document object in View class.
    //this shall be closed in Controller class.
    //this means: close Document in creator.
    //GEAR
    //Document_close(m_doc);
    //END
}

-(void)refresh
{
    [self setNeedsDisplay];
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
    
    [m_view vSetScale:[m_view vGetScaleMin] * m_zoom];
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
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
        [self resetZoomLevel];
        
        if (self.zoomScale <= 1 && (g_def_view == 3 || g_def_view == 4)) {
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
    [self drawRects:context];
    [self drawEllipse:context];
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
	[self refresh];
	if( m_delegate )
		[m_delegate OnSelEnd :m_tx/m_scale: m_ty/m_scale:point.x :point.y];
	return true;
}

-(bool)OnAnnotTouchBegin:(CGPoint)point
{
	if( m_status != sta_annot ) return false;
    m_px = point.x * m_scale;
    m_py = point.y * m_scale;
    m_tx = m_px;
    m_ty = m_py;
	return true;
}

-(bool)OnAnnotTouchMove:(CGPoint)point
{
	if( m_status != sta_annot ) return false;
    if( [m_doc canSave] )
    {
        m_tx = point.x * m_scale;
        m_ty = point.y * m_scale;
    }
    [self refresh];
	return true;
}

-(bool)OnAnnotTouchEnd:(CGPoint)point
{
	if( m_status != sta_annot ) return false;
    if( [m_doc canSave] )
    {
    	m_modified = true;
        m_tx = point.x * m_scale;
        m_ty = point.y * m_scale;
        m_annot_rect.left += m_tx - m_px;
        m_annot_rect.top += m_ty - m_py;
        m_annot_rect.right += m_tx - m_px;
        m_annot_rect.bottom += m_ty - m_py;
        PDFVPage *vpage = [m_view vGetPage:m_annot_pos.pageno];
        struct PDFV_POS pos;
        [m_view vGetPos:&pos :point.x * m_scale :point.y * m_scale];
        if( pos.pageno == m_annot_pos.pageno )
        {
	        PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
	        [mat transformRect:&m_annot_rect];
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
		        [m_annot MoveToPage:dpage:&m_annot_rect];
		        [m_view vRenderSync:m_annot_pos.pageno];
		        [m_view vRenderSync:pos.pageno];
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
			m_modified = true;
			PDF_POINT pt;
			pt.x = pos.x;
			pt.y = pos.y;
			[page addAnnotNote:&pt];
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
}

- (void)OnDoubleTap:(UITouch *)touch
{
    isDoubleTapping = YES;
    
    NSLog(@"double tap");
    if (m_zoom > 1){
        self.pagingEnabled = g_paging_enabled;
        [self resetZoomLevel];
    }else {
        self.pagingEnabled = NO;
        [self initZoomWithPoint:[touch locationInView:self.window]];
        [self zoomToScale:2.0 atPoint:[touch locationInView:self.window]];
    }
    
    if (m_delegate) {
        [m_delegate OnDoubleTapped:[touch locationInView:self.window].x :[touch locationInView:self.window].y];
    }
    
    [self performBlock:^{
        isDoubleTapping = NO;
    } afterDelay:0.5];
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
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        point.x *= m_zoom;
        point.y *= m_zoom;
        if( [self OnSelTouchBegin:point] ) return;
        if( [self OnAnnotTouchBegin:point] ) return;
        if( [self OnNoteTouchBegin:point] ) return;
        if( [self OnInkTouchBegin:point] ) return;
        if( [self OnRectTouchBegin:point] ) return;
        if( [self OnEllipseTouchBegin:point] ) return;
        [self OnNoneTouchBegin:point:touch.timestamp];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        point.x *= m_zoom;
        point.y *= m_zoom;
        if( [self OnSelTouchMove:point] ) return;
        if( [self OnAnnotTouchMove:point] ) return;
        if( [self OnNoteTouchMove:point] ) return;
        if( [self OnInkTouchMove:point] ) return;
        if( [self OnRectTouchMove:point] ) return;
        if( [self OnEllipseTouchMove:point] ) return;
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
        int cnt = [allTouches count];
        if( cnt == 1 )
        {
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint point=[touch locationInView:[touch view]];
            point.x *= m_zoom;
            point.y *= m_zoom;
            if( [self OnSelTouchEnd:point] ) return;
            if( [self OnAnnotTouchEnd:point] ) return;
            if( [self OnNoteTouchEnd:point] ) return;
            if( [self OnInkTouchEnd:point] ) return;
            if( [self OnRectTouchEnd:point] ) return;
            if( [self OnEllipseTouchEnd:point] ) return;
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
    [m_view vGetPos:pos :0 :0];
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
        self.scrollEnabled = true;
        m_status = sta_none;
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
    struct PDFV_POS pos;
    [m_view vGetPos:&pos: m_tx: m_ty];
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        m_modified = [vpage SetSelMarkup:type];
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
    if( ![m_doc canSave] ) return false;
	if( m_status == sta_none )
	{
	    self.scrollEnabled = false;
		m_status = sta_note;
	}
    return true;
}

-(void)vNoteEnd
{
    m_modified = true;
    
	if( m_status == sta_note )
	{
	    self.scrollEnabled = true;
		m_status = sta_none;
		//[m_view vRenderSync:pos.pageno];
		[self refresh];
	}
}

-(bool)vInkStart
{
    if( ![m_doc canSave] ) return false;
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
        self.scrollEnabled = true;
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
                [m_view vRenderSync:pos.pageno];
            }
            m_modified = true;
        }
        m_status = sta_none;
        m_ink = NULL;
        [self refresh];
        
        //GEAR
        //Save Annotations
        [m_doc save];
        //END
        
        self.scrollEnabled = true;
    }
}
-(bool)vEllipseStart
{
    if( ![m_doc canSave] ) return false;
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
        self.scrollEnabled = true;
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
            }
            pt_cur += 2;
        }
        m_modified = (m_ellipse_cnt != 0);
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
        [m_doc save];
        self.scrollEnabled = true;
    }
}
-(bool)vRectStart
{
    if( ![m_doc canSave] ) return false;
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
        self.scrollEnabled = true;
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
            }
            pt_cur += 2;
        }
        m_modified = (m_rects_cnt != 0);
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

        //GEAR
        //Save Annotations
       	//Document_save(m_doc);
        //END
        self.scrollEnabled = true;
    }
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
    	if( m_delegate)
    		[m_delegate OnAnnotPopup :m_annot: [m_annot getPopupSubject] :nuri];
	    [self vAnnotEnd];
	    return;
    }
    [self vAnnotEnd];
    return;
}

-(void)vAnnotRemove
{
	if( m_status != sta_annot ) return;
    m_modified = true;
    [m_annot removeFromPage];
	[self vAnnotEnd];
	[m_view vRenderSync:m_annot_pos.pageno];
	[self refresh];
}

-(void)vAnnotEnd
{
	if( m_status != sta_annot ) return;
    m_status = sta_none;
	self.scrollEnabled = true;
	m_annot = NULL;
    [self refresh];
    if(m_delegate)
        [m_delegate OnAnnotEnd];
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
                //need refresh PDFView and save annot status
                [m_view vRenderSync:m_annot_pos.pageno];
                [m_doc save];
                [self vAnnotEnd];
                return;
            }
            
            nu = [m_annot getComboItemCount];
            if (nu != -1){
                //int j= [m_annot getComboSel];
                NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
                for (int i = 0; i < nu; i++) {
                    NSString *str = [m_annot getComboItem:i];
                    [arr addObject:str];
                }
                if (m_delegate){
                    [m_delegate OnAnnotCommboBox:arr];
                }
                return ;
            }
            NSString *nuri = [m_annot getEditText];
            if (nuri) {
                if (m_delegate) {
                    CGRect annotRect;
                    annotRect.origin.x = m_annot_rect.left / m_scale;
                    annotRect.origin.y = m_annot_rect.top / m_scale;
                    annotRect.size.width = (m_annot_rect.right - m_annot_rect.left)/m_scale;
                    annotRect.size.height = (m_annot_rect.bottom - m_annot_rect.top)/m_scale;
                    [m_delegate OnAnnotEditBox :annotRect : nuri];
                }
                return ;
            }

            
        	if( m_delegate ) [m_delegate OnAnnotClicked :page:m_annot:x:y];
        }
        else
        {
            if( m_delegate )
            {
                [self performBlock:^{
                    if (!isDoubleTapping) {
                        [m_delegate OnSingleTapped:x:y];
                    }
                } afterDelay:0.3];
            }
        }
    }
}
/*
-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos:x:y];
    if(pos.pageno>=0)
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return;
        PDFPage *page = [vpage GetPage];
        if( page != NULL )
        {
            PDFMatrix *mat = [vpage CreateMatrix];
            [mat invert];
            PDF_POINT pt;
            pt.x = [vpage ToDIBX:pos.x];
            pt.y = [vpage ToDIBY:pos.y];
            [mat transformPoint:&pt];
            [page addAnnotNote:&pt];
            PDFAnnot *annot = [page annotAtIndex: [page annotCount] - 1];
            [annot setPopupText:text];
            [m_view vRenderPage:pos.pageno];
            [m_doc save];
            
            [self refresh];
            
        }
    }
}
*/
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
-(void)vAddTextAnnot :(int)x :(int)y :(NSString *)text
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
        m_modified = true;
        
        PDF_POINT pt;
        pt.x = pos.x ;
        pt.y = pos.y ;
        [page addAnnotNote:&pt];
        PDFAnnot *annot = [page annotAtIndex: [page annotCount] - 1];
        [annot setPopupText:text];
        [m_view vRenderSync:pos.pageno];
        [m_doc save];

    }
}

-(void)vGetTextFromPoint:(CGPoint )point
{
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
    [m_annot setComboSel:item];
    [m_view vRenderSync:m_annot_pos.pageno];
    [m_doc save];
    [self vAnnotEnd];
}

- (void)setEditBoxWithText:(NSString *)text
{
    [m_annot setEditText:text];
    [m_view vRenderSync:m_annot_pos.pageno];
    [m_doc save];
    [self vAnnotEnd];
    
}
@end
