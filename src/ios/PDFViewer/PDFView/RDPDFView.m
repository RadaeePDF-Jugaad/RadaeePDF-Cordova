//
//  PDFOffScreenView.m
//  PDFViewer
//
//  Created by Radaee on 2016/12/6.
//
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "RDVLayout.h"
#import "RDVSel.h"
#import "RDVFinder.h"
#import "RDPDFView.h"
#import "RDVGlobal.h"
#import "PDFLayoutView.h"
#import "PDFThumbView.h"


@implementation RDPDFCanvas
-(void)setView :(PDFLayoutView *)view
{
    m_view = view;
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    [self setUserInteractionEnabled:NO];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [m_view onDrawOffScreen:ctx];
}

@end

@implementation RDPDFView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        m_canvas = [[RDPDFCanvas alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_canvas setView:m_view];
        m_canvas.autoresizesSubviews = YES;
        m_canvas.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_view.autoresizesSubviews = YES;
        m_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:m_view];
        [self addSubview:m_canvas];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        CGRect frame = self.frame;
        m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        m_canvas = [[RDPDFCanvas alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_canvas setView:m_view];
        m_canvas.autoresizesSubviews = YES;
        m_canvas.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_view.autoresizesSubviews = YES;
        m_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:m_view];
        [self addSubview:m_canvas];
    }
    return self;
}

-(PDFLayoutView *)view
{
    return m_view;
}
-(RDPDFCanvas *)canvas
{
    return m_canvas;
}
@end

@implementation RDPDFThumb
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_view = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        m_canvas = [[RDPDFCanvas alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_canvas setView:m_view];
        m_canvas.autoresizesSubviews = YES;
        m_canvas.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_view.autoresizesSubviews = YES;
        m_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:m_view];
        [self addSubview:m_canvas];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        CGRect frame = self.frame;
        m_view = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        m_canvas = [[RDPDFCanvas alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_canvas setView:m_view];
        m_canvas.autoresizesSubviews = YES;
        m_canvas.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_view.autoresizesSubviews = YES;
        m_view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:m_view];
        [self addSubview:m_canvas];
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    }
    return self;
}
@end
