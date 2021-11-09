//
//  UILHeadView.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UILHeadView.h"
#import "PDFDialog.h"
#import "UILShadowView.h"

const char *arrowType[] =
{
    "None",
    "Arrow",
    "Closed",
    "Square",
    "Circle",
    "Butt",
    "Diamond",
    "Reverted",
    "Reverted Closed",
    "Slash"
};

@implementation UILHeadView
-(id)init:(CGRect)frame :(func_lhead)callback
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_style = 0;
        m_callback = callback;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)tapAction:(id)sendor
{
    if(m_callback)
        m_callback(m_style);
}
-(void)setStyle:(int)style
{
    m_style = style;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect
{
#define HEAD_LEN 5
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGFloat clrs[4] = {0.2, 0.2, 0.2, 1};
    CGContextSetStrokeColor(ctx, clrs);
    CGFloat clrf[4] = {0.8, 0.8, 0.8, 1};
    CGContextSetFillColor(ctx, clrf);
    
    CGContextSetLineWidth(ctx, 1);
    CGRect rc = self.bounds;
    CGFloat midy = rc.size.height * 0.5f;
    
    CGContextMoveToPoint(ctx, 10, midy);
    CGContextAddLineToPoint(ctx, rc.size.width - 2, midy);
    
    switch(m_style)
    {
    case 1:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        break;
    case 2:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        CGContextClosePath(ctx);
        break;
    case 3:
        CGContextAddRect(ctx, CGRectMake(10 - HEAD_LEN, midy - HEAD_LEN, HEAD_LEN * 2, HEAD_LEN * 2));
        break;
    case 4:
        CGContextAddEllipseInRect(ctx, CGRectMake(10 - HEAD_LEN, midy - HEAD_LEN, HEAD_LEN * 2, HEAD_LEN * 2));
        break;
    case 5:
        CGContextMoveToPoint(ctx, 10, midy - HEAD_LEN);
        CGContextAddLineToPoint(ctx, 10, midy + HEAD_LEN);
        break;
    case 6:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN, midy);
        CGContextAddLineToPoint(ctx, 10, midy - HEAD_LEN);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN, midy);
        CGContextAddLineToPoint(ctx, 10, midy + HEAD_LEN);
        CGContextClosePath(ctx);
        break;
    case 7:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        break;
    case 8:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        CGContextClosePath(ctx);
        break;
    case 9:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.5f, midy - HEAD_LEN * 0.707f);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.5f, midy + HEAD_LEN * 0.707f);
        break;
    }
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextRestoreGState(ctx);
}

@end

@implementation UILHeadBtn
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_style = 0;
        m_vc = nil;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_style = 0;
        m_vc = nil;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)tapAction:(id)sendor
{
#define LHEAD_HEIGHT 40
#define LHEAD_WIDTH 100
    UIView *container = [(PDFDialog *)m_vc popView];
    container.hidden = YES;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame = [self convertRect:frame toView:m_vc.view];
    //frame.origin.x += frame.size.width;
    frame.size.width = LHEAD_WIDTH;
    frame.size.height = LHEAD_HEIGHT * 10;
    CGRect rect = m_vc.view.frame;
    if(frame.origin.y + frame.size.height > rect.origin.y + rect.size.height)
        frame.origin.y = rect.origin.y + rect.size.height - frame.size.height - 20;
    
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];
    view.contentSize = CGSizeMake(LHEAD_WIDTH, 16 + LHEAD_HEIGHT * 10);
    view.scrollEnabled = YES;
    UILShadowView *bgView = [[UILShadowView alloc] initWithFrame:container.frame];
    [bgView addSubview:view];
    bgView.center = container.center;
    pop = [[PDFPopupCtrl alloc] init:bgView];
    [pop setDismiss:^{
        container.hidden = NO;
    }];
    
    UILHeadView *lv;
    UILHeadBtn *thiz = self;
    
    lv = [[UILHeadView alloc] init:CGRectMake(8, 8, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:0]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:1];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:1]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 2, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:2];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:2]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 3, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:3];
    [view addSubview:[self getLineLabelAtIdx:3]];
    [view addSubview:lv];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 4, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:4];
    [view addSubview:[self getLineLabelAtIdx:4]];
    [view addSubview:lv];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 5, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:5];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:5]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 6, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:6];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:6]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 7, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:7];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:7]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 8, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:8];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:8]];

    lv = [[UILHeadView alloc] init:CGRectMake(8, 8 + LHEAD_HEIGHT * 9, LHEAD_WIDTH, LHEAD_HEIGHT) :^(int style) {
        [thiz updateStyle:style];
        [pop dismiss];
    }];
    [lv setStyle:9];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:9]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateStyleFromGesture:)];
    [view addGestureRecognizer:tap];

    [m_vc presentViewController:pop animated:NO completion:nil];
}
-(void)drawRect:(CGRect)rect
{
#define HEAD_LEN 5
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGFloat clrs[4] = {0.2, 0.2, 0.2, 1};
    CGContextSetStrokeColor(ctx, clrs);
    CGFloat clrf[4] = {0.8, 0.8, 0.8, 1};
    CGContextSetFillColor(ctx, clrf);
    
    CGContextSetLineWidth(ctx, 1);
    CGRect rc = self.bounds;
    CGFloat midy = rc.size.height * 0.5f;
    
    CGContextMoveToPoint(ctx, 8, midy);
    CGContextAddLineToPoint(ctx, rc.size.width - 8, midy);
    
    switch(m_style)
    {
    case 1:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        break;
    case 2:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        CGContextClosePath(ctx);
        break;
    case 3:
        CGContextAddRect(ctx, CGRectMake(10 - HEAD_LEN, midy - HEAD_LEN, HEAD_LEN * 2, HEAD_LEN * 2));
        break;
    case 4:
        CGContextAddEllipseInRect(ctx, CGRectMake(10 - HEAD_LEN, midy - HEAD_LEN, HEAD_LEN * 2, HEAD_LEN * 2));
        break;
    case 5:
        CGContextMoveToPoint(ctx, 10, midy - HEAD_LEN);
        CGContextAddLineToPoint(ctx, 10, midy + HEAD_LEN);
        break;
    case 6:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN, midy);
        CGContextAddLineToPoint(ctx, 10, midy - HEAD_LEN);
        CGContextAddLineToPoint(ctx, 10 + HEAD_LEN, midy);
        CGContextAddLineToPoint(ctx, 10, midy + HEAD_LEN);
        CGContextClosePath(ctx);
        break;
    case 7:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        break;
    case 8:
        CGContextMoveToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy - HEAD_LEN * 0.5f);
        CGContextAddLineToPoint(ctx, 10, midy);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.707f, midy + HEAD_LEN * 0.5f);
        CGContextClosePath(ctx);
        break;
    case 9:
        CGContextMoveToPoint(ctx, 10 + HEAD_LEN * 0.5f, midy - HEAD_LEN * 0.707f);
        CGContextAddLineToPoint(ctx, 10 - HEAD_LEN * 0.5f, midy + HEAD_LEN * 0.707f);
        break;
    }
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextRestoreGState(ctx);
}

-(void)updateStyle:(int)style
{
    m_style = style;
    [self setNeedsDisplay];
}
                                                                                 
-(void)setStyle:(int)style :(UIViewController *)vc;
{
    m_vc = vc;
    [self updateStyle:style];
}
-(int)style
{
    return m_style;
}

- (UILabel *)getLineLabelAtIdx:(int)idx
{
    UIFont *font = [UIFont systemFontOfSize:15];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(16 + LHEAD_WIDTH, 8 + idx * LHEAD_HEIGHT, 120, LHEAD_HEIGHT)];
    lab.tag = idx;
    lab.text = [NSString stringWithUTF8String:arrowType[idx]];
    [lab setFont:font];
    return lab;
}

- (void)updateStyleFromGesture:(UITapGestureRecognizer *)tap
{
    CGPoint pt = [tap locationInView:[tap view]];
    [self updateStyle:pt.y / LHEAD_HEIGHT];
    [pop dismiss];
}


@end
