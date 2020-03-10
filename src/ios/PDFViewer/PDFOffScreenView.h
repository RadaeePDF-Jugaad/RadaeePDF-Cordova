//
//  PDFOffScreenView.h
//  PDFViewer
//
//  Created by Radaee on 2016/12/6.
//
//
#pragma once
#import "PDFObjc.h"
#import "RDVLayout.h"
#import "RDVSel.h"
#import "RDVFinder.h"

@protocol PDFOffScreenDelegate <NSObject>
-(void)onDrawOffScreen :(CGContextRef)ctx;
@end

@interface PDFOffScreenView : UIView
{
    id<PDFOffScreenDelegate> m_del;
}
-(id)initWithFrame:(CGRect)frame;
-(void)setDelegate :(id<PDFOffScreenDelegate>)del;
@end
