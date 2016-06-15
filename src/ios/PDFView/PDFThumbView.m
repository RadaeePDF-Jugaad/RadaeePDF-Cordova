//
//  PDFThumb.m
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import "PDFThumbView.h"
#import <QuartzCore/QuartzCore.h>
@implementation PDFThumbView

-(void)OnPageRendered:(PDFVCache *)cache
{
    [self refresh];
}

-(void)OnPageChanged:(int)pageno
{
}

-(void)OnPageDisplayed :(CGContextRef)ctx : (PDFVPage *)page
{
}

-(void)OnFound:(PDFVFinder *)finder
{
}

-(void)vOpen:(PDFDoc *)doc :(id<PDFThumbViewDelegate>)delegate
{
    //GEAR
    [self vClose];
    //END
    m_doc = doc;
    m_view = [[PDFVThmb alloc] init:0:false];
    m_delegate = delegate;
    
    struct PDFVThreadBack tback;
    tback.OnPageRendered = @selector(OnPageRendered:);
    //tback.OnFound = @selector(OnFound:);
    self.backgroundColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    [m_view vOpen:doc :4 : self: &tback];
    [m_view vResize:m_w :m_h];
    self.contentSize = CGSizeMake([m_view vGetDocW]/m_scale, [m_view vGetDocH]/m_scale);
    CGPoint pt;
    pt.x = [m_view vGetX]/m_scale;
    pt.y = [m_view vGetY]/m_scale;
    self.contentOffset = pt;
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                               target:self selector:@selector(vOnTimer:)
                                             userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
    m_status = tsta_none;
    self.delegate = self;
//    m_delegate = nil;
}

-(void)vGoto:(int)pageno
{
    int dx;
    int dy;
    [m_view vGetDeltaToCenterPage:pageno :&dx :&dy];
    [m_view vSetSel:pageno];
    [self scrollRectToVisible:CGRectMake(self.contentOffset.x + dx/m_scale, self.contentOffset.y + dy/m_scale, m_w/m_scale, m_h/m_scale) animated:true];
}

-(void)vClose
{
    if( m_view != nil )
    {
        [m_view vClose];
        m_view = nil;
        [m_timer invalidate];
        m_timer = NULL;
    }
    m_view = NULL;
    m_doc = NULL;
    m_status = tsta_none;
    m_delegate = nil;
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScrollToTop");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [m_view vMoveTo:self.contentOffset.x * m_scale :self.contentOffset.y * m_scale];
    [self refresh];
    //NSLog(@"scrollViewDidScroll");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDragging");
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scrollViewDidEndDragging");
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDecelerating");
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
}

-(void)refresh
{
    [self setNeedsDisplay];
}

-(void)draw:(CGContextRef)context
{
    //return;
    PDFVCanvas *canvas = [[PDFVCanvas alloc] init: context: m_scale];
    [m_view vDraw :canvas :false];
    canvas = nil;
}

-(void)vOnTimer:(NSTimer *)sender
{
    if( [m_view vNeedRefresh] )
    {
        [self refresh];
    }
}

-(id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_doc = NULL;
        m_view = nil;
        m_scale = [[UIScreen mainScreen] scale];
        m_w = frame.size.width * m_scale;
        m_h = frame.size.height * m_scale;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        [self resignFirstResponder];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect
{
    [self draw:UIGraphicsGetCurrentContext()];
}


-(CGSize)sizeThatFits:(CGSize)size
{
    m_w = size.width * m_scale;
    m_h = size.height * m_scale;
    [m_view vResize:m_w :m_h];
    self.contentSize = CGSizeMake([m_view vGetDocW]/m_scale, [m_view vGetDocH]/m_scale);
    return size;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( m_status == tsta_none )
        {
            m_tstamp = touch.timestamp;
            m_tstamp_tap = m_tstamp;
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            m_px = m_tx;
            m_py = m_ty;
            m_status = tsta_hold;
        }
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
        if( m_status == tsta_hold )
        {
            m_px = point.x * m_scale;
            m_py = point.y * m_scale;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if(m_status == tsta_hold)
        {
            m_status = tsta_none;
            //NSTimeInterval del = touch.timestamp - m_tstamp;
            float dx = point.x * m_scale - m_tx;
            float dy = point.y * m_scale - m_ty;
            if( touch.timestamp - m_tstamp_tap < 0.15 )//single tap
            {
                bool single_tap = true;
                if( dx > 5 || dx < -5 )
                    single_tap = false;
                if( dy > 5 || dy < -5 )
                    single_tap = false;
                if( single_tap )
                    [self onSingleTap:(point.x - self.contentOffset.x) * m_scale :(point.y - self.contentOffset.y) * m_scale];
            }
        }
    }
    [self refresh];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)vGetPos:(struct PDFV_POS*)pos
{
    [m_view vGetPos:pos :0 :0];
}

-(void)onSingleTap:(float)x :(float)y
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :x :y];
    if( pos.pageno >= 0 )
    {
        if( [m_view vGetSel] != pos.pageno )
        {
            [self vGoto:pos.pageno];
            if( m_delegate )
                [m_delegate OnPageClicked: pos.pageno];
        }
    }
}
@end
