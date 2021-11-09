//
//  PDFPopupCtrl.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/5.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFPopupCtrl.h"

@implementation PDFPopupBG
- (id)init:(UIView *)child :(id)notifier :(SEL)dismiss
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        Notifier = notifier;
        OnDismiss = dismiss;
        m_child = child;
        self.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        //[self addGestureRecognizer:tap];
        [self addSubview:m_child];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint point = [touch locationInView:self];
    CGRect rect = m_child.frame;
    if(Notifier && !CGRectContainsPoint(rect, point))
        [Notifier performSelector:OnDismiss withObject:self afterDelay:0];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    CGPoint point = [touch locationInView:self];
    CGRect rect = m_child.frame;
    if(Notifier && !CGRectContainsPoint(rect, point))
        [Notifier performSelector:OnDismiss withObject:self afterDelay:0];
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

@implementation PDFPopupCtrl
- (id)init:(UIView *)view
{
    self = [super init];
    if(self)
    {
        m_view = view;
        m_rect = m_view.frame;
        m_dismiss = nil;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return self;
}
- (void)viewDidLayoutSubviews
{
    if(m_rect.size.width > 0 && m_rect.size.height > 0)
        m_view.frame = m_rect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_back = [[PDFPopupBG alloc] init:m_view :self :@selector(onDismiss:)];
    self.view = m_back;
}

- (void)viewDidAppear:(BOOL)animated {
    if ([m_view isKindOfClass:[UITextField class]] || [m_view isKindOfClass:[UITextView class]]) {
        [m_view becomeFirstResponder];
    }
}

- (void)setDismiss:(func_pop_dismiss)dismiss
{
    m_dismiss = dismiss;
}

- (void)onDismiss :(PDFPopupBG *)bg
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (m_dismiss) m_dismiss();
}
- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (m_dismiss) m_dismiss();
}

@end
