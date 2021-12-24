//
//  PDFLayoutView.h
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//
#pragma once
#import "PDFObjc.h"
#import "RDVLayout.h"
#import "RDVFinder.h"
#import "PDFDelegate.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((rgbValue & 0xFF000000) >>  24))/255.0]

@protocol PDFLayoutDelegate <NSObject>
- (void)OnPageChanged :(int)pageno;
- (void)OnPageUpdated :(int)pageno;
- (void)OnLongPressed:(float)x :(float)y;
- (void)OnSingleTapped:(float)x :(float)y;
- (void)OnDoubleTapped:(float)x :(float)y;
- (void)OnFound:(bool)found;
- (void)OnSelStart:(float)x :(float)y;
- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2;
//enter annotation status.
- (void)OnAnnotClicked:(RDPDFAnnot *)annot :(CGRect)annotRect :(float)x :(float)y;
//notified when annotation status end.
- (void)OnAnnotEnd;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotMovie:(NSString *)fileName;
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)fileName;
- (void)OnAnnotEditBox:(RDPDFAnnot *)annot :(CGRect)annotRect :(NSString *)editText :(float)textSize;
- (void)OnAnnotCommboBox:(RDVPage *)vp :(RDPDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selected:(int)index;
- (void)OnAnnotList:(RDVPage *)vp :(RDPDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selectedIndexes:(NSArray *)indexes;
- (void)OnAnnotSignature:(RDVPage *)vp :(RDPDFAnnot *)annot;
- (void)OnAnnotTapped:(RDPDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point;
- (void)OnEditboxOK;
@end

@class RDPDFCanvas;
@interface PDFLayoutView : UIScrollView <UIScrollViewDelegate, PDFOffScreenDelegate, RDVLayoutDelegate, PDFJSDelegate>
{
    RDPDFDoc *m_doc;
    RDVLayout *m_layout;
    NSTimer *m_timer;
    enum LAYOUT_STATUS
    {
        sta_none,
        sta_zoom,
        sta_sel,
        sta_annot,
        sta_note,
        sta_ink,
        sta_rect,
        sta_ellipse,
        sta_line,
        sta_image,
        sta_editbox,
        sta_polygon,
        sta_polyline,
    };
    enum LAYOUT_STATUS m_status;
    float m_scale_pix;
    float m_zoom;
    RDVPos m_zoom_pos;
    CGPoint zoomPoint;
    UIView *m_child;
    RDPDFCanvas *m_canvas;
    id<PDFLayoutDelegate> m_del;
    bool m_modified;
    NSTimeInterval m_tstamp;
    NSTimeInterval m_tstamp_tap;
    float m_tx;
    float m_ty;
    float m_px;
    float m_py;
    int m_page_gap;
    
    int m_w;
    int m_h;
    int m_cur_page;
    
    RDVSel *m_sel;
    RDVPos m_sel_pos;
    
    RDPDFInk *m_ink;
    RDPDFPath *m_polygon;
    
    int m_annot_idx;
    RDPDFAnnot *m_annot;
    RDVPos m_annot_pos;
    PDF_RECT m_annot_rect;
    
    int m_note_cur;
    
    PDF_POINT *m_lines;
    int m_lines_cnt;
    int m_lines_max;
    bool m_lines_drawing;
    
    PDF_POINT *m_rects;
    int m_rects_cnt;
    int m_rects_max;
    bool m_rects_drawing;
    
    PDF_POINT *m_ellipse;
    int m_ellipse_cnt;
    int m_ellipse_max;
    bool m_ellipse_drawing;
    
    BOOL readOnlyEnabled;
    BOOL doublePage;
    
    UIImageView *imgAnnot;
    NSString *tmpImage;
    double lastAngle;
    
    BOOL isResizing;
    BOOL isRotating;
    
    int doubleTapZoomMode;
    int readerBackgroundColor;
    
    RDPDFPage *tappedPage;
    
    bool isDoubleTapping;
}

@property (nonatomic) NSUInteger singleViewPageNo;

-(id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
-(BOOL)PDFOpen :(RDPDFDoc *)doc :(int)page_gap :(RDPDFCanvas *)canvas :(id<PDFLayoutDelegate>) del;
-(void)PDFClose;
-(int)PDFGetVMode;
-(void)PDFSetVMode:(int)vmode;
-(void)PDFSaveView;
-(void)PDFRestoreView;

//start find.
-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word;
//find it.
-(void)vFind:(int)dir;
//end find
-(void)vFindEnd;


//invoke this method to set select mode, once you set this mode, you can select texts by touch and moving.
-(void)vSelStart;
//you should invoke this method in select mode.
-(NSString *)vSelGetText;
//you should invoke this method in select mode.
-(BOOL)vSelMarkup :(int)type;
//invoke this method to leave select mode
-(void)vSelEnd;

//enter text note annotation status.
-(bool)vNoteStart;
//end text note annotation status, and add note to page.
-(void)vNoteEnd;
-(void)vNoteCancel;


//enter ink annotation status.
-(bool)vInkStart;
//end ink annotation status.
-(void)vInkCancel;
//end ink annotation status, and add ink to page.
-(void)vInkEnd;

//enter ink annotation status.
-(bool)vPolygonStart;
//end ink annotation status.
-(void)vPolygonCancel;
//end ink annotation status, and add ink to page.
-(void)vPolygonEnd;

//enter ink annotation status.
-(bool)vPolylineStart;
//end ink annotation status.
-(void)vPolylineCancel;
//end ink annotation status, and add ink to page.
-(void)vPolylineEnd;

//enter line annotation status.
-(bool)vLineStart;
//end line annotation status.
-(void)vLineCancel;
//end line annotation status, and add line to page.
-(void)vLineEnd;

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

- (BOOL)vImageStart;
- (void)vImageCancel;
- (void)vImageEnd;
- (BOOL)useTempImage;

//enter editbox annotation status.
-(bool)vEditboxStart;
//end editbox annotation status.
-(void)vEditboxCancel;
//end editbox annotation status, and add rect to page.
-(void)vEditboxEnd;


//perform annotation actions, and end annotation status.
-(void)vAnnotPerform;
//remove annotation, and end annotation status.
-(void)vAnnotRemove;
//end annotation status.
-(void)vAnnotEnd;

//TextAnnot
- (RDPDFAnnot *)vGetTextAnnot:(int)x :(int)y;
- (void)vAddTextAnnot:(int)x :(int)y :(NSString *)text :(NSString *)subject;

- (void)vGetPos:(RDVPos *)pos;
- (void)vGetPos:(RDVPos *)pos x:(int)x y:(int)y;

-(void)vGoto:(int)pageno;
- (void)vUndo;
- (void)vRedo;
- (void)vClearOP;
- (void)PDFSetGBColor:(int)color;
- (void)setDoubleTapZoomMode:(int)mode;
- (void)vUpdateAnnotPage;
- (void)vUpdatePage:(int)pageno;
- (void)vUpdateRange;
- (CGFloat)vGetPixSize;

- (BOOL)isModified;
- (void)setModified:(BOOL)modified force:(BOOL)force;

//functions below is not standard behavious of PDFLayoutView.
- (BOOL)PDFSignField:(RDVPage *)vp :(RDPDFAnnot *)annot;
- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (NSString *)getImageFromAnnot:(RDPDFAnnot *)annot;
- (NSString *)emptyImageFromAnnot:(RDPDFAnnot *)annot;
- (NSString *)emptyAnnotWithSize:(CGSize)size;

- (BOOL)addAttachmentFromPath:(NSString *)path;
- (BOOL)canSaveDocument;
- (void)setReadOnly:(BOOL)enabled;
- (PDF_RECT)pdfRectFromScreenRect:(CGRect)screenRect;
- (CGPoint)screenPointsFromPdfPoints:(float)x :(float)y :(int)pageNum;
- (CGRect)screenRectFromPdfRect:(float)left :(float)top :(float)right :(float)bottom :(int)pageNum;
- (RDVFinder *)getView;
@end

