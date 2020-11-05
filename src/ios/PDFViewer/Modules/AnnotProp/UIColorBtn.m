//
//  UIColorBtn.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColorBtn.h"
#import "PopColor.h"
#import "PDFPopupCtrl.h"
@implementation UIColorBtn
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)tapAction:(id)sendor
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PopColor" owner:self options:nil];
    PopColor *view = [views lastObject];
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame = [self convertRect:frame toView:m_vc.view];
    frame.origin.x += frame.size.width;
    frame.size.width = 118;
    frame.size.height = 168;
    CGRect rect = m_vc.view.frame;
    if(frame.origin.y + frame.size.height > rect.origin.y + rect.size.height)
        frame.origin.y = rect.origin.y + rect.size.height - frame.size.height;
    view.frame = frame;
    
    PDFPopupCtrl *pop = [[PDFPopupCtrl alloc] init:view];
    unsigned int *tclr = &m_color;
    [view setPara:m_color :m_has_enable :^(Boolean ok, unsigned int color) {
        if(ok)
        {
            CGFloat clr[4];
            clr[0] = ((color >> 16) & 0xff) / 255.0f;
            clr[1] = ((color >> 8) & 0xff) / 255.0f;
            clr[2] = (color & 0xff) / 255.0f;
            clr[3] = ((color >> 24) & 0xff) / 255.0f;
            *tclr = color;
            self.backgroundColor = [UIColor colorWithRed:clr[0] green:clr[1] blue:clr[2] alpha:1];
        }
        [pop dismiss];
    }];
    [m_vc presentViewController:pop animated:NO completion:nil];
}

-(void)setColor:(unsigned int)color :(Boolean)has_enable :(UIViewController *)vc
{
    m_color = color;
    m_has_enable = has_enable;
    m_vc = vc;
    CGFloat clr[4];
    clr[0] = ((color >> 16) & 0xff) / 255.0f;
    clr[1] = ((color >> 8) & 0xff) / 255.0f;
    clr[2] = (color & 0xff) / 255.0f;
    clr[3] = ((m_color >> 24) & 0xff) / 255.0f;
    self.backgroundColor = [UIColor colorWithRed:clr[0] green:clr[1] blue:clr[2] alpha:1];
}
-(int)color
{
    return m_color;
}
@end
