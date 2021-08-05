//
//  DlgPropComm.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "DlgAnnotPropComm.h"

@implementation DlgAnnotPropComm

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_has_fill = YES;
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_has_fill = YES;
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
    mLWidth.text = [NSString stringWithFormat:@"%.2f",[m_annot getStrokeWidth]];
    mLWidth.font = [UIFont systemFontOfSize:15];
    mLWidth.textAlignment = NSTextAlignmentCenter;
    [mLWidth addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [mLStyle setDash:NULL :0 :m_vc];
    unsigned int lcolor = [m_annot getStrokeColor];
    [mLColor setColor: lcolor:NO :m_vc];
    mFColor.tag = 1;
    if(m_has_fill) [mFColor setColor:[m_annot getFillColor] :YES :m_vc];
    mAlpha.value = (lcolor >> 24) / 255.0f;
    mLAlpha.text = [NSString stringWithFormat:@"%d",(lcolor >> 24)];
    mLocked.selected = [m_annot isLocked];
}

-(void)hasFill:(BOOL)has
{
    m_has_fill = has;
    mFColor.hidden = !has;
    mLFColor.hidden = !has;
}

-(void)updateAnnot
{
    unsigned int ia = 255 * mAlpha.value;
    unsigned int color = (mLColor.color&0xFFFFFFFF)|(ia << 24);
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
    [m_annot setStrokeWidth:lw];
    [m_annot setStrokeDash:dashf :dash_cnt];
    [m_annot setStrokeColor:color];
    if(m_has_fill && mFColor.color >> 24)
    {
        color = (mFColor.color&0xFFFFFFFF)|(ia << 24);
        [m_annot setFillColor:color];
    }
    [m_annot setLocked:mLocked.selected];
}

- (void)dismissKeyboard
{
    [mLWidth resignFirstResponder];
}


@end

