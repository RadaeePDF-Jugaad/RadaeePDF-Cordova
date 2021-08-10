//
//  DlgAnnotPropIcon.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/13.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "UIColorBtn.h"
#import "UIIconView.h"
#import "../UILShadowView.h"
@class PDFAnnot;
@interface DlgAnnotPropIcon : UILShadowView
{
    PDFAnnot *m_annot;
    UIViewController *m_vc;
    __weak IBOutlet UIIconBtn *mIcon;
    __weak IBOutlet UIColorBtn *mFColor;
    __weak IBOutlet UISlider *mAlpha;
    __weak IBOutlet UIButton *mLocked;
    __weak IBOutlet UILabel *mLAlpha;
}

-(IBAction)OnAlphaChanged:(id)sender;
-(IBAction)OnLock:(id)sender;
-(void)setAnnot:(PDFAnnot *)annot :(UIViewController *)vc;
-(void)updateAnnot;
@end
