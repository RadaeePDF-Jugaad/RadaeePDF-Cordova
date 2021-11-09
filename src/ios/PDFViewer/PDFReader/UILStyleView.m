//
//  UILStyleView.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UILStyleView.h"
#import "PDFPopupCtrl.h"
#import "PDFDialog.h"
#import "UILShadowView.h"

const char *lineType[] =
{
    "Style 1",
    "Style 2",
    "Style 3",
    "Style 4",
    "Style 5",
    "Style 6"
};

@implementation UILStyleView
-(id)init:(CGRect)frame :(func_lstyle)callback
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_dashs_cnt = 0;
        m_callback = callback;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    if(m_dashs_cnt > 0) CGContextSetLineDash(ctx, 0, m_dashs, m_dashs_cnt);
    CGContextSetLineWidth(ctx, 1);
    CGRect rc = self.bounds;
    CGFloat midy = rc.size.height * 0.5f;
    CGContextMoveToPoint(ctx, 2, midy);
    CGContextAddLineToPoint(ctx, rc.size.width - 2, midy);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
}

-(void)tapAction:(id)sendor
{
    if(m_callback)
        m_callback(m_dashs, m_dashs_cnt);
}

-(void)setDash:(const CGFloat *)dash :(int)dash_cnt
{
    if(dash)
    {
        memcpy(m_dashs, dash, sizeof(CGFloat) * dash_cnt);
        m_dashs_cnt = dash_cnt;
    }
    else
        m_dashs_cnt = 0;
    [self setNeedsDisplay];
}
@end

@implementation UILStyleBtn
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_dashs_cnt = 0;
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
        m_dashs_cnt = 0;
        m_vc = nil;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    if(m_dashs_cnt > 0) CGContextSetLineDash(ctx, 0, m_dashs, m_dashs_cnt);
    CGContextSetLineWidth(ctx, 1);
    CGRect rc = self.bounds;
    CGFloat midy = rc.size.height * 0.5f;
    CGContextMoveToPoint(ctx, 8, midy);
    CGContextAddLineToPoint(ctx, rc.size.width - 8, midy);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextRestoreGState(ctx);
}

-(void)setDash:(const CGFloat *)dash :(int)dash_cnt :(UIViewController *)vc
{
    m_vc = vc;
    [self update:dash :dash_cnt];
}
-(const CGFloat *)dash
{
    return m_dashs;
}
-(int)dashCnt
{
    return m_dashs_cnt;
}
-(void)update:(const CGFloat *)dash :(int)dash_cnt
{
    if(dash)
    {
        memcpy(m_dashs, dash, sizeof(CGFloat) * dash_cnt);
        m_dashs_cnt = dash_cnt;
    }
    else
        m_dashs_cnt = 0;
    [self setNeedsDisplay];
}
-(void)tapAction:(id)sendor
{
#define LSTYLE_HEIGHT 40
#define LSTYLE_WIDTH 100
    UIView *container = [(PDFDialog *)m_vc popView];
    container.hidden = YES;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame = [self convertRect:frame toView:m_vc.view];
    //frame.origin.x += frame.size.width;
    frame.size.width = LSTYLE_WIDTH;
    frame.size.height = LSTYLE_HEIGHT * 6;
    CGRect rect = m_vc.view.frame;
    if(frame.origin.y + frame.size.height > rect.origin.y + rect.size.height)
        frame.origin.y = rect.origin.y + rect.size.height - frame.size.height;
    
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, LSTYLE_HEIGHT * 6 + 16)];
    view.contentSize = CGSizeMake(LSTYLE_WIDTH, 16 + LSTYLE_HEIGHT * 6);
    view.scrollEnabled = YES;
    UILShadowView *bgView = [[UILShadowView alloc] initWithFrame:CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, LSTYLE_HEIGHT * 6 + 16)];
    [bgView addSubview:view];
    bgView.center = container.center;
    pop = [[PDFPopupCtrl alloc] init:bgView];
    [pop setDismiss:^{
        container.hidden = NO;
    }];

    UILStyleView *lv;
    UILStyleBtn *thiz = self;
    CGFloat tdash[4];
    
    lv = [[UILStyleView alloc] init:CGRectMake(8, 8, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:0]];

    lv = [[UILStyleView alloc] init:CGRectMake(8, 8 + LSTYLE_HEIGHT, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    tdash[0] = 1;
    tdash[1] = 1;
    [lv setDash:tdash :2];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:1]];

    lv = [[UILStyleView alloc] init:CGRectMake(8, 8 + LSTYLE_HEIGHT * 2, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    tdash[0] = 2;
    tdash[1] = 2;
    [lv setDash:tdash :2];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:2]];

    lv = [[UILStyleView alloc] init:CGRectMake(8, 8 + LSTYLE_HEIGHT * 3, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    tdash[0] = 4;
    tdash[1] = 4;
    [lv setDash:tdash :2];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:3]];

    lv = [[UILStyleView alloc] init:CGRectMake(8, 8 + LSTYLE_HEIGHT * 4, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    tdash[0] = 4;
    tdash[1] = 2;
    tdash[2] = 2;
    tdash[3] = 2;
    [lv setDash:tdash :4];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:4]];

    lv = [[UILStyleView alloc] init:CGRectMake(8, 8 + LSTYLE_HEIGHT * 5, LSTYLE_WIDTH, LSTYLE_HEIGHT) :^(const CGFloat *dash, int dash_cnt) {
        [thiz update:dash :dash_cnt];
        [pop dismiss];
    }];
    tdash[0] = 12;
    tdash[1] = 2;
    tdash[2] = 4;
    tdash[3] = 2;
    [lv setDash:tdash :4];
    [view addSubview:lv];
    [view addSubview:[self getLineLabelAtIdx:5]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateStyleFromGesture:)];
    [view addGestureRecognizer:tap];

    [m_vc presentViewController:pop animated:NO completion:nil];
}

- (UILabel *)getLineLabelAtIdx:(int)idx
{
    UIFont *font = [UIFont systemFontOfSize:15];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(16 + LSTYLE_WIDTH, 8 + idx * LSTYLE_HEIGHT, 120, LSTYLE_HEIGHT)];
    lab.tag = 0;
    lab.text = [NSString stringWithUTF8String:lineType[idx]];
    [lab setFont:font];
    return lab;
}

- (void)updateStyleFromGesture:(UITapGestureRecognizer *)tap
{
}

@end
