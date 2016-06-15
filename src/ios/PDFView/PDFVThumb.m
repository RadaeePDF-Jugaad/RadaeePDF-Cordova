//
//  PDFThumb.m
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import "PDFVThumb.h"
#import <QuartzCore/QuartzCore.h>
extern int g_PDF_ViewMode;
extern float g_Ink_Width;
extern float g_rect_Width;
extern uint g_ink_color;
extern uint g_rect_color;

@implementation PDFVThumb

-(void)OnPageRendered:(PDFVCache *)cache
{
    [self refresh];
}
-(void)OnPageDisplayed :(CGContextRef)ctx : (PDFVPage *)page
{
}

-(void)OnFound:(PDFVFinder *)finder
{
}

-(void)vOpenThumb:(PDFDoc *)doc
{
    //GEAR
    [self vClose];
    //END
    m_doc = doc;
    
    m_view = [[PDFVThmb alloc] init:0:false];
    struct PDFVThreadBack tback;
    tback.OnPageRendered = @selector(OnPageRendered:);
    //tback.OnFound = @selector(OnFound:);
    self.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    [m_view vOpen:doc :4 : self: &tback];
    [m_view vResize:m_w :m_h];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                               target:self selector:@selector(timerFireMethod:)
                                             userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
    m_status = sta_none;
    
    m_delegate = nil;
}

-(void)vSetDelegate:(id<PDFVThumbDelegate>)delegate
{
    m_delegate = delegate;
}

-(void)vGoto:(int)pageno
{
    [m_view vGetDeltaToCenterPage:pageno :&m_swipe_dx :&m_swipe_dy];
    [m_view vSetSel:pageno];
    [self refresh];
}

/*
-(void)vGoto:(int)pageno
{
    struct PDFV_POS pos;
    
    pos.x = 0;
    pos.y = Document_getPageHeight(m_doc, pageno);
    pos.pageno = pageno-1;
    [m_view vSetPos:&pos :0 :0];
    [self refresh];
}
*/
/*-(void)vOpenPage:(PDF_DOC)doc:(int)pageno:(float)x:(float)y
{
    [self vOpen:doc];
    struct PDFV_POS pos;
    pos.pageno = pageno;
    pos.x = x;
    pos.y = y;
    [m_view vSetPos:&pos :0 :0];
}
*/
-(void)vClose
{
    if( m_view != nil )
    {
        [m_view vClose];
        m_view = nil;
        [m_timer invalidate];
        m_timer = nil;
    }
    m_view = nil;
    m_doc = nil;
    m_status = sta_none;
    m_delegate = nil;
}

-(void)refresh
{
    [self setNeedsDisplay];
}

-(void)draw:(CGContextRef)context
{
    //return;
    PDFVCanvas *canvas = [[PDFVCanvas alloc] init: context: m_scale];
    [m_view vDraw :canvas :(m_status == sta_zoom)];
    canvas = nil;
}

- (void)timerFireMethod:(NSTimer *)sender
{
    if( m_swipe_dx || m_swipe_dy )
    {
        int speedx;
        if( m_swipe_dx > 0 )
        {
            if( m_swipe_dx < 3 ) speedx = m_swipe_dx;
            else speedx = sqrtl(m_swipe_dx<<2);
        }
        else
        {
            if( m_swipe_dx > -3 ) speedx = m_swipe_dx;
            else speedx = -sqrtl(-m_swipe_dx<<2);
        }
        m_swipe_dx -= speedx;

        int speedy;
        if( m_swipe_dy > 0 )
        {
            if( m_swipe_dy < 3 ) speedy = m_swipe_dy;
            else speedy = sqrtl(m_swipe_dy<<2);
        }
        else
        {
            if( m_swipe_dy > -3 ) speedy = m_swipe_dy;
            else speedy = -sqrtl(-m_swipe_dy<<2);
        }
        m_swipe_dy -= speedy;

        [m_view vMoveDelta :speedx :speedy];
        [self refresh];
    }
    else if( [m_view vNeedRefresh] )
    {
        [self refresh];
    }
}

-(id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_doc = nil;
        m_view = nil;
        m_scale = [[UIScreen mainScreen] scale];
        m_w = frame.size.width * m_scale;
        m_h = frame.size.height * m_scale;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        [self resignFirstResponder];
        m_swipe_dx = 0;
        m_swipe_dy = 0;
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
    m_w = size.width * m_scale;
    m_h = size.height * m_scale;
    [m_view vResize:m_w :m_h];
    return size;
    
}

-(void)swipe_init:(float) x :(float) y :(NSTimeInterval) ts
{
    m_swx[0] = x;
    m_swx[1] = x;
    m_swx[2] = x;
    m_swx[3] = x;
    m_swx[4] = x;
    m_swx[5] = x;
    m_swx[6] = x;
    m_swx[7] = x;
    m_swy[0] = y;
    m_swy[1] = y;
    m_swy[2] = y;
    m_swy[3] = y;
    m_swy[4] = y;
    m_swy[5] = y;
    m_swy[6] = y;
    m_swy[7] = y;
    m_tstamp_swipe[0] = ts;
    m_tstamp_swipe[1] = ts;
    m_tstamp_swipe[2] = ts;
    m_tstamp_swipe[3] = ts;
    m_tstamp_swipe[4] = ts;
    m_tstamp_swipe[5] = ts;
    m_tstamp_swipe[6] = ts;
    m_tstamp_swipe[7] = ts;
}

-(void)swipe_rec:(float) x :(float) y :(NSTimeInterval) ts
{
    m_swx[0] = m_swx[1];
    m_swx[1] = m_swx[2];
    m_swx[2] = m_swx[3];
    m_swx[3] = m_swx[4];
    m_swx[4] = m_swx[5];
    m_swx[5] = m_swx[6];
    m_swx[6] = m_swx[7];
    m_swx[7] = x;
    m_swy[0] = m_swy[1];
    m_swy[1] = m_swy[2];
    m_swy[2] = m_swy[3];
    m_swy[3] = m_swy[4];
    m_swy[4] = m_swy[5];
    m_swy[5] = m_swy[6];
    m_swy[6] = m_swy[7];
    m_swy[7] = y;
    m_tstamp_swipe[0] = m_tstamp_swipe[1];
    m_tstamp_swipe[1] = m_tstamp_swipe[2];
    m_tstamp_swipe[2] = m_tstamp_swipe[3];
    m_tstamp_swipe[3] = m_tstamp_swipe[4];
    m_tstamp_swipe[4] = m_tstamp_swipe[5];
    m_tstamp_swipe[5] = m_tstamp_swipe[6];
    m_tstamp_swipe[6] = m_tstamp_swipe[7];
    m_tstamp_swipe[7] = ts;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_swipe_dx = 0;
    m_swipe_dy = 0;
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( m_status == sta_none )
        {
            [m_view vOnTouchDown:point.x * m_scale: point.y * m_scale];
            m_tstamp = touch.timestamp;
            m_tstamp_tap = m_tstamp;
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            m_px = m_tx;
            m_py = m_ty;
            [self swipe_init:m_tx :m_ty :m_tstamp];
            m_status = sta_hold;
           /*
            if( m_delegate )
                [m_delegate OnTouchDown: m_tx :m_ty];
            */
            
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( m_status == sta_hold )
        {
            [m_view vOnTouchMove:point.x * m_scale: point.y * m_scale];
            NSTimeInterval del = touch.timestamp - m_tstamp;
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
            }
            m_px = point.x * m_scale;
            m_py = point.y * m_scale;
            [self swipe_rec:m_px :m_py :touch.timestamp];
        }
        [self refresh];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        switch (m_status)
        {
            case sta_hold:
            {
                m_status = sta_none;
                NSTimeInterval del = touch.timestamp - m_tstamp;
                float dx = point.x * m_scale - m_tx;
                float dy = point.y * m_scale - m_ty;
                float vx = 0;
                float vy = 0;
                if( del > 0 )//fling?
                {
                    vx = dx/del;
                    vy = dy/del;
                }
                dx = 0;
                dy = 0;
                if( vx > 400 || vx < -400 ) dx = vx;
                if( vy > 400 || vy < -400 ) dy = vy;
                
                float sdel = m_tstamp_swipe[7] - m_tstamp_swipe[0];
                float sdx = (m_swx[7] - m_swx[0])/(del * m_scale);
                float sdy = (m_swy[7] - m_swy[0])/(del * m_scale);
                
                 if( sdel < 0.8 && (sdx > 20 || sdx < -20 || dy > 20 || sdy < -20) )//swipe
                    [self onSwipe: sdx :sdy];
                else if( touch.timestamp - m_tstamp_tap < 0.15 )//single tap
                {
                    bool single_tap = true;
                    if( dx > 5 || dx < -5 )
                        single_tap = false;
                    if( dy > 5 || dy < -5 )
                        single_tap = false;
                    if( single_tap )
                        [self onSingleTap:point.x * m_scale :point.y * m_scale];
                }
               /* else if( m_delegate )
                    [m_delegate OnTouchUp:point.x * m_scale :point.y * m_scale];*/
            }
        }
    }
    else if( cnt == 2 && m_status == sta_zoom )
    {
        m_status = sta_none;
    }
    [self refresh];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)onSwipe:(float)dx :(float)dy
{
    m_swipe_dx = -dx * m_scale / 2;
    m_swipe_dy = -dy * m_scale / 2;
}

-(void)vGetPos:(struct PDFV_POS*)pos
{
    [m_view vGetPos:pos :0 :0];
}

- (void)onSingleTap:(float)x :(float)y
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :x :y];
    if( pos.pageno >= 0 )
    {
        if( [m_view vGetSel] != pos.pageno )
        {
            [self vGoto:pos.pageno];
            if( m_delegate )
                [m_delegate PDFVThumbOnPageClicked: pos.pageno];
        }
    }
}
@end
