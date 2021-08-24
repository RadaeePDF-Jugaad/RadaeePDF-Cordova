//
//  RDFileCollectionViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 18/06/2020.
//

#import "RDFileCollectionViewController.h"
#import "RDUtils.h"

@interface RDFileCollectionViewController ()

@end

@implementation RDFileCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"RDFileCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
    // Do any additional setup after loading the view.
    [self refreshDouments];
    NSString *title = [[NSString alloc] initWithFormat:NSLocalizedString(@"All Files", @"Localizable")];
    self.title = title;
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@"btn_files"] tag:0];
       
    self.tabBarItem = item;
    UIBarButtonItem *link = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_link"] style:UIBarButtonItemStylePlain target:self action:@selector(showOpenFromUrlAlert)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshCollectionOnEdit)];
    self.navigationItem.leftBarButtonItem = link;
    self.navigationItem.rightBarButtonItem = refresh;
       
    
}

- (void)refreshDouments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dpath = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    m_files = [[NSMutableArray alloc] init];
    [self addPDFs:dpath :@"" :fm :0];
    [self copyDocumentsFromAssets:dpath];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [m_files count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RDFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    cell.fileName.text = item.help;
    cell.indexPath = indexPath;
    cell.delegate = self;
    [cell.imgPreview setImage:[self setImageForCellAtIndexPath:indexPath]];
    if (!cell.imgPreview.image && [item.help hasSuffix:@".pdf"]) {
        cell.imgPreview.image = [UIImage imageNamed:@"encrypt"];
    }
    [cell setShadow];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    if (GLOBAL.g_render_mode == 2)
        [self pdf_open_path_page:item :nil];
    else if(GLOBAL.g_render_mode == 5)
        [self pdf_open_path_reflow:item :nil];
    else
        [self pdf_open_path:item :nil];
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] bounds].size.width <= 375) {
            return CGSizeMake(150, 150);
        }
        return CGSizeMake(170, 170);
    }
    return CGSizeMake(200, 200);
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}
*/

#pragma mark - Files
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

- (void)copyDocumentsFromAssets :(NSString *)dpath
{
    NSString *hf = [[NSBundle mainBundle] pathForResource:@"PDFRes" ofType:nil];
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

- (UIImage *)setImageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    NSString *path = item.path;
    CGImageRef img_ref = nil;

    const char *cpath = [path UTF8String];
    [item.locker lock];
    PDF_ERR err;
    Document_setOpenFlag(3);
    PDF_DOC m_docThumb = Document_open(cpath,nil, &err);
    Document_setOpenFlag(1);
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
        int iw = 200;
        int ih = 200;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            ih = 200;
            iw = 200;
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
    if(!img_ref) return nil;
    return [UIImage imageWithCGImage:img_ref];
}

- (void)pdf_open_path:(RDFileItem *)item :(NSString *)pswd
{
    //Open PDF file
    PDFDoc *doc = [[PDFDoc alloc] init];
    [item.locker lock];
    int result = [doc open:item.path :pswd];
    [item.locker unlock];
    if(result == 0)//succeeded
    {
        m_pdf = [[UIStoryboard storyboardWithName:@"PDFReaderCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfreader"];
        [m_pdf setDoc:doc];
        m_pdf.hidesBottomBarWhenPushed = YES;
        GLOBAL.g_pdf_name = [NSMutableString stringWithString:[item.path lastPathComponent]];
        [self.navigationController pushViewController:m_pdf animated:YES];
    }
    else if(result == 2)//require password
    {
        [self pdf_show_pwd_error:^(NSString *pwd) {
            [self pdf_open_path:item :pwd];
        }];
    }
    else//error
    {
        NSString *str1 = NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2 = NSLocalizedString(@"Error Document,Can't open", @"Localizable");
        NSString *str3 = NSLocalizedString(@"OK", @"Localizable");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1 message:str2 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)pdf_open_path_page:(RDFileItem *)item :(NSString *)pswd
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
        [self pdf_show_pwd_error:^(NSString *pwd) {
            [self pdf_open_path_page:item :pwd];
        }];
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

- (void)pdf_open_path_reflow:(RDFileItem *)item :(NSString *)pswd
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
        [self pdf_show_pwd_error:^(NSString *pwd) {
            [self pdf_open_path_reflow:item :pwd];
        }];
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

- (void)pdf_show_pwd_error:(void (^)(NSString *pwd))success
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
        success(password.text);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Localizable")  style:UIAlertActionStyleCancel handler:nil];
    
    [pwdAlert addAction:okAction];
    [pwdAlert addAction:cancel];
    [self presentViewController:pwdAlert animated:YES completion:nil];
}

#pragma mark - Url

- (void)showOpenFromUrlAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open from URL" message:@"Please insert URL" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = @"Insert PDF URL here";
    }];
    UIAlertAction *demo = [UIAlertAction actionWithTitle:@"Demo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openPDFWithUrl:testUrlPath];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *urlTextField = alert.textFields.firstObject;
        [self openPDFWithUrl:urlTextField.text];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:open];
    [alert addAction:demo];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openPDFWithUrl:(NSString *)url {
    
    if( m_pdf == nil )
    {
        m_pdf = [[UIStoryboard storyboardWithName:@"PDFReaderCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfreader"];
    }
    
    // OPENHTTP
    NSString *testfile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cache.pdf"];
    httpStream = [[PDFHttpStream alloc] init];
    [httpStream open:url :testfile];
    PDFDoc *doc = [[PDFDoc alloc] init];
    [PDFDoc setOpenFlag:3];
    int error = [doc openStream:httpStream :@""];
    
    switch(error)
    {
        case err_ok: {
                [doc getLinearizedStatus];
                [m_pdf setDoc:doc :YES];
                GLOBAL.g_pdf_name = [NSMutableString stringWithFormat:@"%@", [url lastPathComponent]];
                m_pdf.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:m_pdf animated:YES];
            }
            break;
        default: {
               NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
               NSString *str2=NSLocalizedString(@"Error Document,Can't open", @"Localizable");
               NSString *str3=NSLocalizedString(@"OK", @"Localizable");
               UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1 message:str2 preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
               [alert addAction:okAction];
               [self presentViewController:alert animated:YES completion:nil];
            }
            break;
    }
}

#pragma mark - RDCollectionViewCell delegate

- (void)showInfosAtIndexPath:(NSIndexPath *)indexPath
{
    RDFileItem *item = [m_files objectAtIndex:indexPath.row];
    RDFileDetailViewController *fileDetail = [[RDFileDetailViewController alloc]initWithNibName:@"RDFileDetailViewController" bundle:nil];
    fileDetail.coverImage = [self setImageForCellAtIndexPath:indexPath];
    fileDetail.pdfPath = item.path;
    fileDetail.delegate = self;
    fileDetail.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    fileDetail.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:fileDetail animated:YES completion:nil];
}

#pragma mark - RDFileDetailViewController delegate

- (void)showSelectedFileMeta:(NSString *)pdfPath
{
    PDFDoc *doc = [[PDFDoc alloc] init];
    __block BOOL error = [doc open:pdfPath :@""];
    if (error) {
        [self pdf_show_pwd_error:^(NSString *pwd) {
            error = [doc open:pdfPath :pwd];
        }];
    }
    
    RDMetaDataViewController *metaViewController = [[RDMetaDataViewController alloc] initWithNibName:@"RDMetaDataViewController" bundle:nil];
    metaViewController.doc = doc;
    metaViewController.autoSave = YES;
    metaViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    metaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:metaViewController animated:YES completion:nil];
    
}

- (void)refreshCollectionOnEdit
{
    [self refreshDouments];
    [self.collectionView reloadData];
}

@end
