//
//  DlgAnnotPropLine.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "UILStyleView.h"
#import "UILHeadView.h"
#import "UIColorBtn.h"
#import "../UILShadowView.h"
@class RDPDFAnnot;
@interface DlgAnnotPropLine : UILShadowView
{
    RDPDFAnnot *m_annot;
    UIViewController *m_vc;
    __weak IBOutlet UITextField *mLWidth;
    __weak IBOutlet UILabel *mLLWidth;
    __weak IBOutlet UILStyleBtn *mLStyle;
    __weak IBOutlet UILabel *mLLStyle;
    __weak IBOutlet UIColorBtn *mLColor;
    __weak IBOutlet UILabel *mLLColor;
    __weak IBOutlet UIColorBtn *mFColor;
    __weak IBOutlet UILabel *mLFColor;
    __weak IBOutlet UILHeadBtn *mLStart;
    __weak IBOutlet UILabel *mLLStart;
    __weak IBOutlet UILHeadBtn *mLEnd;
    __weak IBOutlet UILabel *mLLEnd;
    __weak IBOutlet UISlider *mAlpha;
    __weak IBOutlet UILabel *mLAlpha;
    __weak IBOutlet UILabel *mLLock;
    __weak IBOutlet UIButton *mLocked;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setAnnot:(RDPDFAnnot *)annot :(UIViewController *)vc;
-(void)updateAnnot;
-(IBAction)OnAlphaChanged:(id)sender;
-(IBAction)OnLock:(id)sender;
@end
