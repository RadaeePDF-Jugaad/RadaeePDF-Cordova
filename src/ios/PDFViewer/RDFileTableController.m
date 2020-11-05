//
//  RDFileTableController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "RDFileTableController.h"
#define testUrlPath @"https://www.radaeepdf.com/documentation/MRBrochoure.pdf"

//NSMutableString *pdfName;
//NSMutableString *pdfPath;

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

@implementation RDFileItem
-(id)init:(NSString *)help :(NSString *)path :(int)level
{
    self = [super init];
    if(self)
    {
        _help = help;
        _path = path;
        _level = level;
        _locker = [[RDVLocker alloc] init];
    }
    return self;
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
        if( [fm fileExistsAtPath:dst isDirectory:&dir] )
        {
            if( dir )
            {
                [self addPDFs:dpath :dst :fm :level+1];
            }
            else if( [dst hasSuffix:@".pdf"] )
            {
                NSString *dis = [subdir stringByAppendingFormat:@"%@",fName];//display name
                RDFileItem *item = [[RDFileItem alloc] init:dis :dst :level];
                [m_files addObject:item];
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
                RDFileItem *item = [[RDFileItem alloc] init:dis :dst :level];
                [m_files addObject:item];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    m_files = [[NSMutableArray alloc] init];
    [self addPDFs:dpath :@"" :fm :0];
    
    NSString *title = [[NSString alloc] initWithFormat:NSLocalizedString(@"All Files", @"Localizable")];
    self.title = title;
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@"btn_outline"] tag:0];
    
    self.tabBarItem =item;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self copyDocumentsFromAssets:dpath];
    
    //test demo for PDFMemOpen or PDFStreamOpen or HTTPPDFStream，click right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Url" style:UIBarButtonItemStylePlain target:self action:@selector(selectRightAction)];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    UILabel *label = nil;
    if(!cell)
    {
        CGRect rc = self.view.frame;
        CGRect rect = CGRectMake(0, 0, rc.size.width, 25);
        cell = [[UITableViewCell alloc] initWithFrame:rect];
        //get  ios version
        if([[[UIDevice currentDevice]systemVersion] floatValue]>=7.0)
        {
            //above ios7
            rect.origin.x += 70;
            rect.origin.y += 15;
            rect.size.width -= 4;
            rect.size.height -= 4;
        }
        else
        {
            rect.origin.x += 60;
            rect.origin.y += 15;
            rect.size.width -= 4;
            rect.size.height -= 4;
        }
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = 1;
        label.font = [UIFont systemFontOfSize:rect.size.height - 4];
        [cell.contentView addSubview:label];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [[UIColor alloc] initWithWhite:1 alpha:0];
    }
    else label = (UILabel *)[cell.contentView viewWithTag:1];
    NSUInteger row = [indexPath row];
    RDFileItem *item = [m_files objectAtIndex:row];
    cell.textLabel.numberOfLines = 0;
    UIImage *image = [UIImage imageNamed:@"encrypt"];
    cell.imageView.image = image;
    label.text = item.help;
    return cell;
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
    
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    NSString *path = item.path;
    [item.locker lock];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path error:nil];
    [m_files removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [item.locker unlock];
}

- (void)pdf_open_path:(RDFileItem *)item :(NSString *)pswd
{
    if( m_pdf == nil )
        {
            m_pdf = [[RDLoPDFViewController alloc] initWithNibName:@"RDLoPDFViewController" bundle:nil];
            m_pdf.view.frame = self.view.frame;
        }
        
        NSLock *theLock = [[NSLock alloc] init];
                    
        if ([theLock tryLock])
        {
            //Open PDF file
            int result = [m_pdf PDFOpen:item.path :pswd];

            if(result == 1)
            {
                m_pdf.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:m_pdf animated:YES];
            }
            //return value is encryption document
            else if(result == 2)
            {
                NSString *title = NSLocalizedString(@"Please Enter PassWord", @"Localizable");
                UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
                [pwdAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = NSLocalizedString(@"PassWord", @"Localizable");
                    textField.secureTextEntry = YES;
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    UITextField *password = pwdAlert.textFields.firstObject;
                    if (![password.text isEqualToString:@""]) {
                        int result = [self->m_pdf PDFOpen:item.path :password.text];
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

- (void)openPageMode:(RDFileItem *)item :(NSString *)pswd
{
    //Open PDF file
    m_pdfP = [[RDPageViewController alloc] initWithNibName:@"RDPageViewController" bundle:nil];
    [item.locker lock];
    int result = [m_pdfP PDFOpenAtPath:item.path withPwd:pswd];
    [item.locker unlock];
    if(result == 1)//succeeded
    {
        m_pdfP.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:m_pdfP animated:YES];
    }
    else if(result == 2)//require password
    {
        NSString *title = NSLocalizedString(@"Please Enter PassWord", @"Localizable");
        UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [pwdAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
        {
            textField.placeholder = NSLocalizedString(@"PassWord", @"Localizable");
            textField.secureTextEntry = YES;
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UITextField *password = pwdAlert.textFields.firstObject;
            [self openPageMode:item :password.text];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Localizable")  style:UIAlertActionStyleCancel handler:nil];
        
        [pwdAlert addAction:okAction];
        [pwdAlert addAction:cancel];
        [self presentViewController:pwdAlert animated:YES completion:nil];
    }
    else//error
    {
        NSString *str1 = NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2 = NSLocalizedString(@"Error Document,Can't open", @"Localizable");
        NSString *str3 = NSLocalizedString(@"OK", @"Localizable");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                                                       message:str2
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openReflowMode:(RDFileItem *)item :(NSString *)pswd
{
    //Open PDF file
    m_pdfR = [[RDPDFReflowViewController alloc] initWithNibName:@"RDPDFReflowViewController" bundle:nil];
    [item.locker lock];
    int result = [m_pdfR PDFOpen:item.path :pswd];
    [item.locker unlock];
    if(result == 1)//succeeded
    {
        m_pdfR.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:m_pdfR animated:YES];
    }
    else if(result == 2)//require password
    {
        NSString *title = NSLocalizedString(@"Please Enter PassWord", @"Localizable");
        UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [pwdAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"PassWord", @"Localizable");
             textField.secureTextEntry = YES;
         }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UITextField *password = pwdAlert.textFields.firstObject;
            [self openReflowMode:item :password.text];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Localizable")  style:UIAlertActionStyleCancel handler:nil];
        
        [pwdAlert addAction:okAction];
        [pwdAlert addAction:cancel];
        [self presentViewController:pwdAlert animated:YES completion:nil];
    }
    else//error
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1 message:str2 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    if (GLOBAL.g_render_mode == 2)
        [self openPageMode:item :nil];
    else if(GLOBAL.g_render_mode == 5)
        [self openReflowMode:item :nil];
    else
        [self pdf_open_path:item :nil];
}
    
- (void)presentPwdAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
}

- (void)copyDocumentsFromAssets:(NSString *)dpath
{
    NSString *hf = [[NSBundle mainBundle] pathForResource:@"fdat" ofType:nil];
    for (NSString *fpath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:hf error:nil]) {
        if([fpath.pathExtension isEqualToString:@"pdf"] || [fpath.pathExtension isEqualToString:@"PDF"]) {
            
            NSString *documentPath = [hf stringByAppendingPathComponent:fpath];
            NSString *destPath = [dpath stringByAppendingPathComponent:fpath];
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
                [[NSFileManager defaultManager] copyItemAtPath:documentPath toPath:destPath error:nil];
                RDFileItem *item = [[RDFileItem alloc] init:[fpath stringByDeletingPathExtension] :destPath :0];
                [m_files addObject:item];
            }
        }
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
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    NSString *path = item.path;
    CGImageRef img_ref = nil;

    const char *cpath = [path UTF8String];
    [item.locker lock];
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
            default:
                result = 0;
                break;
        }
    }
    else
    {
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
        Document_close(m_docThumb);
        void *data = Global_dibGetData(bmp);
        CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, iw * ih * 4, NULL );
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
        img_ref = CGImageCreate( iw, ih, 8, 32, iw<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
        CGColorSpaceRelease(cs);
        CGDataProviderRelease( provider );
    }
    [item.locker unlock];
    if(!img_ref) return;
    UIImage *img= [UIImage imageWithCGImage:img_ref];
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
    });
}

@end
