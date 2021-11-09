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

#define DLG_BUTTON_HEIGHT 40
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect rect = self.view.frame;
    if(m_has_button)
    {
        m_rect.origin.x = (rect.size.width - m_rect.size.width) * 0.5f;
        m_rect.origin.y = (rect.size.height - m_rect.size.height - 50) * 0.5f;
        [m_view setFrame:m_rect];
    }
    else
    {
        m_rect.origin.x = (rect.size.width - m_rect.size.width) * 0.5f;
        m_rect.origin.y = (rect.size.height - m_rect.size.height) * 0.5f;
        [m_view setFrame:m_rect];
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
    if ([m_view isKindOfClass:[UILShadowView class]]) {
           [[(UILShadowView *)m_view buttonView] setHidden:!m_has_button];
           if (m_has_button) {
               [[(UILShadowView *)m_view okButton] addTarget:self action:@selector(OnOK:) forControlEvents:UIControlEventTouchUpInside];
               [[(UILShadowView *)m_view cancelButton] addTarget:self action:@selector(OnCancel:) forControlEvents:UIControlEventTouchUpInside];
           }
       }
    m_back = [[PDFDialogBG alloc] init:m_view];
    self.view = m_back;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnCancel:)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if(m_dismiss) m_dismiss(m_ok);
}

- (UIView *)popView {
    return m_view;
}

@end
