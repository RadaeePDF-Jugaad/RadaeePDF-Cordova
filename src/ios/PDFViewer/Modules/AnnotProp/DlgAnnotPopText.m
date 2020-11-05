//
//  DlgPopText.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DlgAnnotPopText.h"
#import "PDFObjc.h"

@implementation DlgAnnotPopText
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
-(void)setAnnot:(PDFAnnot *)annot
{
    m_annot = annot;
    mSubj.text = [annot getPopupSubject];
    mText.text = [annot getPopupText];
}
-(NSString *)popSubject
{
    return mSubj.text;
}
-(NSString *)popText
{
    return mText.text;
}

@end
