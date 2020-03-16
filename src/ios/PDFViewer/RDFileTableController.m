//
//  RDFileTableController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "RDFileTableController.h"
#define testUrlPath @"http://www.radaee.com/files/test.pdf"

NSMutableString *pdfName;
NSMutableString *pdfPath;
NSString *pdfFullPath;

@interface RDFileTableController ()

@end

//Open pdf file from filestream
@implementation PDFFileStream

-(void)open :(NSString *)filePath
{
    //fileHandle = [NSFileHandle fileHandleForReadingAtPath:testfile];
    const char *path = [filePath UTF8String];
    if((m_file = fopen(path, "rb+"))){
        m_writable = true;
    }
    else {
        m_file = fopen(path,"rb");
        m_writable = false;
    }
}
-(bool)writeable
{
    return m_writable;
}
-(void)close :(NSString *)filePath
{
    if( m_file )
        fclose(m_file);
    m_file = NULL;
}
-(int)read: (void *)buf : (int)len
{
    if( !m_file ) return 0;
    int read = (int)fread(buf, 1, len,m_file);
    return read;
}
-(int)write:(const void *)buf :(int)len
{
    if( !m_file ) return 0;
    return (int)fwrite(buf, 1, len, m_file);
}

-(unsigned long long)position
{
    if( !m_file ) return 0;
    int pos = (int)ftell(m_file);
    return pos;
}

-(unsigned long long)length
{
    if( !m_file ) return 0;
    int pos = (int)ftell(m_file);
    fseek(m_file, 0, SEEK_END);
    int filesize = (int)ftell(m_file);
    fseek(m_file, pos, SEEK_SET);
    return filesize;
}

-(bool)seek:(unsigned long long)pos
{
    if( !m_file ) return false;
    fseek(m_file, (int)pos , SEEK_SET);
    return true;
}
@end


@implementation RDFileTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    return self;
}
#pragma mark -addFiles
- (void)addPDFs:(NSString *)dpath :(NSString *)subdir :(NSFileManager *)fm :(int)level
{
    NSString *path = [dpath stringByAppendingFormat:@"/%@", subdir];
    NSDirectoryEnumerator *fenum = [fm enumeratorAtPath:path];
    NSString *fName;
    while(fName = [fenum nextObject])
    {
        BOOL dir;
        NSString *dst = [path stringByAppendingFormat:@"%@",fName];
        pdfPath = (NSMutableString *)path;
        if( [fm fileExistsAtPath:dst isDirectory:&dir] )
        {
            if( dir )
            {
                [self addPDFs:dpath :dst :fm :level+1];
            }
            else if( [dst hasSuffix:@".pdf"] )
            {
                NSString *dis = [subdir stringByAppendingFormat:@"%@",fName];//display name
                
                //add to list
                NSArray *arr = [[NSArray alloc] initWithObjects:dis,dst,level, nil];
                [m_files addObject:arr];
            }
        }
    }
}

- (void)delPDFs:(NSString *)dpath :(NSString *)subdir :(NSFileManager *)fm :(int)level
{
    NSString *path = [dpath stringByAppendingFormat:@"/%@", subdir];
    NSDirectoryEnumerator *fenum = [fm enumeratorAtPath:path];
    NSString *fName;
    while(fName = [fenum nextObject])
    {
        BOOL dir;
        NSString *dst = [path stringByAppendingFormat:@"/%@",fName];
        if( [fm fileExistsAtPath:dst isDirectory:&dir] )
        {
            if( dir )
            {
                [self addPDFs:dpath :dst :fm :level+1];
            }
            else if( [dst hasSuffix:@".pdf"] )
            {
                NSString *dis = [subdir stringByAppendingFormat:@"%@",fName];//display name
                
                NSArray *arr = [[NSArray alloc] initWithObjects:dis,dst,level, nil];
                
                [m_files addObject:arr];
            }
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice]systemVersion] floatValue]>=7.0)
    {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath=[paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    m_files = [[NSMutableArray alloc] init];
    [self addPDFs:dpath :@"" :fm :0];
    
    NSString *title = [[NSString alloc] initWithFormat:NSLocalizedString(@"All Files", @"Localizable")];
    self.title = title;
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@"btn_outline"] tag:0];
    
    self.tabBarItem =item;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self initSettingWithUserDefault:dpath];
    //test demo for PDFMemOpen or PDFStreamOpen or HTTPPDFStream，click right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(selectRightAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
}
-(void)selectRightAction
{
    NSLog(@"click right");
    if( m_pdf == nil )
    {
        m_pdf = [[RDLoPDFViewController alloc] init];
    }
    
    // OPENHTTP
    [self openPDFWithUrl];
    
    // OPENMEM
    //[self openPDFWithMem];
    
    m_pdf.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:m_pdf animated:YES];
}

- (void)openPDFWithUrl {
    NSString *testfile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cache.pdf"];
    
    httpStream = [[PDFHttpStream alloc] init];
    [httpStream open:testUrlPath :testfile];
    [m_pdf PDFOpenStream:httpStream :@""];
}

- (void)openPDFWithMem {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath=[paths objectAtIndex:0];
    
    NSString *hf = [[NSBundle mainBundle]pathForResource:@"help" ofType:@"pdf" inDirectory:@"fdat"];
    NSString *helpfile = [hf substringFromIndex:hf.length-8];
    NSString *documentPath = [dpath stringByAppendingString: [NSString stringWithFormat:@"/%@",helpfile]];
    
    [[NSFileManager defaultManager] copyItemAtPath:hf toPath:documentPath error:nil];
    
    
    NSString *testfile1 = documentPath;
    
    char *path1 = (char *)[testfile1 UTF8String];
    FILE *file1 = fopen(path1, "rb");
    fseek(file1, 0, SEEK_END);
    int filesize1 = (int)ftell(file1);
    fseek(file1, 0, SEEK_SET);
    buffer = malloc((filesize1)*sizeof(char));
    fread(buffer, filesize1, 1, file1);
    fclose(file1);
    
    [m_pdf PDFOpenMem: buffer :filesize1 :nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = nil;
    //get  ios version
    if([[[UIDevice currentDevice]systemVersion] floatValue]>=7.0)
    {
        //above ios7
        if( cell == nil )
        {
            CGRect rc = self.view.frame;
            CGRect rect = CGRectMake(0, 0, rc.size.width, 25);
            
            cell = [[UITableViewCell alloc] initWithFrame:rect];
            rect.origin.x += 70;
            rect.origin.y += 15;
            rect.size.width -= 4;
            rect.size.height -= 4;
            label = [[UILabel alloc] initWithFrame:rect];
            label.tag = 1;
            label.font = [UIFont systemFontOfSize:rect.size.height - 4];
            [cell.contentView addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if( label == nil )
            label = (UILabel *)[cell.contentView viewWithTag:1];
        
        NSUInteger row = [indexPath row];
        NSArray *arr = [m_files objectAtIndex:row];
        cell.textLabel.numberOfLines = 0;
        UIImage *image = [UIImage imageNamed:@"encrypt.png"];
        cell.imageView.image = image;
        label.text = [arr objectAtIndex:0];
        return cell;
    }
    else
    {
        if( cell == nil )
        {
            CGRect rc = self.view.frame;
            CGRect rect = CGRectMake(0, 0, rc.size.width, 25);
            
            cell = [[UITableViewCell alloc] initWithFrame:rect];
            rect.origin.x += 60;
            rect.origin.y += 15;
            rect.size.width -= 4;
            rect.size.height -= 4;
            label = [[UILabel alloc] initWithFrame:rect];
            label.tag = 1;
            label.font = [UIFont systemFontOfSize:rect.size.height - 4];
            [cell.contentView addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if( label == nil )
            label = (UILabel *)[cell.contentView viewWithTag:1];
        
        NSUInteger row = [indexPath row];
        NSArray *arr = [m_files objectAtIndex:row];
        cell.textLabel.numberOfLines = 0;
        UIImage *image = [UIImage imageNamed:@"encrypt.png"];
        cell.imageView.image = image;
        label.text = [arr objectAtIndex:0];
        return cell;
        
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger row = [indexPath row];
    
    if( m_pdf == nil )
    {
        m_pdf = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
    }
    
    NSArray *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectAtIndex:1];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    [m_files removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //GEAR
    [self loadSettingsWithDefaults];
    //END
    NSArray *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectAtIndex:1];
    
    pdfName = (NSMutableString *)[path substringFromIndex:pdfPath.length];
    pdfFullPath = path;
    
    if (GLOBAL.g_render_mode == 2) {
        m_pdfP = [[RDPageViewController alloc] initWithNibName:@"RDPageViewController" bundle:nil];
        
        NSLock *theLock = [[NSLock alloc] init];
        if ([theLock tryLock])
        {
            NSString *pwd = NULL;
            
            //Set PDF file
            int result = [m_pdfP PDFOpenAtPath:pdfFullPath withPwd:pwd];

            if(result == 1)
            {
                m_pdfP.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:m_pdfP animated:YES];
            }
            //return value is encryption document
            else if(result == 2)
            {
                [self presentPwdAlertControllerWithTitle:NSLocalizedString(@"Please Enter PassWord", @"Localizable") message:nil];
            }
            else if (result == 0)
            {
                NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
                NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
                NSString *str3=NSLocalizedString(@"OK", @"Localizable");
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                           message:str2
                                           preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            [theLock unlock];
        }
        
    } else {
        if( m_pdf == nil )
            {
                m_pdf = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
            }
            
            NSLock *theLock = [[NSLock alloc] init];
            
            if(GLOBAL.g_render_mode == 5) {
                m_pdfR = [[RDPDFReflowViewController alloc] initWithNibName:@"RDPDFReflowViewController" bundle:nil];
                [m_pdfR PDFOpen:pdfFullPath];
                
                m_pdfR.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:m_pdfR animated:YES];
                return;
            }
            
            if ([theLock tryLock])
            {
                NSString *pwd = NULL;
                
                //Open PDF file
                int result = [m_pdf PDFOpen:pdfFullPath :pwd];

                if(result == 1)
                {
                    m_pdf.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:m_pdf animated:YES];
                }
                //return value is encryption document
                else if(result == 2)
                {
                    [self presentPwdAlertControllerWithTitle:NSLocalizedString(@"Please Enter PassWord", @"Localizable") message:nil];
                }
                else if (result == 0)
                {
                    NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
                    NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
                    NSString *str3=NSLocalizedString(@"OK", @"Localizable");
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                               message:str2
                                               preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                [theLock unlock];
            }
        }
    }
    
/*
- (void)alertView:(UIAlertView *)pwdDlg clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int result;
    NSString *pwd;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        UITextField *tf = [pwdDlg textFieldAtIndex:0];
        pwd = tf.text;
    }
    if(buttonIndex == 0)
    {
        result = [m_pdf PDFOpen:pdfFullPath :pwd];

        if(result == 1)
        {
            UINavigationController *nav = self.navigationController;
            m_pdf.hidesBottomBarWhenPushed = YES;
            nav.hidesBottomBarWhenPushed =NO;
            [nav pushViewController:m_pdf animated:YES];
        }
        else if(result == 2)
        {
            NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
            NSString *str2=NSLocalizedString(@"Error PassWord", @"Localizable");
            NSString *str3=NSLocalizedString(@"OK", @"Localizable");
            UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:nil cancelButtonTitle:str3 otherButtonTitles:nil,nil];
            [alter show];
        }
    }
    
}
 */

- (void)presentPwdAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [pwdAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"PassWord", @"Localizable");
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UITextField *password = pwdAlert.textFields.firstObject;
        if (![password.text isEqualToString:@""]) {
            int result = [self->m_pdf PDFOpen:pdfFullPath :password.text];
                if(result == 1)
                {
                    UINavigationController *nav = self.navigationController;
                    self->m_pdf.hidesBottomBarWhenPushed = YES;
                    nav.hidesBottomBarWhenPushed =NO;
                    [nav pushViewController:self->m_pdf animated:YES];
                }
                else if(result == 2)
                {
                    NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
                    NSString *str2=NSLocalizedString(@"Error PassWord", @"Localizable");
                    [self presentPwdAlertControllerWithTitle:str1 message:str2];
                }
        }
        else
        {
            [self presentViewController:pwdAlert animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Localizable")  style:UIAlertActionStyleCancel handler:nil];
    
    [pwdAlert addAction:okAction];
    [pwdAlert addAction:cancel];
    [self presentViewController:pwdAlert animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

- (void)loadSettingsWithDefaults
{
    GLOBAL.g_case_sensitive = [[NSUserDefaults standardUserDefaults] boolForKey:@"CaseSensitive"];
    GLOBAL.g_match_whole_word = [[NSUserDefaults standardUserDefaults] boolForKey:@"MatchWholeWord"];
    
    GLOBAL.g_screen_awake = [[NSUserDefaults standardUserDefaults] boolForKey:@"KeepScreenAwake"];
    [[UIApplication sharedApplication] setIdleTimerDisabled:GLOBAL.g_screen_awake];
    
    GLOBAL.g_render_quality = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RenderQuality"];
    if(GLOBAL.g_render_quality == 0)
    {
        GLOBAL.g_render_quality =1;
    }
    
    GLOBAL.g_render_mode =  (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"ViewMode"];
    
    //for curl mode
    GLOBAL.g_curl_enabled = (GLOBAL.g_render_mode == 2);
    
    GLOBAL.g_ink_color = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"InkColor"];
    if(GLOBAL.g_ink_color == 0)
    {
        GLOBAL.g_ink_color = 0xFF0000FF;
    }
    
    GLOBAL.g_ink_width = [[NSUserDefaults standardUserDefaults] floatForKey:@"InkWidth"];
    if (GLOBAL.g_ink_width == 0) {
        GLOBAL.g_ink_width = 2.0f;
    }
    
    GLOBAL.g_rect_color = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RectColor"];
    if(GLOBAL.g_rect_color==0)
    {
        GLOBAL.g_rect_color =0xFF0000FF;
    }
    
    GLOBAL.g_annot_underline_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UnderlineColor"];
    if (GLOBAL.g_annot_underline_clr == 0) {
        GLOBAL.g_annot_underline_clr = 0xFF0000FF;
    }
    GLOBAL.g_annot_strikeout_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"StrikeoutColor"];
    if (GLOBAL.g_annot_strikeout_clr == 0) {
        GLOBAL.g_annot_strikeout_clr = 0xFFFF0000;
    }
    GLOBAL.g_annot_highlight_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"HighlightColor"];
    if(GLOBAL.g_annot_highlight_clr ==0)
    {
        GLOBAL.g_annot_highlight_clr =0xFFFFFF00;
    }
    GLOBAL.g_oval_color = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"OvalColor"];
    if(GLOBAL.g_oval_color ==0)
    {
        GLOBAL.g_oval_color =0xFFFFFF00;
    }
}

- (void)initSettingWithUserDefault :(NSString *)dpath
{
    NSString *hf = [[NSBundle mainBundle]pathForResource:@"help" ofType:@"pdf" inDirectory:@"fdat"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool b_helpfile = [userDefaults boolForKey:@"helpfileLoaded"];
    if (!b_helpfile)
    {
        //[m_files addObject:[NSArray arrayWithObjects:helpfile, hf, 0, nil]];
        NSString *helpfile = [hf substringFromIndex:hf.length-8];
        
        NSString *documentPath = [dpath stringByAppendingString: [NSString stringWithFormat:@"/%@",helpfile]];
        
        [[NSFileManager defaultManager] copyItemAtPath:hf toPath:documentPath error:nil];
        
        [m_files addObject:[NSArray arrayWithObjects:helpfile,documentPath,0,nil]];
        [[NSUserDefaults standardUserDefaults]  setBool:true forKey:@"helpfileLoaded"];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"CaseSensitive"];
        GLOBAL.g_case_sensitive = FALSE;
        
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"MatchWholeWord"];
        GLOBAL.g_match_whole_word = FALSE;
        
        [[NSUserDefaults standardUserDefaults] setFloat:0.1f forKey:@"SwipeSpeed"];
        GLOBAL.g_swipe_speed = 0.15f;
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"RenderQuality"];
        GLOBAL.g_render_quality =1;
        
        GLOBAL.g_swipe_distance = 1.0f;
        [[NSUserDefaults standardUserDefaults] setFloat:GLOBAL.g_swipe_distance forKey:@"SwipeDistance"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ViewMode"];
        GLOBAL.g_render_mode =0;
        
        [[NSUserDefaults standardUserDefaults]  setBool:FALSE forKey:@"SelectTextRight"];
        GLOBAL.g_sel_right = FALSE;
        
        [[NSUserDefaults standardUserDefaults]  setBool:FALSE forKey:@"KeepScreenAwake"];
        GLOBAL.g_screen_awake = FALSE;
        [[UIApplication sharedApplication] setIdleTimerDisabled:GLOBAL.g_screen_awake];
        
        [[NSUserDefaults standardUserDefaults]  setInteger:0xFF000000 forKey:@"InkColor"];
        GLOBAL.g_ink_color = 0xFF000000;
        [[NSUserDefaults standardUserDefaults]  setInteger:0xFF000000 forKey:@"RectColor"];
        GLOBAL.g_rect_color = 0xFF000000;
        [[NSUserDefaults standardUserDefaults]  setInteger:0xFF000000 forKey:@"OvalColor"];
        GLOBAL.g_oval_color = 0xFF000000;
        GLOBAL.g_ink_width = 2.0f;
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSThread detachNewThreadSelector:@selector(updateImageForCellAtIndexPath:) toTarget:self withObject:indexPath];
}

- (void)updateImageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *row_item = [m_files objectAtIndex:indexPath.row];
    NSString *path = [row_item objectAtIndex:1];
    CGImageRef img_ref = nil;
    @synchronized (self) {
        const char *cpath = [path UTF8String];
        PDF_ERR err;
        PDF_DOC m_docThumb = Document_open(cpath,nil, &err);
        int result = 1;
        if( m_docThumb == NULL )
        {
            switch( err )
            {
                case err_password:
                    result = 2;
                    break;
                default: result = 0;
            }
        }
        
        PDF_PAGE page = Document_getPage(m_docThumb, 0);
        float w = Document_getPageWidth(m_docThumb,0);
        float h = Document_getPageHeight(m_docThumb,0);
        PDF_DIB m_dib = NULL;
        int iw = 89;
        int ih = 111;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            ih = 105;
            iw = 80;
        }
        PDF_DIB bmp = Global_dibGet(m_dib, iw, ih);
        float ratiox = iw/w;
        float ratioy = ih/h;
        if( ratiox > ratioy ) ratiox = ratioy;
        PDF_MATRIX mat = Matrix_createScale(ratiox, -ratiox, 0, h * ratioy);
        Page_renderPrepare( page, bmp );
        Page_render(page, bmp, mat,false,1);
        Matrix_destroy(mat);
        Page_close(page);
        
        if(m_docThumb) Document_close(m_docThumb);
        
        void *data = Global_dibGetData(bmp);
        CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, iw * ih * 4, NULL );
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
        img_ref = CGImageCreate( iw, ih, 8, 32, iw<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
        CGColorSpaceRelease(cs);
        CGDataProviderRelease( provider );
    }
    
    UIImage *img= [UIImage imageWithCGImage:img_ref];
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
    });
}

@end
