//
//  DlgPropComm.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "UILStyleView.h"
#import "UIColorBtn.h"
#import "../UILShadowView.h"
@class RDPDFAnnot;
@interface DlgAnnotPropComm : UILShadowView
{
    RDPDFAnnot *m_annot;
    UIViewController *m_vc;
    BOOL m_has_fill;
    __weak IBOutlet UITextField *mLWidth;
    __weak IBOutlet UILabel *mLLWidth;
    __weak IBOutlet UILStyleBtn *mLStyle;
    __weak IBOutlet UILabel *mLLStyle;
    __weak IBOutlet UIColorBtn *mLColor;
    __weak IBOutlet UILabel *mLLColor;
    __weak IBOutlet UIColorBtn *mFColor;
    __weak IBOutlet UILabel *mLFColor;
    __weak IBOutlet UISlider *mAlpha;
    __weak IBOutlet UILabel *mLAlpha;
    __weak IBOutlet UIButton *mLocked;
    __weak IBOutlet UILabel *mLLock;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setAnnot:(RDPDFAnnot *)annot :(UIViewController *)vc;
-(void)hasFill:(BOOL)has;
-(void)updateAnnot;
-(IBAction)OnAlphaChanged:(id)sender;
-(IBAction)OnLock:(id)sender;
@end
