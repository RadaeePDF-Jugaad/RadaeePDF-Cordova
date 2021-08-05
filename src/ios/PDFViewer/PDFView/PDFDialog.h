//
//  PDFDialog.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import "UILShadowView.h"
#import <UIKit/UIKit.h>
@interface PDFDialogBG : UIView
{
    UIView *m_child;
}
- (id)init:(UIView *)child;
@end

typedef void(^func_cb)(BOOL);
@interface PDFDialog : UIViewController
{
    UIView *m_back;
    UIView *m_view;
    CGRect m_rect;
    BOOL m_ok;
    BOOL m_has_button;
    func_cb m_dismiss;
}
@property BOOL ok_pressed;
- (id)init:(UIView *)view :(CGRect)rect :(BOOL)has_button :(func_cb)dismiss;
- (void)dismiss;
- (UIView *)popView;
- (UIView *)buttonView;
@end
