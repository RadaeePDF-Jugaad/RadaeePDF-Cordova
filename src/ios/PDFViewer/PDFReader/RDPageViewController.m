//
//  RDPageViewController.m
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import "RDPageViewController.h"
#import "RDSinglePageViewController.h"

@interface RDPageViewController ()
{
    PDFDoc *doc;
    BOOL statusBarHidden;
    BOOL isImmersive;
    int pageno;
    int bgColor;
}

@end

@implementation RDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIViewController *vc = [self viewControllerAtIndex:0];
    [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(closeView)];
}

- (int)PDFOpenAtPath:(NSString *)path withPwd:(NSString *)pwd
{
    doc = [[PDFDoc alloc] init];
    int err_code = [doc open:path :pwd];
    switch(err_code)
    {
        case err_ok:
            return 1;
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    RDSinglePageViewController *viewController = [[RDSinglePageViewController alloc] init];
    viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    viewController.doc = doc;
    viewController.pageViewNo = index;
    pageno = (int)index+1;
    if (bgColor)
    {
        CGFloat r = ((bgColor >> 16)&255) / 255.0;
        CGFloat g = ((bgColor >> 8)&255) / 255.0;
        CGFloat b = (bgColor&255) / 255.0;
        CGFloat a = ((bgColor >> 24)&255) / 255.0;
        viewController.pdfView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return viewController;
}

- (BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

#pragma mark - Page View Controller Data Source

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [doc pageCount];
}
 
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((RDSinglePageViewController*) viewController).pageViewNo;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}
 
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((RDSinglePageViewController*) viewController).pageViewNo;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == doc.pageCount) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    for (RDSinglePageViewController *v in previousViewControllers) {
        if(v.pdfView != nil)
        {
            [self closeViewController:v];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)closeView
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self PDFClose];
}

-(void)PDFClose
{
    for (RDSinglePageViewController *v in self.viewControllers) {
        if(v.pdfView != nil)
        {
            [self closeViewController:v];
        }
    }
    
    doc = NULL;
}

- (void)closeViewController:(RDSinglePageViewController *)v {
    if(v.pdfView != nil)
    {
        [v.pdfView PDFClose];
        [v.pdfView removeFromSuperview];
        v.pdfView = NULL;
        v.doc = NULL;
    }
}

#pragma mark - lib methods

- (id)getDoc
{
    return doc;
}

- (int)getCurrentPage
{
    return pageno;
}

- (CGImageRef)imageForPage:(int)pg
{
    return nil;
}

- (void)setThumbnailBGColor:(int)color
{
}

- (void)setThumbGridBGColor:(int)color
{
}

- (void)setThumbGridElementHeight:(float)height
{
}

- (void)setThumbGridGap:(float)gap
{
}

- (void)setThumbGridViewMode:(int)mode
{
}

- (void)setReaderBGColor:(int)color
{
    GLOBAL.g_readerview_bg_color = color;
}

- (void)setToolbarColor:(int)color {
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(color);
}

- (void)setToolbarTintColor:(int)color {
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(color);
}


- (void)setThumbHeight:(float)height
{
}

- (void)setFirstPageCover:(BOOL)cover
{
}

- (void)setDoubleTapZoomMode:(int)mode
{
}

- (void)setImmersive:(BOOL)immersive
{
    isImmersive = immersive;
    
    if (isImmersive) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

#pragma mark - Attachments

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size
{
    return NO;
}

#pragma mark - Annot render

- (BOOL)addAttachmentFromPath:(NSString *)path
{
    return NO;
}

#pragma mark - Flat annot

- (bool)flatAnnotAtPage:(int)page doc:(PDFDoc *)doc
{
    return NO;
}

- (bool)flatAnnots
{
    return nil;
}

#pragma mark - Save document

- (bool)saveDocumentToPath:(NSString *)path
{
    if([path containsString:@"file://"])
    {
        NSString *filePath = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            filePath = [documentsDirectory stringByAppendingPathComponent:filePath];
            return [doc saveAs:filePath: NO];
        }
    }
    return [doc saveAs:path: NO];
}

#pragma mark - Form Manager

- (NSString *)getJSONFormFields
{
    return @"";
}

- (NSString *)getJSONFormFieldsAtPage:(int)page
{
    return @"";
}

- (NSString *)setFormFieldWithJSON:(NSString *)json
{
    return @"";
}

#pragma mark - Utils Method

- (void)showBars
{
    statusBarHidden = NO;
    [self prefersStatusBarHidden];
    isImmersive = NO;
    [self.navigationController setNavigationBarHidden:isImmersive animated:YES];
}

- (void)hideBars
{
    statusBarHidden = YES;
    [self prefersStatusBarHidden];
    isImmersive = YES;
    [self.navigationController setNavigationBarHidden:isImmersive animated:YES];
}
@end
