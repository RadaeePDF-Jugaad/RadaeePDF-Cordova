//
//  RDPDFViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "RDPDFViewController.h"
#import "PopupMenu.h"
#import "ViewModeTableViewController.h"

#define SYS_VERSION [[[UIDevice currentDevice]systemVersion] floatValue]

@interface RDPDFViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,ViewModeDelegate>
{
    UIPickerView *pickerView;
    NSArray *pickViewArr;
    UIButton *confirmPickerBtn;
    int selectItem;
    UITextField *textFd;
	UIPopoverController *bookmarkPopover;
    UIPopoverController *viewModePopover;
    NSString *password;
}

@end

@implementation RDPDFViewController
@synthesize m_searchBar;
@synthesize drawLineToolBar;
@synthesize drawRectToolBar;
@synthesize toolBar;
@synthesize searchToolBar;
@synthesize window = _window;
@synthesize sliderBar;
@synthesize pageNumLabel;
@synthesize pagenow;
@synthesize pagecount;
@synthesize  b_keyboard;
extern int g_PDF_ViewMode;
extern float g_Ink_Width;
extern float g_swipe_speed;
extern float g_swipe_distance;
extern int g_render_quality;
extern bool g_DarkMode;
extern bool g_sel_right;
extern bool g_ScreenAwake;
extern int g_render_quality;
extern NSUserDefaults *userDefaults;
extern int bookMarkNum;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;
extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_ellipse_color;
bool b_outline;
extern uint g_oval_color;

- (void)toolbarStyle
{
    //set style
    toolBar.barStyle = searchToolBar.barStyle = m_searchBar.barStyle = annotToolBar.barStyle = drawLineToolBar.barStyle = drawRectToolBar.barStyle = self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //set tint
    toolBar.tintColor = searchToolBar.tintColor = m_searchBar.tintColor = annotToolBar.tintColor = drawLineToolBar.tintColor = drawRectToolBar.tintColor = m_slider.tintColor = self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
}

- (void)createToolbarItems
{
    BOOL isActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"actIsActive"];
    int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
    
    UIBarButtonItem *viewModeButton;
    
    if (_viewModeImage) {
        viewModeButton = [[UIBarButtonItem alloc] initWithImage:_viewModeImage style:UIBarButtonItemStylePlain target:self action:@selector(showViewModeTableView)];
    }
    else
    {
        viewModeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showViewModeTableView)];
    }
    
    UIBarButtonItem *searchButton;
    
    if (_searchImage) {
        searchButton = [[UIBarButtonItem alloc] initWithImage:_searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchView:)];
    }
    else
    {
        searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchView:)];
    }
    
    searchButton.width =30;
    
    
    UIBarButtonItem *lineButton=[[UIBarButtonItem alloc]initWithImage:_lineImage style:UIBarButtonItemStylePlain target:self action:@selector(drawLine:)];
    lineButton.width =30;
    
    UIBarButtonItem *rectButton=[[UIBarButtonItem alloc]initWithImage:_rectImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRect:)];
    rectButton.width =30;

    UIBarButtonItem *circleButton=[[UIBarButtonItem alloc]initWithImage:_ellipseImage style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipse:)];
    circleButton.width =30;
    
    UIBarButtonItem *addBookMarkButton;
    
    if (_bookmarkImage) {
        addBookMarkButton = [[UIBarButtonItem alloc] initWithImage:_bookmarkImage style:UIBarButtonItemStylePlain target:self action:@selector(composeFile:)];
    }
    else
    {
        addBookMarkButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(composeFile:)];
    }
    
    addBookMarkButton.width =30;
    
    UIBarButtonItem *addBookMarkListButton;
    
    if (_bookmarkListImage) {
        addBookMarkListButton = [[UIBarButtonItem alloc] initWithImage:_bookmarkListImage style:UIBarButtonItemStylePlain target:self action:@selector(bookmarkList)];
    }
    else
    {
        addBookMarkListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarkList)];
    }
    
    addBookMarkListButton.width =30;
    
    UIBarButtonItem *viewMenuButton;
    
    if (_outlineImage) {
        viewMenuButton = [[UIBarButtonItem alloc] initWithImage:_outlineImage style:UIBarButtonItemStylePlain target:self action:@selector(viewMenu:)];
    }
    else
    {
        viewMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(viewMenu:)];
    }
    
    viewMenuButton.width =30;
    
    UIBarButtonItem *printButton;
    
    if (_printImage) {
        printButton = [[UIBarButtonItem alloc] initWithImage:_printImage style:UIBarButtonItemStylePlain target:self action:@selector(printPdf)];
    }
    else
    {
        printButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(printPdf)];
    }
    
    printButton.width =30;
    
    NSMutableArray *toolbarItem = [[NSMutableArray alloc] initWithObjects:viewModeButton, searchButton, lineButton, rectButton, circleButton, addBookMarkButton, addBookMarkListButton, viewMenuButton, printButton,nil];
    
    if (!isActive || licenseType < 1) {
        [toolbarItem removeObject:lineButton];
        [toolbarItem removeObject:rectButton];
        [toolbarItem removeObject:circleButton];
        if (!isActive) {
            [toolbarItem removeObject:searchButton];
        }
    }
    
    [toolBar setItems:toolbarItem animated:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self = [super initWithNibName:nil bundle:nil]) {
 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"actIsActive"];
    int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
    
    PDFannot = [[PDFAnnot alloc] init];
    b_outline = false;
    b_findStart = NO;
    findString = nil;
    b_lock = NO;
    b_sigleTap =false;
    b_keyboard = false;
    statusBarHidden = NO;
    popupMenu1 = [[PopupMenu alloc] init];
    tempfiles = [[NSMutableArray alloc]init];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    PopupMenuItem *item1 = [PopupMenuItem itemWithTitle:@"Copy" image:nil target:self action:@selector(Copy:)];
    item1.width = 40;
    
    PopupMenuItem *item2 = [PopupMenuItem itemWithTitle:@"Mark" image:nil target:self action:@selector(Mark:)];
    item1.width = 40;
    
    PopupMenuItem *item3 = [PopupMenuItem itemWithTitle:@"STO" image:nil target:self action:@selector(StrikeOut:)];
    item2.width =40;
    PopupMenuItem *item4 = [PopupMenuItem itemWithTitle:@"HL" image:nil target:self action:@selector(HighLight:)];
    item3.width=40;
    PopupMenuItem *item5 = [PopupMenuItem itemWithTitle:@"UDL" image:nil target:self action:@selector(UnderLine:)];
    item4.width =40;
    PopupMenuItem *item6 = [PopupMenuItem itemWithTitle:@"TA" image:nil target:self action:@selector(TextAnnot:)];
    item6.width = 40;
    
    if (!isActive || licenseType < 1) {
        item2 = item3 = item4 = item5 = item6 = nil;
    }
    
    popupMenu1.items = [NSArray arrayWithObjects:item1,item5,item4,item3,item6,nil];

    m_bSel = false;
    float width = [UIScreen mainScreen].bounds.size.width;
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 160, width, 60)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:pickerView];
    [self.view bringSubviewToFront:pickerView];
    //pickerView.hidden = YES;
    
    confirmPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmPickerBtn.frame = CGRectMake(width - 60, pickerView.frame.origin.y - 40, 60, 40);
    [confirmPickerBtn setTitle:@"OK" forState:UIControlStateNormal];
    confirmPickerBtn.hidden = YES;
    [confirmPickerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    confirmPickerBtn.backgroundColor = [UIColor clearColor];
    [confirmPickerBtn addTarget:self action:@selector(setComboselect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmPickerBtn];
    
    textFd = [[UITextField alloc] init];
    textFd.delegate = self;
    [self.view addSubview:textFd];
    textFd.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    toolBar = [UIToolbar new];
    [toolBar sizeToFit];
    b_findStart = NO;
	[self createToolbarItems];
    self.navigationItem.titleView =toolBar;
    
    [self toolbarStyle];
    
    //GEAR
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayedDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    //END
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(!b_outline)
    {
       //[m_ThumbView vClose] should before [m_view vClose]
        [m_Thumbview vClose];
        [m_view vClose];
        m_slider = nil;
    }
    
    //delete temp files
    for(int i=0; i<[tempfiles count];i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[tempfiles objectAtIndex:i] error:nil];
        [tempfiles removeObjectAtIndex:i];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)closeView
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)bookmarkList
{
    BookmarkTableViewController *b = [[BookmarkTableViewController alloc] init];
    b.items = [RadaeePDFPlugin loadBookmarkForPdf:[pdfName substringToIndex:pdfName.length-4]];
    b.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:b];
        bookmarkPopover.popoverContentSize = CGSizeMake(300, 44 * b.items.count);
        
        [bookmarkPopover presentPopoverFromBarButtonItem:[self.toolBar.items objectAtIndex:5] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        b_outline = true;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:b];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)composeFile:(id)sender
{

    
    int pageno = 0;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos];
    pageno = pos.pageno;
    float x = pos.x;
    float y = pos.y;
    NSString *tempFile; 
    NSString *tempName;
    tempName = [pdfName substringToIndex:pdfName.length-4];
    tempFile = [tempName stringByAppendingFormat:@"%d%@",pageno,@".bookmark"];
    NSString *tempPath;
    tempPath = [pdfPath stringByAppendingFormat:@"%@",pdfName];
    NSString *fileContent = [NSString stringWithFormat:@"%@,%@,%d,%f,%f",tempPath,tempName,pageno,x,y];
    NSString *BookMarkDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSString *bookMarkFile = [BookMarkDir stringByAppendingPathComponent:tempFile];
    if(![[NSFileManager defaultManager]fileExistsAtPath:bookMarkFile])
    {
        [[NSFileManager defaultManager]createFileAtPath:bookMarkFile contents:nil attributes:nil];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:bookMarkFile];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[fileContent dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Add BookMark Success!", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2  delegate:self cancelButtonTitle:str3 otherButtonTitles:nil, nil];
        
        [alter show];
    }
    else {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"BookMark Already Exist", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil, nil];
        [alter show];
    }
}
- (IBAction)searchView:(id) sender
{
    searchToolBar = [UIToolbar new];
    [searchToolBar sizeToFit];
    
    //searchToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *nextbutton= [[UIBarButtonItem alloc] initWithImage:_nextImage style:UIBarButtonItemStylePlain target:self action:@selector(nextword:)];
    nextbutton.width =30;
    UIBarButtonItem *prevbutton=[[UIBarButtonItem alloc] initWithImage:_prevImage style:UIBarButtonItemStylePlain target:self action:@selector(prevword:)];
    prevbutton.width =30;
    UIBarButtonItem *cancelbtn=[[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(searchCancel:)];
    cancelbtn.width =30;

    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:prevbutton,nextbutton,cancelbtn,nil];
    [self.searchToolBar setItems:toolbarItem animated:NO];
    self.navigationItem.titleView =searchToolBar;

    
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    if(SYS_VERSION>=7.0)
    {
        float hi = self.navigationController.navigationBar.bounds.size.height;
        m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, hi+20, cwidth, 41)];
    }
    else
    {
        m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, cwidth, 41)];
    }
    m_searchBar.delegate = self;
    //m_searchBar.barStyle =UIBarStyleBlackTranslucent;
    m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchBar.placeholder = @"Search";
    m_searchBar.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:m_searchBar];
    
    [self toolbarStyle];

}
- (IBAction)drawLine:(id) sender
{
  
    if(![m_view vInkStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    drawLineToolBar = [UIToolbar new];
    [drawLineToolBar sizeToFit];
    //drawLineToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawLineDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawLineCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [self.drawLineToolBar setItems:toolbarItem animated:NO];
    self.navigationItem.titleView =drawLineToolBar;
    
    [self toolbarStyle];
}
-(IBAction)drawLineDone:(id)sender
{
    [m_view vInkEnd];
    [drawLineToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
}
-(IBAction)drawLineCancel:(id)sender
{
    [drawLineToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
    [m_view vInkCancel];
}

- (IBAction)drawRect:(id) sender
{
    
    if(![m_view vRectStart])    
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    drawRectToolBar = [UIToolbar new];
    [drawRectToolBar sizeToFit];
    //drawRectToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRectDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawRectCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [self.drawRectToolBar setItems:toolbarItem animated:NO];
    self.navigationItem.titleView =drawRectToolBar;
    
    [self toolbarStyle];
}
-(IBAction)drawRectDone:(id)sender
{
    
    [m_view vRectEnd];
    [drawRectToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
}
-(IBAction)drawRectCancel:(id)sender
{
    [drawRectToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
    [m_view vRectCancel];
}
- (IBAction)drawEllipse:(id) sender
{
    
    if(![m_view vEllipseStart])
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
        [alter show];
        return;
    }
    
    drawRectToolBar = [UIToolbar new];
    [drawRectToolBar sizeToFit];
    //drawRectToolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn= [[UIBarButtonItem alloc] initWithImage:_doneImage style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [self.drawRectToolBar setItems:toolbarItem animated:NO];
    self.navigationItem.titleView =drawRectToolBar;
    
    [self toolbarStyle];
}
-(IBAction)drawEllipseDone:(id)sender
{
    
    [m_view vEllipseEnd];
    [drawRectToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
}
-(IBAction)drawEllipseCancel:(id)sender
{
    [drawRectToolBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
    [m_view vEllipseCancel];
}
- (IBAction)viewMenu:(id) sender
{
    
    b_outline =true;
    PDFOutline *root = [m_doc rootOutline];
    if( root )
    {
        outlineView = [[OutLineViewController alloc] init];
        //First parameter is root node
        [outlineView setList:m_doc :NULL :root];
        UINavigationController *nav = self.navigationController;
        outlineView.hidesBottomBarWhenPushed = YES;
        [outlineView setJump:self];
        [nav pushViewController:outlineView animated:YES];
    }
 
        
}
-(IBAction)lockView:(id)sender
{

}

- (void)viewDidUnload
{
    NSLog(@"PDFView Unload");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeOrientation" object:nil];
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect =[[UIScreen mainScreen]bounds];
    if ([self isPortrait])
    {
        if (rect.size.height < rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    else
    {
        if (rect.size.height > rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    
    [m_view setFrame:rect];
    [m_view sizeThatFits:rect.size];
    [self.toolBar sizeToFit];
    
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    if ([self isPortrait]) {
        if (cwidth > cheight) {
            cwidth = cheight;
            cheight = boundsc.size.width;
        }
    }
    else
    {
        if (cwidth < cheight) {
            cwidth = cheight;
            cheight = boundsc.size.width;
        }
    }
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    if(SYS_VERSION>=7.0)
    {
        [m_Thumbview setFrame:CGRectMake(0, cheight-50, cwidth, 50)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-50, cwidth, 50).size];
        [m_slider setFrame:CGRectMake(0, cheight-50, cwidth, 50)];
        [m_slider sizeThatFits:CGRectMake(0, cheight-50, cwidth, 50).size];
        
        [m_searchBar setFrame:CGRectMake(0,hi+20,cwidth,41)];
    }
    else
    {
        [m_Thumbview setFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 50)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-hi-50-20, cwidth, 50).size];
        [m_slider setFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 50)];
        [m_slider sizeThatFits:CGRectMake(0, cheight-hi-50-20, cwidth, 50).size];
        [m_searchBar setFrame:CGRectMake(0, 0, cwidth, 41)];
    }
    [m_Thumbview refresh];
    
    [m_view resetZoomLevel];
}
- (IBAction)sliderAction:(id)sender
{
}

-(int)PDFOpen:(NSString *)path : (NSString *)pwd
{
    pdfPath = [path mutableCopy];
    pdfName = [[path lastPathComponent] mutableCopy];
    password = pwd;
    
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc open:path :pwd];
    if ([m_doc canSave]){
        NSString *cacheFile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cache.dat"];
       // [m_doc setCache:cacheFile];
    }
    
    switch( err )
    {
    case err_ok:
        break;
    case err_password:
        return 2;
        break;
    default: return 0;
    }
    CGRect rect = [[UIScreen mainScreen]bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    if(SYS_VERSION>=7.0)
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    }
    else
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}
-(int)PDFOpenStream:(id<PDFStream>)stream :(NSString *)password
{
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
   // err = [m_doc open:path :pwd];
    err = [m_doc openStream:stream :password];
    switch( err )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    CGRect rect = [[UIScreen mainScreen]bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    if(SYS_VERSION>=7.0)
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    }
    else
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    [m_view vOpen:m_doc:(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

-(int)PDFopenMem:(void *)data :(int)data_size :(NSString *)pwd
{
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc openMem:data :data_size :pwd];
    switch( err )
    {
        case err_ok:
        break;
        case err_password:
        return 2;
        break;
        default: return 0;
    }
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    if(SYS_VERSION>=7.0)
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    }
    else
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

- (void)PDFSeekBarInit:(int)pageno
{
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    if(SYS_VERSION>=7.0)
    {
        m_slider = [[UISlider alloc] initWithFrame:CGRectMake(0, cheight-50, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
    }
    else{
        m_slider = [[UISlider alloc] initWithFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 65, 30)];
    }
    
    m_slider.minimumValue = 1;
    m_slider.maximumValue = pagecount;
    m_slider.continuous = NO;
    m_slider.value = pageno;
    
    [m_slider addTarget:self action:@selector(OnSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [m_slider setBackgroundColor:[UIColor blackColor]];
    
    [self toolbarStyle];
    
    [self.view addSubview:m_slider];
    
    pagenow = pageno;
    pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    pageNumLabel.textColor = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    pageNumLabel.textAlignment= UITextAlignmentCenter;
    pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius = 10;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagecount];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
    pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    pageNumLabel.shadowColor = [UIColor grayColor];
    pageNumLabel.shadowOffset = CGSizeMake(1.0,1.0);
    [self.view addSubview:pageNumLabel];
    
    [pageNumLabel setHidden:NO];
}


-(void)PDFThumbNailinit:(int)pageno
{
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];

    if(SYS_VERSION>=7.0)
    {
        m_Thumbview = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, cheight-50, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
    }
    else{
        m_Thumbview = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 65, 30)];
    }
    [m_Thumbview vOpen :m_doc :(id<PDFThumbViewDelegate>)self];
    [self.view addSubview:m_Thumbview];
    pagenow = pageno;
    pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    pageNumLabel.textColor = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    pageNumLabel.textAlignment= UITextAlignmentCenter;
    pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius = 10;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagecount];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];    
    pageNumLabel.text = pagestr;
    pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    pageNumLabel.shadowColor = [UIColor grayColor];
    pageNumLabel.shadowOffset = CGSizeMake(1.0,1.0);
    [self.view addSubview:pageNumLabel];
 
    [pageNumLabel setHidden:NO];
    
}


-(void)initbar :(int) pageno
{
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    sliderBar = [[UISlider alloc]initWithFrame:CGRectMake(20, cheight-100, cwidth-30, 10)];
    pagecount = [m_doc pageCount];
    sliderBar.maximumValue = pagecount; //The Biggest Page Number
    sliderBar.minimumValue = 1;//The Littlest Page Number
    [self.view addSubview:sliderBar];
    [sliderBar setHidden:NO];
    [sliderBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderBar addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)PDFGoto :(int)pageno
{
    [m_view vGoto:pageno];
}
-(void)OnSliderValueChange:(UISlider *)slider
{
    [self OnPageClicked:slider.value];
}
-(void)OnPageClicked :(int)pageno
{
    [m_view resetZoomLevel];
    [m_view vGoto:pageno];
    pagenow = pageno-1;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
}

-(int)PDFOpenPage:(NSString *)path :(int)pageno :(float)x :(float)y :(NSString *)pwd
{
   
    PDF_ERR err = 0;
    err = [m_doc open:path :pwd];
    switch( err )
    {
    case err_ok:
        break;
    case err_password:
        return 2;
        break;
    default: return 0;
    }

    CGRect rect = [[UIScreen mainScreen]bounds];
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-self.navigationController.navigationBar.bounds.size.height)];
   // [m_view vOpenPage:m_doc :pageno :x :y :self];
    [m_view vGoto:pageno];
    pagecount = [m_doc pageCount];
    [self.view addSubview:m_view];
    return 1;
}
-(IBAction)sliderValueChanged:(id)sender
{
    pagenow = (int)round(sliderBar.value);
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
    
}
-(IBAction)sliderDragUp:(id)sender
{
    pagenow = (int)round(sliderBar.value);
    [m_view vGoto:pagenow - 1];
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagenow];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
}

-(void)PDFClose
{
    if( m_view != nil )
    {
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    m_doc = NULL;
}
//Add Call Search API
- (void)searchBarSearchButtonClicked:(UISearchBar *)m_SearchBar
{
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    if(SYS_VERSION>=7.0)
    {
        [m_searchBar setFrame:CGRectMake(0,hi+20,cwidth,41)];
    }
    else
    {
        [m_searchBar setFrame:CGRectMake(0,0,cwidth,41)];
    }
    NSString *text = m_SearchBar.text;
    [m_SearchBar resignFirstResponder];
    if (m_SearchBar.text.length >40)
    {
        return ;
    }
    if(!b_findStart)
    {
        findString =text;
        [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
        b_findStart = YES;
        [m_view vFind:1];
    }
    else if(text != nil && text.length > 0)
    {
        bool stringCmp =false;
        if( findString != NULL )
        {
            if(g_CaseSensitive == true)
                stringCmp=[text compare:findString] == NSOrderedSame;
            else
                stringCmp=[text caseInsensitiveCompare:findString] == NSOrderedSame;
        }
        if( !stringCmp )
        {
            [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
            findString =text;
        }
        [m_view vFind:1];
    }
}
-(IBAction)prevword:(id)sender
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length >40)
    {
        return ;
    }
    if(!b_findStart)
    {
        findString =text;
        [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
        b_findStart = YES;
        [m_view vFind:-1];
    }
    else if(text != nil && text.length > 0)
    {
        bool stringCmp =false;
        if( findString != NULL )
        {
            if(g_CaseSensitive == true)
                stringCmp=[text compare:findString] == NSOrderedSame;
            else
                stringCmp=[text caseInsensitiveCompare:findString] == NSOrderedSame;
        }
        if( !stringCmp )
        {
            [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
            findString =text;
        }
        [m_view vFind:-1];
    }
}

-(IBAction)nextword:(id)sender
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length >40)
    {
        return ;
    }
    if(!b_findStart)
    {
        findString =text;
        [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
        b_findStart = YES;
        [m_view vFind:1];
    }
    else if(text != nil && text.length > 0)
    {
        bool stringCmp =false;
        if( findString != NULL )
        {
            if(g_CaseSensitive == true)
                stringCmp=[text compare:findString] == NSOrderedSame;
            else
                stringCmp=[text caseInsensitiveCompare:findString] == NSOrderedSame;
        }
        if( !stringCmp )
        {
            [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
            findString =text;
        }
        [m_view vFind:1];
    }
}

-(IBAction)searchCancel:(id)sender
{
    [m_searchBar resignFirstResponder];
    [m_searchBar removeFromSuperview];
    self.navigationItem.titleView =toolBar;
    findString = nil;
    [m_view vFindEnd];
    b_findStart = NO;
    m_searchBar = NULL;
}

- (void)didSelectItem:(int)page
{
    [m_view vGoto:page];
}

- (void)OnPageChanged :(int)pageno
{
    pageno++;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pageno];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
    
    [m_Thumbview vGoto:pageno-1];
    m_slider.value = pageno;
}

- (void)OnSingleTapped:(float)x :(float)y
{
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
        confirmPickerBtn.hidden = YES;
    }
    [m_searchBar resignFirstResponder];
    if(SYS_VERSION>=7.0)
    {
        //ios7
        if(self.navigationController.navigationBar.hidden)
        {
            m_Thumbview.hidden = NO;
            m_slider.hidden = NO;
            [self.pageNumLabel setHidden:false];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [m_searchBar setHidden:NO];
            statusBarHidden = NO;
        }
        else
        {
             m_Thumbview.hidden =YES;
            [self.pageNumLabel setHidden:true];
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [m_searchBar resignFirstResponder];
            [m_searchBar setHidden:YES];
            m_slider.hidden = YES;
            statusBarHidden = YES;
        }
        b_outline = true;
        m_bSel = false;
        [m_view vSelEnd];
        [self refreshStatusBar];
    }
    else
    {
        
         if(m_Thumbview.hidden)
         {
             m_Thumbview.hidden = NO;
             m_slider.hidden = NO;
             [self.pageNumLabel setHidden:false];
         }
         else
         {
             m_Thumbview.hidden =YES;
             m_slider.hidden = YES;
             [self.pageNumLabel setHidden:true];
         }
        
        b_outline = true;
        m_bSel = false;
        [m_view vSelEnd];
    }
    
}

- (void)OnDoubleTapped:(float)x :(float)y
{
    
}

- (void)OnFound:(bool)found
{
    if( !found )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Waring" message:@"Find Over" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)refreshStatusBar{
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2
{
    if (m_bSel) {
        NSString *s = [m_view vSelGetText];
        if(s)
        {
            [popupMenu1 showInView:m_view atPoint:CGPointMake(x1, y1)];//popup a menu.
            posx = (int)x2;
            posy = (int)y2;
        }
        
    }
}
#pragma mark AnnotToolBar
-(void)addAnnotToolBar
{
    annotToolBar = [UIToolbar new];
    [annotToolBar sizeToFit];
    //annotToolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *playbutton= [[UIBarButtonItem alloc] initWithImage:_performImage style:UIBarButtonItemStylePlain target:self action:@selector(performAnnot)];
    playbutton.width =30;
    UIBarButtonItem *deletebutton= [[UIBarButtonItem alloc] initWithImage:_deleteImage style:UIBarButtonItemStylePlain target:self action:@selector(deleteAnnot)];
    deletebutton.width =30;
    UIBarButtonItem *cancelbtn= [[UIBarButtonItem alloc] initWithImage:_removeImage style:UIBarButtonItemStylePlain target:self action:@selector(annotCancel)];
    cancelbtn.width =30;
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:playbutton,deletebutton,cancelbtn,nil];
    [annotToolBar setItems:toolbarItem animated:NO];
    self.navigationItem.titleView =annotToolBar;
    
    [self toolbarStyle];
}
-(void)performAnnot
{
    [m_view vAnnotPerform];
}
-(void)deleteAnnot
{
    [m_view vAnnotRemove];
}
-(void)annotCancel
{
    [self removeAnnotToolBar];
}
-(void)removeAnnotToolBar
{
    [annotToolBar removeFromSuperview];
     self.navigationItem.titleView =toolBar;
}
//enter annotation status.
-(void)OnAnnotClicked:(PDFPage *)page :(PDFAnnot *)annot :(float)x :(float)y
{
    if(SYS_VERSION>=7.0)
    {
        //TEST EditText method
        //if([annot fieldType]==2){
        //    [annot setEditText:@"123"];
        //}
        
        //ios7
        m_Thumbview.hidden = NO;
        m_slider.hidden = NO;
        [self.pageNumLabel setHidden:false];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [m_searchBar setHidden:NO];
        statusBarHidden = NO;
        
        b_outline = true;
        m_bSel = false;
        [self refreshStatusBar];
    }
    else
    {
        
        m_Thumbview.hidden = NO;
        m_slider.hidden = YES;
        [self.pageNumLabel setHidden:false];
       
        b_outline = true;
        m_bSel = false;
    }

    PDFannot = annot;
    annot_x  = x;
    annot_y  = y;
    [self addAnnotToolBar];
}
//notified when annotation status end.
- (void)OnAnnotEnd
{
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
        confirmPickerBtn.hidden = YES;
    }
    if (!textFd.hidden){
        [textFd resignFirstResponder];
        textFd.hidden = YES;
    }
    [self removeAnnotToolBar];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno
{
     [m_view vGoto:pageno];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotPopup:(PDFAnnot *)annot :(NSString *)subj :(NSString *)text
{

    if(text!=nil)
    {
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        textAnnotVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:navController animated:YES completion:nil];
    }

}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url
{
    if( url )//open URI
    {
        nuri = url;
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Do you want to open:", @"Localizable");
        NSString *message = [str2 stringByAppendingFormat:@"%@",url];
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        NSString *str4=NSLocalizedString(@"Cancel", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:message delegate:self cancelButtonTitle:str3 otherButtonTitles:str4, nil];
        [alter show];
        return;
    }
}

//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    //GEAR
    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:urlPath];
        mpvc.view.frame = self.view.bounds;
        mpvc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentMoviePlayerViewControllerAnimated:mpvc];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't find media file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
}

-(void)OnLongPressed:(float)x :(float)y
{
    [m_view vSelStart];//start to select
    m_bSel = true;
}
/*
-(void)OnFound:(bool)found
{
    if( !found )//todo: show alert dialog
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Waring" message:@"Find Over" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
*/
-(void)OnSingleTapped:(float)x :(float)y :(NSString *)text
{
    [m_searchBar resignFirstResponder];
    //[self OnTouchDown];
    if(SYS_VERSION>=7.0)
    {
        //ios7
        if(YES)
        {
          //  m_Thumbview.hidden = NO;
            [self.pageNumLabel setHidden:false];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [m_searchBar setHidden:NO];
        }
        else
        {
           // m_Thumbview.hidden =YES;
            [self.pageNumLabel setHidden:true];
           //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
           [[UIApplication sharedApplication] setStatusBarHidden:YES];
           // BOOL navBarState = [self.navigationController isNavigationBarHidden];
            //Set the navigationBarHidden to the opposite of the current state.
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [m_searchBar resignFirstResponder];
            [m_searchBar setHidden:YES];
            //[self.navigationController setToolbarHidden:!navBarState animated:YES];
            
        }
        b_outline = true;
        m_bSel = false;
        [m_view vSelEnd];
    }
    else
    {
        
        if(self.navigationController.navigationBar.hidden)
        {
            m_Thumbview.hidden = NO;
            m_slider.hidden = NO;
            [self.pageNumLabel setHidden:false];
        }
        else
        {
            m_Thumbview.hidden =YES;
            m_slider.hidden = YES;
            [self.pageNumLabel setHidden:true];
        }
        
        b_outline = true;
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    if([text length]>0)
    {
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        textAnnotVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}
/*
-(void)OnTouchDown
{
  
    [popupMenu1 dismiss];
    [popupMenu2 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
}
*/
-(void)OnSelStart :(float)x :(float)y;
{
   
    [popupMenu1 dismiss];
    [popupMenu2 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)m_searchBar
{
    b_keyboard = true;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -need delete
//PopupView action
- (void)OnOpenURL:(NSString*)url
{
    if( url )//open URI
    {
        nuri = url;
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Do you want to open:", @"Localizable");
        NSString *message = [str2 stringByAppendingFormat:@"%@",url];
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        NSString *str4=NSLocalizedString(@"Cancel", @"Localizable");
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:message delegate:self cancelButtonTitle:str3 otherButtonTitles:str4, nil];
        [alter show];
        return;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:nuri]];
    }
}
-(void)Mark :(id)sender
{
    [popupMenu1 dismiss];
    [popupMenu2 showInView:m_view atPoint:CGPointMake(end_x/2, end_y/2)];
}
-(void)Copy :(id)sender
{
    
    NSString* s = [m_view vSelGetText];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = s;
    NSLog(@"%@",s);
    [popupMenu1 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
}
-(void)StrikeOut :(id)sender
{
    //2strikethrough
    [m_view vSelMarkup:annotUnderlineColor :2];
    [popupMenu1 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
}

-(void)HighLight :(id)sender
{
    //0HighLight
    [m_view vSelMarkup:annotUnderlineColor :0];
    [popupMenu1 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
}
-(void)UnderLine :(id)sender
{
     //1UnderLine
    [m_view vSelMarkup:annotUnderlineColor :1];
    [popupMenu1 dismiss];
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
}
//GEAR
- (void)moviePlayedDidFinish:(NSNotification *)notification
{
    //movie player exit with error
    if ([[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unsupported format" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
//END

-(void)TextAnnot :(id)sender
{
    
    m_bSel = false;
    b_outline = true;
    [m_view vSelEnd];
  //  [m_view vNoteStart];
    
    PDFannot = [m_view vGetTextAnnot :posx :posy];
    textAnnotVC = [[TextAnnotViewController alloc]init];
    [textAnnotVC setPos_x:posx];
    [textAnnotVC setDelegate:self];
    [textAnnotVC setPos_y:posy];
    
  //  [textAnnotVC setText:text];
    textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    textAnnotVC.modalPresentationStyle = UIModalPresentationFormSheet;

    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:textAnnotVC];
    [m_view vNoteStart];
   
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navController animated:YES completion:nil];
    
}

-(void)OnSaveTextAnnot:(NSString *)textAnnot
{
    if([textAnnot isEqualToString:@""])
    {
        [m_view vAnnotEnd];
    }
    else{
        [m_view vNoteEnd];
        if(PDFannot){
            [PDFannot setPopupText:textAnnot];
        }else{
            [m_view vAddTextAnnot:posx :posy:textAnnot];
        }
    }
}
//This is a delegate function ,when tap the media annot in pdf file
//will generate a temp file,fileName is temp media path
- (void)OnMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];
 //GEAR
    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:urlPath];
        mpvc.view.frame = self.view.bounds;
        mpvc.modalPresentationStyle = UIModalPresentationFormSheet;

        [self presentMoviePlayerViewControllerAnimated:mpvc];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't find media file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
//END
}


    
- (void)OnSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    
    //
    //open media file
    //
}

//End PopupView action
- (void)OnAnnotCommboBox:(NSArray *)dataArray
{
    NSLog(@"");
    pickViewArr = dataArray;
    pickerView.hidden = NO;
    confirmPickerBtn.hidden = NO;
    [self.view bringSubviewToFront:confirmPickerBtn];
    [self.view bringSubviewToFront:pickerView];
    [pickerView reloadAllComponents];
    
}

#pragma mark - Set view

- (void)showViewModeTableView
{
    ViewModeTableViewController *vm = [[ViewModeTableViewController alloc] init];
    vm.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        viewModePopover = [[UIPopoverController alloc] initWithContentViewController:vm];
        [viewModePopover setPopoverContentSize:CGSizeMake(300, 44 * 3) animated:NO];
        [viewModePopover presentPopoverFromBarButtonItem:[self.toolBar.items objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        b_outline = true;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vm];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)setReaderViewMode:(int)mode
{
    if ([viewModePopover isPopoverVisible]) {
        [viewModePopover dismissPopoverAnimated:YES];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    int currentPage = [m_view vGetCurrentPage];
    if( m_view != nil )
    {
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    
    switch (mode) {
        case 0:
            g_def_view = mode;
            break;
        case 1:
        {
            g_def_view = 3;
            g_double_page_enabled = NO;
            break;
        }
        case 2:
        {
            g_def_view = 3;
            g_double_page_enabled = YES;
            break;
        }
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:@"DefView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CGRect rect = [[UIScreen mainScreen]bounds];
    
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
    }
    //END
    if(SYS_VERSION>=7.0)
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    }
    else
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    
    if (m_Thumbview) {
        [self.view insertSubview:m_view belowSubview:m_Thumbview];
    }
    
    if (m_slider) {
        [self.view insertSubview:m_view belowSubview:m_slider];
    }
    
    m_bSel = false;

    [self PDFGoto:currentPage];
}

#pragma mark - Print

- (void)printPdf
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) {
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"PDF file not available"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    NSData *myData = [NSData dataWithContentsOfFile:pdfPath];
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if ( pic && [UIPrintInteractionController canPrintData: myData] ) {
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [pdfPath lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = myData;
        
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
            }
        };
        
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}

#pragma mark - PickerView DataSource and Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [pickViewArr count];
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickViewArr objectAtIndex:(int)row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectItem = (int)row;
}
- (void)setComboselect
{
    [m_view setCommboItem:selectItem];
    pickerView.hidden = YES;
    confirmPickerBtn.hidden = YES;
}
#pragma mark -EditBox delegate
- (void)OnAnnotEditBox :(CGRect)annotRect :(NSString *)editText
{
    NSLog(@"annotRect = %@",NSStringFromCGRect(annotRect));
    textFd.hidden = NO;
    textFd.frame = annotRect;
    textFd.text = editText;
    textFd.backgroundColor = [UIColor whiteColor];
    textFd.font = [UIFont systemFontOfSize:annotRect.size.height -3];
    [self.view bringSubviewToFront:textFd];
    [textFd becomeFirstResponder];
}

#pragma mark - textField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    NSLog(@"textView.text = %@",textField.text);
    [m_view setEditBoxWithText:textField.text];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
