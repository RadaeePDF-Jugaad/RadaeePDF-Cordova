//
//  PDFPopupCtrl.h
//  RDPDFReader
//
//  Created by Radaee on 2020/5/5.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once

#import <UIKit/UIKit.h>
@interface PDFPopupBG : UIView
{
    SEL OnDismiss;
    id Notifier;
    UIView *m_child;
}
- (id)init:(UIView *)child :(id)notifier :(SEL)dismiss;
@end

typedef void(^func_pop_dismiss)(void);
@interface PDFPopupCtrl : UIViewController
{
    UIView *m_back;
    UIView *m_view;
    CGRect m_rect;
    func_pop_dismiss m_dismiss;
}
- (id)init:(UIView *)view;
- (void)setDismiss:(func_pop_dismiss)dismiss;
- (void)dismiss;
@end
