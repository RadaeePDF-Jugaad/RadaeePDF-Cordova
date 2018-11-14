 //
//  RDPDFViewController.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFView.h"
#import "PDFIOS.h"
#import "PDFThumbView.h"
#import "PDFGridView.h"

@class TextAnnotViewController;
@class OutLineViewController;
@class PDFView;
@class PopupMenu;

@class PDFV;

// define the protocol for the delegate
@protocol RDPDFViewControllerDelegate<NSObject>
// define protocol functions that can be used in any class using this delegate
- (void)willShowReader;
- (void)didShowReader;
- (void)willCloseReader;
- (void)didCloseReader;
- (void)didChangePage:(int)page;
- (void)didSearchTerm:(NSString *)term found:(BOOL)found;
- (void)didTapOnPage:(int)page atPoint:(CGPoint)point;
- (void)didDoubleTapOnPage:(int)page atPoint:(CGPoint)point;
- (void)didLongPressOnPage:(int)page atPoint:(CGPoint)point;
- (void)didTapOnAnnotationOfType:(int)type atPage:(int)page atPoint:(CGPoint)point;
@end;

@interface RDPDFViewController : UIViewController <UISearchBarDelegate,UIPrintInteractionControllerDelegate,PDFViewDelegate>
{
    int posx;
    int posy;
    float begin_x;
    float begin_y;
    float end_x;
    float end_y;
    bool m_bSel;
    BOOL b_findStart;
    BOOL b_lock;
    BOOL b_sigleTap;
    BOOL statusBarHidden;
    
    CGRect recttoolbar;
    NSString *nuri;
    NSString *findString;
    NSMutableArray *tempfiles;
    
    PDFDoc *m_doc;
    PDFView *m_view;
    PDFThumbView *m_Thumbview;
    PDFGridView *m_Gridview;

    TextAnnotViewController *textAnnotVC;
    OutLineViewController *outlineView;
    
    //PDFAnnot begin
    PDFPage *PDFpage;
    PDFAnnot *PDFannot;
    float annot_x;
    float annot_y;
    //PDFAnnot end
    
    BOOL autoSave;
    BOOL b_keyboard;
    BOOL b_noteAnnot;
    
    float thumbViewHeight;
    
    BOOL defaultTranslucent;
    BOOL firstPageCover;
    BOOL isImmersive;
    BOOL readOnly;
    
    int gridBackgroundColor;
    int gridElementHeight;
    int gridGap;
    int gridMode;
    int doubleTapZoomMode;
    
    UISlider *m_slider;
}

#pragma mark - lib properties

@property (strong, nonatomic) UIImage *closeImage;
@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *addBookmarkImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rowImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *bitmapImage;
@property (strong, nonatomic) UIImage *noteImage;
@property (strong, nonatomic) UIImage *signatureImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *gridImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;
@property (strong, nonatomic) UIImage *undoImage;
@property (strong, nonatomic) UIImage *redoImage;
@property (strong, nonatomic) UIImage *performImage;
@property (strong, nonatomic) UIImage *moreImage;
@property (strong, nonatomic) UIImage *drawImage;
@property (strong, nonatomic) UIImage *selectImage;
@property (strong, nonatomic) UIImage *saveImage;

@property (nonatomic) BOOL hideSearchImage;
@property (nonatomic) BOOL hideDrawImage;
@property (nonatomic) BOOL hideSelImage;
@property (nonatomic) BOOL hideUndoImage;
@property (nonatomic) BOOL hideRedoImage;
@property (nonatomic) BOOL hideMoreImage;
@property (nonatomic) BOOL hideGridImage;

// define delegate property
@property (nonatomic, assign) id <RDPDFViewControllerDelegate> delegate;

#pragma mark - standard properties

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) int pagecount;
@property (assign, nonatomic) int pagenow;
@property (assign, nonatomic) BOOL b_keyboard;
@property (assign, nonatomic) PopupMenu* popupMenu;

-(IBAction)sliderValueChanged:(id)sender;
-(IBAction)sliderDragUp:(id)sender;
-(int)PDFOpen:(NSString *)path :(NSString *)pwd;
-(int)PDFOpen:(NSString *)path : (NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSaveEnabled author:(NSString *)author;
-(int)PDFOpenPage:(NSString *)path :(int)pageno : (float)x :(float)y :(NSString *)pwd;

-(int)PDFopenMem :(void *)data :(int)data_size :(NSString *)pwd;
-(int)PDFOpenStream :(id<PDFStream>)stream :(NSString *)password;
-(void)PDFGoto :(int)pageno;
-(void)PDFClose;
-(void)initbar :(int)pageno;
-(BOOL)isPortrait;
-(void)PDFThumbNailinit :(int)pageno;
- (void)PDFSeekBarInit:(int)pageno;
- (void)toggleGridView;

#pragma mark - lib methods

- (id)getDoc;
- (int)getCurrentPage;
- (CGImageRef)imageForPage:(int)pg;
- (void)setThumbnailBGColor:(int)color;
- (void)setThumbGridBGColor:(int)color;
- (void)setThumbGridElementHeight:(float)height;
- (void)setThumbGridGap:(float)gap;
- (void)setThumbGridViewMode:(int)mode;
- (void)setReaderBGColor:(int)color;
- (void)setThumbHeight:(float)height;
- (void)setFirstPageCover:(BOOL)cover;
- (void)setDoubleTapZoomMode:(int)mode;
- (void)setImmersive:(BOOL)immersive;
- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (BOOL)addAttachmentFromPath:(NSString *)path;
- (void)refreshCurrentPage;

// Form Manager

- (NSString *)getJSONFormFields;
- (NSString *)getJSONFormFieldsAtPage:(int)page;
- (NSString *)setFormFieldWithJSON:(NSString *)json;

@end
