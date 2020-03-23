//
//  PDFLayoutView.m
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFLayoutView.h"
#import "RDVPage.h"
#import "RDVGlobal.h"
#import "RDVCanvas.h"
#import "RDVFinder.h"
#import "RDVSel.h"
#import "RDUtils.h"
#import "ActionStackManager.h"

/*#import "FTSManager.h"*/
#import "ReaderHandler.h"

#define TEMP_SIGNATURE @"radaee_signature_temp.png"
#define TEMP_SIGNATURE_EMPTY @"radaee_empty_signature_temp.png"

@class RDVLayoutDual;
@interface PDFLayoutView () {
#ifdef FTS_ENABLED
    FTSOccurrence *currentOccurrence;
#endif
    ActionStackManager *actionManger;
}

@end

@implementation PDFLayoutView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_doc = nil;
        m_layout = nil;
        m_timer = nil;
        m_scale_pix = [[UIScreen mainScreen] scale];
        m_status = sta_none;
        m_sel = nil;
        m_cur_page = -1;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        self.delegate = self;
        m_zoom = 1;
        self.minimumZoomScale = 1;
        self.maximumZoomScale = GLOBAL.g_layout_zoom_level;
        self.bouncesZoom = NO;
        m_child = [[PDFOffScreenView alloc] initWithFrame
                   :CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_child setDelegate :self];
        [self addSubview:m_child];
        [self resignFirstResponder];
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return self;
}

-(void)dealloc
{
    [self PDFClose];
}

- (void)clean {
    [self PDFClose];
    if (!m_child) {
        m_child = [[PDFOffScreenView alloc] initWithFrame:self.frame];
        [m_child setDelegate :self];
        [self addSubview:m_child];
    }
}

-(BOOL)PDFOpen:(PDFDoc *)doc :(int)page_gap :(id<PDFLayoutDelegate>)del
{
    [self clean];

    // Load global var
    doublePage = GLOBAL.g_double_page_enabled;
    
    // Zoom action on double tap
    // 1: default zoom
    // 2: smart zoom
    doubleTapZoomMode = 1;
    
    m_doc = doc;
    self.m_del = del;
    
    // Set meta tag UUID with the pdf id
    [self setUUIDMeta];
    
    actionManger = [[ActionStackManager alloc] init];
    
    
    bool *horzs = (bool *)calloc( sizeof(bool), m_doc.pageCount );
    self.backgroundColor = (GLOBAL.g_readerview_bg_color != 0) ? UIColorFromRGB(GLOBAL.g_readerview_bg_color) : [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    m_child.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    switch (GLOBAL.g_render_mode) {
        case 1:// Horizontal LTOR
            doublePage = NO;
            GLOBAL.g_paging_enabled = NO;
            m_layout = [[RDVLayoutHorz alloc] init:self :false];
            break;
        case 2:// PageView RTOL
            doublePage = NO;
            GLOBAL.g_paging_enabled = NO;
            memset(horzs, 0, sizeof(bool));
            m_layout = [[RDVLayoutSingle alloc] init:self :true :(int)_pageViewNo];
            break;
        case 3:// Single Page (LTOR, paging enabled)
            doublePage = NO;
            GLOBAL.g_paging_enabled = YES;
            memset(horzs, 0, sizeof(bool) * m_doc.pageCount);
            m_layout = [[RDVLayoutDual alloc] init:self :false :NULL :0 :horzs :[doc pageCount]];
            break;
        case 4: // Double Page first page single (paging enabled)
            for (int i = 0; i < m_doc.pageCount; i++) {
                if (i > 0) {
                    horzs[i] = true;
                }
            }
            memset(horzs, 1, sizeof(bool) * m_doc.pageCount);
            m_layout = [[RDVLayoutDual alloc] init:self :false :NULL :0 :horzs :[doc pageCount]];
            break;
        case 5:// Double Page (RTOL, paging enabled)
            GLOBAL.g_paging_enabled = YES;
            memset(horzs, 1, sizeof(bool) * m_doc.pageCount);
            m_layout = [[RDVLayoutDual alloc] init:self :true :NULL :0 :horzs :[doc pageCount]];
            break;
        case 6:// Double Page (LTOR, paging enabled)
            GLOBAL.g_paging_enabled = YES;
            memset(horzs, 1, sizeof(bool) * m_doc.pageCount);
            m_layout = [[RDVLayoutDual alloc] init:self :false :NULL :0 :horzs :[doc pageCount]];
            break;
        case 7:// Horizontal RTOL
            doublePage = NO;
            GLOBAL.g_paging_enabled = NO;
            memset(horzs, 0, sizeof(bool) * m_doc.pageCount);
            m_layout = [[RDVLayoutHorz alloc] init:self :true];
            break;
            default:// 0: Vertical
                GLOBAL.g_paging_enabled = NO;
                m_layout = [[RDVLayoutVert alloc] init : self];
                break;
        }
        free( horzs );
        if ([self pagingAvailable]) {
            self.pagingEnabled = GLOBAL.g_paging_enabled;
        }
        if (GLOBAL.g_render_mode == 2) {
            [(RDVLayoutSingle *)m_layout vOpen :m_doc :page_gap * m_scale_pix :self.layer :(int)_pageViewNo];
        } else {
            [m_layout vOpen :m_doc :page_gap * m_scale_pix :self.layer];
        }
    [self bringSubviewToFront:m_child];
    m_status = sta_none;
    m_zoom = 1;
    self.zoomScale = 1;
    CGRect rect = self.frame;
    CGSize size = rect.size;
    [m_layout vResize:size.width * m_scale_pix :size.height * m_scale_pix];

    if([m_layout isKindOfClass:[RDVLayoutVert class]]){
        self.contentSize = CGSizeMake(0, [m_layout doch]/m_scale_pix);
    }else{
        self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, 0);
    }

    [self setNeedsDisplay];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                               target:self selector:@selector(ProOnTimer:)
                                             userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
   return TRUE;
}
-(BOOL)isModified
{
	return m_modified;
}

- (void)setModified:(BOOL)modified force:(BOOL)force
{
    if(m_modified == modified) return;
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
    [annot setPopupLabel:GLOBAL.g_author];
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
    [annot getRect:&rect];
    int width = (rect.right - rect.left) * m_scale_pix;
    int height = (rect.bottom- rect.top) * m_scale_pix;
    PDFDIB *dib = [[PDFDIB alloc] init:width : height];
    Global_setAnnotTransparency(0x00000000);
    [annot render:dib :0xffffffff];
    Global_setAnnotTransparency(0x200040FF);
    
    UIImage *img = [UIImage imageWithCGImage:[dib image]];
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];
    
    // Save image.
    [UIImagePNGRepresentation(img) writeToFile:filePath atomically:YES];
    
    return filePath;
}

- (NSString *)emptyImageFromAnnot:(PDFAnnot *)annot {
    PDF_RECT rect;
    [annot getRect:&rect];
    int width = (rect.right - rect.left) * m_scale_pix;
    int height = (rect.bottom- rect.top) * m_scale_pix;
    return [self emptyAnnotWithSize:CGSizeMake(width, height)];
}

- (NSString *)emptyAnnotWithSize:(CGSize)size
{
    PDFDIB *emptyDib = [[PDFDIB alloc] init:size.width : size.height];
    [emptyDib erase:0xffffffff];
    UIImage *emptyImg = [UIImage imageWithCGImage:[emptyDib image]];
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
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
    NSString *filePath = [GLOBAL.g_pdf_path stringByAppendingPathComponent:@"test.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImagePNGRepresentation([UIImage imageWithCGImage:ref]) attributes:nil];
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
            [self autoSave];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)autoSave {
    if(GLOBAL.g_save_doc && m_modified)
    {
        [m_doc save];
        m_modified = false;
    }
}

-(void)PDFClose
{
    if( [self isModified] && m_doc != NULL )
    {
        [m_doc save];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"fileStat"];
    }
    
    if(m_timer)
    {
        [m_timer invalidate];
        m_timer = NULL;
    }
    m_doc = nil;
    if(m_layout)
        [m_layout vClose];
    m_layout = nil;
    m_sel = nil;
    m_cur_page = -1;
    m_status = sta_none;
    m_zoom = 1;
    self.zoomScale = 1;
    [m_child removeFromSuperview];
    m_child = nil;
    self.m_del = nil;
}

-(void)ProRedrawOS
{
    [self bringSubviewToFront:m_child];
    [m_child setNeedsDisplay];
}
-(void)ProUpdatePage:(int) pageno
{
    [m_layout vRenderSync:pageno];
    [self.m_del OnPageUpdated:pageno];
}

- (void)RDVOnPageRendered:(int)pageno
{

}

-(void)RDVOnFound :(RDVFinder *)finder
{
    [m_layout vFindGoto];
    CGPoint pt;
    pt.x = [m_layout docx] / m_scale_pix;
    pt.y = [m_layout docy] / m_scale_pix;
    self.contentOffset = pt;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refresh];
    });
    
    if( self.m_del )
    {
        int pageno = [finder find_get_page];
        [self.m_del OnFound: (pageno >= 0 && pageno < [m_doc pageCount])];
    }
}

-(void)ProOnTimer:(NSTimer *)sender
{
    [self setNeedsDisplay];
}

-(CGSize)sizeThatFits:(CGSize)size
{
    self.zoomScale = m_zoom = 1;
    [m_layout vResize:size.width * m_scale_pix :size.height * m_scale_pix];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, [m_layout doch]/m_scale_pix);
    [m_layout vGotoPage:m_cur_page];
    [self setContentOffset:CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix) animated:NO];
    CGRect rect = CGRectMake( self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height );
    m_child.frame = rect;
    
    if (self.zoomScale <= 1 && [self pagingAvailable]) {
        self.pagingEnabled = GLOBAL.g_paging_enabled;
    }
    
    return size;
}

-(void)osDrawAnnot:(CGContextRef)context
{
    if( m_status == sta_annot && GLOBAL.g_highlight_annotation)
    {
        int dx = (m_tx - m_px) / m_scale_pix;
        int dy = (m_ty - m_py) / m_scale_pix;
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        float scale = 1.0f/(m_zoom * m_scale_pix);
        CGRect rect1 = CGRectMake(m_annot_rect.left * scale + dx,
                                  m_annot_rect.top * scale + dy,
                                  (m_annot_rect.right - m_annot_rect.left) * scale,
                                  (m_annot_rect.bottom - m_annot_rect.top) * scale);
        CGContextStrokeRect(context, rect1);
    }
}

-(void)osDrawInk:(CGContextRef)context
{
    if( m_status == sta_ink && m_ink )
    {
        int cnt = [m_ink nodesCount];
        int cur = 0;
        CGContextSetLineWidth(context, GLOBAL.g_ink_width);
        float red = ((GLOBAL.g_ink_color>>16)&0xFF)/255.0f;
        float green = ((GLOBAL.g_ink_color>>8)&0xFF)/255.0f;
        float blue = (GLOBAL.g_ink_color&0xFF)/255.0f;
        float alpha = ((GLOBAL.g_ink_color>>24)&0xFF)/255.0f;
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
                    CGContextAddLineToPoint(context,
                                            pt.x/m_scale_pix,
                                            pt.y/m_scale_pix);
                    cur++;
                    break;
                case 2:
                    [m_ink node: cur + 1: &pt2];
                    CGContextAddCurveToPoint(context,
                                             pt.x/m_scale_pix,
                                             pt.y/m_scale_pix,
                                             pt.x/m_scale_pix,
                                             pt.y/m_scale_pix,
                                             pt2.x/m_scale_pix,
                                             pt2.y/m_scale_pix );
                    cur += 2;
                    break;
                default:
                    CGContextMoveToPoint(context,
                                         pt.x/m_scale_pix,
                                         pt.y/m_scale_pix);
                    cur++;
                    break;
            }
        }
        CGContextStrokePath(context);
    }
}

-(void)osDrawLines:(CGContextRef)context
{
    if( m_status == sta_line && (m_lines_cnt || m_lines_drawing) )
    {
        CGContextSetLineWidth(context, GLOBAL.g_line_width);
        float red = ((GLOBAL.g_line_color>>16)&0xFF)/255.0f;
        float green = ((GLOBAL.g_line_color>>8)&0xFF)/255.0f;
        float blue = (GLOBAL.g_line_color&0xFF)/255.0f;
        float alpha = ((GLOBAL.g_line_color>>24)&0xFF)/255.0f;
        CGContextSetRGBFillColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_lines;
        PDF_POINT *pt_end = m_lines + (m_lines_cnt<<1);
        if( m_lines_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            CGPoint start = CGPointMake(self.contentOffset.x + pt_cur->x/m_scale_pix, self.contentOffset.y + pt_cur->y/m_scale_pix);
            CGPoint end = CGPointMake(self.contentOffset.x + pt_cur[1].x/m_scale_pix, self.contentOffset.y + pt_cur[1].y/m_scale_pix);
            CGPoint points[2] = {start, end};
            CGContextStrokeLineSegments(context, points, 2);
            pt_cur += 2;
        }
    }
}

-(void)osDrawRects:(CGContextRef)context
{
    if( m_status == sta_rect && (m_rects_cnt || m_rects_drawing) )
    {
        CGContextSetLineWidth(context, GLOBAL.g_rect_width);
        float red = ((GLOBAL.g_rect_color>>16)&0xFF)/255.0f;
        float green = ((GLOBAL.g_rect_color>>8)&0xFF)/255.0f;
        float blue = (GLOBAL.g_rect_color&0xFF)/255.0f;
        float alpha = ((GLOBAL.g_rect_color>>24)&0xFF)/255.0f;
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
            CGRect rect1 = CGRectMake(rect.left/m_scale_pix,
                                      rect.top/m_scale_pix,
                                      (rect.right - rect.left)/m_scale_pix,
                                      (rect.bottom - rect.top)/m_scale_pix);
            CGContextStrokeRect(context, rect1);
            pt_cur += 2;
        }
    }
}

-(void)osDrawEllipse:(CGContextRef)context
{
    if( m_status == sta_ellipse && (m_ellipse_cnt || m_ellipse_drawing) )
    {
        CGContextSetLineWidth(context, GLOBAL.g_oval_width);
        float red = ((GLOBAL.g_oval_color>>16)&0xFF)/255.0f;
        float green = ((GLOBAL.g_oval_color>>8)&0xFF)/255.0f;
        float blue = (GLOBAL.g_oval_color&0xFF)/255.0f;
        float alpha = ((GLOBAL.g_oval_color>>24)&0xFF)/255.0f;
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
            CGRect rect1 = CGRectMake(rect.left/m_scale_pix,
                                      rect.top/m_scale_pix,
                                      (rect.right - rect.left)/m_scale_pix,
                                      (rect.bottom - rect.top)/m_scale_pix);
            CGContextStrokeEllipseInRect(context, rect1);
            
            pt_cur += 2;
        }
    }
}

-(void)osDrawFind:(CGContextRef)context
{
    if(m_status != sta_none) return;
    RDVFinder *finder = [m_layout finder];
    if(!finder) return;
    int pgno = [finder find_get_page];
    if(pgno < [m_layout cur_pg1] || pgno >= [m_layout cur_pg2]) return;
    [finder drawOffScreen :[[RDVCanvas alloc] init :context :m_scale_pix * m_zoom]
                          :[m_layout vGetPage:pgno]
                          :[m_layout docx]
                          :[m_layout docy]];
}

-(void)osDrawSel:(CGContextRef)context
{
    if(m_status != sta_sel) return;
    [m_sel drawOffScreen :[[RDVCanvas alloc] init :context :m_scale_pix * m_zoom]
                          :[m_layout vGetPage:[m_sel pageno]]
                          :[m_layout docx]
                          :[m_layout docy]];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //layout will check which part is rendered, and which is not.
    //it only refresh rendering block.
    [m_layout vDraw:[[RDVCanvas alloc] init :ctx :m_scale_pix]];
    
    //check current page changed?
    RDVPos pos;
    [m_layout vGetPos :((doublePage) ? [m_layout vw] >> 2 : [m_layout vw] >> 1) :[m_layout vh] >> 1 :&pos];
    if( m_cur_page != pos.pageno )
    {
        m_cur_page = pos.pageno;
        if( self.m_del )
            [self.m_del OnPageChanged:m_cur_page];
    }
}

#ifdef FTS_ENABLED
- (void)drawSearchRect:(CGContextRef)context
{
    if (m_cur_page == currentOccurrence.page) {
        PDF_RECT drawRect;
        
        RDVPage *vpage = [m_layout vGetPage:m_cur_page];
        
        drawRect.left = [vpage GetX] - self.contentOffset.x * m_scale_pix + [vpage ToDIBX:currentOccurrence.rect_l];
        drawRect.right = [vpage GetX] - self.contentOffset.x * m_scale_pix + [vpage ToDIBX:currentOccurrence.rect_r];
        drawRect.top = [vpage GetY] - self.contentOffset.y * m_scale_pix + [vpage ToDIBY:currentOccurrence.rect_b];
        drawRect.bottom = [vpage GetY] - self.contentOffset.y * m_scale_pix + [vpage ToDIBY:currentOccurrence.rect_t];
        
        int dx = m_tx - m_px;
        int dy = m_ty - m_py;
        
        CGContextSetRGBFillColor(context, 0.5, 0.0, 0.93, 0.25);
        
        CGRect rect1 = CGRectMake(self.contentOffset.x + (drawRect.left+dx)/m_scale_pix,
                                  self.contentOffset.y + (drawRect.top+dy)/m_scale_pix,
                                  (drawRect.right - drawRect.left)/m_scale_pix,
                                  (drawRect.bottom - drawRect.top)/m_scale_pix);
        CGContextFillRect(context, rect1);
    }
}

- (void)applyFTSOccurrence:(FTSOccurrence *)occurrence
{
    currentOccurrence = occurrence;
}
#endif

-(void)onDrawOffScreen:(CGContextRef)ctx
{
    //draw all other status.
    [self osDrawFind:ctx];
    [self osDrawSel:ctx];
    [self osDrawAnnot:ctx];
    [self osDrawInk:ctx];
    [self osDrawLines:ctx];
    [self osDrawRects:ctx];
    [self osDrawEllipse:ctx];
#ifdef FTS_ENABLED
    [self drawSearchRect:ctx];
#endif
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != self) return;
    /*
    if(GLOBAL.g_render_mode == 3 || GLOBAL.g_render_mode == 4) {
        //Vertical block
        if (self.contentOffset.y <= 0)
            self.contentOffset = CGPointMake(self.contentOffset.x, 0);
        if (self.contentOffset.y > 0 && self.contentOffset.y >= self.contentSize.height - self.frame.size.height) {
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentSize.height - self.frame.size.height);
        }
    }*/
    
    //NSLog(@"POS:%f,%f", self.contentOffset.x, self.contentOffset.y);
    if(m_status == sta_zoom)
    {
        self.contentOffset = CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix);
        [self setNeedsDisplay];
    }
    else
    {
        int xval = self.contentOffset.x * m_scale_pix;
        int yval = self.contentOffset.y * m_scale_pix;
        int xlay = [m_layout docx];
        int ylay = [m_layout docy];
        int vw = [m_layout vw];
        int vh = [m_layout vh];
        if(xval > xlay - vw && xval < xlay + vw && yval > ylay - vh && yval < ylay + vh)
        {
            if(xval < 0) xval = 0;
            if(yval < 0) yval = 0;
            [m_layout vMoveTo:xval :yval];
        }
        else self.contentOffset = CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix);
        [self setNeedsDisplay];
        //NSLog(@"ZPOS4:%f,%f", self.contentOffset.x, self.contentOffset.y);
    }
    CGRect rect = CGRectMake( self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height );
    m_child.frame = rect;
    [self ProRedrawOS];
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
        [self zoomStartAtPoint:[scrollView.pinchGestureRecognizer locationInView:self.window]];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if( m_status == sta_zoom )
    {
        [self zoomToScale:self.zoomScale atPoint:[scrollView.pinchGestureRecognizer locationInView:self.window]];
    }
}

- (void)initZoomWithPoint:(CGPoint)point
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] > 6.0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGFloat buffer = point.y;
        point.y = point.x;
        point.x = [m_layout vw]/m_scale_pix - buffer;
    }
    
    zoomPoint = CGPointMake((point.x - ([m_layout vw]/m_scale_pix/2)), (point.y - ([m_layout vh]/m_scale_pix/2)));
    zoomPoint.x = (zoomPoint.x < 0) ? (zoomPoint.x * -1) : zoomPoint.x;
    zoomPoint.y = (zoomPoint.y < 0) ? (zoomPoint.y * -1) : zoomPoint.y;
    [m_layout vGetPos :(point.x - (zoomPoint.x * self.zoomScale)) * m_scale_pix :(point.y - (zoomPoint.y * self.zoomScale)) * m_scale_pix :&m_zoom_pos];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if( m_status == sta_zoom )
    {
        [self zoomConfirmToScale:scale];
    }
}

- (void)zoomPageToScale:(CGFloat)scale atPoint:(CGPoint)point {
    [self zoomStartAtPoint:point];
    [self zoomToScale:scale atPoint:point];
    [self zoomConfirmToScale:scale];
}

- (void)zoomStartAtPoint:(CGPoint)point {
    [m_layout vZoomStart];
    m_status = sta_zoom;
    [self initZoomWithPoint:point];
}

- (void)zoomToScale:(CGFloat)scale atPoint:(CGPoint)point
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] > 6.0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGFloat buffer = point.y;
        point.y = point.x;
        point.x = [m_layout vw]/m_scale_pix - buffer;
    }
    
    self.zoomScale = scale;
    [m_layout vZooming:self.zoomScale];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, [m_layout doch]/m_scale_pix);
    [m_layout vSetPos:(point.x - (zoomPoint.x * self.zoomScale)) * m_scale_pix :(point.y - (zoomPoint.y * self.zoomScale)) * m_scale_pix :&m_zoom_pos];
    self.contentOffset = CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix);
    [self refresh];
}

- (void)zoomConfirmToScale:(CGFloat)scale {
    m_zoom = scale;
    [m_layout vZooming:m_zoom];
    [m_layout vZoomConfirm];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, [m_layout doch]/m_scale_pix);
    self.contentOffset  = CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix);
    //NSLog(@"ZPOS7:%f,%f", self.contentOffset.x, self.contentOffset.y);
    m_status = sta_none;
    [self refresh];
    
    if (self.zoomScale <= 1 && m_status != sta_annot)
    {
        [self vGoto:m_cur_page];
     
        if (self.zoomScale <= 1 && [self pagingAvailable]) {
            self.pagingEnabled = GLOBAL.g_paging_enabled;
        }
    }
}

- (void)refresh
{
    //[self setNeedsLayout];
    [self setNeedsDisplay];
    [self ProRedrawOS];
}

- (void)centerPage
{
    if(GLOBAL.g_render_mode == 3 || GLOBAL.g_render_mode == 6)
    {
        //[self resetZoomLevel];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    NSUInteger cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
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
    NSUInteger cnt = [allTouches count];
    
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( [self OnSelTouchMove :point] ) return;
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
        NSUInteger cnt = [allTouches count];
        if( cnt == 1 )
        {
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint point=[touch locationInView:[touch view]];
            if( [self OnSelTouchEnd:point] ) return;
            if( [self OnAnnotTouchEnd:point] ) return;
            if( [self OnNoteTouchEnd:point] ) return;
            if( [self OnInkTouchEnd:point] ) return;
            if( [self OnLineTouchEnd:point] ) return;
            if( [self OnRectTouchEnd:point] ) return;
            if( [self OnEllipseTouchEnd:point] ) return;
            if( [self OnImageTouchMove:point] ) return;
            [self OnNoneTouchEnd:point:touch.timestamp];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)OnDoubleTap:(UITouch *)touch
{
    isDoubleTapping = YES;
    
    NSLog(@"double tap");
    
    if (doubleTapZoomMode > 0) {
        if (m_zoom > GLOBAL.g_zoom_level){
            if ([self pagingAvailable]) {
                self.pagingEnabled = GLOBAL.g_paging_enabled;
            }
            [self resetZoomLevel];
        } else {
            self.pagingEnabled = NO;
            
            if (doubleTapZoomMode == 1) {
                [self defaultZoom:touch];
            } else {
#ifndef SMART_ZOOM
                //[self defaultZoom:touch];
#else
                [self initZoomWithPoint:[touch locationInView:self.window]];
                RDVPos pos;
                CGPoint p = [touch locationInView:self.window];
                
                [m_layout vGetPos:p.x * m_scale_pix :p.y * m_scale_pix :&pos];
                PDF_RECT mZoomRect = [ReaderHandler handleAutomaticZoom:m_layout withPos:pos forDoc:m_doc containedInWidth:[m_layout vw]];
                
                float mParagraphWidth = mZoomRect.right - mZoomRect.left;
                
                if ((int)mParagraphWidth == 0) {
                    [self defaultZoom:touch]; // Call defaultZoom as fallback
                    return;
                }
                
                int scale = (int) ([m_layout vw] / mParagraphWidth); //screen width / paragraph width
                
                pos.pdfx = mZoomRect.right - (mParagraphWidth / 2);
                
                if (scale > 1) {
                    
                    self.zoomScale = (scale > GLOBAL.g_zoom_level) ? GLOBAL.g_zoom_level : scale;
                    m_zoom = scale;
                    
                    [m_layout vZoomStart];
                    [m_layout vZooming:scale];
                    [m_layout vSetPos:[m_layout vw] /2 :[m_layout vh] /2 :&pos];
                    [m_layout vZoomConfirm];
                    
                    CGSize sz;
                    sz.width = [m_layout docw]/m_scale_pix;
                    sz.height = [m_layout doch]/m_scale_pix;
                    self.contentSize = sz;
                    //[m_view vSetPos:&m_zoom_pos :(pos.x - (zoomPoint.x * scale)) * m_scale :(pos.y - (zoomPoint.y * scale)) * m_scale];
                    self.contentOffset = CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix);
                    
                    [self refresh];
                }
#endif
            }
        }
    }
    
    if (self.m_del) {
        [self.m_del OnDoubleTapped:[touch locationInView:self.window].x :[touch locationInView:self.window].y];
    }
    
    [self performSelector:@selector(delayedDoubleTapping) withObject:nil afterDelay:0.5];

}

- (void)delayedOnSingleTapping:(NSArray *)a
{
    if (!isDoubleTapping && a) {
        [self.m_del OnSingleTapped:[[a objectAtIndex:0] floatValue]:[[a objectAtIndex:1] floatValue]];
    }
}

- (void)delayedDoubleTapping
{
    isDoubleTapping = NO;
}

- (void)resetZoomLevel
{
    enum LAYOUT_STATUS m_status_buf = m_status;
    [self zoomPageToScale:1.0 atPoint:CGPointMake([m_layout vw] / 2, [m_layout vh] / 2)];
    
    if ([imgAnnot isDescendantOfView:self]) {
        CGPoint center = self.center;
        center.x += self.contentOffset.x;
        center.y += self.contentOffset.y;
        imgAnnot.center = center;
    }
    
    m_status = m_status_buf;
}

- (void)defaultZoom:(UITouch *)touch
{
    if (self.zoomScale == GLOBAL.g_zoom_level && GLOBAL.g_zoom_step > 0) {
        GLOBAL.g_zoom_step *= -1;
    } else if (self.zoomScale <= self.minimumZoomScale && GLOBAL.g_zoom_step) {
        GLOBAL.g_zoom_step = 1;
    }
    self.zoomScale = (self.zoomScale + GLOBAL.g_zoom_step > GLOBAL.g_zoom_level) ? GLOBAL.g_zoom_level : self.zoomScale + GLOBAL.g_zoom_step;
    [self zoomPageToScale:self.zoomScale atPoint:[touch locationInView:self.window]];
}

-(void)OnSingleTap:(float)x :(float)y
{
    [m_layout vGetPos :x * m_scale_pix * m_zoom :y * m_scale_pix * m_zoom :&m_annot_pos];
    
    if( m_annot_pos.pageno >= 0 )
    {
        RDVPage *vpage = [m_layout vGetPage:m_annot_pos.pageno];
        if( !vpage )//shall not happen
        {
            if(self.m_del) [self.m_del OnSingleTapped:x:y];
            return;
       	}
        PDFPage *page = [vpage GetPage];
        if( !page ) return;
        m_annot = [page annotAtPoint:m_annot_pos.pdfx: m_annot_pos.pdfy];
        m_annot_idx = -1;
        if( m_annot )
        {
            m_annot_idx = [m_annot getIndex];
            
            if(self.m_del && [self.m_del respondsToSelector:@selector(didTapAnnot:atPage:atPoint:)])
            {
                [self.m_del didTapAnnot:m_annot atPage:m_cur_page atPoint:CGPointMake(x, y)];
            }
            
            if (![self canSaveDocument] && m_annot.type != 1) {
                if( self.m_del )
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
            m_annot_rect.left = [vpage x] - self.contentOffset.x * m_scale_pix + [vpage ToDIBX:m_annot_rect.left];
            m_annot_rect.right = [vpage x] - self.contentOffset.x * m_scale_pix + [vpage ToDIBX:m_annot_rect.right];
            float tmp = m_annot_rect.top;
            m_annot_rect.top = [vpage y] - self.contentOffset.y * m_scale_pix + [vpage ToDIBY:m_annot_rect.bottom];
            m_annot_rect.bottom = [vpage y] - self.contentOffset.y * m_scale_pix + [vpage ToDIBY:tmp];
            [self ProRedrawOS];
            
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
                //need refresh PDFView and save annot status
                [self ProUpdatePage :m_annot_pos.pageno];
                [self vAnnotEnd];
                [self autoSave];
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
                
                [self executeAnnotJS];
                
                if (self.m_del){
                    [self.m_del OnAnnotCommboBox:arr selected:[m_annot getComboSel]];
                }
                return ;
            }
            
            nu = [m_annot getListItemCount];
            if (nu != -1){
                
                //BOOL multi = [m_annot isMultiSel];
                
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
                
                if (self.m_del){
                    [self.m_del OnAnnotList:m_annot items:arr selectedIndexes:selected_items]; // Modified method
                }
                return;
            }
            
            NSString *nuri = [m_annot getEditText];
            if (nuri) {
                if (self.m_del) {
                    CGRect annotRect;
                    annotRect.origin.x = m_annot_rect.left / m_scale_pix;
                    annotRect.origin.y = m_annot_rect.top / m_scale_pix;
                    annotRect.size.width = (m_annot_rect.right - m_annot_rect.left)/m_scale_pix;
                    annotRect.size.height = (m_annot_rect.bottom - m_annot_rect.top)/m_scale_pix;
                    [self.m_del OnAnnotEditBox:annotRect :nuri :([m_annot getEditTextSize] / m_scale_pix) * (m_zoom * [m_layout vGetScaleMin:m_cur_page])];
                }
                return ;
            }
            
            nuri = [m_annot getURI];
            if(nuri)//open url
            {
                if( self.m_del && GLOBAL.g_auto_launch_link)
                {
                    [self.m_del OnAnnotOpenURL:nuri];
                    [self vAnnotEnd];
                    return;
                }
            }
            
            if(self.m_del) [self.m_del OnAnnotClicked:m_annot:x:y];
        }
        else
        {
            if(self.m_del) {
                NSArray *a = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
                [self performSelector:@selector(delayedOnSingleTapping:) withObject:a afterDelay:0.3];
            }
        }
    }
}

-(bool)OnSelTouchBegin:(CGPoint)point
{
    if( m_status != sta_sel ) return false;
    m_tx = point.x * m_scale_pix;
    m_ty = point.y * m_scale_pix;
    [m_layout vGetPos : m_tx * m_zoom: m_ty * m_zoom :&m_sel_pos];
    
    m_sel = [[RDVSel alloc] init:[m_doc page :m_sel_pos.pageno] :m_sel_pos.pageno];
    if( self.m_del )
        [self.m_del OnSelStart:point.x: point.y];
    return true;
}

-(bool)OnSelTouchMove:(CGPoint)point
{
    if( m_status != sta_sel ) return false;
    RDVPage *vp = [m_layout vGetPage:m_sel_pos.pageno];
    float pdfx = [vp GetPDFX :[m_layout docx] + point.x * m_scale_pix * m_zoom];
    float pdfy = [vp GetPDFY :[m_layout docy] + point.y * m_scale_pix * m_zoom];
    [m_sel SetSel :m_sel_pos.pdfx :m_sel_pos.pdfy :pdfx :pdfy];
    
    [self ProRedrawOS];
    return true;
}

-(bool)OnSelTouchEnd:(CGPoint)point
{
    if( m_status != sta_sel ) return false;

    if( self.m_del )
        [self.m_del OnSelEnd :m_tx/m_scale_pix :m_ty/m_scale_pix :point.x :point.y];
    return true;
}

- (NSString *)getImageFromRect:(int)top :(int)right :(int)left :(int)bottom :(int) pageNum
{
    if (!m_doc)
        return nil;
    
    // set dib size with the draw_rect
    int width = right - left;
    int height = bottom - top;
    
    // get the selected page
    PDFPage *page = [m_doc page:pageNum];
    [page objsStart];
    PDFDIB *dib = [[PDFDIB alloc] init :width :height];
    
    // set the matrix with the draw_rect (we need only a portion of the page)
    PDFMatrix *mat = [[PDFMatrix alloc] init :1 :-1 :-left :bottom];
    [page renderPrepare :dib];
    [page render :dib :mat :2];//always render best.
    mat = NULL;
    
    // get the UIImage
    UIImage *img = [UIImage imageWithCGImage:[dib image]];
    
    //save image in PNG
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.png"];
    [UIImagePNGRepresentation(img) writeToFile:tempDir atomically:YES];
    
    NSString *imageBase64 = [UIImagePNGRepresentation(img) base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)];
    
    return imageBase64;
}

-(bool)OnAnnotTouchBegin:(CGPoint)point
{
    if (m_status != sta_annot) return false;
    if (![m_annot canMoveAnnot]) return false;
    m_px = point.x * m_scale_pix;
    m_py = point.y * m_scale_pix;
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
        m_tx = point.x * m_scale_pix;
        m_ty = point.y * m_scale_pix;
    }
    [self ProRedrawOS];
    return true;
}

-(bool)OnAnnotTouchEnd:(CGPoint)point
{
    if (m_status != sta_annot) return false;
    if (m_annot.type == 20) { // EditText
        if (self.m_del) {
            [self.m_del OnAnnotEnd];
        }
    }
    
    if (![m_annot canMoveAnnot]) {
        [self vAnnotEnd];
        return false;
    }
    if([self canSaveDocument])
    {
        [self setModified:YES force:NO];
        
        m_tx = point.x * m_scale_pix;
        m_ty = point.y * m_scale_pix;
        m_annot_rect.left += (m_tx - m_px) * m_zoom;
        m_annot_rect.top += (m_ty - m_py) * m_zoom;
        m_annot_rect.right += (m_tx - m_px) * m_zoom;
        m_annot_rect.bottom += (m_ty - m_py) * m_zoom;
        RDVPage *vpage = [m_layout vGetPage:m_annot_pos.pageno];
        RDVPos pos;
        [m_layout vGetPos :point.x * m_scale_pix * m_zoom :point.y * m_scale_pix *m_zoom :&pos];
        PDFPage *page = [vpage GetPage];
        PDFAnnot *annot = [page annotAtIndex:m_annot_idx];
        if( pos.pageno == m_annot_pos.pageno )
        {
            PDFMatrix *mat = [vpage CreateInvertMatrix
                              :self.contentOffset.x * m_scale_pix
                              :self.contentOffset.y * m_scale_pix];
            [mat transformRect:&m_annot_rect];
            
            //Action Stack Manger
            PDF_RECT rect;
            [annot getRect:&rect];
            [actionManger push:[[ASMove alloc] initWithPage:pos.pageno initRect:rect destPage:pos.pageno destRect:m_annot_rect index:m_annot_idx ref:[annot getRef]]];
            
            [annot setRect:&m_annot_rect];
            [self ProUpdatePage :m_annot_pos.pageno];
            [self vAnnotEnd];
            [self updateLastAnnotInfoAtPage:page];
        }
        else
        {
            RDVPage *vdest = [m_layout vGetPage:pos.pageno];
            PDFPage *dpage = [vpage GetPage];
            if( dpage )
            {
                PDFMatrix *mat = [vdest CreateInvertMatrix
                                  :self.contentOffset.x * m_scale_pix
                                  :self.contentOffset.y * m_scale_pix];
                [mat transformRect :&m_annot_rect];
                
                //Action Stack Manger
                PDF_RECT rect;
                [m_annot getRect:&rect];
                
                PDF_OBJ_REF ref = [m_annot getRef];
                
                [annot MoveToPage :dpage :&m_annot_rect];
                [self ProUpdatePage :m_annot_pos.pageno];
                [self ProUpdatePage :pos.pageno];
                
                ASMove *item = [[ASMove alloc] initWithPage:m_annot_pos.pageno initRect:rect destPage:pos.pageno destRect:m_annot_rect index:([dpage annotCount] - 1) ref:ref];
                [actionManger push:item];
                item.m_pageno = item.m_pageno0;
                [actionManger orderOnDel:item];
                item.m_pageno = item.m_pageno1;
                [actionManger orderIndexes:item];
                
                [self vAnnotEnd];
                [self updateLastAnnotInfoAtPage:dpage];
            }
        }
        
        [self autoSave];
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
    RDVPos pos;
    [m_layout vGetPos :point.x * m_scale_pix * m_zoom :point.y * m_scale_pix * m_zoom :&pos];
    RDVPage *vpage = [m_layout vGetPage:pos.pageno];
    if( vpage )
    {
        PDFPage *page = [vpage GetPage];
        if( page )
        {
            [self setModified:YES force:NO];
            
            PDF_POINT pt;
            pt.x = pos.pdfx;
            pt.y = pos.pdfy;
            [page addAnnotNote:&pt];
            
            //Action Stack Manger
            [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
            
            // Set Author and Modify date
            [self updateLastAnnotInfoAtPage:page];
            
            [self ProUpdatePage :pos.pageno];
            [self setNeedsDisplay];
        }
    }
    [self autoSave];
    return true;
}

-(bool)OnInkTouchBegin:(CGPoint)point
{
    if( m_status != sta_ink ) return false;
    if( !m_ink )
    {
        m_tx = point.x * m_scale_pix;
        m_ty = point.y * m_scale_pix;
        m_ink = [[PDFInk alloc] init :GLOBAL.g_ink_width * m_scale_pix: GLOBAL.g_ink_color];
    }
    [m_ink onDown :point.x * m_scale_pix :point.y * m_scale_pix];
    return true;
}

-(bool)OnInkTouchMove:(CGPoint)point
{
    if( m_status != sta_ink ) return false;
    [m_ink onMove :point.x * m_scale_pix :point.y * m_scale_pix];
    [self ProRedrawOS];
    return true;
}
-(bool)OnInkTouchEnd:(CGPoint)point
{
    if( m_status != sta_ink ) return false;
    [m_ink onUp :point.x * m_scale_pix :point.y * m_scale_pix];
    [self ProRedrawOS];
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
    m_tx = point.x * m_scale_pix;
    m_ty = point.y * m_scale_pix;
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
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
    [self refresh];
    return true;
}

-(bool)OnLineTouchEnd:(CGPoint)point
{
    if( m_status != sta_line ) return false;
    PDF_POINT *pt_cur = &m_lines[m_lines_cnt<<1];
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
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
    m_tx = point.x * m_scale_pix;
    m_ty = point.y * m_scale_pix;
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
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
    [self ProRedrawOS];
    return true;
}

-(bool)OnRectTouchEnd:(CGPoint)point
{
    if( m_status != sta_rect ) return false;
    PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
    m_rects_cnt++;
    if( m_rects_drawing )
    {
        m_rects_drawing = false;
        [self ProRedrawOS];
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
    m_tx = point.x * m_scale_pix;
    m_ty = point.y * m_scale_pix;
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
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
    [self ProRedrawOS];
    return true;
}

-(bool)OnEllipseTouchEnd:(CGPoint)point
{
    if( m_status != sta_ellipse ) return false;
    PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
    pt_cur[1].x = point.x * m_scale_pix;
    pt_cur[1].y = point.y * m_scale_pix;
    m_ellipse_cnt++;
    if( m_ellipse_drawing )
    {
        m_ellipse_drawing = false;
        [self ProRedrawOS];
    }
    return true;
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

-(void)OnNoneTouchBegin:(CGPoint)point :(NSTimeInterval)timeStamp
{
    m_tstamp = timeStamp;
    m_tstamp_tap = m_tstamp;
    m_tx = point.x * m_scale_pix;
    m_ty = point.y * m_scale_pix;
    m_px = m_tx;
    m_py = m_ty;
}

-(void)OnNoneTouchMove:(CGPoint)point :(NSTimeInterval)timeStamp
{
    NSTimeInterval del = timeStamp - m_tstamp;
    if( del > 0 )
    {
        float dx = point.x * m_scale_pix - m_px;
        float dy = point.y * m_scale_pix - m_py;
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
            dx = point.x * m_scale_pix - m_tx;
            dy = point.y * m_scale_pix - m_ty;
            if( dx < 10 && dx > -10 && dy < 10 && dy > -10 )
            {
                m_status = sta_none;
                if( self.m_del )
                    [self.m_del OnLongPressed :point.x :point.y];
            }
        }
    }
    m_px = point.x * m_scale_pix;
    m_py = point.y * m_scale_pix;
}

-(void)OnNoneTouchEnd:(CGPoint)point :(NSTimeInterval)timeStamp
{
    float dx = point.x - m_tx / m_scale_pix;
    float dy = point.y - m_ty / m_scale_pix;
    if( timeStamp - m_tstamp_tap < 0.15 )//single tap
    {
        bool single_tap = true;
        if( dx > 5 || dx < -5 )
            single_tap = false;
        if( dy > 5 || dy < -5 )
            single_tap = false;
        if( single_tap )
        {
            [self OnSingleTap :point.x :point.y];
        }
    } else {
        bool long_press = true;
        if( dx > 5 || dx < -5 )
            long_press = false;
        if( dy > 5 || dy < -5 )
            long_press = false;
        if( long_press )
        {
            if( self.m_del )
                [self.m_del OnLongPressed:point.x :point.y];
        }
    }
}

- (void)vAddTextAnnot:(int)x :(int)y :(NSString *)text :(NSString *)subject
{
    RDVPos pos;
    [m_layout vGetPos:x * m_scale_pix * m_zoom :y * m_scale_pix * m_zoom :&pos];
    if(pos.pageno>=0)
    {
        RDVPage *vpage = [m_layout vGetPage:pos.pageno];
        if( !vpage ) return;
        PDFPage *page = [vpage GetPage];
        if (!page) {
            return;
        }
        [self setModified:YES force:NO];
        
        PDF_POINT pt;
        pt.x = pos.pdfx ;
        pt.y = pos.pdfy ;
        [page addAnnotNote:&pt];
        
        //Action Stack Manger
        [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
        
        PDFAnnot *annot = [page annotAtIndex: [page annotCount] - 1];
        [annot setPopupSubject:subject];
        [annot setPopupText:text];
        
        // Set Author and Modify date
        [self updateLastAnnotInfoAtPage:page];
        
        [self refreshCurrentPage];
        [self autoSave];
    }
}

- (PDFAnnot *)vGetTextAnnot:(int)x :(int)y
{
    PDFAnnot *annot;
    RDVPos pos;
    [m_layout vGetPos:x * m_scale_pix * m_zoom :y * m_scale_pix * m_zoom :&pos];
    if(pos.pageno>=0)
    {
        PDFPage *page = [m_doc page:pos.pageno];
        [page objsStart];
        if( !page ) return NULL;
        annot = [page annotAtPoint:pos.pdfx: pos.pdfy];
        
    }
    return annot;
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
    [m_layout vRenderSync:m_cur_page];
    [self refresh];
    
    [self setModified:YES force:NO];
    
    // Set Author and Modify date
    [self updateLastAnnotInfoAtPage:page];
    
    [self autoSave];
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
    
    [self ProUpdatePage:m_cur_page];
    
    [self setModified:YES force:NO];
    
    [self vAnnotEnd];
    
    [self autoSave];
}

- (BOOL)setSignatureImageAtIndex:(int)index atPage:(int)pageNum {
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:TEMP_SIGNATURE];
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    //get the PDFVPage
    RDVPage *vpage = [m_layout vGetPage:pageNum];
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
    
    [self ProUpdatePage:pageNum];
    
    // Delete temp signature image
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    if (success) {
        [self setModified:YES force:NO];
    }
    
    return success;
}
/*
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
 */

- (void)setCommboItem:(int)item
{
    if ([m_annot getComboSel] != item) {
        [self setModified:YES force:NO];
    }
    [m_annot setComboSel:item];
    [self setModifyDateForAnnot:m_annot];
    [self ProUpdatePage:m_annot_pos.pageno];
    [self vAnnotEnd];
    
    [self autoSave];
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
    
    [self ProUpdatePage:m_annot_pos.pageno];
    [self vAnnotEnd];
    
    [self autoSave];
}


- (void)refreshCurrentPage {
    if (m_cur_page > 0) {
        [self ProUpdatePage:m_cur_page - 1];
    }
    if ((m_cur_page + 1) < [m_doc pageCount]) {
        [self ProUpdatePage:m_cur_page + 1];
    }
    
    if (m_cur_page >= 0 && m_cur_page < [m_doc pageCount]) {
        [self ProUpdatePage:m_cur_page];
    }
    
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
}

- (void)refreshCachedPages {
    int start = m_layout.cur_pg1;
    int end = m_layout.cur_pg2;
    
    while (start < end) {
        [self ProUpdatePage:start];
        start++;
    }
}

- (BOOL)pagingAvailable
{
    return (GLOBAL.g_render_mode == 3 || GLOBAL.g_render_mode == 4 || GLOBAL.g_render_mode == 6);
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
    GLOBAL.g_readerview_bg_color = color;
    
    if (GLOBAL.g_readerview_bg_color != 0) {
        self.backgroundColor = UIColorFromRGB(color);
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

- (BOOL)useTempImage
{
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
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

- (BOOL)forceSave
{
    if ([m_doc save]) {
        [self setModified:NO force:YES];
        return YES;
    }
    
    return NO;
}

#pragma mark - VFind

-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word
{
    if( !pat ) return false;
    [m_layout vFindStart:pat :match_case :whole_word];
    [self ProRedrawOS];
    return true;
}

-(void)vFind:(int)dir
{
    if( [m_layout vFind:dir] < 0 )//no more found.
    {
        if( self.m_del ) [self.m_del OnFound:false];
    }
    
    [self ProRedrawOS];
}
-(void)vFindEnd
{
    [m_layout vFindEnd];
    [self setNeedsDisplay];
}


-(void)vSelStart
{
    if( m_status == sta_none )
    {
        m_status = sta_sel;
        self.scrollEnabled = false;
    }
}

-(void)vSelEnd
{
    if( m_status == sta_sel )
    {
        self.scrollEnabled = true;
        m_status = sta_none;
        m_sel = nil;
        [self refreshCurrentPage];
    }
}

-(NSString *)vSelGetText
{
    if( m_status != sta_sel || !m_sel ) return nil;
    return [m_sel GetSelString];
}

-(BOOL)vSelMarkup:(int)color :(int)type
{
    if( m_status != sta_sel || !m_sel ) return false;
    
    [self setModified:[m_sel SetSelMarkup:type] force:NO];
    [actionManger push:[[ASAdd alloc] initWithPage:m_sel.pageno page:m_sel.pdfpage index:(m_sel.pdfpage.annotCount - 1)]];
    
    [self autoSave];
    [self ProUpdatePage :m_sel_pos.pageno];
    [self setNeedsDisplay];
    return true;
}



-(void)vAnnotPerform
{
    if( m_status != sta_annot ) return;
    if ([m_annot get3D]) {
        [m_annot get3DData:[NSTemporaryDirectory() stringByAppendingString:[m_annot get3D]]];
    }
    int pageno = [m_annot getDest];
    if( pageno >= 0 )//goto page
    {
        if(self.m_del)
            [self.m_del OnAnnotGoto:pageno];
        [self vAnnotEnd];
        return;
    }
    NSString *nuri = [m_annot getURI];
    if(nuri)//open url
    {
        if(self.m_del)
            [self.m_del OnAnnotOpenURL:nuri];
        [self vAnnotEnd];
        return;
    }
    nuri = [m_annot getMovie];
    if( nuri )
    {
        nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
        [m_annot getMovieData:nuri];
        if(self.m_del)
            [self.m_del OnAnnotMovie:nuri];
        [self vAnnotEnd];
        return;
    }
    nuri = [m_annot getSound];
    if( nuri )
    {
        int spara[4];
        nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
        [m_annot getSoundData:spara :nuri];
        if(self.m_del)
            [self.m_del OnAnnotSound:nuri];
        [self vAnnotEnd];
        return;
    }
    nuri = [m_annot getPopupText];
    if( nuri )
    {
        //popup dialog to show text and subject.
        //nuri is text content.
        //subj is subject string.
        if(self.m_del && (![m_annot isAnnotReadOnly] || m_annot.type == 1))
            [self.m_del OnAnnotPopup:m_annot];
        [self vAnnotEnd];
        return;
    }
    if ([self canSaveDocument] && m_annot.fieldType == 4 && m_annot.getSignStatus == 0){
        if (self.m_del && [self.m_del respondsToSelector:@selector(OnAnnotSignature:)] && GLOBAL.g_enable_graphical_signature) {
            [self.m_del OnAnnotSignature:m_annot];
        }
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
    [actionManger push:[[ASDel alloc] initWithPage:m_annot_pos.pageno page:page index:m_annot_idx]];
    
    PDFAnnot *annot = [page annotAtIndex:m_annot_idx];
    [annot removeFromPage];
    [self vAnnotEnd];
    
    [self ProUpdatePage :m_annot_pos.pageno];
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    
    [self autoSave];
}
-(void)removeAnnot :(PDFAnnot *)annot
{
    [annot removeFromPage];
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    [m_doc save];
}

-(void)vAnnotEnd
{
    if( m_status != sta_annot ) return;
    m_status = sta_none;
    self.scrollEnabled = true;
    m_annot_idx = -1;
    m_annot = nil;
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    if(self.m_del)
        [self.m_del OnAnnotEnd];
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
        self.scrollEnabled = true;
        m_status = sta_none;
        [self setNeedsDisplay];
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
        [self setNeedsDisplay];
        [m_child setNeedsDisplay];
    }
}

-(void)vInkEnd
{
    if( !m_ink ) m_status = sta_none;
    if( m_status != sta_ink ) return;
    RDVPos pos;
    [m_layout vGetPos :m_tx * m_zoom :m_ty * m_zoom :&pos];
    if(pos.pageno >= 0)
    {
        RDVPage *vpage = [m_layout vGetPage:pos.pageno];
        PDFMatrix *mats = [[PDFMatrix alloc] init :m_zoom :m_zoom :0 :0];
        [mats transformInk:m_ink];
        PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale_pix
                                                  :self.contentOffset.y * m_scale_pix];
        PDFPage *page = [vpage GetPage];
        [mat transformInk:m_ink];
        [page addAnnotInk:m_ink];
        // Set Author and Modify date
        [self updateLastAnnotInfoAtPage:page];

        //Action Stack Manger
        [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
        
        [self ProUpdatePage :pos.pageno];
        [self setModified:YES force:NO];
    }
    m_status = sta_none;
    m_ink = nil;
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    [self autoSave];
    self.scrollEnabled = true;
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
        RDVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_lines;
        PDF_POINT *pt_end = pt_cur + (m_lines_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            RDVPos pos;
            [m_layout vGetPos:pt_cur->x :pt_cur->y :&pos];
            if( pos.pageno >= 0 )
            {
                RDVPage *vpage = [m_layout vGetPage:pos.pageno];
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
                PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale_pix :self.contentOffset.y * m_scale_pix];
                [mat transformPoint:pt_cur];
                [mat transformPoint:&pt_cur[1]];
                [page addAnnotLine:pt_cur :&pt_cur[1] :GLOBAL.g_line_width :GLOBAL.g_line_annot_style1 :GLOBAL.g_line_annot_style2 :GLOBAL.g_line_color :GLOBAL.g_line_annot_fill_color];
                
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
            [self ProUpdatePage :[pages[cur] pageno]];
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
        [self setNeedsDisplay];
        [m_child setNeedsDisplay];
    }
}
-(void)vRectEnd
{
    if( m_status != sta_rect ) return;
    RDVPage *pages[128];
    int cur;
    int end;
    int pages_cnt = 0;
    PDF_POINT *pt_cur = m_rects;
    PDF_POINT *pt_end = pt_cur + (m_rects_cnt<<1);
    while( pt_cur < pt_end )
    {
        PDF_RECT rect;
        RDVPos pos;
        [m_layout vGetPos :pt_cur->x * m_zoom :pt_cur->y * m_zoom :&pos];
        if( pos.pageno >= 0 )
        {
            RDVPage *vpage = [m_layout vGetPage:pos.pageno];
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
                rect.right = pt_cur->x * m_zoom;
                rect.left = pt_cur[1].x * m_zoom;
            }
            else
            {
                rect.left = pt_cur->x * m_zoom;
                rect.right = pt_cur[1].x * m_zoom;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y * m_zoom;
                rect.top = pt_cur[1].y * m_zoom;
            }
            else
            {
                rect.top = pt_cur->y * m_zoom;
                rect.bottom = pt_cur[1].y * m_zoom;
            }
            PDFPage *page = [vpage GetPage];
            PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale_pix
                                                      :self.contentOffset.y * m_scale_pix];
            [mat transformRect:&rect];
            [page addAnnotRect:&rect: GLOBAL.g_rect_width * m_scale_pix / [vpage scale]: GLOBAL.g_rect_color: GLOBAL.g_rect_annot_fill_color];
            
            //Action Stack Manger
            [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
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
        [self ProUpdatePage :[pages[cur] pageno]];
        cur++;
    }
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    
    [self autoSave];
    self.scrollEnabled = true;
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
        [self setNeedsDisplay];
        [m_child setNeedsDisplay];
    }
}

-(void)vEllipseEnd
{
    if( m_status != sta_ellipse ) return;
    RDVPage *pages[128];
    int cur;
    int end;
    int pages_cnt = 0;
    PDF_POINT *pt_cur = m_ellipse;
    PDF_POINT *pt_end = pt_cur + (m_ellipse_cnt<<1);
    while( pt_cur < pt_end )
    {
        PDF_RECT rect;
        RDVPos pos;
        [m_layout vGetPos :pt_cur->x * m_zoom :pt_cur->y * m_zoom :&pos];
        if( pos.pageno >= 0 )
        {
            RDVPage *vpage = [m_layout vGetPage:pos.pageno];
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
                rect.right = pt_cur->x * m_zoom;
                rect.left = pt_cur[1].x * m_zoom;
            }
            else
            {
                rect.left = pt_cur->x * m_zoom;
                rect.right = pt_cur[1].x * m_zoom;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y * m_zoom;
                rect.top = pt_cur[1].y * m_zoom;
            }
            else
            {
                rect.top = pt_cur->y * m_zoom;
                rect.bottom = pt_cur[1].y * m_zoom;
            }
            PDFPage *page = [vpage GetPage];
            PDFMatrix *mat = [vpage CreateInvertMatrix:self.contentOffset.x * m_scale_pix
                                                      :self.contentOffset.y * m_scale_pix];
            [mat transformRect:&rect];
            [page addAnnotEllipse:&rect:GLOBAL.g_oval_width * m_scale_pix / [vpage scale] :GLOBAL.g_oval_color:GLOBAL.g_ellipse_annot_fill_color];
            
            //Action Stack Manger
            [actionManger push:[[ASAdd alloc] initWithPage:pos.pageno page:page index:(page.annotCount - 1)]];
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
        [self ProUpdatePage :[pages[cur] pageno]];
        cur++;
    }
    [self setNeedsDisplay];
    [m_child setNeedsDisplay];
    self.scrollEnabled = true;
    [self autoSave];
}

- (BOOL)vImageStart
{
    if(![self canSaveDocument]) return false;
    if( m_status == sta_none )
    {
        self.scrollEnabled = false;
        m_status = sta_image;
        
        if(!imgAnnot)
            imgAnnot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_add"]];
        
        if (![imgAnnot isDescendantOfView:self]) {
            
            RDVPage *page = [m_layout vGetPage:m_cur_page];
            CGFloat pageWidth = [page GetWidth] / m_scale_pix;
            
            if (pageWidth < imgAnnot.frame.size.width) {
                CGFloat ratio = imgAnnot.frame.size.width / imgAnnot.frame.size.height;
                [imgAnnot setFrame:CGRectMake(0, 0, pageWidth / 2 , (pageWidth / 2) / ratio)];
            } else {
                [imgAnnot setFrame:CGRectMake(0, 0, (imgAnnot.frame.size.width / m_scale_pix) * [page GetScale], (imgAnnot.frame.size.height / m_scale_pix) * [page GetScale])];
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
        
        RDVPos pos1;
        RDVPos pos2;
        
        [m_layout vGetPos:(imgAnnot.frame.origin.x - self.contentOffset.x) * m_scale_pix * m_zoom :(imgAnnot.frame.origin.y - self.contentOffset.y) * m_scale_pix * m_zoom: &pos1];
        [m_layout vGetPos:(imgAnnot.frame.origin.x - self.contentOffset.x + imgAnnot.frame.size.width) * m_scale_pix * m_zoom :(imgAnnot.frame.origin.y - self.contentOffset.y + imgAnnot.frame.size.height) * m_scale_pix * m_zoom :&pos2];
        
        PDF_RECT rect;
        
        rect.left = pos1.pdfx;
        rect.right = pos2.pdfx;
        rect.top = pos2.pdfy;
        rect.bottom = pos1.pdfy;
        
        [self vAddImageWithImage:imgAnnot.image withRect:rect];
        
        [imgAnnot removeFromSuperview];
        imgAnnot = nil;
        
        [self refresh];
        
        self.scrollEnabled = true;
    }
}

- (void)enableScroll
{
    self.scrollEnabled = true;
    /*
    if ([self isCurlEnabled] && m_zoom <= 1)
        self.scrollEnabled = false;
     */
}

#pragma mark view Method
-(void)vGetPos:(RDVPos *)pos
{
    [m_layout vGetPos:[m_layout vw]/2 :[m_layout vh]/2 :pos];
}

- (void)vGetPos:(RDVPos *)pos x:(int)x y:(int)y
{
    [m_layout vGetPos:x * m_scale_pix * m_zoom :y * m_scale_pix * m_zoom :pos];
}

-(void)vGoto:(int)pageno
{
    /*
    if (pageno < 0 || pageno >= m_doc.pageCount) {
        pageno = 0;
    }
    
    if (doublePage) {
        if (GLOBAL.g_paging_enabled && GLOBAL.g_render_mode == 4 && pageno > 0 && (pageno + 1) < m_doc.pageCount && (pageno % 2 == 0) && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno++;
        }
        
        BOOL checkMod = (coverPage) ? (pageno % 2 == 0) : (pageno % 2 != 0);
        
        if (GLOBAL.g_paging_enabled && GLOBAL.g_render_mode == 4 && pageno > 0 && checkMod && !UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            pageno--;
        }
    }
    
    RDVPos pos;
    
    pos.pdfx = 0;
    pos.pdfy = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    int pages = (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) && doublePage && m_doc.pageCount > 1 && !(coverPage && (pageno < 1 || ((pageno % 2 != 0) && pageno == (m_doc.pageCount - 1))))) ? 2 : 1;
    float gapX;
    
    if (pages > 1 && (pageno + 1) < m_doc.pageCount) {
        gapX = ([m_layout vw] - (([m_doc pageWidth:pageno] * [m_layout zoomMin]) + ([m_doc pageWidth:pageno + 1]  * [m_layout zoomMin]))) / 2;
    } else {
        gapX = ([m_layout vw] - ([m_doc pageWidth:pageno] * [m_layout zoomMin])) / 2;
    }
    
    float gapY = ([m_layout vh] - ([m_doc pageHeight:pageno]*[m_layout zoomMin])) / 2;
    
    if (GLOBAL.g_render_mode > 1)
        [m_layout vSetPos:gapX :gapY :&pos];
    else
        [m_layout vSetPos:0 :0 :&pos];
    
    CGPoint pt;
    pt.x = [m_layout docx]/m_scale_pix;
    pt.y = [m_layout docy]/m_scale_pix;
    
    self.contentOffset = pt;
    
    [self refresh];
    */
    
    [m_layout vGotoPage:pageno];
    CGPoint pt;
    pt.x = m_layout.docx/m_scale_pix;
    pt.y = m_layout.docy/m_scale_pix;
    self.contentOffset = pt;
    [self ProRedrawOS];
    [self setNeedsDisplay];
}

- (int)vGetCurrentPage
{
    return m_cur_page;
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

#pragma mark - PDFJSDelegate Methods

- (void)executeAnnotJS {
    [self executeAnnotJS:m_annot];
}

- (void)executeAnnotJS:(PDFAnnot *)annot
{
    if (!annot || ! GLOBAL.g_execute_annot_JS) {
        return;
    }
    
    NSString *js = [annot getJS];
    
    if (js) {
        [self runJS:js];
    }
    
    js = [annot getAdditionalJS:1];
    
    if (js) {
        [self runJS:js];
    }
    
    js = [annot getFieldJS:3];
    
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

-(void)OnUncaughtException:(int)code :(NSString *)para
{}

#pragma mark - Screen/PDF coordinates convertion

- (PDF_RECT)pdfRectFromScreenRect:(CGRect)screenRect
{
    RDVPos pos1;
    RDVPos pos2;
    
    [m_layout vGetPos:(screenRect.origin.x - self.contentOffset.x) * m_scale_pix * m_zoom :(screenRect.origin.y - self.contentOffset.y) * m_scale_pix * m_zoom: &pos1];
    [m_layout vGetPos:(screenRect.origin.x - self.contentOffset.x + screenRect.size.width) * m_scale_pix * m_zoom :(screenRect.origin.y - self.contentOffset.y + screenRect.size.height) * m_scale_pix * m_zoom :&pos2];
    
    PDF_RECT pdfRect;
    
    pdfRect.left = pos1.pdfx;
    pdfRect.right = pos2.pdfx;
    pdfRect.top = pos2.pdfy;
    pdfRect.bottom = pos1.pdfy;
    
    return pdfRect;
}

@end
