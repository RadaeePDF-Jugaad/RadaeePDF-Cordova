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
#import "OutLineViewController.h"
#import <CoreData/CoreData.h>
#import "TextAnnotViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PDFThumbView.h"
#import "BookmarkTableViewController.h"
#import "RadaeePDFPlugin.h"
#import "RDFormManager.h"
#import "RDMoreTableViewController.h"
#import "RDAnnotListViewController.h"

@class OutLineViewController;
@class PDFView;
@class PopupMenu;
@class PDFV;

// define the protocol for the delegate
@protocol RDPDFViewControllerDelegate
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

//---------------------------------------------------------
/*
 Author: Emanuele
 Date last update: 01/12/16
 Note: Aggiunta la possibilità di nascondere le icone della
 toolbar
 */
//---------------------------------------------------------

@interface RDPDFViewController : UIViewController <UISearchBarDelegate,saveTextAnnotDelegate,PDFViewDelegate,BookmarkTableViewDelegate,UIPrintInteractionControllerDelegate>
{
    BOOL defaultTranslucent;
    BOOL firstPageCover;
    BOOL isImmersive;
    BOOL readOnly;
    
    int gridBackgroundColor;
    int gridElementHeight;
    int gridGap;
    int gridMode;
    int doubleTapZoomMode;
    
    float thumbHeight;
    
    //GEAR
    MPMoviePlayerViewController *mpvc;
    //FINE
    PDFView *m_view;
    PDFThumbView *m_Thumbview;
    PDFThumbView *m_Gridview;
    UISlider *m_slider;
    PDFDoc *m_doc;
    BOOL b_findStart;
    CGRect recttoolbar;
    NSString *findString;
    BOOL b_lock;
    OutLineViewController *outlineView;
    BOOL b_sigleTap;
    PopupMenu* popupMenu1;
    PopupMenu* popupMenu2;

    NSString *nuri;
    //popup view
    float begin_x;
    float begin_y;
    float end_x;
    float end_y;
    bool m_bSel;
    
    BOOL statusBarHidden;
    BOOL alreadySelected;
    
    int posx;
    int posy;
    TextAnnotViewController *textAnnotVC;
    NSMutableArray *tempfiles;
    UIToolbar *annotToolBar;
    
    //PDFAnnot begin
    PDFPage *PDFpage;
    PDFAnnot *PDFannot;
    float annot_x;
    float annot_y;
    //PDFAnnot end
    
    BOOL b_keyboard;
    BOOL b_noteAnnot;
}

#pragma mark - lib features

@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *bookmarkListImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *gridImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;
@property (strong, nonatomic) UIImage *performImage;
@property (strong, nonatomic) UIImage *drawImage;
@property (strong, nonatomic) UIImage *selImage;
@property (strong, nonatomic) UIImage *undoImage;
@property (strong, nonatomic) UIImage *redoImage;
@property (strong, nonatomic) UIImage *moreImage;

@property (nonatomic) BOOL hideViewModeImage;
@property (nonatomic) BOOL hideSearchImage;
@property (nonatomic) BOOL hideBookmarkImage;
@property (nonatomic) BOOL hideBookmarkListImage;
@property (nonatomic) BOOL hideOutlineImage;
@property (nonatomic) BOOL hideLineImage;
@property (nonatomic) BOOL hideRectImage;
@property (nonatomic) BOOL hideEllipseImage;
@property (nonatomic) BOOL hidePrintImage;
@property (nonatomic) BOOL hideGridImage;
@property (nonatomic) BOOL hideDrawImage;
@property (nonatomic) BOOL hideSelImage;
@property (nonatomic) BOOL hideUndoImage;
@property (nonatomic) BOOL hideRedoImage;
@property (nonatomic) BOOL hideMoreImage;

// define delegate property
@property (nonatomic, assign) id <RDPDFViewControllerDelegate> delegate;

#pragma mark - standard properties

@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UIToolbar *searchToolBar;
@property (strong,nonatomic) UIToolbar *drawLineToolBar;
@property (strong,nonatomic) UIToolbar *drawRectToolBar;
@property (strong,nonatomic) UIMenuController *selectMC;
@property (strong,nonatomic) UIMenuItem *textCopy;
@property (strong,nonatomic) UILabel *confirmedCopy;
@property (strong,nonatomic) UIMenuItem *underline;
@property (strong,nonatomic) UIMenuItem *highline;
@property (strong,nonatomic) UIMenuItem *strike;
@property (strong,nonatomic) UIWindow *window;
@property (strong,nonatomic) UIAlertController *moreItemsContainer;
@property (strong,nonatomic) UIBarButtonItem *moreButton;
@property (strong,nonatomic) UIBarButtonItem *drawButton;
@property (strong,nonatomic) UIBarButtonItem *selButton;
@property (strong,nonatomic) UIBarButtonItem *viewModeButton;
@property (strong, nonatomic) IBOutlet UISearchBar* m_searchBar;
@property (strong,nonatomic)IBOutlet UISlider *sliderBar;
@property (strong,nonatomic)IBOutlet UILabel *pageNumLabel;
@property (assign, nonatomic)int pagecount;
@property (assign, nonatomic)int pagenow;
@property (assign,nonatomic) PopupMenu* popupMenu;
- (IBAction)composeFile:(id) sender;
- (IBAction)searchView:(id) sender;
- (IBAction)drawLine:(id) sender;
- (IBAction)drawRect:(id) sender;
-(IBAction)drawEllipse:(id)sender;
- (IBAction)viewMenu:(id) sender;
-(IBAction)lockView:(id)sender;
-(IBAction)searchCancel:(id)sender;
-(IBAction)prevword:(id)sender;
-(IBAction)nextword:(id)sender;

-(IBAction)drawLineDone:(id)sender;
-(IBAction)drawLineCancel:(id)sender;

-(IBAction)drawRectDone:(id)sender;
-(IBAction)drawRectCancel:(id)sender;

-(IBAction)drawEllipseDone:(id)sender;
-(IBAction)drawEllipseCancel:(id)sender;

-(IBAction)sliderValueChanged:(id)sender;
-(IBAction)sliderDragUp:(id)sender;
-(int)PDFOpen:(NSString *)path :(NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSaveEnabled;
-(int)PDFOpenPage:(NSString *)path :(int)pageno : (float)x :(float)y :(NSString *)pwd;

//for test
-(int)PDFopenMem : (void *)data : (int)data_size :(NSString *)pwd;
-(int)PDFOpenStream :(id<PDFStream>)stream :(NSString *)password;

//-(int)openStream:(id<PDFStream>)stream : (NSString *)password;
-(void)PDFGoto:(int)pageno;
-(void)PDFClose;
-(void)initbar :(int) pageno;
-(BOOL)isPortrait;
-(void)PDFThumbNailinit:(int) pageno;
- (void)PDFSeekBarInit:(int)pageno;

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

- (void)refreshCurrentPage;

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;

- (BOOL)addAttachmentFromPath:(NSString *)path;

//GEAR
- (void)moviePlayedDidFinish:(NSNotification *)notification;
//END
@end
