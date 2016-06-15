//
//  PDFView.h
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "PDFV.h"

@protocol PDFThumbViewDelegate <NSObject>
- (void)OnPageClicked :(int) pageno;
@end

@interface PDFThumbView : UIScrollView<PDFVInnerDel, UIScrollViewDelegate>
{
    PDFDoc *m_doc;
    PDFVThmb *m_view;
    
    NSTimer *m_timer;
    int m_w;
    int m_h;
    enum THUMB_STATUS
    {
        tsta_none = 0,
        tsta_hold = 1,
    };
    enum THUMB_STATUS m_status;
    NSTimeInterval m_tstamp;
    NSTimeInterval m_tstamp_tap;
    float m_tx;
    float m_ty;
    float m_px;
    float m_py;
    float m_scale;
    id<PDFThumbViewDelegate> m_delegate;
}

-(void)vOpen:(PDFDoc *)doc :(id<PDFThumbViewDelegate>)delegate;
-(void)vGoto:(int)pageno;
-(void)vClose;
-(void)refresh;
@end

