//
//  UIColorBtn.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColorBtn.h"
#import "PDFPopupCtrl.h"
#import "RDAnnotPickerViewController.h"

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
    RDAnnotPickerViewController *pickerViewController = [[RDAnnotPickerViewController alloc] initWithNibName:@"RDAnnotPickerViewController" bundle:nil];
    pickerViewController.colorBtn = self;
    [pickerViewController.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2f]];
    pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    pickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [m_vc presentViewController:pickerViewController animated:YES completion:nil];
    [self showViews];
}

- (void)showViews
{
    if ([m_vc.view isHidden]) {
        [m_vc.view setHidden:NO];
    } else {
        [m_vc.view setHidden:YES];
    }
    
}

- (void)setColor:(unsigned int)color :(Boolean)has_enable
{
    [self showViews];
    [self setColor:color :has_enable :m_vc];
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
    self.backgroundColor = [UIColor colorWithRed:clr[0] green:clr[1] blue:clr[2] alpha:clr[3]];
}
-(int)color
{
    return m_color;
}
@end
