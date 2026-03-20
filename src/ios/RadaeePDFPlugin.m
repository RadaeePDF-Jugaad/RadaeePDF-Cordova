//
//  AlmaZBarReaderViewController.h
//  Paolo Messina
//
//  Created by Paolo Messina on 06/07/15.
//
//

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((rgbValue & 0xFF000000) >>  24))/255.0]

#import "RadaeePDFPlugin.h"
#import "PDFReaderCtrl.h"
#import "RDPageViewController.h"
#import "PDFHttpStream.h"
#import "RDFormManager.h"
#import "RDUtils.h"

#pragma mark - Synthesize

@interface RadaeePDFPlugin() <PDFReaderDelegate>

@end

@implementation RadaeePDFPlugin
@synthesize cdv_command;

#pragma mark - Cordova Plugin

+ (RadaeePDFPlugin *)pluginInit
{
    RadaeePDFPlugin *r = [[RadaeePDFPlugin alloc] init];
    return r;
}

#pragma mark - Plugin API

- (void)show:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    // Get user parameters
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    url = [params objectForKey:@"url"];
    GLOBAL.g_annot_def_author = ([params objectForKey:@"author"]) ? [params objectForKey:@"author"] : @"";

    if([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]){

        NSString *cacheFile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cacheFile.pdf"];

        PDFHttpStream *httpStream = [[PDFHttpStream alloc] init];
        [httpStream open:url :cacheFile];

        [self readerInit];

        RDPDFDoc *doc = [[RDPDFDoc alloc] init];
        [RDPDFDoc setOpenFlag:3];
        int result = [doc openStream:httpStream :@""];

        switch(result)
        {
            case err_ok: {
                    [doc getLinearizedStatus];
                [m_pdf setDoc:doc:true];
                    GLOBAL.g_pdf_name = [NSMutableString stringWithFormat:@"%@", [url lastPathComponent]];
                    [self showReader];
                }
                break;
            default: {
                   NSLog(@"%d", result);
                   if(result != err_ok && result != err_open){
                       [self pdfChargeDidFailWithError:@"Error open pdf" andCode:(NSInteger) result];
                       return;
                   }
                }
                break;
        }


    } else {
        if ([url containsString:@"file://"]) {

            NSString *filePath = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];

            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                filePath = [documentsDirectory stringByAppendingPathComponent:filePath];
            }

            [self openPdf:filePath atPage:[[params objectForKey:@"gotoPage"] intValue] withPassword:[params objectForKey:@"password"] readOnly:[[params objectForKey:@"readOnlyMode"] boolValue] autoSave:[[params objectForKey:@"automaticSave"] boolValue]];
        } else {
            [self openFromPath:command];
        }
    }

}

- (void)openFromAssets:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    // Get user parameters
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    url = [params objectForKey:@"url"];
    GLOBAL.g_annot_def_author = ([params objectForKey:@"author"]) ? [params objectForKey:@"author"] : @"";

    NSString *filePath = [[NSBundle mainBundle] pathForResource:url ofType:nil];

    [self openPdf:filePath atPage:[[params objectForKey:@"gotoPage"] intValue] withPassword:[params objectForKey:@"password"] readOnly:[[params objectForKey:@"readOnlyMode"] boolValue] autoSave:[[params objectForKey:@"automaticSave"] boolValue]];
}

- (void)openFromPath:(CDVInvokedUrlCommand *)command
{
    // Get user parameters
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    url = [params objectForKey:@"url"];
    GLOBAL.g_annot_def_author = ([params objectForKey:@"author"]) ? [params objectForKey:@"author"] : @"";

    NSString *filePath = url;

    [self openPdf:filePath atPage:[[params objectForKey:@"gotoPage"] intValue] withPassword:[params objectForKey:@"password"] readOnly:[[params objectForKey:@"readOnlyMode"] boolValue] autoSave:[[params objectForKey:@"automaticSave"] boolValue]];
}

- (void)openPdf:(NSString *)filePath atPage:(int)page withPassword:(NSString *)password readOnly:(BOOL)readOnly autoSave:(BOOL)autoSave
{
    NSLog(@"File Path: %@", filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self pdfChargeDidFailWithError:@"File not exist" andCode:200];
        return;
    }

    _lastOpenedPath = filePath;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"fileStat"];

    [self readerInit];

    int result = 0;

    if ([self isPageViewController]) {
        result = [m_pdfP PDFOpenAtPath:filePath withPwd:password];
    } else {
        RDPDFDoc *doc = [[RDPDFDoc alloc] init];
        result = [doc open:filePath :password];
        if(!result)
        {
            GLOBAL.g_pdf_path = [[filePath stringByDeletingLastPathComponent] mutableCopy];
            GLOBAL.g_pdf_name = [[filePath lastPathComponent] mutableCopy];
            GLOBAL.g_auto_save_doc = autoSave;
            [m_pdf setDoc:doc :page :readOnly];
        }
    }

    NSLog(@"%d", result);
    if(result != err_ok && result != err_open){
        [self pdfChargeDidFailWithError:@"Error open pdf" andCode:(NSInteger) result];
        return;
    }

    [self showReader];
}

- (void)closeReader:(CDVInvokedUrlCommand *)command
{
    if (m_pdf != nil && ![self isPageViewController]) {
        [m_pdf closeView];
    }
    else if (m_pdfP != nil && [self isPageViewController])
    {
        [m_pdfP closeView];
    }
}

- (void)activateLicense:(CDVInvokedUrlCommand *)command
{
    [self pluginInitialize];
    [self copyDocumentsFromAssets];

    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    [[NSUserDefaults standardUserDefaults] setObject:[params objectForKey:@"key"] forKey:@"actSerial"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    g_serial = [params objectForKey:@"key"];

    [RDVGlobal Init];

    [self activateLicenseResult:[[NSUserDefaults standardUserDefaults] boolForKey:@"actIsActive"]];
}

- (void)copyDocumentsFromAssets
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath = [paths objectAtIndex:0];
    NSString *hf = [[NSBundle mainBundle] pathForResource:@"PDFRes" ofType:nil];
    for (NSString *fpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:hf error:nil]) {
        if([fpath.pathExtension isEqualToString:@"pdf"] || [fpath.pathExtension isEqualToString:@"PDF"])
        {
            NSString *documentPath = [hf stringByAppendingPathComponent:fpath];
            NSString *destPath = [dpath stringByAppendingPathComponent:fpath];

            if(![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
                [[NSFileManager defaultManager] copyItemAtPath:documentPath toPath:destPath error:nil];
            }
        }
    }
}

- (void)fileState:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

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

        [self cdvOkWithMessage:message];
    }
    else
        [self cdvErrorWithMessage:@"File not found"];
}

- (void)getPageNumber:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    if (m_pdf == nil || [m_pdf getDoc] == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    int page = 0;
    if (![self isPageViewController]) {
        page = [m_pdf PDFCurPage];
    } else {
        page = [m_pdfP getCurrentPage];
    }

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%i", page]];
}

- (void)getPageCount:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    if (m_pdf == nil || [m_pdf getDoc] == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    int count = [(RDPDFDoc *)[m_pdf getDoc] pageCount];
    [self cdvOkWithMessage:[NSString stringWithFormat:@"%i", count]];
}

- (void)setThumbnailBGColor:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    GLOBAL.g_thumbview_bg_color = [[params objectForKey:@"color"] intValue];
}

- (void)setThumbGridBGColor:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    gridBackgroundColor = [[params objectForKey:@"color"] intValue];
}

- (void)setReaderBGColor:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    GLOBAL.g_readerview_bg_color = [[params objectForKey:@"color"] intValue];
}

- (void)setThumbGridElementHeight:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    gridElementHeight = [[params objectForKey:@"height"] floatValue];
}

- (void)setThumbGridGap:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    gridGap = [[params objectForKey:@"gap"] floatValue];
}

- (void)setThumbGridViewMode:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    gridMode = [[params objectForKey:@"mode"] floatValue];
}

- (void)setTitleBGColor:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    titleBackgroundColor = [[params objectForKey:@"color"] intValue];
}

- (void)setIconsBGColor:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    iconsBackgroundColor = [[params objectForKey:@"color"] intValue];
}

- (void)setThumbHeight:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    GLOBAL.g_thumbview_height = [[params objectForKey:@"height"] floatValue];
}

- (void)getGlobal:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *name = [params objectForKey:@"name"];
    id value = [RDUtils getGlobalFromString:name];

    if (value) {
        [self cdvOkWithMessage:[NSString stringWithFormat:@"%@ = %@", name, value]];
    }
}

- (void)setGlobal:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *name = [params objectForKey:@"name"];
    id value = [params objectForKey:@"value"];

    NSArray *integerGlobals = [NSArray arrayWithObjects: @"g_render_quality", @"g_view_mode", @"g_navigation_mode", @"g_line_annot_style1", @"g_line_annot_style2", @"g_thumbview_height", nil];

    NSArray *uintegerGlobals = [NSArray arrayWithObjects: @"g_rect_annot_color", @"g_line_annot_color", @"g_ink_color", @"g_sel_color", @"g_oval_annot_color", @"g_rect_annot_fill_color", @"g_oval_annot_fill_color", @"g_line_annot_fill_color", @"g_annot_highlight_clr", @"g_annot_underline_clr", @"g_annot_strikeout_clr", @"g_annot_squiggly_clr", @"g_annot_transparency", @"g_find_primary_color",@"g_find_secondary_color", @"g_readerview_bg_color", @"g_thumbview_bg_color" , @"g_thumbview_label_color", nil];

    NSArray *floatGlobals = [NSArray arrayWithObjects: @"g_ink_width", @"g_rect_annot_width", @"g_line_annot_width", @"g_oval_annot_width", @"g_swipe_speed" , @"g_swipe_distance" , @"g_tap_zoom_level", @"g_layout_zoom_level", @"g_zoom_step",  nil];

    NSArray *boolGlobals = [NSArray arrayWithObjects: @"g_case_sensitive", @"g_match_whole_word", @"g_sel_rtol", @"g_screen_awake", @"g_auto_save_doc", @"g_paging_enabled", @"g_double_page_enabled", @"g_curl_enabled", @"g_cover_page_enabled", @"g_fit_signature_to_field", @"g_exec_js", @"g_dark_mode", @"g_annot_lock", @"g_annot_readonly", @"g_auto_launch_link", @"g_highlight_annotation", @"g_hand_signature", @"g_readonly" , @"g_fake_sign", @"g_layout_rtol", @"g_auto_scale" , nil];

    NSArray *stringGlobals = [NSArray arrayWithObjects:@"text", @"g_pdf_name", @"g_pdf_path", @"g_annot_def_author", @"g_sign_pad_descr", nil];

    if ([integerGlobals containsObject:name]) {
        if ([value isKindOfClass:[NSString class]]) {
            [self cdvErrorWithMessage:[NSString stringWithFormat:@"Bad property"]];
        }
        [RDUtils setGlobalFromString:[params objectForKey:@"name"] withValue:[NSNumber numberWithInt:[value intValue]]];
    }

    else if ([uintegerGlobals containsObject:name]) {
        if ([value isKindOfClass:[NSString class]]) {
            [self cdvErrorWithMessage:[NSString stringWithFormat:@"Bad property"]];
        }
        [RDUtils setGlobalFromString:[params objectForKey:@"name"] withValue:[NSNumber numberWithUnsignedInt:(uint)value]];
    }

    else if ([floatGlobals containsObject:name]) {
        if ([value isKindOfClass:[NSString class]]) {
            [self cdvErrorWithMessage:[NSString stringWithFormat:@"Bad property"]];
        }
        [RDUtils setGlobalFromString:[params objectForKey:@"name"] withValue:[NSNumber numberWithFloat:[value floatValue]]];
    }

    else if ([boolGlobals containsObject:name])
    {
        if ([value isKindOfClass:[NSString class]]) {
            [self cdvErrorWithMessage:[NSString stringWithFormat:@"Bad property"]];
        }
        [RDUtils setGlobalFromString:[params objectForKey:@"name"] withValue:[NSNumber numberWithBool:(BOOL)value]];
    }

    else if ([stringGlobals containsObject:name]) {
        [RDUtils setGlobalFromString:[params objectForKey:@"name"] withValue:value];
    }
}


- (void)setFirstPageCover:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    firstPageCover = [[params objectForKey:@"cover"] boolValue];
}

- (void)setDoubleTapZoomMode:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    doubleTapZoomMode = [[params objectForKey:@"mode"] intValue];
}

- (void)setImmersive:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    isImmersive = [[params objectForKey:@"immersive"] boolValue];

    if (m_pdf != nil && [m_pdf getDoc] != nil) {
        [m_pdf setImmersive:isImmersive];
    }
}

- (void)readerInit
{
    if( m_pdf == nil && ![self isPageViewController])
    {
        m_pdf = [[UIStoryboard storyboardWithName:@"PDFReaderCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfreader"];
    } if ([self isPageViewController]) {
        m_pdfP = [[RDPageViewController alloc] initWithNibName:@"RDPageViewController" bundle:nil];
    } else {
        [m_pdf setDelegate:self];

        [self setPagingEnabled:NO];
        [self setDoublePageEnabled:YES];

        [m_pdf setDoubleTapZoomMode:2];
        [m_pdf setImmersive:isImmersive];

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


        if (!disableToolbar && toolbarItemEdited)
            return;

        if (disableToolbar) {
            [m_pdf setHideSearchImage:YES];
            [m_pdf setHideDrawImage:YES];
            [m_pdf setHideMoreImage:YES];
        } else {
            [m_pdf setHideSearchImage:NO];
            [m_pdf setHideDrawImage:NO];
            [m_pdf setHideMoreImage:NO];
        }

        /*
         SetColor, Available features

         0: inkColor
         1: rectColor
         2: underlineColor
         3: strikeoutColor
         4: highlightColor
         5: ovalColor
         6: selColor
         7: arrowColor

         */
    }
}

- (void)setBarButtonVisibility:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    NSString *code = [params objectForKey:@"code"];
    BOOL visibility = ![[params objectForKey:@"visibility"] boolValue];
    toolbarItemEdited = YES;
    if (![self isPageViewController] && !m_pdf)
        [self readerInit];

    if ([code isEqualToString:@"btn_search"]) {
        [m_pdf setHideSearchImage:visibility];
    } else if ([code isEqualToString:@"btn_draw"]) {
        [m_pdf setHideDrawImage:visibility];
    } else if ([code isEqualToString:@"btn_view"]) {
        [m_pdf setHideViewImage:visibility];
    } else if ([code isEqualToString:@"btn_thumb"]) {
        [m_pdf setHideThumbImage:visibility];
    } else if ([code isEqualToString:@"btn_more"]) {
        [m_pdf setHideMoreImage:visibility];
    }
}

- (void)showReader
{
    [self pdfChargeDidFinishLoading];
    if (![self isPageViewController]) {
        //toggle thumbnail/seekbar
        if (bottomBar < 1){
            [m_pdf setThumbnailBGColor:GLOBAL.g_thumbview_bg_color];
        }

        [m_pdf setReaderBGColor:GLOBAL.g_readerview_bg_color];

        m_pdf.hidesBottomBarWhenPushed = YES;
    }


    UINavigationController *navController;

    navController = [[UINavigationController alloc] initWithRootViewController:([self isPageViewController]) ? m_pdfP : m_pdf];

    if (titleBackgroundColor != 0) {
        navController.navigationBar.barTintColor = UIColorFromRGB(titleBackgroundColor);
    } else {
        navController.navigationBar.barTintColor = [UIColor blackColor];
    }

    if (iconsBackgroundColor != 0) {
        navController.navigationBar.tintColor = UIColorFromRGB(iconsBackgroundColor);
    } else {
        navController.navigationBar.tintColor = [UIColor orangeColor];
    }

    [navController.navigationBar setTranslucent:NO];

    navController.modalPresentationStyle = UIModalPresentationFullScreen;

    [self.viewController presentViewController:navController animated:YES completion:nil];
}

- (void)extractTextFromPage:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    int pageNum = [[params objectForKey:@"page"] intValue];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    RDPDFPage *page = [doc page:pageNum];
    [page objsStart:false];

    [self cdvOkWithMessage:[page objsString:0 :page.objsCount]];

    page = nil;
}

- (void)encryptDocAs:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"dst"];
    NSString *userPwd = [params objectForKey:@"user_pwd"];
    NSString *ownerPwd = [params objectForKey:@"owner_pwd"];
    int permission = [[params objectForKey:@"permission"] intValue];
    int method = [[params objectForKey:@"method"] intValue];
    NSString *idString = [params objectForKey:@"id"];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    unsigned char *c = (unsigned char *)[idString cStringUsingEncoding:NSUTF8StringEncoding];

    bool res = [doc encryptAs:path :userPwd :ownerPwd :permission :method :c];

    if (res) {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }
}

- (void)addAnnotAttachment:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"path"];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    if([m_pdf addAttachmentFromPath:path])
    {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }
}

- (void)renderAnnotToFile:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    int pageno = [[params objectForKey:@"page"] intValue];
    int index = [[params objectForKey:@"annotIndex"] intValue];
    NSString *path = [params objectForKey:@"renderPath"];
    int width = [[params objectForKey:@"width"] intValue];
    int height = [[params objectForKey:@"height"] intValue];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Error in pdf instance"];
        return;
    }

    if([m_pdf saveImageFromAnnotAtIndex:index atPage:pageno savePath:path size:CGSizeMake(width, height)])
    {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }
}

- (void)flatAnnots:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    if([m_pdf flatAnnots])
    {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }
}
- (void)flatAnnotAtPage:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageno = [[params objectForKey:@"page"] intValue];

    if([PDFReaderCtrl flatAnnotAtPage:pageno doc:nil])
    {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }

}
- (void)saveDocumentToPath:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"path"];

    if(![[[path pathExtension] lowercaseString] isEqualToString:@"pdf"])
    {
        path = [path stringByAppendingPathComponent:@"newFile.pdf"];
    }

    if([m_pdf saveDocumentToPath:path])
    {
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }

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

- (void)setReaderViewMode:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    int mode = [[params objectForKey:@"mode"] intValue];

    GLOBAL.g_view_mode = mode;
}

- (void)setToolbarEnabled:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    BOOL enabled = [[params objectForKey:@"enabled"] boolValue];

    disableToolbar = !enabled;
}

- (BOOL)isPageViewController
{
    if (GLOBAL.g_view_mode != 2) {
        return NO;
    }
    else return YES;
}

#pragma mark - Bookmarks

- (void)addToBookmarks:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"pdfPath"];

    [self cdvOkWithMessage:[RadaeePDFPlugin addToBookmarks:path page:[[params objectForKey:@"page"] intValue] label:[params objectForKey:@"label"]]];
}

- (void)removeBookmark:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"pdfPath"];

    [RadaeePDFPlugin removeBookmark:[[params objectForKey:@"page"] intValue] pdfPath:path];
}

- (void)getBookmarks:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    NSString *path = [params objectForKey:@"pdfPath"];

    [self cdvOkWithMessage:[RadaeePDFPlugin getBookmarks:path]];
}

#pragma mark - Callbacks

- (void)willShowReaderCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_willShowReader = command;
}
- (void)didShowReaderCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didShowReader = command;
}
- (void)willCloseReaderCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_willCloseReader = command;
}
- (void)didCloseReaderCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didCloseReader = command;
}
- (void)didChangePageCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didChangePage = command;
}
- (void)didSearchTermCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didSearchTerm = command;
}
- (void)didTapOnPageCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didTapOnPage = command;
}
- (void)didDoubleTapOnPageCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didDoubleTapOnPage = command;
}

- (void)didLongPressOnPageCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didLongPressOnPage = command;
}
- (void)didTapOnAnnotationOfTypeCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_didTapOnAnnotationOfType = command;
}

- (void)onAnnotExportedCallback:(CDVInvokedUrlCommand *)command
{
    self.cdv_onAnnotExported = command;
}

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
#pragma mark - Delegate Methods

- (void)activateLicenseResult:(BOOL)success
{
    if (success) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult
                                                resultWithStatus:CDVCommandStatus_OK
                                                messageAsString:@"License activated"] callbackId:[self.cdv_command callbackId]];
    }
    else
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"License NOT activated"] callbackId:[self.cdv_command callbackId]];
    }
}

- (void)chargePdfSendResult:(CDVPluginResult*)result
{
    //m_pdf = nil;
    [self.commandDelegate sendPluginResult:result callbackId: [self.cdv_command callbackId]];
}

- (void)pdfChargeDidFinishLoading
{
    [self chargePdfSendResult:[CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:@"Pdf Succesfully charged"]];
}

- (void)pdfChargeDidFailWithError:(NSString*)errorMessage andCode:(NSInteger)statusCode{
    //if(m_pdf)
    //[m_pdf dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *dict = @{@"errorMessage" : errorMessage, @"statusCode" : [NSNumber numberWithInteger:statusCode]};
    [self chargePdfSendResult:[CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsDictionary:dict]];
}

- (void)cdvSendDictCallback:(NSDictionary *)message orCommand:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:res callbackId:[command callbackId]];
}

- (void)cdvSendCallback:(NSString *)message orCommand:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [res setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:res callbackId:[command callbackId]];
}

- (void)cdvOkWithMessage:(NSString *)message
{
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [res setKeepCallback:0];
    [self.commandDelegate sendPluginResult:res callbackId:[self.cdv_command callbackId]];
}

- (void)cdvErrorWithMessage:(NSString *)errorMessage
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage] callbackId:[self.cdv_command callbackId]];
}

- (void)setFormFieldsResult
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:[self.cdv_command callbackId]];
}

#pragma mark - Form Extractor

- (void)JSONFormFields:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;

    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];

    [self cdvOkWithMessage:[fe jsonInfoForAllPages]];
}

- (void)JSONFormFieldsAtPage:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];

    [self cdvOkWithMessage:[fe jsonInfoForPage:[[params objectForKey:@"page"]intValue]]];
}

- (void)setFormFieldWithJSON:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:[m_pdf getDoc]];

    NSError *error;
    if ([params objectForKey:@"json"]) {
        [fe setInfoWithJson:[params objectForKey:@"json"] error:&error];

        if (error) {
            [self cdvErrorWithMessage:[error description]];
        } else
        {
            if (m_pdf) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Radaee-Refresh-Page" object:nil];
            }
            [self setFormFieldsResult];
        }
    } else
    {
        [self cdvErrorWithMessage:@"JSON not found"];
    }
}

#pragma mark - FTS Methods
#ifdef FTS_ENABLED
- (void)FTS_SetIndexDB:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    [[FTSManager sharedInstance] FTS_SetIndexDB:[params objectForKey:@"dbPath"]];
    [self cdvOkWithMessage:@"Success"];
}
- (void)FTS_AddIndex:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    if([[FTSManager sharedInstance] FTS_AddIndex:[params objectForKey:@"filePath"] password:[params objectForKey:@"password"]])
        [self cdvOkWithMessage:@"Success"];
    else
        [self cdvErrorWithMessage:@"Failure"];
}
- (void)FTS_RemoveFromIndex:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    [[FTSManager sharedInstance] FTS_RemoveFromIndex:[params objectForKey:@"filePath"] password:[params objectForKey:@"password"]];
    [self cdvOkWithMessage:@"Success"];
}
- (void)FTS_Search:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    [[FTSManager sharedInstance] FTS_Search:[params objectForKey:@"term"] filter:[params objectForKey:@"filePath"] password:[params objectForKey:@"password"] writeJSON:[params objectForKey:@"resultPath"] success:^(NSMutableArray *occurrences, BOOL didWriteFile) {

        // Return the JSON as string
        if (!didWriteFile) {
            NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:occurrences.count];

            for (FTSOccurrence *occurrence in occurrences) {
                [jsonArray addObject:[occurrence getDictionaryFormat]];
            }

            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];

            [self cdvOkWithMessage:jsonString];
        } else {
            [self cdvOkWithMessage:@"Success"];
        }
    }];
}
- (void)SetSearchType:(CDVInvokedUrlCommand*)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];

    [[FTSManager sharedInstance] SetSearchType:[[params objectForKey:@"type"] intValue]];
    [self cdvOkWithMessage:@"Success"];
}
- (void)GetSearchType:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    [self cdvOkWithMessage:[NSString stringWithFormat:@"%i",[[FTSManager sharedInstance] GetSearchType]]];
}
#endif
#pragma mark - Reader Delegate

- (void)willShowReader
{
    /*
     if (_delegate) {
     [_delegate willShowReader];
     }
     */

    [self cdvSendCallback:@"" orCommand:self.cdv_willShowReader];
}

- (void)didShowReader
{
    /*
     if (_delegate) {
     [_delegate didShowReader];
     }
     */

    [self cdvSendCallback:@"" orCommand:self.cdv_didShowReader];
}

- (void)willCloseReader
{
    /*
     if (_delegate) {
     [_delegate willCloseReader];
     }
     */

    [self cdvSendCallback:@"" orCommand:self.cdv_willCloseReader];
}

- (void)didCloseReader
{
    /*
     if (_delegate) {
     [_delegate didCloseReader];
     }
     */

    [self cdvSendCallback:@"" orCommand:self.cdv_didCloseReader];
}

- (void)didChangePage:(int)page
{
    /*
     if (_delegate) {
     [_delegate didChangePage:page];
     }
     */

    [self cdvSendCallback:[NSString stringWithFormat:@"%i", page] orCommand:self.cdv_didChangePage];
}

- (void)didSearchTerm:(NSString *)term found:(BOOL)found
{
    /*
     if (_delegate) {
     [_delegate didSearchTerm:term found:found];
     }
     */

    [self cdvSendCallback:term orCommand:self.cdv_didSearchTerm];
}

- (void)didTapOnPage:(int)page atPoint:(CGPoint)point
{
    /*
     if (_delegate) {
     [_delegate didTapOnPage:page atPoint:point];
     }
     */

    [self cdvSendCallback:[NSString stringWithFormat:@"%i", page] orCommand:self.cdv_didTapOnPage];
}

- (void)didDoubleTapOnPage:(int)page atPoint:(CGPoint)point
{
    [self cdvSendCallback:[NSString stringWithFormat:@"%i", page] orCommand:self.cdv_didDoubleTapOnPage];
}

- (void)didLongPressOnPage:(int)page atPoint:(CGPoint)point
{
    [self cdvSendCallback:[NSString stringWithFormat:@"%i", page] orCommand:self.cdv_didLongPressOnPage];
}

- (void)didTapOnAnnotationOfType:(int)type atPage:(int)page atPoint:(CGPoint)point
{
    /*
     if (_delegate) {
     [_delegate didTapOnAnnotationOfType:type atPage:page atPoint:point];
     }
     */
    [self cdvSendDictCallback:@{@"index": [NSNumber numberWithInt:page], @"type": [NSNumber numberWithInt:type]} orCommand:self.cdv_didTapOnAnnotationOfType];
}

- (void)onAnnotExported:(NSString *)path
{
    [self cdvSendCallback:path orCommand:self.cdv_onAnnotExported];
}

- (void)refreshCurrentPage
{
    //[m_pdf updateAllPages];
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

- (void)getTextAnnotationDetails:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageNum = [[params objectForKey:@"page"] intValue];

    RDPDFDoc *doc = [m_pdf getDoc];
    NSMutableArray *array = [NSMutableArray array];
    NSString *json = @"";

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    RDPDFPage *page = [doc page:pageNum];

    if (page == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    [page objsStart:false];

    for (int c = 0; c < [page annotCount]; c++) {
        RDPDFAnnot *annot = [page annotAtIndex:c];
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

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

- (void)getMarkupAnnotationDetails:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageNum = [[params objectForKey:@"page"] intValue];

    RDPDFDoc *doc = [m_pdf getDoc];
    NSMutableArray *array = [NSMutableArray array];
    NSString *json = @"";

    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    RDPDFPage *page = [doc page:pageNum];

    if (page == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    [page objsStart:false];

    for (int c = 0; c < [page annotCount]; c++) {
        RDPDFAnnot *annot = [page annotAtIndex:c];
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

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

- (void)addTextAnnotation:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageNum = [[params objectForKey:@"page"] intValue];
    float x = [[params objectForKey:@"x"] floatValue];
    float y = [[params objectForKey:@"y"] floatValue];
    NSString *text = [params objectForKey:@"text"];
    NSString *subject = [params objectForKey:@"subject"];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        return;
    }

    RDPDFPage *page = [doc page:pageNum];

    if (page == nil) {
        return;
    }

    [page objsStart:false];

    PDF_POINT pt;
    pt.x = x;
    pt.y = y;
    [page addAnnotNote:&pt];

    RDPDFAnnot *annot = [page annotAtIndex:[page annotCount]-1];
    [annot setPopupText:text];
    [annot setPopupSubject:subject];

    if (annot) {
        [doc save];
        [m_pdf updatePage:pageNum];
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }

    page = nil;
    doc = nil;
}

- (void)getCharIndex:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageNum = [[params objectForKey:@"page"] intValue];
    float x = [[params objectForKey:@"x"] floatValue];
    float y = [[params objectForKey:@"y"] floatValue];

    RDPDFDoc *doc = [m_pdf getDoc];
    if (m_pdf == nil || doc == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    RDPDFPage *page = [doc page:pageNum];

    if (page == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    [page objsStart:false];

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%i", [page objsGetCharIndex:x :y]]];
}

- (void)addMarkupAnnotation:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    int pageNum = [[params objectForKey:@"page"] intValue];
    int type = [[params objectForKey:@"type"] intValue];
    int index1 = [[params objectForKey:@"index1"] intValue];
    int index2 = [[params objectForKey:@"index2"] intValue];

    RDPDFDoc *doc = [m_pdf getDoc];

    if (m_pdf == nil || doc == nil) {
        return;
    }

    RDPDFPage *page = [doc page:pageNum];

    if (page == nil) {
        return;
    }

    [page objsStart:false];

    int color = GLOBAL.g_annot_highlight_clr;
    if( type == 1 ) color = GLOBAL.g_annot_underline_clr;
    if( type == 2 ) color = GLOBAL.g_annot_strikeout_clr;
    if( type == 4 ) color = GLOBAL.g_annot_squiggly_clr;

    if ([page addAnnotMarkup:index1 :index2 :type :color]) {
        [doc save];
        [m_pdf updatePage:pageNum];
        [self cdvOkWithMessage:@"Success"];
    } else {
        [self cdvErrorWithMessage:@"Failure"];
    }

    page = nil;
    doc = nil;
}

#pragma mark - PDF/Screen rect and coordinates

- (void)getPDFCoordinates:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    float x = [[params objectForKey:@"x"] floatValue];
    float y = [[params objectForKey:@"y"] floatValue];

    if (m_pdf == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    CGPoint pdfPoints = [m_pdf pdfPointsFromScreenPoints:x :y];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pdfPoints.x], @"x",[NSNumber numberWithInt:pdfPoints.y], @"y", nil];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

- (void)getScreenCoordinates:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    float x = [[params objectForKey:@"x"] floatValue];
    float y = [[params objectForKey:@"y"] floatValue];
    int pageNum = [[params objectForKey:@"page"] intValue];

    if (m_pdf == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    CGPoint pdfPoints = [m_pdf screenPointsFromPdfPoints:x :y :pageNum];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pdfPoints.x], @"x",[NSNumber numberWithInt:pdfPoints.y], @"y", nil];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

- (void)getPDFRect:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    float x = [[params objectForKey:@"x"] floatValue];
    float y = [[params objectForKey:@"y"] floatValue];
    float width = [[params objectForKey:@"width"] floatValue];
    float height = [[params objectForKey:@"height"] floatValue];

    if (m_pdf == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
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

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

- (void)getScreenRect:(CDVInvokedUrlCommand *)command
{
    self.cdv_command = command;
    NSDictionary *params = (NSDictionary*) [cdv_command argumentAtIndex:0];
    float left = [[params objectForKey:@"left"] floatValue];
    float top = [[params objectForKey:@"top"] floatValue];
    float right = [[params objectForKey:@"right"] floatValue];
    float bottom = [[params objectForKey:@"bottom"] floatValue];
    int pageNum = [[params objectForKey:@"page"] intValue];

    if (m_pdf == nil) {
        [self cdvErrorWithMessage:@"Failure"];
        return;
    }

    CGRect rect = [m_pdf screenRectFromPdfRect:left :top :right :bottom :pageNum];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:rect.origin.x], @"x",[NSNumber numberWithFloat:rect.origin.y], @"y",[NSNumber numberWithFloat:rect.size.width], @"width",[NSNumber numberWithFloat:rect.size.height], @"height", nil];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [self cdvOkWithMessage:[NSString stringWithFormat:@"%@", json]];
}

@end
