//
//  PDFThumbView.m
//  PDFViewer
//
//  Created by strong on 2016/12/11.
//
//

#import "PDFThumbView.h"
#import "RDVPage.h"
#import "RDVCanvas.h"

@implementation PDFThumbView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_child.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.pagingEnabled = NO;
    }
    return self;
}

-(BOOL)PDFOpen :(PDFDoc *)doc :(int)page_gap :(id<PDFThumbViewDelegate>)del
{
    [self PDFClose];
    m_zoom = 1;
    m_doc = doc;
    m_delegate = del;
    self.m_del = nil;
    page_gap = 1;
    m_sel_pno = -1;
    m_layout = [[RDVLayoutThumb alloc] init :self :(GLOBAL.g_render_mode == 7)];
    [m_layout vOpen:m_doc :page_gap * m_scale_pix :self.layer];
    [self bringSubviewToFront:m_child];
    m_status = sta_none;
    [m_layout vResize:self.frame.size.width * m_scale_pix :self.frame.size.height * m_scale_pix];
    self.contentSize = CGSizeMake([m_layout docw]/m_scale_pix, 0);
    self.backgroundColor = (GLOBAL.g_thumbview_bg_color != 0) ? UIColorFromRGB(GLOBAL.g_thumbview_bg_color) : [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(ProOnTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
    return TRUE;
}

- (BOOL)pagingAvailable {
    return NO;
}

-(void)vGoto:(int)pageno
{
    RDVPos pos;
    RDVPage *vp = [m_layout vGetPage:pageno];
    pos.pdfx = 0;
    pos.pdfy = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    float xpos = self.frame.size.width * [[UIScreen mainScreen] scale];
    [m_layout vSetPos:(xpos - vp.w) / 2 :0 :&pos];
    m_sel_pno = pageno;
    
    [self bringSubviewToFront:m_child];
    
    CGPoint pt;
    pt.x = m_layout.docx / m_scale_pix;
    pt.y = m_layout.docy / m_scale_pix;
    self.contentOffset = pt;
    [m_child setNeedsDisplay];
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

#pragma mark delegate
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = (int)[allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        //if( m_status == sta_none )
        {
            m_tstamp = touch.timestamp;
            m_tstamp_tap = m_tstamp;
            m_tx = point.x * m_scale_pix;
            m_ty = point.y * m_scale_pix;
            m_px = m_tx;
            m_py = m_ty;
           // m_status = sta_hold;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = (int)[allTouches count];
    
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        //if( m_status == sta_hold )
        {
            m_px = point.x * m_scale_pix;
            m_py = point.y * m_scale_pix;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = (int)[allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        //if(m_status == sta_hold)
        //{
            m_status = sta_none;
            //NSTimeInterval del = touch.timestamp - m_tstamp;
            float dx = point.x * m_scale_pix - m_tx;
            float dy = point.y * m_scale_pix - m_ty;
            if( touch.timestamp - m_tstamp_tap < 0.15 )//single tap
            {
                bool single_tap = true;
                if( dx > 5 || dx < -5 )
                    single_tap = false;
                if( dy > 5 || dy < -5 )
                    single_tap = false;
                if( single_tap )
                    [self OnSingleTap:point.x * m_scale_pix :point.y * m_scale_pix];
            }
        //}
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)OnSingleTap:(float)x :(float)y
{
    RDVPos pos;
    [m_layout vGetPos:x :y :&pos];
    if( pos.pageno >= 0 && pos.pageno != m_sel_pno )
    {
        [self vGoto :pos.pageno];
        [m_child setNeedsDisplay];
        if( m_delegate )
            [m_delegate OnPageClicked: pos.pageno];
    }
}

-(void)onDrawOffScreen:(CGContextRef)ctx
{
    if(m_sel_pno >= 0)
    {
        RDVPage *vpage = [m_layout vGetPage:m_sel_pno];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        float scale = 1.0f/(m_zoom * m_scale_pix);
        float left = (float)vpage.x - self.contentOffset.x * m_scale_pix;
        float top = (float)vpage.y - self.contentOffset.y * m_scale_pix;
        CGRect rect = CGRectMake(scale * left, scale * top, scale * vpage.w, scale * vpage.h);
        CGFloat clr[4] = {0, 0, 1, 0.25};
        CGContextSetFillColor(ctx, clr);
        CGContextFillRect(ctx, rect);
    }
    
    int start = m_layout.cur_pg1;
    int end = m_layout.cur_pg2;
    while (start <= end) {
        
        RDVPage *vpage = [m_layout vGetPage:start];
        float scale = 1.0f/(m_zoom * m_scale_pix);
        float left = (float)vpage.x - self.contentOffset.x * m_scale_pix;
        CGRect rect = CGRectMake(scale * left, scale * (vpage.h/2 - vpage.h/5), scale * vpage.w, scale * (vpage.h/5));
        // Add the page number
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [[NSString stringWithFormat:@"%i", start+1] drawInRect:rect withAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:scale * (vpage.h/5)], NSForegroundColorAttributeName: [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f], NSParagraphStyleAttributeName: paragraphStyle}];
        
        start++;
    }
}

- (void)setThumbBackgroundColor:(int)color
{
    GLOBAL.g_thumbview_bg_color = color;
    
    if (GLOBAL.g_thumbview_bg_color != 0) {
        self.backgroundColor = UIColorFromRGB(GLOBAL.g_thumbview_bg_color);
    }
}

@end
