#import <Cordova/CDV.h>

@class RDPDFViewController;

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
    
    int bottomBar;
}

@property (nonatomic, retain) CDVInvokedUrlCommand *cdv_command;

@property (nonatomic) int viewMode;
@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;

- (void)pluginInitialize;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)activateLicense:(CDVInvokedUrlCommand*)command;
- (void)openFromAssets:(CDVInvokedUrlCommand*)command;

+ (RadaeePDFPlugin *)pluginInit;

+ (NSMutableArray *)loadBookmark;
+ (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfName;

//Settings

- (void)setPagingEnabled:(BOOL)enabled;
- (void)setDoublePageEnabled:(BOOL)enabled;
- (BOOL)setReaderViewMode:(int)mode;
- (void)toggleThumbSeekBar:(int)mode;
- (void)setColor:(int)color forFeature:(int)feature;

@end
