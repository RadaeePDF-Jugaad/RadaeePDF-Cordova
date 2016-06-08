//
//  PDFReaderCtrl.h
//  RDPDFReader
//
//  Created by Radaee on 2020/5/5.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "../PDFView/RDPDFView.h"
#import "../RDToolbar.h"
#import "SearchResultViewController.h"
#import "RDPopupTextViewController.h"
#import "../RDTreeTableViewController/RDTreeViewController.h"
//#import "PDFIOS.h"

@class PDFLayoutView;
@class PDFThumbView;
@class RDPDFDoc;

@protocol PDFReaderDelegate<NSObject>
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


@class PDFPopupCtrl;
@class MenuAnnotOp;
@interface PDFReaderCtrl : UIViewController
{
    PDFLayoutView *m_view;
    PDFThumbView *m_thumb;
    BOOL m_readonly;
    int m_page_no;
    int m_page_cnt;
    RDPDFDoc *m_doc;
    PDFPopupCtrl *m_popup;
    MenuAnnotOp *m_menu_op;
    UIMenuController *selectMenu;
    int m_annot_type;
    NSString *m_fstr;
    BOOL m_whole;
    BOOL m_case;
    BOOL showingThumb;
    BOOL findStart;
    
    UITapGestureRecognizer *searchTapNone;
    UITapGestureRecognizer *searchTapField;
}
@property (nonatomic, assign) id <PDFReaderDelegate> delegate;
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
@property (strong, nonatomic) UIImage *shareImage;
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
@property (strong, nonatomic) UIImage *metaImage;

@property (nonatomic) BOOL hideSearchImage;
@property (nonatomic) BOOL hideDrawImage;
@property (nonatomic) BOOL hideViewImage;
@property (nonatomic) BOOL hideThumbImage;
@property (nonatomic) BOOL hideMoreImage;

@property (strong, nonatomic) IBOutlet RDPDFView *mView;
@property (strong, nonatomic) IBOutlet RDPDFThumb *mThumb;
@property (strong, nonatomic) IBOutlet UIView *mSliderView;
@property (strong, nonatomic) IBOutlet UISlider *mSlider;
@property (strong, nonatomic) IBOutlet UILabel *mSliderLabel;
@property (strong, nonatomic) IBOutlet UIToolbar *mBarNoneTop;
@property (strong, nonatomic) IBOutlet RDToolbar *mBarNoneBottom;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBarThumbButton;
@property (strong, nonatomic) IBOutlet RDToolbar *mBarAnnot;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBarAnnotColorButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBarAnnotDoneButton;
@property (strong, nonatomic) IBOutlet UIToolbar *mBarSearchTop;
@property (strong, nonatomic) IBOutlet RDToolbar *mBarSearchBottom;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBarSearchResults;
@property (strong, nonatomic) IBOutlet UITextField *mSearchText;
@property (strong, nonatomic) IBOutlet UIButton *mSearchWhole;
@property (strong, nonatomic) IBOutlet UIButton *mSearchCase;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBtnBack;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBtnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBtnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBtnPrev;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mBtnNext;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *thumbHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mBarNoneBottomWidthConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *annotItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *thumbItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moreItem;

- (void)setDoc:(RDPDFDoc *)doc;
- (void)setDoc:(RDPDFDoc *)doc :(BOOL)readonly;
- (void)setDoc:(RDPDFDoc *)doc :(int)pageno :(BOOL)readonly;
- (RDPDFDoc *)getDoc;
- (void)PDFGoto:(int)pageno;
- (int)PDFCurPage;
- (void)setImmersive:(BOOL)immersive;
- (void)setDoubleTapZoomMode:(int)mode;
- (void)setThumbnailBGColor:(int)color;
- (void)setReaderBGColor:(int)color;
- (BOOL)addAttachmentFromPath:(NSString *)path;
- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
+ (bool)flatAnnotAtPage:(int)page doc:(RDPDFDoc *)doc;
- (bool)flatAnnots;
- (bool)saveDocumentToPath:(NSString *)path;
//- (void)updateAllPages;
- (void)updatePage:(int)pageno;
- (void)viewDidLoad;
- (void)closeView;
- (IBAction)back_pressed:(id)sender;
- (IBAction)mode_pressed:(id)sender;
- (IBAction)thumb_pressed:(id)sender;
- (IBAction)tool_pressed:(id)sender;
- (IBAction)annot_pressed:(id)sender;
- (IBAction)search_pressed:(id)sender;
- (IBAction)annot_ok:(id)sender;
- (IBAction)annot_cancel:(id)sender;
- (IBAction)annot_color:(id)sender;
- (IBAction)search_cancel:(id)sender;
- (IBAction)search_backward:(id)sender;
- (IBAction)search_forward:(id)sender;

- (CGPoint)pdfPointsFromScreenPoints:(int)x :(int)y;
- (CGPoint)screenPointsFromPdfPoints:(float)x :(float)y :(int)pageNum;
- (NSArray *)pdfRectFromScreenRect:(CGRect)screenRect;
- (CGRect)screenRectFromPdfRect:(float)top :(float)left :(float)right :(float)bottom :(int)pageNum;
@end
