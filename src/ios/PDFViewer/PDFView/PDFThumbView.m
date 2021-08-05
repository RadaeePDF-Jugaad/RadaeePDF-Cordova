//
//  PDFThumbView.m
//  PDFViewer
//
//  Created by strong on 2016/12/11.
//
//

#import "PDFThumbView.h"
#import "RDPDFView.h"
#import "RDVPage.h"
#import "RDVCanvas.h"

@implementation PDFThumbView
{
    int m_save_gap;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_scale_pix = [[UIScreen mainScreen] scale];
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.pagingEnabled = NO;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_scale_pix = [[UIScreen mainScreen] scale];
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.pagingEnabled = NO;
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!m_layout) return;
    [m_layout vResize:frame.size.width * m_scale_pix :frame.size.height * m_scale_pix];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, [m_layout doch]/m_scale_pix);
    [m_layout vGotoPage:m_cur_page];
    [self setContentOffset:CGPointMake([m_layout docx]/m_scale_pix, [m_layout docy]/m_scale_pix) animated:NO];
}

- (BOOL)pagingAvailable {
    return NO;
}
-(void)ProOnTimer:(NSTimer *)sender
{
    [self setNeedsDisplay];
}

-(BOOL)PDFOpen :(PDFDoc *)doc :(int)page_gap :(RDPDFCanvas *)canvas :(id<PDFThumbViewDelegate>)del
{
    [self PDFClose];
    m_zoom = 1;
    m_doc = doc;
    m_delegate = del;
    m_del = nil;
    //page_gap = 1;
    m_sel_pno = -1;
    m_canvas = canvas;
    m_layout = [[RDVLayoutThumb alloc] init :self :(GLOBAL.g_render_mode == 7)];
    m_save_gap = page_gap;
    [m_layout vOpen:m_doc :page_gap * m_scale_pix :self.layer];
    [self bringSubviewToFront:m_child];
    m_status = sta_none;
    CGRect rect = self.frame;
    [m_layout vResize:rect.size.width * m_scale_pix :rect.size.height * m_scale_pix];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, 0);
    self.backgroundColor = (GLOBAL.g_thumbview_bg_color) ? UIColorFromRGB(GLOBAL.g_thumbview_bg_color) : [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:0.5f];
    [self setNeedsDisplay];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(ProOnTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    return TRUE;
}

- (void)PDFSaveView
{
    [super PDFSaveView];
    m_sel_pno = -1;
}
- (void)PDFRestoreView
{
    m_layout = [[RDVLayoutThumb alloc] init :self :(GLOBAL.g_render_mode == 7)];
    [m_layout vOpen:m_doc :m_save_gap * m_scale_pix :self.layer];
    [self bringSubviewToFront:m_child];
    m_status = sta_none;
    CGRect rect = self.frame;
    [m_layout vResize:rect.size.width * m_scale_pix :rect.size.height * m_scale_pix];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, 0);
    [self setNeedsDisplay];
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    RDVPos pos;
    CGPoint pt = [tap locationOfTouch:0 inView:m_canvas];
    [m_layout vGetPos:pt.x * m_scale_pix :pt.y * m_scale_pix :&pos];
    if( pos.pageno >= 0 && pos.pageno != m_sel_pno )
    {
        [self vGoto :pos.pageno];
        if( m_delegate )
            [m_delegate OnPageClicked: pos.pageno];
    }
}

-(void)vGoto:(int)pageno
{
    RDVPos pos;
    RDVPage *vp = [m_layout vGetPage:pageno];
    pos.pdfx = 0;
    pos.pdfy = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    float xpos = self.frame.size.width * m_scale_pix;
    [m_layout vSetPos:(xpos - vp.w) / 2 :0 :&pos];
    m_sel_pno = pageno;
    
    CGPoint pt;
    pt.x = m_layout.docx / m_scale_pix;
    pt.y = m_layout.docy / m_scale_pix;
    [self setContentOffset:pt animated:YES];
    [m_canvas setNeedsDisplay];
}

-(void)PDFUpdatePage:(int)pageno
{
    [m_layout vRenderAsync:pageno];
}

-(void)PDFClose
{
    [super PDFClose];
    m_sel_pno = -1;
    m_delegate = nil;
}

-(void)onDrawOffScreen:(CGContextRef)ctx
{
    int start = m_layout.cur_pg1;
    int end = m_layout.cur_pg2;
    if (start < 0 && end < 0) return;
    if(m_sel_pno >= 0 && m_sel_pno >= start && m_sel_pno <= end)
    {
        RDVPage *vpage = [m_layout vGetPage:m_sel_pno];
        float scale = 1.0f/(m_zoom * m_scale_pix);
        float left = (float)vpage.x - self.contentOffset.x * m_scale_pix;
        float top = (float)vpage.y - self.contentOffset.y * m_scale_pix;
        CGRect rect = CGRectMake(scale * left, scale * top, scale * vpage.w, scale * vpage.h);
        //CGRect rect = CGRectMake(0, 0, scale * vpage.w, scale * vpage.h);
        CGFloat clr[4] = {0, 0, 1, 0.25};
        CGContextSetFillColor(ctx, clr);
        CGContextFillRect(ctx, rect);
    }

    while (start <= end)
    {
        RDVPage *vpage = [m_layout vGetPage:start];
        float scale = 1.0f / (m_zoom * m_scale_pix);
        float left = (float)vpage.x - self.contentOffset.x * m_scale_pix;
        CGRect rect = CGRectMake(scale * left, scale * (vpage.h/2 - vpage.h/5), scale * vpage.w, scale * (vpage.h/5));
        // Add the page number
        if (!m_font) m_font = [UIFont systemFontOfSize:scale * vpage.h / 5];
        if (!m_color) m_color = UIColorFromRGB(GLOBAL.g_thumbview_label_color);
        if (!m_pstyle)
        {
            m_pstyle = [[NSMutableParagraphStyle alloc] init];
            [m_pstyle setAlignment:NSTextAlignmentCenter];
        }
        NSString *sdraw = [NSString stringWithFormat:@"%i", ++start];
        [sdraw drawInRect:rect withAttributes:@{NSFontAttributeName: m_font, NSForegroundColorAttributeName: m_color, NSParagraphStyleAttributeName: m_pstyle}];
    }
}


- (void)PDFSetBGColor:(int)color
{
    GLOBAL.g_thumbview_bg_color = color;
    
    if (GLOBAL.g_thumbview_bg_color != 0) {
        self.backgroundColor = UIColorFromRGB(GLOBAL.g_thumbview_bg_color);
    }
}
@end
