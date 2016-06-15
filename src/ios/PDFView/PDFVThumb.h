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
#import "RDPDFViewController.h"

@protocol PDFVThumbDelegate <NSObject>
- (void)PDFVThumbOnPageClicked :(int) pageno;
@end

@interface PDFVThumb : UIView<PDFVInnerDel>
{
    PDFDoc *m_doc;
    PDFVThmb *m_view;
    
    NSTimer *m_timer;
    int m_w;
    int m_h;
    /*enum STATUS
    {
        sta_none,
        sta_hold,
        sta_zoom,
        sta_sel,
        sta_ink,
        sta_rect,
    };
     */
    enum STATUS m_status;
    NSTimeInterval m_tstamp;
    NSTimeInterval m_tstamp_tap;
    float m_tx;
    float m_ty;
    float m_px;
    float m_py;
    float m_swx[8];
    float m_swy[8];
    NSTimeInterval m_tstamp_swipe[8];
    float m_zoom_x;
    float m_zoom_y;
    struct PDFV_POS m_zoom_pos;
    float m_zoom_dis;
    float m_zoom_ratio;
    float m_scale;
    int m_swipe_dx;
    int m_swipe_dy;
    NSMutableArray* m_arrayTouch;
    NSString *nuri;
    id<PDFVThumbDelegate> m_delegate;
}

-(void)vOpenThumb:(PDFDoc *)doc;
//-(void)vOpenPage:(PDFDoc *)doc :(int)pageno :(float)x :(float)y;
-(void)vSetDelegate:(id<PDFVThumbDelegate>)delegate;
-(void)vGoto:(int)pageno;
-(void)vClose;
//invoke this method to set select mode, once you set this mode, you can select texts by touch and moving.

-(void)vGetPos:(struct PDFV_POS*)pos;
//invoke this method to set ink mode, once you set this mode, you can draw ink by touch and moving.

-(void)onSingleTap:(float)x :(float)y;
-(void)onSwipe:(float)dx :(float)dy;
-(void)refresh;

@end

