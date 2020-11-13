//
//  UIColorBtn.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
@interface UIColorBtn : UIView
{
    unsigned int m_color;
    Boolean m_has_enable;
    UIViewController *m_vc;
}
-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithFrame:(CGRect)frame;
-(void)setColor:(unsigned int)color :(Boolean)has_enable :(UIViewController *)vc;
-(int)color;
@end
