//
//  DlgAnnotPropLine.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DlgAnnotPropLine.h"
#import "PDFObjc.h"
@implementation DlgAnnotPropLine

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
    }
    return self;
}
-(IBAction)OnAlphaChanged:(id)sender
{
    unsigned int ia = 255 * mAlpha.value;
    mLAlpha.text = [NSString stringWithFormat:@"%d",ia];
}
-(IBAction)OnLock:(id)sender
{
    mLocked.selected = !mLocked.selected;
}

-(void)setAnnot:(PDFAnnot *)annot :(UIViewController *)vc
{
    m_annot = annot;
    m_vc = vc;
    mLWidth.text = [NSString stringWithFormat:@"%f",[m_annot getStrokeWidth]];
    [mLStyle setDash:NULL :0 :m_vc];
    unsigned int lcolor = [m_annot getStrokeColor];
    [mLColor setColor: lcolor:NO :m_vc];
    [mFColor setColor:[m_annot getFillColor] :YES :m_vc];
    int lhead = [m_annot getLineStyle];
    [mLStart setStyle:lhead & 0xffff :m_vc];
    [mLEnd setStyle:lhead >> 16 :m_vc];
    mAlpha.value = (lcolor >> 24) / 255.0f;
    mLAlpha.text = [NSString stringWithFormat:@"%d",(lcolor >> 24)];
    mLocked.selected = [m_annot isLocked];
}
-(void)updateAnnot
{
    unsigned int ia = 255 * mAlpha.value;
    unsigned int color = (mLColor.color&0xFFFFFF)|(ia << 24);
    CGFloat lw = [mLWidth.text floatValue];
    const CGFloat *dash = mLStyle.dash;
    float dashf[4];
    if(dash)
    {
        dashf[0] = dash[0];
        dashf[1] = dash[1];
        dashf[2] = dash[2];
        dashf[3] = dash[3];
    }
    int dash_cnt = mLStyle.dashCnt;
    [m_annot setLocked:mLocked.selected];
    if (![m_annot isLocked]) {
        [m_annot setStrokeWidth:lw];
        [m_annot setStrokeDash:dashf :dash_cnt];
        [m_annot setStrokeColor:color];
        if(mFColor.color >> 24)
        {
            color = (mFColor.color&0xFFFFFF)|(ia << 24);
            [m_annot setFillColor:color];
        }
        int lhead = mLStart.style | (mLEnd.style << 16);
        [m_annot setLineStyle:lhead];
    }
}
@end
