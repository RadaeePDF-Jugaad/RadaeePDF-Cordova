#import <Cordova/CDV.h>

@class RDPDFViewController;

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
- (void)didTapOnAnnotationOfType:(int)type atPage:(int)page atPoint:(CGPoint)point;
@end;

@interface RadaeePDFPlugin : CDVPlugin{
    CDVInvokedUrlCommand* cdv_command;
    RDPDFViewController *m_pdf;
    
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
    BOOL disableToolbar;
    
    int bottomBar;
}

@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_command;

@property (nonatomic) int viewMode;
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
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;

@property (nonatomic, assign) id <RadaeePDFPluginDelegate> delegate;

- (void)pluginInitialize;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)activateLicense:(CDVInvokedUrlCommand*)command;
- (void)openFromAssets:(CDVInvokedUrlCommand*)command;
- (void)openFromPath:(CDVInvokedUrlCommand*)command;
- (void)fileState:(CDVInvokedUrlCommand*)command;
- (void)getPageNumber:(CDVInvokedUrlCommand*)command;
- (void)getPageCount:(CDVInvokedUrlCommand*)command;
- (void)setThumbnailBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridBGColor:(CDVInvokedUrlCommand*)command;
- (void)setReaderBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridElementHeight:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridGap:(CDVInvokedUrlCommand*)command;
- (void)setThumbGridViewMode:(CDVInvokedUrlCommand*)command;
- (void)setTitleBGColor:(CDVInvokedUrlCommand*)command;
- (void)setIconsBGColor:(CDVInvokedUrlCommand*)command;
- (void)setThumbHeight:(CDVInvokedUrlCommand*)command;
- (void)setFirstPageCover:(CDVInvokedUrlCommand*)command;
- (void)setDoubleTapZoomMode:(CDVInvokedUrlCommand*)command;
- (void)setImmersive:(CDVInvokedUrlCommand*)command;
- (void)setReaderViewMode:(CDVInvokedUrlCommand*)command;
- (void)setToolbarEnabled:(CDVInvokedUrlCommand*)command;
- (void)extractTextFromPage:(CDVInvokedUrlCommand*)command;
- (void)encryptDocAs:(CDVInvokedUrlCommand *)command;

// Form Manager

- (void)JSONFormFields:(CDVInvokedUrlCommand*)command;
- (void)JSONFormFieldsAtPage:(CDVInvokedUrlCommand*)command;

- (void)setFormFieldWithJSON:(CDVInvokedUrlCommand *)command;

+ (RadaeePDFPlugin *)pluginInit;

// Bookmarks
- (void)addToBookmarks:(CDVInvokedUrlCommand *)command;//(NSString *)pdfPath page:(int)page label:(NSString *)label;
- (void)removeBookmark:(CDVInvokedUrlCommand *)command;//(int)page pdfPath:(NSString *)pdfPath;
- (void)getBookmarks:(CDVInvokedUrlCommand *)command;//(NSString *)pdfPath;

+ (NSString *)addToBookmarks:(NSString *)pdfPath page:(int)page label:(NSString *)label;
+ (void)removeBookmark:(int)page pdfPath:(NSString *)pdfPath;
+ (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfName withPath:(BOOL)withPath;

//Settings

- (void)setPagingEnabled:(BOOL)enabled;
- (void)setDoublePageEnabled:(BOOL)enabled;
- (void)toggleThumbSeekBar:(int)mode;
- (void)setColor:(int)color forFeature:(int)feature;

@end
