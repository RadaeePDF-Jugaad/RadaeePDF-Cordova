//
//  PDFView.h
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFObjc.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((rgbValue & 0xFF000000) >>  24))/255.0]

@class PDFPage;
@class PDFAnnot;
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
- (void)OnAnnotEditBox :(CGRect)annotRect :(NSString *)editText :(float)textSize;
- (void)OnAnnotCommboBox:(NSArray *)dataArray selected:(int)index;
- (void)OnAnnotList:(PDFAnnot *)annot items :(NSArray *)dataArray selectedIndexes:(NSArray *)indexes;
- (void)didTapAnnot:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point;

//touches delegate methods
- (void)touchesOnViewBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesOnViewMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesOnViewEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface PDFView : UIScrollView

@property (nonatomic) BOOL isCurling;

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
//get current annotation
-(PDFAnnot *)vGetCurrentAnnot;

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

-(void)vLockSide:(bool)lock;
	
//start find.
-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word;
//find it.
-(void)vFind:(int)dir;
//end find
-(void)vFindEnd;

//get position at left-top on the screen.
-(void)vGetPos :(struct PDFV_POS*)pos;
-(void)vGetPos :(struct PDFV_POS*)pos x:(int)x y:(int)y;
//set position to left-top on the screen;
-(void)vSetPos:(const struct PDFV_POS*)pos;

- (void)vUndo;
- (void)vRedo;

//goto page.
-(void)vGoto:(int)pageno;
//-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text;
-(PDFAnnot *)vGetTextAnnot :(int)x :(int)y;
-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text :(NSString *)subject;
- (int)vGetCurrentPage;
- (void)resetZoomLevel;

- (void)setCommboItem :(int)item;
- (void)setEditBoxWithText :(NSString *)text;

- (void)setReaderBackgroundColor:(int)color;
- (void)setFirstPageCover:(BOOL)cover;
- (void)setDoubleTapZoomMode:(int)mode;

- (CGImageRef )vGetImageForPage:(int)pg withSize:(CGSize)size withBackground:(BOOL)hasBackground;
- (float)getViewWidth;
- (float)getViewHeight;
- (BOOL)isCurlEnabled;

- (void)refreshCurrentPage;

- (BOOL)isModified;
- (void)setModified:(BOOL)modified force:(BOOL)force;

- (void)selectListBoxItems:(NSArray *)items;
- (BOOL)setSignatureImageAtIndex:(int)index atPage:(int)pageNum;

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (NSString *)getImageFromAnnot:(PDFAnnot *)annot;
- (NSString *)emptyAnnotWithSize:(CGSize)size;

- (BOOL)addAttachmentFromPath:(NSString *)path;
- (BOOL)forceSave;

- (BOOL)canSaveDocument;
- (void)setReadOnly:(BOOL)enabled;

#ifdef FTS_ENABLED
- (void)applyFTSOccurrence:(FTSOccurrence *)occurrence;
#endif

@end

