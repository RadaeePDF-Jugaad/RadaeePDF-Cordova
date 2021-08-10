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
@class PDFAnnot;
@interface DlgAnnotPropLine : UILShadowView
{
    PDFAnnot *m_annot;
    UIViewController *m_vc;
    __weak IBOutlet UITextField *mLWidth;
    __weak IBOutlet UILStyleBtn *mLStyle;
    __weak IBOutlet UIColorBtn *mLColor;
    __weak IBOutlet UIColorBtn *mFColor;
    __weak IBOutlet UILHeadBtn *mLStart;
    __weak IBOutlet UILHeadBtn *mLEnd;
    __weak IBOutlet UISlider *mAlpha;
    __weak IBOutlet UILabel *mLAlpha;
    __weak IBOutlet UIButton *mLocked;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setAnnot:(PDFAnnot *)annot :(UIViewController *)vc;
-(void)updateAnnot;
-(IBAction)OnAlphaChanged:(id)sender;
-(IBAction)OnLock:(id)sender;
@end
