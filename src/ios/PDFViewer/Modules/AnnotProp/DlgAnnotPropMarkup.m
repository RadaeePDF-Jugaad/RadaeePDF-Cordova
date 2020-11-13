//
//  DlgAnnotPropMarkup.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DlgAnnotPropMarkup.h"
#import "PDFObjc.h"
@implementation DlgAnnotPropMarkup
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

-(void)setAnnot:(PDFAnnot *)annot :(UIViewController *)vc;
{
    m_annot = annot;
    m_vc = vc;
    unsigned int color;
    if([m_annot type] == 9)
        color = [m_annot getFillColor];
    else
        color = [m_annot getStrokeColor];
    [mColor setColor: color:NO :m_vc];
    mAlpha.value = (color >> 24) / 255.0f;
    mLAlpha.text = [NSString stringWithFormat:@"%d",(color >> 24)];
    mLocked.selected = [m_annot isLocked];
}
-(void)updateAnnot
{
    unsigned int ia = 255 * mAlpha.value;
    unsigned int color = (mColor.color&0xFFFFFF)|(ia << 24);
    [m_annot setLocked:mLocked.selected];
    if (![m_annot isLocked]) {
        if([m_annot type] == 9)
            [m_annot setFillColor:color];
        else
            [m_annot setStrokeColor:color];
    }
}

- (IBAction)OnAlpha:(id)sender
{
    unsigned int ia = 255 * mAlpha.value;
    mLAlpha.text = [NSString stringWithFormat:@"%d",ia];
}

- (IBAction)OnLocked:(id)sender
{
    mLocked.selected = !mLocked.selected;
}

@end
