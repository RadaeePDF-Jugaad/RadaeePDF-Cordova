#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "../PDFLayout/RDVGlobal.h"
#import "../PDFReader/RDMetaDataViewController.h"
#import "../PDFReader/DlgAnnotPropMarkup.h"
#import "../PDFReader/DlgAnnotPropIcon.h"
#import "../PDFReader/DlgAnnotPropComm.h"
#import "../PDFReader/DlgAnnotPropLine.h"
#import "../PDFReader/UIColorBtn.h"
#import "../RDToolbar.h"
#import "../PDFReader/PDFReaderCtrl.h"
#import "../PDFPages/PDFPagesCtrl.h"
#import "../PDFPages/PDFPagesView.h"
#import "../PDFPages/UIPageCellView.h"

@class PDFDoc;
@class PDFReaderCtrl;
@class RDPageViewController;

// define the protocol for the delegate
@protocol RadaeePDFPluginDelegate
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
- (void)onAnnotExported:(NSString *)path;
@end;

@interface RadaeePDFPlugin : NSObject{
    PDFReaderCtrl *m_pdf;
    RDPageViewController *m_pdfP;
    
    NSURLConnection *pdfConn;
    NSString *url;
    NSMutableData *receivedData;
    void *buffer;
    
    //colors
    int inkColor;
    int rectColor;
    int underlineColor;
    int strikeoutColor;
    int highlightColor;
    int ovalColor;
    int selColor;
    int arrowColor;
    
    int thumbBackgroundColor;
    int gridBackgroundColor;
    int readerBackgroundColor;
    int titleBackgroundColor;
    int iconsBackgroundColor;
    
    float thumbHeight;
    int gridElementHeight;
    int gridGap;
    int gridMode;
    
    int doubleTapZoomMode;
    
    BOOL firstPageCover;
    BOOL isImmersive;
    
    int bottomBar;
}

@property (strong, nonatomic) NSString *lastOpenedPath;
@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *gridImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *exportImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;

+ (RadaeePDFPlugin *)pluginInit;
- (id)show:(NSString *)file withPassword:(NSString *)password;
- (id)show:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave;
- (id)show:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author;
- (void)activateLicenseWithBundleId:(NSString *)bundleId company:(NSString *)company email:(NSString *)email key:(NSString *)key licenseType:(int)type;
- (id)openFromAssets:(NSString *)file withPassword:(NSString *)password;
- (id)openFromAssets:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave;
- (id)openFromAssets:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author;
- (id)openFromPath:(NSString *)path withPassword:(NSString *)password;
- (id)openFromPath:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author;
- (id)openFromMem:(NSData *)data withPassword:(NSString *)password;
- (NSString *)fileState;
- (int)getPageNumber;
- (int)getPageCount;
- (void)setThumbnailBGColor:(int)color;
- (void)setThumbGridBGColor:(int)color;
- (void)setReaderBGColor:(int)color;
- (void)setThumbGridElementHeight:(float)height;
- (void)setThumbGridGap:(float)gap;
- (void)setThumbGridViewMode:(int)mode;
- (void)setTitleBGColor:(int)color;
- (void)setIconsBGColor:(int)color;
- (void)setThumbHeight:(float)height;
- (void)setFirstPageCover:(BOOL)cover;
- (void)setDoubleTapZoomMode:(int)mode;
- (void)setImmersive:(BOOL)immersive;
- (BOOL)setReaderViewMode:(int)mode;
- (NSString *)extractTextFromPage:(int)pageNum;
- (BOOL)encryptDocAs:(NSString *)path userPwd:(NSString *)userPwd ownerPwd:(NSString *)ownerPwd permission:(int)permission method:(int)method idString:(NSString *)idString;
- (BOOL)addAnnotAttachment:(NSString *)path;
- (BOOL)renderAnnotToFile:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (BOOL)flatAnnots;
- (BOOL)flatAnnotAtPage:(int)pageno;
- (BOOL)saveDocumentToPath:(NSString *)path;

// Form Manager

- (NSString *)getJSONFormFields;
- (NSString *)getJSONFormFieldsAtPage:(int)page;
- (NSString *)setFormFieldWithJSON:(NSString *)json;

+ (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfName withPath:(BOOL)withPath;

// Bookmarks
+ (NSString *)addToBookmarks:(NSString *)pdfPath page:(int)page label:(NSString *)label;
+ (void)removeBookmark:(int)page pdfPath:(NSString *)pdfPath;
+ (NSString *)getBookmarks:(NSString *)pdfPath;

//Settings

- (void)setPagingEnabled:(BOOL)enabled;
- (void)setDoublePageEnabled:(BOOL)enabled;
- (void)toggleThumbSeekBar:(int)mode;
- (void)setColor:(int)color forFeature:(int)feature;

// Delegate
- (void)setDelegate:(id)myDelegate;

- (void)refreshCurrentPage;
- (id)getGlobal;

//get text & markup annot details
- (NSString *)getTextAnnotationDetails:(int)pageNum;
- (NSString *)getMarkupAnnotationDetails:(int)pageNum;

//add text annot
- (void)addTextAnnotation:(int)pageNum :(float)x :(float)y :(NSString *)text :(NSString *)subject;

//get char indexes and add markup annot
- (int)getCharIndex:(int)pageNum :(float)x :(float)y;
- (void)addMarkupAnnotation:(int)pageNum :(int)type :(int)index1 :(int)index2;

//get screen points from pdf points
- (NSString *)getPDFCoordinates:(int)x :(int)y;
- (NSString *)getScreenCoordinates:(int)x :(int)y :(int)pageNum;
- (NSString *)getPDFRect:(float)x :(float)y :(float)width :(float)height;
- (NSString *)getScreenRect:(float)left :(float)top :(float)right :(float)bottom :(int)pageNum;

@end
