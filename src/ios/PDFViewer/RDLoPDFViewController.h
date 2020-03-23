//
//  ViewController.h
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFLayoutView.h"
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PDFThumbView.h"
#import "PDFGridView.h"

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

@class TextAnnotViewController;
@class OutLineViewController;
@interface RDLoPDFViewController : UIViewController<PDFLayoutDelegate,UISearchBarDelegate,UIPrintInteractionControllerDelegate,PDFThumbViewDelegate>
{
    PDFLayoutView *m_view;
    PDFThumbView *m_Thumbview;
    UISlider *m_slider;
    //PDFGridView *m_Gridview;
    PDFDoc *m_doc;
    
    BOOL firstPageCover;
    BOOL isImmersive;
    BOOL readOnly;
    
    TextAnnotViewController *textAnnotVC;
    OutLineViewController *outlineView;
}

@property(nonatomic,strong) UILabel *pageNumLabel;

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

@property (nonatomic) BOOL hideSearchImage;
@property (nonatomic) BOOL hideDrawImage;
@property (nonatomic) BOOL hideSelImage;
@property (nonatomic) BOOL hideUndoImage;
@property (nonatomic) BOOL hideRedoImage;
@property (nonatomic) BOOL hideMoreImage;
@property (nonatomic) BOOL hideGridImage;

// define delegate property
@property (nonatomic, assign) id <RDPDFViewControllerDelegate> delegate;

- (int)PDFOpen:(NSString *)path : (NSString *)pwd;
- (int)PDFOpen:(NSString *)path : (NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSave author:(NSString *)author;
- (int)PDFOpenStream:(id<PDFStream>)stream :(NSString *)password;
- (int)PDFOpenMem:(void *)data :(int)data_size :(NSString *)pwd;
- (void)PDFGoto:(int)pageno;
- (void)closeView;

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
- (void)setToolbarColor:(int)color;
- (void)setToolbarTintColor:(int)color;
- (void)setThumbHeight:(float)height;
- (void)setFirstPageCover:(BOOL)cover;
- (void)setDoubleTapZoomMode:(int)mode;
- (void)setImmersive:(BOOL)immersive;
- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (BOOL)addAttachmentFromPath:(NSString *)path;
- (void)refreshCurrentPage;

- (bool)flatAnnotAtPage:(int)page doc:(PDFDoc *)doc;
- (bool)flatAnnots;
- (bool)saveDocumentToPath:(NSString *)path;

// Form Manager

- (NSString *)getJSONFormFields;
- (NSString *)getJSONFormFieldsAtPage:(int)page;
- (NSString *)setFormFieldWithJSON:(NSString *)json;
@end

