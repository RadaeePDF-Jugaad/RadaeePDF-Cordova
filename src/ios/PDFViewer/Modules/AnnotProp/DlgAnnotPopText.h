//
//  DlgPopText.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
@class PDFAnnot;
@interface DlgAnnotPopText : UIView
{
    PDFAnnot *m_annot;
    __weak IBOutlet UITextField *mSubj;
    __weak IBOutlet UITextView *mText;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setAnnot:(PDFAnnot *)annot;
-(NSString *)popSubject;
-(NSString *)popText;
@end
