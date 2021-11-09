//
//  UILStyleView.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "../UILElement.h"
#import "../PDFView/PDFPopupCtrl.h"

typedef void(^func_lstyle)(const CGFloat *, int);
@interface UILStyleView : UIView
{
    CGFloat m_dashs[4];
    int m_dashs_cnt;
    func_lstyle m_callback;
}
-(id)init:(CGRect)frame :(func_lstyle)callback;
-(void)setDash:(const CGFloat *)dash :(int)dash_cnt;
@end

@interface UILStyleBtn : UILElement
{
    CGFloat m_dashs[4];
    int m_dashs_cnt;
    UIViewController *m_vc;
    PDFPopupCtrl *pop;
}

-(void)setDash:(const CGFloat *)dash :(int)dash_cnt :(UIViewController *)vc;
-(const CGFloat *)dash;
-(int)dashCnt;
@end
