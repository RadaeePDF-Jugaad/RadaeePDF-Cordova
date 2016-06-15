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
#import "NSObject+PerformBlock.h"

@protocol PDFViewDelegate <NSObject>
- (void)OnPageChanged :(int)pageno;
- (void)OnLongPressed:(float)x :(float)y;
- (void)OnSingleTapped:(float)x :(float)y;
- (void)OnDoubleTapped:(float)x :(float)y;
- (void)OnFound:(bool)found;
- (void)OnSelStart:(float)x :(float)y;
- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2;
//enter annotation status.
- (void)OnAnnotClicked:(PDFPage *)page :(PDFAnnot *)annot :(float)x :(float)y;
//notified when annotation status end.
- (void)OnAnnotEnd;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotPopup:(PDFAnnot *)annot :(NSString *)subj :(NSString *)text;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotMovie:(NSString *)fileName;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)fileName;
- (void)OnAnnotEditBox :(CGRect)annotRect :(NSString *)editText;
- (void)OnAnnotCommboBox:(NSArray *)dataArray;
@end

@interface PDFView : UIScrollView<PDFVInnerDel, UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    PDFDoc *m_doc;
    PDFV *m_view;
    PDFInk *m_ink;
    PDF_POINT *m_rects;
    PDF_POINT *m_ellipse;
    UIView *m_child;

	PDFAnnot *m_annot;
	struct PDFV_POS m_annot_pos;
	PDF_RECT m_annot_rect;
	
    int m_rects_cnt;
    int m_rects_max;
    bool m_rects_drawing;
    
    int m_ellipse_cnt;
    int m_ellipse_max;
    bool m_ellipse_drawing;
    
    int m_type;
    
    NSTimer *m_timer;
    bool m_modified;
    int m_w;
    int m_h;
    int m_cur_page;
    
    CGPoint zoomPoint;
    bool isDoubleTapping;
    
    BOOL pagingEnabled;
    BOOL doublePage;
    
    enum STATUS
    {
        sta_none,
        sta_zoom,
        sta_sel,
        sta_annot,
        sta_note,
        sta_ink,
        sta_rect,
        sta_ellipse,
    };
    enum STATUS m_status;
    NSTimeInterval m_tstamp;
    NSTimeInterval m_tstamp_tap;
    float m_tx;
    float m_ty;
    float m_px;
    float m_py;
    float m_zoom;
    struct PDFV_POS m_zoom_pos;
    float m_scale;
    id<PDFViewDelegate> m_delegate;
}

-(void)vOpen:(PDFDoc *)doc :(id<PDFViewDelegate>)delegate;
-(void)vClose;

//invoke this method to set select mode, once you set this mode, you can select texts by touch and moving.
-(void)vSelStart;
//you should invoke this method in select mode.
-(NSString *)vSelGetText;
//you should invoke this method in select mode.
-(BOOL)vSelMarkup:(int)color :(int)type;
//invoke this method to leave select mode
-(void)vSelEnd;

//perform annotation actions, and end annotation status.
-(void)vAnnotPerform;
//remove annotation, and end annotation status.
-(void)vAnnotRemove;
//end annotation status.
-(void)vAnnotEnd;

//enter ink annotation status.
-(bool)vNoteStart;
//end ink annotation status, and add ink to page.
-(void)vNoteEnd;

//enter ink annotation status.
-(bool)vInkStart;
//end ink annotation status.
-(void)vInkCancel;
//end ink annotation status, and add ink to page.
-(void)vInkEnd;

//enter rect annotation status.
-(bool)vRectStart;
//end rect annotation status.
-(void)vRectCancel;
//end rect annotation status, and add rect to page.
-(void)vRectEnd;

//enter ellipse annotation status.
-(bool)vEllipseStart;
//end ellipse annotation status.
-(void)vEllipseCancel;
//end ellipse annotation status, and add ellipse to page.
-(void)vEllipseEnd;

-(void)vLockSide:(bool)lock;
	
//start find.
-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word;
//find it.
-(void)vFind:(int)dir;
//end find
-(void)vFindEnd;

//get position at left-top on the screen.
-(void)vGetPos :(struct PDFV_POS*)pos;
//set position to left-top on the screen;
-(void)vSetPos:(const struct PDFV_POS*)pos;

//goto page.
-(void)vGoto:(int)pageno;
//-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text;
-(PDFAnnot *)vGetTextAnnot :(int)x :(int)y;
-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text;
- (int)vGetCurrentPage;
- (void)resetZoomLevel;

- (void)setCommboItem :(int)item;
- (void)setEditBoxWithText :(NSString *)text;

@end

