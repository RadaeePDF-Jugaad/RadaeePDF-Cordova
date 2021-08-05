//
//  DlgAnnotPropIcon.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/13.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "DlgAnnotPropIcon.h"

@implementation DlgAnnotPropIcon

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
    m_vc = vc;
    m_annot = annot;
    [mIcon setIcon:m_annot :m_vc];
    
    unsigned int fcolor = [m_annot getFillColor];
    mFColor.tag = 1;
    [mFColor setColor:fcolor :YES :m_vc];
    mAlpha.value = (fcolor >> 24) / 255.0f;
    mLAlpha.text = [NSString stringWithFormat:@"%d",(fcolor >> 24)];
    mLocked.selected = [m_annot isLocked];
}

-(void)updateAnnot
{
    unsigned int ia = 255 * mAlpha.value;
    unsigned int color = (mFColor.color&0xFFFFFFFF)|(ia << 24);
    [m_annot setFillColor:color];
    [m_annot setLocked:mLocked.selected];
    [m_annot setIcon:[mIcon icon]];
}

@end
