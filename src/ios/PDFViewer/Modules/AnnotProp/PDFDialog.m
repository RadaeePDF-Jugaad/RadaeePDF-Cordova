//
//  PDFDialog.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PDFDialog.h"

@implementation PDFDialogBG
- (id)init:(UIView *)child
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        m_child = child;
        self.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2f];
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        //[self addGestureRecognizer:tap];
        [self addSubview:m_child];
    }
    return self;
}

/*
 -(void)tapAction:(UITapGestureRecognizer *)tap
 {
 CGPoint pt = [tap locationOfTouch:0 inView:self];
 NSString *str = [[NSString alloc] initWithFormat:@"%f, %f", pt.x, pt.y];
 NSLog(str);
 if(Notifier && !CGRectContainsPoint(rect, pt))
 }
 */
@end

@implementation PDFDialog
@synthesize ok_pressed = m_ok;
- (id)init:(UIView *)view :(CGRect)rect :(BOOL)has_button :(func_cb)dismiss
{
    self = [super init];
    if(self)
    {
        m_view = view;
        m_rect = rect;
        m_has_button = has_button;
        m_dismiss = dismiss;
        m_ok = NO;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

#define DLG_BUTTON_HEIGHT 30
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect rect = self.view.frame;
    if(m_has_button)
    {
        m_rect.origin.x = (rect.size.width - m_rect.size.width) * 0.5f;
        m_rect.origin.y = (rect.size.height - m_rect.size.height - DLG_BUTTON_HEIGHT) * 0.5f;
        [m_view setFrame:m_rect];
        [btn_ok setFrame:CGRectMake(m_rect.origin.x, m_rect.origin.y + m_rect.size.height, m_rect.size.width * 0.5f, DLG_BUTTON_HEIGHT)];
        [btn_cancel setFrame:CGRectMake(m_rect.origin.x + m_rect.size.width * 0.5f, m_rect.origin.y + m_rect.size.height, m_rect.size.width * 0.5f, DLG_BUTTON_HEIGHT)];
        [btn_ok.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn_cancel.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn_ok setTitle:@"OK" forState:UIControlStateNormal];
        [btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        btn_ok.backgroundColor = m_view.backgroundColor;
        btn_cancel.backgroundColor = m_view.backgroundColor;
        btn_ok.titleLabel.textColor = [UIColor blueColor];
        btn_cancel.titleLabel.textColor = [UIColor blueColor];
        btn_ok.hidden = NO;
        btn_cancel.hidden = NO;
    }
    else
    {
        m_rect.origin.x = (rect.size.width - m_rect.size.width) * 0.5f;
        m_rect.origin.y = (rect.size.height - m_rect.size.height) * 0.5f;
        [m_view setFrame:m_rect];
        btn_ok.hidden = YES;
        btn_cancel.hidden = YES;
    }
}

- (void)OnOK:(id)sender
{
    m_ok = YES;
    [self dismiss];
}

- (void)OnCancel:(id)sender
{
    [self dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_back = [[PDFDialogBG alloc] init:m_view];
    self.view = m_back;
    btn_ok = [[UIButton alloc] init];
    btn_cancel = [[UIButton alloc] init];
    [m_back addSubview:btn_ok];
    [m_back addSubview:btn_cancel];
    [btn_ok addTarget:self action:@selector(OnOK:) forControlEvents:UIControlEventTouchUpInside];
    [btn_cancel addTarget:self action:@selector(OnCancel:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if(m_dismiss) m_dismiss(m_ok);
}

@end
