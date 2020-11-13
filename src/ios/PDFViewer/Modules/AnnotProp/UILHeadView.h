//
//  UILHeadView.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
typedef void(^func_lhead)(int);
@interface UILHeadView : UIView
{
    int m_style;
    func_lhead m_callback;
}
-(id)init:(CGRect)frame :(func_lhead)callback;
-(void)setStyle:(int)style;
@end

@interface UILHeadBtn : UIView
{
    int m_style;
    UIViewController *m_vc;
}
-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithFrame:(CGRect)frame;
-(void)setStyle:(int)style :(UIViewController *)vc;
-(int)style;
@end
