//
//  DlgAnnotPropMarkup.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import "UIColorBtn.h"
#import "../UILShadowView.h"
@class RDPDFAnnot;
@interface DlgAnnotPropMarkup : UILShadowView
{
    RDPDFAnnot *m_annot;
    UIViewController *m_vc;
    __weak IBOutlet UIColorBtn *mColor;
    __weak IBOutlet UILabel *mLColor;
    __weak IBOutlet UISlider *mAlpha;
    __weak IBOutlet UILabel *mLLock;
    __weak IBOutlet UIButton *mLocked;
    __weak IBOutlet UILabel *mLAlpha;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setAnnot:(RDPDFAnnot *)annot :(UIViewController *)vc;
-(void)updateAnnot;
- (IBAction)OnAlpha:(id)sender;
- (IBAction)OnLocked:(id)sender;
@end
