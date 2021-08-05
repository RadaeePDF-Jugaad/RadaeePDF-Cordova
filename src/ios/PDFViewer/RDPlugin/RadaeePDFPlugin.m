//
//  AlmaZBarReaderViewController.h
//  Paolo Messina
//
//  Created by Paolo Messina on 06/07/15.
//
//

#import "RadaeePDFPlugin.h"
#import "RDPageViewController.h"
#import "PDFHttpStream.h"
#import "RDFormManager.h"
#import "RDVGlobal.h"
#import "PDFIOS.h"

#pragma mark - Synthesize

@interface RadaeePDFPlugin() <PDFReaderDelegate> {
    id <RadaeePDFPluginDelegate> delegate;
}

@end

@implementation RadaeePDFPlugin

#pragma mark - Cordova Plugin

+ (RadaeePDFPlugin *)pluginInit
{
    RadaeePDFPlugin *r = [[RadaeePDFPlugin alloc] init];
    [r pluginInitialize];
    
    return r;
}

- (void)pluginInitialize
{
    inkColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"InkColor"];
    rectColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RectColor"];
    underlineColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UnderlineColor"];
    strikeoutColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"StrikeoutColor"];
    highlightColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"HighlightColor"];
    ovalColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"OvalColor"];
    selColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SelColor"];
    arrowColor = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"ArrowColor"];
}

#pragma mark - Plugin API

- (id)show:(NSString *)file withPassword:(NSString *)password
{
    return [self show:file atPage:0 withPassword:password readOnly:NO autoSave:NO];
}

- (id)show:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave {
    return [self show:file atPage:0 withPassword:password readOnly:NO autoSave:NO author:@""];
}

- (id)show:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author
{
    if (!file)
        return nil;
    
    // Get user parameters
    url = file;
    
    if([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]){
        
        NSString *cacheFile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cacheFile.pdf"];
        
        PDFHttpStream *httpStream = [[PDFHttpStream alloc] init];
        [httpStream open:url :cacheFile];
        
        [self readerInit];
        PDFDoc *doc = [[PDFDoc alloc] init];
        int result = [doc openStream:httpStream :password];
        if(!result) [m_pdf setDoc:doc :page :readOnly];
        
        NSLog(@"%d", result);
        if(result != err_ok && result != err_open){
            return nil;
        }
        
        return [self showReader];
        
    } else {
        if ([url containsString:@"file://"]) {
            NSString *filePath = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                filePath = [documentsDirectory stringByAppendingPathComponent:filePath];
            }
            
            return [self openPdf:filePath atPage:page withPassword:password readOnly:readOnly autoSave:autoSave author:author data:nil];
        } else {
            return [self openFromPath:url atPage:page withPassword:password readOnly:readOnly autoSave:autoSave author:author];
        }
    }
    
}

- (id)openFromAssets:(NSString *)file withPassword:(NSString *)password
{
    return [self openFromAssets:file atPage:0 withPassword:password readOnly:NO autoSave:NO];
}

- (id)openFromAssets:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave {
    return [self openFromAssets:file atPage:0 withPassword:password readOnly:NO autoSave:NO author:@""];
}

- (id)openFromAssets:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author {
    if (!file)
        return nil;
    
    // Get user parameters
    url = file;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:url ofType:nil];
    
    return [self openPdf:filePath atPage:page withPassword:password readOnly:readOnly autoSave:autoSave author:author data:nil];
}

- (id)openFromMem:(NSData *)data withPassword:(NSString *)password
{
    return [self openPdf:nil atPage:0 withPassword:password readOnly:NO autoSave:NO author:@"" data:data];
}

- (id)openFromPath:(NSString *)path withPassword:(NSString *)password
{
    // Get user parameters
    url = path;
    
    NSString *filePath = url;
    
    return [self openPdf:filePath atPage:0 withPassword:password readOnly:NO autoSave:NO author:@"" data:nil];
}

- (id)openFromPath:(NSString *)file atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author {
    return [self openPdf:file atPage:page withPassword:password readOnly:readOnly autoSave:autoSave author:author data:nil];
}

- (id)openPdf:(NSString *)filePath atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave author:(NSString *)author data:(NSData *)data
{
    GLOBAL.g_author = (author) ? author : @"";
    
    NSLog(@"File Path: %@", filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    _lastOpenedPath = filePath;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"fileStat"];
    
    [self readerInit];
    
    int result = 0;
    
    //Open PDF from Mem demo
    if (data != nil) {
        const char *path1 = [filePath UTF8String];
        FILE *file1 = fopen(path1, "rb");
        fseek(file1, 0, SEEK_END);
        long filesize1 = ftell(file1);
        fseek(file1, 0, SEEK_SET);
        buffer = malloc((filesize1)*sizeof(char));
        fread(buffer, filesize1, 1, file1);
        fclose(file1);
        
        //Open PDF file
        PDFDoc *doc = [[PDFDoc alloc] init];
        int result = [doc openMem:buffer :(int)filesize1 :nil];
        if(!result) [m_pdf setDoc:doc :page :readOnly];
    } else if ([self isPageViewController]) {
        //Set PDF file
        int result = [m_pdfP PDFOpenAtPath:filePath withPwd:password];

        if(result == 1)
        {
            m_pdfP.hidesBottomBarWhenPushed = YES;
        }
    } else {
        PDFDoc *doc = [[PDFDoc alloc] init];
        int result = [doc open:filePath :password];
        if(!result)
        {
            GLOBAL.g_author = author;
            GLOBAL.g_pdf_path = [[filePath stringByDeletingLastPathComponent] mutableCopy];
            GLOBAL.g_pdf_name = [[filePath lastPathComponent] mutableCopy];
            GLOBAL.g_save_doc = autoSave;
            [m_pdf setDoc:doc :page :readOnly];
        }
    }
    
    NSLog(@"%d", result);
    if(result != err_ok && result != err_open){
        return nil;
    }
    
    if ([self isPageViewController]) return [self showCurlingReader];
    return [self showReader];
}


- (void)activateLicenseWithBundleId:(NSString *)bundleId company:(NSString *)company email:(NSString *)email key:(NSString *)key licenseType:(int)type
{
    [self pluginInitialize];
    
    g_id = bundleId;
    g_company = company;
    g_mail = email;
    g_serial = key;
        
    [RDVGlobal Init];
}

- (NSString *)fileState
{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_lastOpenedPath]) {
        
        NSString *message = @"";
        
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"fileStat"]) {
            case 0:
                message = @"File has not been modified.";
                break;
                
            case 1:
                message = @"File has been modified but not saved.";
                break;
                
            case 2:
                message = @"File has been modified and saved.";
                break;
                
            default:
                break;
        }
        
        return message;
    }
    else
        return @"File not found";
}

- (int)getPageNumber
{
    if (m_pdf == nil || [m_pdf getDoc] == nil)
        return -1;
    return [m_pdf PDFCurPage];
}

- (int)getPageCount
{
    if (m_pdf == nil || [m_pdf getDoc] == nil) {
        return -1;
    }
    
    return [(PDFDoc *)[m_pdf getDoc] pageCount];
}

- (void)setThumbnailBGColor:(int)color
{
    thumbBackgroundColor = color;
}

- (void)setThumbGridBGColor:(int)color
{
    gridBackgroundColor = color;
}

- (void)setReaderBGColor:(int)color
{
    readerBackgroundColor = color;
}

- (void)setThumbGridElementHeight:(float)height
{
    gridElementHeight = height;
}

- (void)setThumbGridGap:(float)gap
{
    gridGap = gap;
}

- (void)setThumbGridViewMode:(int)mode
{
    gridMode = mode;
}

- (void)setTitleBGColor:(int)color
{
    titleBackgroundColor = color;
}

- (void)setIconsBGColor:(int)color
{
    iconsBackgroundColor = color;
}

- (void)setThumbHeight:(float)height
{
    thumbHeight = height;
}

- (void)setFirstPageCover:(BOOL)cover
{
    firstPageCover = cover;
}

- (void)setDoubleTapZoomMode:(int)mode
{
    doubleTapZoomMode = mode;
}

- (void)setImmersive:(BOOL)immersive
{
    isImmersive = immersive;
    
    if (m_pdf != nil && [m_pdf getDoc] != nil) {
        [m_pdf setImmersive:isImmersive];
    }
}

- (void)readerInit
{
    if( m_pdf == nil && ![self isPageViewController])
    {
        m_pdf = [[UIStoryboard storyboardWithName:@"PDFReaderCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfreader"];
    }
    
    if ([self isPageViewController]) {
        m_pdfP = [[RDPageViewController alloc] initWithNibName:@"RDPageViewController" bundle:nil];
    } else {
        [m_pdf setDelegate:self];
        
        [self setPagingEnabled:NO];
        [self setDoublePageEnabled:YES];
        
        [m_pdf setFirstPageCover:firstPageCover];
        [m_pdf setDoubleTapZoomMode:2];
        [m_pdf setImmersive:NO];
        
        [m_pdf setViewModeImage:[UIImage imageNamed:@"btn_view.png"]];
        [m_pdf setSearchImage:[UIImage imageNamed:@"btn_search.png"]];
        [m_pdf setLineImage:[UIImage imageNamed:@"btn_annot_ink.png"]];
        [m_pdf setRectImage:[UIImage imageNamed:@"btn_annot_rect.png"]];
        [m_pdf setEllipseImage:[UIImage imageNamed:@"btn_annot_ellipse.png"]];
        [m_pdf setOutlineImage:[UIImage imageNamed:@"btn_outline.png"]];
        [m_pdf setPrintImage:[UIImage imageNamed:@"btn_print.png"]];
        [m_pdf setGridImage:[UIImage imageNamed:@"btn_grid.png"]];
        [m_pdf setUndoImage:[UIImage imageNamed:@"btn_undo.png"]];
        [m_pdf setRedoImage:[UIImage imageNamed:@"btn_redo.png"]];
        [m_pdf setMoreImage:[UIImage imageNamed:@"btn_more.png"]];
        
        [m_pdf setRemoveImage:[UIImage imageNamed:@"annot_remove.png"]];
        
        [m_pdf setPrevImage:[UIImage imageNamed:@"btn_left.png"]];
        [m_pdf setNextImage:[UIImage imageNamed:@"btn_right.png"]];
        
        [m_pdf setPerformImage:[UIImage imageNamed:@"btn_perform.png"]];
        [m_pdf setDeleteImage:[UIImage imageNamed:@"btn_remove.png"]];
        
        [m_pdf setDoneImage:[UIImage imageNamed:@"btn_done.png"]];
        
        [m_pdf setHideGridImage:YES];
    }
    [self loadSettingsWithDefaults];
}

- (id)getGlobal {
    return GLOBAL;
}

- (PDFReaderCtrl *)showReader
{
    [m_pdf setReaderBGColor:readerBackgroundColor];
    //Set thumbGridView
    //thumbGridView was not used anymore.
    //[m_pdf setThumbGridBGColor:gridBackgroundColor];
    //[m_pdf setThumbGridElementHeight:gridElementHeight];
    //[m_pdf setThumbGridGap:gridGap];
    //[m_pdf setThumbGridViewMode:gridMode];
    
    m_pdf.hidesBottomBarWhenPushed = YES;
    
    return m_pdf;
}

- (RDPageViewController *)showCurlingReader
{
    m_pdfP.hidesBottomBarWhenPushed = YES;
    return m_pdfP;
}


- (NSString *)extractTextFromPage:(int)pageNum
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return @"";
    }
    
    PDFPage *page = [doc page:pageNum];
    [page objsStart];
    
    return [page objsString:0 :page.objsCount];
    
    page = nil;
}

- (BOOL)encryptDocAs:(NSString *)path userPwd:(NSString *)userPwd ownerPwd:(NSString *)ownerPwd permission:(int)permission method:(int)method idString:(NSString *)idString
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return NO;
    }
    
    unsigned char *c = (unsigned char *)[idString cStringUsingEncoding:NSUTF8StringEncoding];
    
    return [doc encryptAs:path :userPwd :ownerPwd :permission :method :c];
}

- (BOOL)addAnnotAttachment:(NSString *)path
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return NO;
    }
    
    return [m_pdf addAttachmentFromPath:path];
}

- (BOOL)renderAnnotToFile:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize)size
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return NO;
    }
    
    return [m_pdf saveImageFromAnnotAtIndex:index atPage:pageno savePath:path size:size];
}

- (BOOL)flatAnnots
{
    return [m_pdf flatAnnots];
}

- (BOOL)flatAnnotAtPage:(int)pageno
{
    return [PDFReaderCtrl flatAnnotAtPage:pageno doc:nil];
}

- (BOOL)saveDocumentToPath:(NSString *)path
{
    return [m_pdf saveDocumentToPath:path];
}

#pragma mark - Settings

- (void)toggleThumbSeekBar:(int)mode
{
    bottomBar = mode;
}

- (void)setPagingEnabled:(BOOL)enabled
{
    GLOBAL.g_paging_enabled = enabled;
}

- (void)setDoublePageEnabled:(BOOL)enabled
{
    GLOBAL.g_double_page_enabled = enabled;
}

- (BOOL)setReaderViewMode:(int)mode
{
    GLOBAL.g_render_mode = mode;
    return YES;
}

- (BOOL)isPageViewController
{
    if (GLOBAL.g_render_mode != 2) {
        return NO;
    }
    else return YES;
}

- (void)setColor:(int)color forFeature:(int)feature
{
    switch (feature) {
        case 0:
            inkColor = color;
            break;
            
        case 1:
            rectColor = color;
            break;
            
        case 2:
            underlineColor = color;
            break;
            
        case 3:
            strikeoutColor = color;
            break;
            
        case 4:
            highlightColor = color;
            break;
            
        case 5:
            ovalColor = color;
            break;
            
        case 6:
            selColor = color;
            break;
            
        case 7:
            arrowColor = color;
            break;
            
        default:
            break;
    }
}

#pragma mark - Init defaults

- (void)loadSettingsWithDefaults
{
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_case_sensitive forKey:@"CaseSensitive"];
    [[NSUserDefaults standardUserDefaults] setFloat:GLOBAL.g_ink_width forKey:@"InkWidth"];
    [[NSUserDefaults standardUserDefaults] setFloat:GLOBAL.g_rect_width forKey:@"RectWidth"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.15f forKey:@"SwipeSpeed"];
    [[NSUserDefaults standardUserDefaults] setFloat:1.0f forKey:@"SwipeDistance"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_render_quality forKey:@"RenderQuality"];
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_match_whole_word forKey:@"MatchWholeWord"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_ink_color forKey:@"InkColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_rect_color forKey:@"RectColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_annot_underline_clr forKey:@"UnderlineColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_annot_strikeout_clr forKey:@"StrikeoutColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_annot_highlight_clr forKey:@"HighlightColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_oval_color forKey:@"OvalColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_render_mode forKey:@"DefView"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_sel_color forKey:@"SelColor"];
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_line_color forKey:@"ArrowColor"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Bookmarks

+ (NSString *)addToBookmarks:(NSString *)pdfPath page:(int)page label:(NSString *)label
{
    pdfPath = [pdfPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSString *tempName = [[pdfPath lastPathComponent] stringByDeletingPathExtension];
    NSString *tempFile = [tempName stringByAppendingFormat:@"%d%@",page,@".bookmark"];
    
    NSString *fileContent = [NSString stringWithFormat:@"%i",page];
    NSString *BookMarkDir = [pdfPath stringByDeletingLastPathComponent];
    
    NSString *bookMarkFile = [BookMarkDir stringByAppendingPathComponent:tempFile];
    
    if (![[NSFileManager defaultManager] isWritableFileAtPath:BookMarkDir]) {
        return @"Cannot add bookmark";
    }
    
    NSLog(@"%@", bookMarkFile);
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:bookMarkFile])
    {
        [[NSFileManager defaultManager]createFileAtPath:bookMarkFile contents:nil attributes:nil];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:bookMarkFile];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[fileContent dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
        
        return @"Add BookMark Success!";
    }
    else {
        return @"BookMark Already Exist";
    }
}

+ (void)removeBookmark:(int)page pdfPath:(NSString *)pdfPath
{
    pdfPath = [pdfPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSString *item = [[pdfPath lastPathComponent] stringByDeletingPathExtension];
    NSString *folder = [pdfPath stringByDeletingLastPathComponent];
    NSString *bookmarkFile = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%i.bookmark", item, page]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:bookmarkFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:bookmarkFile error:nil];
    }
}

+ (NSString *)getBookmarks:(NSString *)pdfPath
{
    pdfPath = [pdfPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        NSMutableArray *bookmarks = [RadaeePDFPlugin loadBookmarkForPdf:pdfPath withPath:NO];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bookmarks options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    
    return @"";
}

+ (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfPath withPath:(BOOL)withPath
{
    return [RadaeePDFPlugin addBookMarks:[pdfPath stringByDeletingLastPathComponent] :@"" :[NSFileManager defaultManager] pdfName:[[pdfPath lastPathComponent] stringByDeletingPathExtension] withPath:withPath];
}

+ (NSMutableArray *)addBookMarks:(NSString *)dpath :(NSString *)subdir :(NSFileManager *)fm pdfName:(NSString *)pdfName withPath:(BOOL)withPath
{
    NSMutableArray *bookmarks = [NSMutableArray array];
    
    NSDirectoryEnumerator *fenum = [fm enumeratorAtPath:dpath];
    NSString *fName;
    while(fName = [fenum nextObject])
    {
        NSLog(@"%@", [dpath stringByAppendingPathComponent:fName]);
        NSString *dst = [dpath stringByAppendingPathComponent:fName];
        NSString *tempString;
        
        if(fName.length >10)
        {
            tempString = [fName pathExtension];
        }
        
        if( [tempString isEqualToString:@"bookmark"] )
        {
            if (pdfName.length > 0 && ![fName containsString:pdfName]) {
                continue;
            }
            
            //add to list.
            NSFileHandle *fileHandle =[NSFileHandle fileHandleForReadingAtPath:dst];
            NSString *content = [[NSString alloc]initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
            NSArray *myarray =[content componentsSeparatedByString:@","];
            [myarray objectAtIndex:0];
            NSArray *arr = [[NSArray alloc] initWithObjects:[myarray objectAtIndex:0],dst,nil];
            
            if (withPath) {
                [bookmarks addObject:arr];
            } else {
                [bookmarks addObject:@{@"Page:": [NSNumber numberWithInteger:[[myarray objectAtIndex:0] intValue]], @"Label": @""}];
            }
            
        }
    }
    
    return bookmarks;
}

#pragma mark - Form Extractor

- (NSString *)getJSONFormFields
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];
    return [fe jsonInfoForAllPages];
}

- (NSString *)getJSONFormFieldsAtPage:(int)page
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];
    return [fe jsonInfoForPage:page];
}

- (NSString *)setFormFieldWithJSON:(NSString *)json
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];
    
    NSError *error;
    if (json && json.length > 0) {
        [fe setInfoWithJson:json error:&error];
        
        if (error) {
            return error.description;
        } else
        {
            [self refreshCurrentPage];
        }
    } else
    {
        return @"JSON not valid";
    }
    
    return @"";
}

#pragma mark - Reader Delegate

- (void)willShowReader
{
    if (delegate) {
        [delegate willShowReader];
    }
}

- (void)didShowReader
{
    if (delegate) {
        [delegate didShowReader];
    }
}

- (void)willCloseReader
{
    if (delegate) {
        [delegate willCloseReader];
    }
}

- (void)didCloseReader
{
    if (delegate) {
        [delegate didCloseReader];
    }
}

- (void)didChangePage:(int)page
{
    if (delegate) {
        [delegate didChangePage:page];
    }
}

- (void)didTapOnPage:(int)page atPoint:(CGPoint)point
{
    if (delegate) {
        [delegate didTapOnPage:page atPoint:point];
    }
}

- (void)didDoubleTapOnPage:(int)page atPoint:(CGPoint)point
{
    if (delegate) {
        [delegate didDoubleTapOnPage:page atPoint:point];
    }
}

- (void)didLongPressOnPage:(int)page atPoint:(CGPoint)point
{
    if (delegate) {
        [delegate didLongPressOnPage:page atPoint:point];
    }
}

- (void)didTapOnAnnotationOfType:(int)type atPage:(int)page atPoint:(CGPoint)point
{
    if (delegate) {
        [delegate didTapOnAnnotationOfType:type atPage:page atPoint:point];
    }
}

- (void)didSearchTerm:(NSString *)term found:(BOOL)found
{
    if (delegate) {
        [delegate didSearchTerm:term found:found];
    }
}

- (void)onAnnotExported:(NSString *)path
{
    if (delegate) {
        [delegate onAnnotExported:path];
    }
}

- (void)refreshCurrentPage
{
    [m_pdf refreshCurrentPage];
}

#pragma mark - Delegate Setting

- (void)setDelegate:(id)myDelegate
{
    delegate = myDelegate;
}

#pragma mark - Path Utils

- (NSString *)getCustomPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    NSString *customDirectory = [libraryPath stringByAppendingPathComponent:@"customDirectory"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:customDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:customDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return customDirectory;
}

- (BOOL)moveFileToCustomDir:(NSString *)path overwrite:(BOOL)overwrite
{
    NSString *itemPath = [[self getCustomPath] stringByAppendingPathComponent:[path lastPathComponent]];
    
    BOOL res = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:itemPath];
    
    if (exist && overwrite) {
        [[NSFileManager defaultManager] removeItemAtPath:itemPath error:nil];
    }
    
    if (!exist) {
        res = [[NSFileManager defaultManager] copyItemAtPath:path toPath:[[self getCustomPath] stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
    }
    
    return res;
}

#pragma mark - get/add text and markup annot

- (NSString *)getTextAnnotationDetails:(int)pageNum
{
    PDFDoc *doc = [m_pdf getDoc];
    NSMutableArray *array = [NSMutableArray array];
    NSString *json = @"";
    
    if (m_pdf == nil || doc == nil) {
        return nil;
    }
    
    PDFPage *page = [doc page:pageNum];
    
    if (page == nil) {
        return nil;
    }
    
    [page objsStart];
    
    for (int c = 0; c < [page annotCount]; c++) {
        PDFAnnot *annot = [page annotAtIndex:c];
        //detect if is annot text
        if (annot.type == 1) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            PDF_RECT rect;
            [annot getRect:&rect];
            [dict setObject:[NSNumber numberWithInt:[annot getIndex]] forKey:@"index"];
            [dict setObject:[NSNumber numberWithFloat:rect.top] forKey:@"top"];
            [dict setObject:[NSNumber numberWithFloat:rect.left] forKey:@"left"];
            [dict setObject:[NSNumber numberWithFloat:rect.right] forKey:@"right"];
            [dict setObject:[NSNumber numberWithFloat:rect.bottom] forKey:@"bottom"];
            [dict setObject:[annot getPopupText] forKey:@"text"];
            [dict setObject:[annot getPopupSubject] forKey:@"subject"];
            [array addObject:dict];
        }
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    page = nil;
    doc = nil;
    
    return json;
}

- (NSString *)getMarkupAnnotationDetails:(int)pageNum
{
    PDFDoc *doc = [m_pdf getDoc];
    NSMutableArray *array = [NSMutableArray array];
    NSString *json = @"";
    
    if (m_pdf == nil || doc == nil) {
        return nil;
    }
    
    PDFPage *page = [doc page:pageNum];
    
    if (page == nil) {
        return nil;
    }
    
    [page objsStart];
    
    for (int c = 0; c < [page annotCount]; c++) {
        PDFAnnot *annot = [page annotAtIndex:c];
        //detect if is annot text
        if (annot.type >= 9 && annot.type <= 12) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            PDF_RECT rect;
            [annot getRect:&rect];
            [dict setObject:[NSNumber numberWithInt:[annot getIndex]] forKey:@"index"];
            [dict setObject:[NSNumber numberWithFloat:rect.top] forKey:@"top"];
            [dict setObject:[NSNumber numberWithFloat:rect.left] forKey:@"left"];
            [dict setObject:[NSNumber numberWithFloat:rect.right] forKey:@"right"];
            [dict setObject:[NSNumber numberWithFloat:rect.bottom] forKey:@"bottom"];
            [dict setObject:[NSNumber numberWithInt:[annot type]] forKey:@"type"];
            [array addObject:dict];
        }
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    page = nil;
    doc = nil;
    
    return json;
}

- (void)addTextAnnotation:(int)pageNum :(float)x :(float)y :(NSString *)text :(NSString *)subject
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return;
    }
    
    PDFPage *page = [doc page:pageNum];
    
    if (page == nil) {
        return;
    }
    
    [page objsStart];
    
    PDF_POINT pt;
    pt.x = x;
    pt.y = y;
    [page addAnnotNote:&pt];
    
    PDFAnnot *annot = [page annotAtIndex:[page annotCount]-1];
    [annot setPopupText:text];
    [annot setPopupSubject:subject];
    
    [doc save];
    
    [m_pdf refreshCurrentPage];
    
    page = nil;
    doc = nil;
}

- (int)getCharIndex:(int)pageNum :(float)x :(float)y
{
    PDFDoc *doc = [m_pdf getDoc];
    if (m_pdf == nil || doc == nil) {
        return 0;
    }
    
    PDFPage *page = [doc page:pageNum];
    
    if (page == nil) {
        return 0;
    }
    
    [page objsStart];
    
    return [page objsGetCharIndex:x :y];
}

- (void)addMarkupAnnotation:(int)pageNum :(int)type :(int)index1 :(int)index2
{
    PDFDoc *doc = [m_pdf getDoc];
    
    if (m_pdf == nil || doc == nil) {
        return;
    }
    
    PDFPage *page = [doc page:pageNum];
    
    if (page == nil) {
        return;
    }
    
    [page objsStart];
    
    int color = GLOBAL.g_annot_highlight_clr;
    if( type == 1 ) color = GLOBAL.g_annot_underline_clr;
    if( type == 2 ) color = GLOBAL.g_annot_strikeout_clr;
    if( type == 4 ) color = GLOBAL.g_annot_squiggly_clr;
    [page addAnnotMarkup:index1 :index2 :type :color];
    
    [doc save];
    
    [m_pdf refreshCurrentPage];
    
    page = nil;
    doc = nil;
}

- (NSString *)getPDFCoordinates:(int)x :(int)y
{
    if (m_pdf == nil) {
        return nil;
    }
    
    CGPoint pdfPoints = [m_pdf pdfPointsFromScreenPoints:x :y];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pdfPoints.x], @"x",[NSNumber numberWithInt:pdfPoints.y], @"y", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSString *)getScreenCoordinates:(int)x :(int)y :(int)pageNum
{
    if (m_pdf == nil) {
        return nil;
    }
    
    CGPoint pdfPoints = [m_pdf screenPointsFromPdfPoints:x :y :pageNum];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pdfPoints.x], @"x",[NSNumber numberWithInt:pdfPoints.y], @"y", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSString *)getPDFRect:(float)x :(float)y :(float)width :(float)height
{
    if (m_pdf == nil) {
        return nil;
    }
        
    NSArray *arect = [m_pdf pdfRectFromScreenRect:CGRectMake(x, y, width, height)];
    
    PDF_RECT rect;
    rect.top = [[arect objectAtIndex:0] floatValue];
    rect.left = [[arect objectAtIndex:1] floatValue];
    rect.right = [[arect objectAtIndex:2] floatValue];
    rect.bottom = [[arect objectAtIndex:3] floatValue];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:rect.top], @"top", [NSNumber numberWithFloat:rect.left], @"left",[NSNumber numberWithFloat:rect.right], @"right",[NSNumber numberWithFloat:rect.bottom], @"bottom", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSString *)getScreenRect:(float)left :(float)top :(float)right :(float)bottom :(int)pageNum
{
    if (m_pdf == nil) {
        return nil;
    }
    
    CGRect rect = [m_pdf screenRectFromPdfRect:left :top :right :bottom :pageNum];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:rect.origin.x], @"x",[NSNumber numberWithFloat:rect.origin.y], @"y",[NSNumber numberWithFloat:rect.size.width], @"width",[NSNumber numberWithFloat:rect.size.height], @"height", nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}

@end
