//
//  RDPDFReflowViewController.m
//  PDFViewer
//
//  Created by strong on 14-1-19.
//
//

#import "RDPDFReflowViewController.h"

@interface RDPDFReflowViewController ()

@end

@implementation RDPDFReflowViewController
@synthesize toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    toolBar = [UIToolbar new];
    [toolBar sizeToFit];
    [self createToolbarItems];
    self.navigationItem.titleView = toolBar;
    m_cur_page = 0;
    ratio = 1.4;
}
-(void)viewWillAppear:(BOOL)animated
{
    
 //   [m_view render];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
  //  [m_view vClose];
}

-(void)createToolbarItems
{
    toolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *fontBigButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fontBig"] style:UIBarButtonItemStylePlain target:self action:@selector(fontBig)];
    fontBigButton.width =29;
    UIBarButtonItem *fontSmallButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fontSmall"] style:UIBarButtonItemStylePlain target:self action:@selector(fontSmall)];
    fontSmallButton.width =29;
    UIBarButtonItem *nextPageButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_right"] style:UIBarButtonItemStylePlain target:self action:@selector(nextPage)];
    nextPageButton.width =29;
    UIBarButtonItem *prePageButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_left"] style:UIBarButtonItemStylePlain target:self action:@selector(prePage)];
    prePageButton.width =29;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    spacer.width = 10;
    NSArray *toolbarItem = [[NSArray alloc] initWithObjects:fontBigButton,spacer,fontSmallButton,spacer,prePageButton,spacer,nextPageButton, nil];
    [self.toolBar setItems:toolbarItem animated:YES];

}

-(int)PDFOpen:(NSString *)path :(NSString *)pswd
{
    m_doc = [[PDFDoc alloc] init];
    int err_code = [m_doc open:path :pswd];
    switch(err_code)
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default:
            return 0;
            break;
    }

    CGRect rect = [UIScreen mainScreen].bounds;
    if([[[UIDevice currentDevice] systemVersion]integerValue]>=7)
    {
        m_view = [[PDFReflowView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    }
    else
    {
        m_view = [[PDFReflowView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    CGPoint offset;
    offset.x = self.view.frame.size.width;
    offset.y = self.view.frame.size.height*0.5;
    [m_view setContentOffset:offset];
    
    [m_view vOpen:m_doc :path];
   // [m_view vOpen:m_doc :nil];
    
    [m_view sizeToFit];
    [self.view addSubview:m_view];
    [m_view render:m_cur_page:ratio];
    pageCount = [m_doc pageCount];
    return 1;
}

-(void)fontBig
{
    ratio+=0.2;
    if(ratio>=4.0){
        ratio = 4.0;
    }
    [m_view render:m_cur_page:ratio];
    
}
-(void)fontSmall
{
    ratio -=0.2;
    if(ratio<=1.4){
        ratio = 1.4;
    }
    [m_view render:m_cur_page:ratio];
}
-(void)prePage
{
    if(m_cur_page--<=0){
        m_cur_page = 0;
    }
    [m_view render:m_cur_page:ratio];
}
-(void)nextPage
{
    if(m_cur_page++>=pageCount){
        m_cur_page = pageCount;
    }
    [m_view render:m_cur_page:ratio];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||[[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}
@end
