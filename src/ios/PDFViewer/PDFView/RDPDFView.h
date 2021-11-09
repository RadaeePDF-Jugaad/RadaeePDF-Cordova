//
//  PDFOffScreenView.h
//  PDFViewer
//
//  Created by Radaee on 2016/12/6.
//
//
#pragma once
#import "PDFDelegate.h"

@class RDVLayout;
@class RDVSel;
@class RDVFinder;

@class PDFLayoutView;
@interface RDPDFCanvas : UIView
{
    PDFLayoutView *m_view;
}
-(void)setView :(PDFLayoutView *)view;
@end

@interface RDPDFView : UIView
{
    PDFLayoutView *m_view;
    RDPDFCanvas *m_canvas;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(PDFLayoutView *)view;
-(RDPDFCanvas *)canvas;
@end

@interface RDPDFThumb :RDPDFView
{
}
@end
