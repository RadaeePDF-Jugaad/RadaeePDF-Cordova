//
//  PopColor.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopColor.h"
@implementation PopColor
-(void)setPara:(unsigned int)color :(Boolean)has_enable :(func_color)callback
{
    m_callback = callback;
    m_has_enable = has_enable;
    if(!m_has_enable)
    {
        mEnable.hidden = YES;
        mLEnable.hidden = YES;
    }
    m_color = color;
    CGFloat clr[4];
    clr[0] = ((m_color >> 16) & 0xff) / 255.0f;
    clr[1] = ((m_color >> 8) & 0xff) / 255.0f;
    clr[2] = (m_color & 0xff) / 255.0f;
    self.backgroundColor = [UIColor colorWithRed:clr[0] green:clr[1] blue:clr[2] alpha:1];
    mR.value = clr[0];
    mG.value = clr[1];
    mB.value = clr[2];
    if(m_has_enable)
    {
        int aval = ((m_color >> 24) & 0xff);
        if(aval)
            mEnable.selected = YES;
        else
            mEnable.selected = NO;
    }
}

-(IBAction)OnEnable:(id)sender
{
    if(!mEnable.selected)
        mEnable.selected = YES;
    else
        mEnable.selected = NO;
}

-(IBAction)OnOK:(id)sender
{
    if(mEnable.selected || !m_has_enable)
    {
        CGFloat r = mR.value;
        CGFloat g = mG.value;
        CGFloat b = mB.value;
        int ir = 255 * r;
        int ig = 255 * g;
        int ib = 255 * b;
        m_color = 0xFF000000|(ir << 16)|(ig << 8)|ib;
    }
    else
        m_color = 0;
    m_callback(YES, m_color);
}

-(IBAction)OnCancel:(id)sender
{
    m_callback(NO, 0);
}

-(IBAction)OnProgress:(id)sender
{
    CGFloat r = mR.value;
    CGFloat g = mG.value;
    CGFloat b = mB.value;
    self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end

