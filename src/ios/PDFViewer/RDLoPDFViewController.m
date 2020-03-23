//
//  ViewController.m
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import "RDLoPDFViewController.h"
#import "OutLineViewController.h"
#import "RDToolBar.h"
#import "RDVGlobal.h"

#import "TextAnnotViewController.h"
#import <AVKit/AVKit.h>
#import "DrawModeTableViewController.h"
#import "RDMoreTableViewController.h"
#import "BookmarkTableViewController.h"
#import "RDAnnotListViewController.h"
#import "SignatureViewController.h"
#import "ViewModeTableViewController.h"
#import "RDFormManager.h"
#import "RDExtendedSearch.h"
#import "SearchResultTableViewController.h"

#define SYS_VERSION [[[UIDevice currentDevice]systemVersion] floatValue]
#define THUMB_HEIGHT 99

@interface RDLoPDFViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIDocumentInteractionControllerDelegate,RDToolBarDelegate,DrawModeDelegate,RDMoreTableViewControllerDelegate, SignatureDelegate/*, ADVSignatureDelegate*/, ViewModeDelegate, BookmarkTableViewDelegate, RDAnnotListViewControllerDelegate, SearchResultViewControllerDelegate, saveTextAnnotDelegate>
{
    NSString *findString;
    RDToolBar *toolBar;
    UIToolbar *drawToolbar;
    UISearchBar* m_searchBar;
    UISlider *sliderBar;
    UILabel *pageNumLabel;
    BOOL b_findStart;
    BOOL m_bSel;
    BOOL statusBarHidden;
    BOOL isPrint;
    BOOL b_outline;
    BOOL b_noteAnnot;
    int pagecount;
    int pagenow;
    NSMutableArray *tempfiles;
   
    AVPlayerViewController *avvc;
    UIPickerView *pickerView;
    NSArray *pickViewArr;
    UIButton *confirmPickerBtn;
    UITextField *textFd;
    
    UIMenuController *selectMenu;
    int selectItem;
    UIAlertController *moreItemsContainer;
    RDMoreTableViewController *moreTVContainer;
    BookmarkTableViewController *b;
    //UIPopoverController *bookmarkPopover;
    CGPoint annotTapped;
    RDAnnotListViewController *annotListTV;
    UIMenuController *selectMC;
    BOOL alreadySelected;
    
    PDFAnnot *cachedAnnot;
    int posx;
    int posy;
    
    int gridBackgroundColor;
    int gridElementHeight;
    int gridGap;
    int gridMode;
    int doubleTapZoomMode;
    
    int statusBarHeight;
    
    UIColor *toolbarColor;
    UIColor *toolbarTintColor;
    
    UILabel *sliderLabel;
}
@end


@implementation RDLoPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialPopupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshToolbarPosition) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    isPrint = NO;
    m_bSel = false;
    float width = [UIScreen mainScreen].bounds.size.width;
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 160, width, 60)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:pickerView];
    [self.view bringSubviewToFront:pickerView];
    
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
}
-(void)viewWillAppear:(BOOL)animated
{
    if (_delegate && [_delegate respondsToSelector:@selector(willShowReader)]) {
        [_delegate willShowReader];
    }
    
    [self createToolbarItems];
    [toolBar sizeToFit];
    b_findStart = NO;
    isPrint = NO;
    b_outline = NO;
    
    self.navigationController.navigationBarHidden = YES;
    
    [toolBar removeFromSuperview];
    
    [self refreshToolbarPosition];
    
    [self.view addSubview:toolBar];
    
    toolBar.hidden = NO;
    
    [self toolBarStyle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didShowReader)]) {
        [_delegate didShowReader];
    }
    
    [self pageNumLabelInit:pagenow];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(!b_outline && !isPrint){
        [m_Thumbview PDFClose];
        [m_view PDFClose];
        m_doc = nil;
    }
    
    //delete temp files
    [self clearTempFiles];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(!b_outline)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(didCloseReader)]) {
            [_delegate didCloseReader];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}
- (void)pageNumLabelInit:(int)pageno
{
    if (pageNumLabel) {
        [pageNumLabel removeFromSuperview];
    }
    
    pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [self barHeightDistance], 65, 30)];
    pagenow = pageno;
    pageNumLabel.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.4];
    pageNumLabel.textColor = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    pageNumLabel.textAlignment= NSTextAlignmentCenter;
    pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius = 10;
    pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    [self updatePageNumLabel:pageno+1];
    [self.view addSubview:pageNumLabel];
    
    [pageNumLabel setHidden:toolBar.hidden];
}

- (void)updatePageNumLabel:(int)page
{
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",page];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
    pagenow = (page - 1);
}

- (void)refreshPageNumLabelPosition {
    pageNumLabel.frame = CGRectMake(0, [self barHeightDistance], 65, 30);
}

-(void)PDFGoto:(int)pageno
{
    if (pageno < 0) {
        [self PDFGoto:0];
        return;
    }
    
    if (pageno > m_doc.pageCount - 1) {
        [self PDFGoto:m_doc.pageCount - 1];
        return;
    }
    
    [m_view resetZoomLevel];
    [m_view vGoto:pageno];
    [m_Thumbview vGoto:pageno];
    [self updatePageNumLabel:(pageno + 1)];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [m_view setFrame:CGRectMake(0, 0, size.width, size.height)];
    [m_view sizeThatFits:size];
    m_Thumbview.frame = CGRectMake(0, size.height - GLOBAL.g_thumbview_height, size.width, GLOBAL.g_thumbview_height);
    m_slider.frame = CGRectMake(0, size.height - GLOBAL.g_thumbview_height, size.width, GLOBAL.g_thumbview_height);
    [m_Thumbview sizeThatFits:m_Thumbview.frame.size];
    [m_slider sizeThatFits:m_slider.frame.size];
    [m_Thumbview vGoto:pagenow];
    m_slider.value = pagenow +1;
    [self setSliderText:(int)m_slider.value];
}

- (void)createToolbarItems
{
    toolBar = [[RDToolBar alloc] init];
    toolBar.m_delegate = self;
    
    // Set images
    toolBar.closeImage = _closeImage;
    toolBar.searchImage = _searchImage;
    toolBar.selectImage = _selectImage;
    toolBar.drawImage = _drawImage;
    toolBar.undoImage = _undoImage;
    toolBar.redoImage = _redoImage;
    toolBar.gridImage = _gridImage;
    toolBar.deleteImage = _deleteImage;
    toolBar.doneImage = _doneImage;
    toolBar.removeImage = _removeImage;
    toolBar.performImage = _performImage;
    toolBar.moreImage = _moreImage;
    toolBar.prevImage = _prevImage;
    toolBar.nextImage = _nextImage;
    
    // Hide icons
    toolBar.hideSearchImage = _hideSearchImage;
    toolBar.hideDrawImage = _hideDrawImage;
    toolBar.hideSelImage = _hideSelImage;
    toolBar.hideUndoImage = _hideUndoImage;
    toolBar.hideRedoImage = _hideRedoImage;
    toolBar.hideMoreImage = _hideMoreImage;
    toolBar.hideGridImage = YES;
    
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    [toolBar setupToolBarArray];
}

- (void)refreshToolbarPosition {
    [self refreshStatusBarHeight];
    
    if (@available(iOS 13.0, *)) {
        [toolBar setFrame:CGRectMake(0, 0, [self screenRect].size.width, toolBar.barHeight + statusBarHeight)];
        [toolBar.bar setFrame:CGRectMake(0, toolBar.frame.size.height - toolBar.barHeight, [self screenRect].size.width, toolBar.barHeight)];
    } else {
        [toolBar setFrame:CGRectMake(0, statusBarHeight, [self screenRect].size.width, toolBar.barHeight)];
        [toolBar.bar setFrame:CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height)];
    }
    
    [self refreshPageNumLabelPosition];
}

-(int)PDFOpen:(NSString *)path : (NSString *)pwd {
    return [self PDFOpen:path :pwd atPage:0 readOnly:NO autoSave:NO author:@""];
}

-(int)PDFOpen:(NSString *)path : (NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSave author:(NSString *)author
{
    GLOBAL.g_author = author;
    GLOBAL.g_pdf_path = [[path stringByDeletingLastPathComponent] mutableCopy];
    GLOBAL.g_pdf_name = [[path lastPathComponent] mutableCopy];
    GLOBAL.g_save_doc = autoSave;
    
    CGRect rect = [self screenRect];
    m_doc = [[PDFDoc alloc] init];
    int err_code = [m_doc open:path :pwd];
    switch( err_code )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    
    m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [m_view setReadOnly:readOnlyEnabled];
    readOnly = readOnlyEnabled;
    BOOL res = [m_view PDFOpen:m_doc :4 :self];
    [self.view addSubview:m_view];
    pagecount = [m_doc pageCount];
    
    [self thumbInit:page];
    [self PDFGoto:page];
    
    return res;
}

- (int)PDFOpenStream:(id<PDFStream>)stream :(NSString *)password
{
    CGRect rect = [self screenRect];
    m_doc = [[PDFDoc alloc] init];
    int err_code = [m_doc openStream:stream :password];
    switch( err_code )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    
    m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.view addSubview:m_view];
    pagecount = [m_doc pageCount];
    
    [self thumbInit:0];
    
    return [m_view PDFOpen:m_doc :4 :self];
}

- (int)PDFOpenMem:(void *)data :(int)data_size :(NSString *)pwd
{
    CGRect rect = [self screenRect];
    m_doc = [[PDFDoc alloc] init];
    int err_code = [m_doc openMem:data :data_size :pwd];
    switch( err_code )
    {
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
    
    m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.view addSubview:m_view];
    pagecount = [m_doc pageCount];
    
    [self thumbInit:0];
    
    return [m_view PDFOpen:m_doc :4 :self];
}
/*
 #pragma mark - Grid View
 
 - (void)toggleGrid
 {
 [self toggleGridView];
 }
 
 - (void)toggleGridView
 {
 if (!m_Gridview) {
 [self showGridView];
 
 } else {
 [self hideGridView];
 }
 }
 
 - (void)showGridView
 {
 if (!m_Gridview) {
 m_Gridview = [[PDFGridView alloc] initWithFrame:CGRectMake(100, 100, 500, 500)];
 [m_Gridview PDFOpen:m_doc :4 :(id<PDFThumbViewDelegate>)self];
 
 if (gridBackgroundColor != 0) {
 [m_Gridview setThumbBackgroundColor:gridBackgroundColor];
 }
 
 [self.view addSubview:m_Gridview];
 }
 }
 
 - (void)hideGridView
 {
 if(m_Gridview) {
 [m_Gridview removeFromSuperview];
 [m_Gridview PDFClose];
 m_Gridview = nil;
 }
 }
 
 #pragma mark - Slider
 
 - (void)sliderInit:(int)pageno
 {
 CGRect boundsc = [self screenRect];
 
 int cwidth = boundsc.size.width;
 int cheight = boundsc.size.height;
 
 m_slider = [[UISlider alloc] initWithFrame:CGRectMake(0, cheight-50, cwidth, 50)];
 
 m_slider.minimumValue = 1;
 m_slider.maximumValue = pagecount;
 m_slider.continuous = NO;
 m_slider.value = pageno;
 
 [m_slider addTarget:self action:@selector(OnSliderValueChange:) forControlEvents:UIControlEventValueChanged];
 
 [m_slider setBackgroundColor:[UIColor blackColor]];
 
 [self.view addSubview:m_slider];
 
 [self pageNumLabelInit:pageno];
 }
 */
#pragma mark - Thumbnail

- (void)thumbInit:(int)pageno {
    CGRect rect = [self screenRect];
    
    if (GLOBAL.g_thumbview_height == 0) {
        GLOBAL.g_thumbview_height = THUMB_HEIGHT;
    }
    
    if (m_Thumbview) {
        [m_Thumbview PDFClose];
        [m_Thumbview removeFromSuperview];
        m_Thumbview = NULL;
    }
    
    if (m_slider) {
        [m_slider removeFromSuperview];
        m_slider = nil;
    }
    
    m_Thumbview = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, rect.size.height - GLOBAL.g_thumbview_height, rect.size.width, GLOBAL.g_thumbview_height)];
    [m_Thumbview PDFOpen:m_doc :4 :self];
    [m_Thumbview vGoto:pageno];//page 0 for default selected page.
    [self.view addSubview:m_Thumbview];
    m_Thumbview.hidden = !GLOBAL.g_navigation_mode;
    
    sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, GLOBAL.g_thumbview_height / 3)];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.textAlignment = NSTextAlignmentCenter;
    sliderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self setSliderText:pageno + 1];
    
    m_slider = [[UISlider alloc] initWithFrame:CGRectMake(0, rect.size.height - GLOBAL.g_thumbview_height, rect.size.width, GLOBAL.g_thumbview_height)];
    m_slider.minimumValue = 1;
    m_slider.maximumValue = m_doc.pageCount;
    //m_slider.continuous = NO;
    m_slider.value = pageno + 1;
    [m_slider addTarget:self action:@selector(OnSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [m_slider addTarget:self action:@selector(OnSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    m_slider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [m_slider addSubview:sliderLabel];
    m_slider.hidden = GLOBAL.g_navigation_mode;
    [self.view addSubview:m_slider];
}

#pragma mark - Slider

- (void)setSliderText:(int)value {
    sliderLabel.text = [NSString stringWithFormat:@"%i/%i", value, m_doc.pageCount];
}

-(void)OnSliderValueChange:(UISlider *)slider
{
    [self updateSlider:slider.value goto:NO];
}


-(void)OnSliderTouchUp:(UISlider *)slider
{
    [self updateSlider:slider.value goto:YES];
}

- (void)updateSlider:(int)value goto:(BOOL)haveToGoTo {
    int page = value;
    if (page <= 0) {
        page = 1;
    }
    if (page >= m_doc.pageCount) {
        page = m_doc.pageCount;
    }
    
    if (haveToGoTo) {
        [self OnPageClicked:page - 1];
    } else {
        [self setSliderText:page];
    }
}

-(void)OnPageClicked:(int)pageno
{
    [self PDFGoto:pageno];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark perform annot method
-(void)performAnnot
{
    [m_view vAnnotPerform];
    [toolBar changeToNormalToolBar];
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
    [toolBar changeToNormalToolBar];
    [m_view vAnnotEnd];
}
#pragma mark - press annot method
- (void)OnPageChanged :(int)pageno
{
    static int prevPage = -1;
    if (_delegate && [_delegate respondsToSelector:@selector(didChangePage:)]) {
        if (pageno != prevPage) {
            prevPage = pageno;
            [_delegate didChangePage:pageno];
        }
    }
    
    [m_Thumbview vGoto:pageno];
    m_slider.value = pageno +1;
    [self setSliderText:(int)m_slider.value];
    [self updatePageNumLabel:(pageno + 1)];
}

- (void)OnPageUpdated :(int)pageno
{
    [m_Thumbview PDFUpdatePage:pageno];
}

- (void)OnLongPressed:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didLongPressOnPage:atPoint:)]) {
        [_delegate didLongPressOnPage:(pagenow) atPoint:CGPointMake(x, y)];
    }
}

- (void)OnSingleTapped:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnPage:atPoint:)]) {
        RDVPos pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
    
    if (b_noteAnnot) {
        posx = x;
        posy = y;
        [self TextAnnot];
        return;
    }
    
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
        confirmPickerBtn.hidden = YES;
    }
    
    [m_searchBar resignFirstResponder];
    if(isImmersive)
    {
        [self showBars];
    }
    else
    {
        [self hideBars];
    }
    
    b_outline = false;
    m_bSel = false;
    [m_view vSelEnd];
}

- (void)OnDoubleTapped:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didDoubleTapOnPage:atPoint:)]) {
        RDVPos pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didDoubleTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
}

- (void)OnFound:(bool)found
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSearchTerm:found:)]) {
        [_delegate didSearchTerm:findString found:found];
    }
    
    if( !found )
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Waring"
                                   message:@"Find Over"
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
/*
 -(void)selectText:(id)sender
 {
 selectToolBar = [UIToolbar new];
 [selectToolBar sizeToFit];
 selectToolBar.barStyle = UIBarStyleBlackOpaque;
 UIBarButtonItem *selectDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(selectDone)];
 selectDoneBtn.width =30;
 UIBarButtonItem *selectCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(selectCancel)];
 selectCancelBtn.width =30;
 UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
 initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
 target:nil
 action:nil];
 
 NSArray *toolbarItem = [[NSArray alloc]initWithObjects:selectDoneBtn,spacer,selectCancelBtn,nil];
 [selectToolBar setItems:toolbarItem animated:NO];
 self.navigationItem.titleView = selectToolBar;
 [m_view vSelStart];
 [m_view vNoteStart];
 }
 
 -(void)selectDone
 {
 m_bSel = false;
 [drawLineToolBar removeFromSuperview];
 self.navigationItem.titleView =toolBar;
 [m_view vSelEnd];
 [m_view vNoteEnd];
 }
 
 -(void)selectCancel
 {
 [drawLineToolBar removeFromSuperview];
 self.navigationItem.titleView =toolBar;
 [m_view vSelEnd];
 [m_view vNoteEnd];
 }
 */
- (void)OnSelStart:(float)x :(float)y
{
    if(m_bSel)
    {
        m_bSel = false;
    }
    m_bSel = YES;
}

- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2
{
    if (m_bSel) {
        NSString *s = [m_view vSelGetText];
        NSLog(@"OnSelEnd select text = %@",s);
        if(s)
        {
            //popup a menu
            [selectMenu setTargetRect:CGRectMake(x2,y2, 0, 0) inView:self.view];
            [selectMenu setMenuVisible:YES animated:YES];
        }
    }
}
//enter annotation status.
- (void)OnAnnotClicked:(PDFAnnot *)annot :(float)x :(float)y
{
    [m_searchBar setHidden:NO];
    
    b_outline = false;
    m_bSel = false;
    
    [toolBar changeToPerformToolBar];
    [self showBars];
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
    [toolBar changeToNormalToolBar];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno
{
    [self PDFGoto:pageno];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotPopup:(PDFAnnot *)annot
{
    if(annot){
        b_outline = true;
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setText:[annot getPopupText]];
        [textAnnotVC setSubject:[annot getPopupSubject]];
        if ([annot isAnnotReadOnly])
            textAnnotVC.readOnly = YES;
        textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [navController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
    }
}

- (void)OnAnnotList:(PDFAnnot *)annot items:(NSArray *)dataArray selectedIndexes:(NSArray *)indexes
{
    NSLog(@"list sels");
    
    annotListTV = [[RDAnnotListViewController alloc] init];
    BOOL isMultiSel;
    isMultiSel = [annot isMultiSel];
    annotListTV.delegate = self;
    annotListTV.annotList = dataArray;
    annotListTV.multiSel = isMultiSel;
    annotListTV.annotSelected = [NSMutableArray arrayWithArray:indexes];
    annotListTV.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    annotListTV.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    b_outline = TRUE;
    [self presentViewController:annotListTV animated:YES completion:nil];
}

- (void)OnAnnotSignature:(PDFAnnot *)annot {
    cachedAnnot = annot;
    
    NSString *annotImage = [m_view getImageFromAnnot:annot];
    NSString *emptyImage = [m_view emptyImageFromAnnot:annot];
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:annotImage error:nil];
    NSDictionary *emptyAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:emptyImage error:nil];
    
    if (attr.fileSize != emptyAttr.fileSize) {
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable") message:NSLocalizedString(@"Signature already exist. Do you want delete it?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self presentSignatureViewController];
        }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->m_view vAnnotEnd];
        }];
              
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentSignatureViewController];
    }
}

- (void)didTapAnnot:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnAnnotationOfType:atPage:atPoint:)]) {
        [_delegate didTapOnAnnotationOfType:annot.type atPage:page atPoint:point];
    }
}

//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url
{
    b_outline = YES;
    //open URI
    if( url ){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable")
                                                                       message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Do you want to open:", @"Localizable"), url]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        avvc = [[AVPlayerViewController alloc] init];
        avvc.player = [AVPlayer playerWithURL:urlPath];
        avvc.view.frame = self.view.bounds;
        avvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:avvc animated:YES completion:nil];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                   message:@"Couldn't find media file"
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
}
- (void)OnAnnotEditBox:(CGRect)annotRect :(NSString *)editText :(float)textSize
{
    textFd.hidden = NO;
    textFd.frame = annotRect;
    textFd.text = editText;
    textFd.backgroundColor = [UIColor whiteColor];
    textFd.font = [UIFont systemFontOfSize:textSize];
    [self.view bringSubviewToFront:textFd];
    [textFd becomeFirstResponder];
}
- (void)OnAnnotCommboBox:(NSArray *)dataArray selected:(int)index
{
    pickViewArr = dataArray;
    pickerView.hidden = NO;
    confirmPickerBtn.hidden = NO;
    [self.view bringSubviewToFront:confirmPickerBtn];
    [self.view bringSubviewToFront:pickerView];
    [pickerView reloadAllComponents];
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

#pragma mark - annotList Delegate
- (void)listCheckedAt:(NSArray *)indexes
{
    [annotListTV dismissViewControllerAnimated:YES completion:nil];
    [m_view selectListBoxItems:indexes];
    [m_view vSelEnd];
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

//add begin and end editing delegate to add keyboard notifications
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}

//add keyboard notification
#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    //move the view to avoid the keyboard overlay
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    float gap = (keyboardFrameBeginRect.size.height - 30) - (textFd.frame.origin.y + textFd.frame.size.height);
    
    if (gap < 0) {
        [self.view setFrame:CGRectMake(0, gap, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    //restore the correct view position
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Toolbar Method

- (void)closeView
{
    if ([m_view isModified] && !GLOBAL.g_save_doc) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Exiting", nil)
                                                                       message:NSLocalizedString(@"Document modified.\r\nDo you want to save it?", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Yes", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self PDFClose];
                                 [self.navigationController setNavigationBarHidden:NO];
                                 [self.navigationController popViewControllerAnimated:YES];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"No", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
            [self->m_view setModified:NO force:YES];
                                     [self PDFClose];
                                     [self.navigationController setNavigationBarHidden:NO];
                                     [self.navigationController popViewControllerAnimated:YES];
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self PDFClose];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)PDFClose
{
    if (_delegate && [_delegate respondsToSelector:@selector(willCloseReader)] && m_doc != nil) {
        [_delegate willCloseReader];
    }
    
    if( m_view != nil )
    {
        [m_view PDFClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    
    if (m_Thumbview != nil) {
        [m_Thumbview PDFClose];
        [m_Thumbview removeFromSuperview];
        m_Thumbview = NULL;
    }
    
    m_doc = NULL;
    [toolBar removeFromSuperview];
}

#pragma mark - More

-(void)showMoreButtons{
    if (m_bSel == true)
    {
        [m_view vSelEnd];
        m_bSel = false;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        moreItemsContainer = [UIAlertController
                              alertControllerWithTitle:NSLocalizedString(@"Select Action", nil)
                              message:@""
                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *viewMode = [UIAlertAction actionWithTitle:NSLocalizedString(@"View Mode", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       [self showViewModeTableView];
                                   }];
        UIAlertAction *addBookMark = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Bookmark", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          [self composeFile];
                                      }];
        
        UIAlertAction *bookMarkList = [UIAlertAction actionWithTitle:NSLocalizedString(@"Bookmark List", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                       {
                                           [self bookmarkList];
                                       }];
        
        UIAlertAction *viewMenu =  [UIAlertAction actionWithTitle:NSLocalizedString(@"View Menu", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self viewMenu];
                                    }];
        
        UIAlertAction *savePDF = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  {
                                      [self savePdf];
                                  }];
        
        UIAlertAction *printPDF =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Print", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self printPdf];
                                    }];
        UIAlertAction *sharePDF =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self sharePDF];
                                    }];
        
        UIAlertAction *cancel =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                  {
            [self->moreItemsContainer dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [viewMode setValue:[(_viewModeImage) ? _viewModeImage : [UIImage imageNamed:@"btn_view"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [addBookMark setValue:[(_addBookmarkImage) ? _addBookmarkImage : [UIImage imageNamed:@"btn_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [bookMarkList setValue:[(_bookmarkImage) ? _bookmarkImage : [UIImage imageNamed:@"btn_show"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [viewMenu setValue:[(_outlineImage) ? _outlineImage : [UIImage imageNamed:@"btn_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [savePDF setValue:[(_saveImage) ? _saveImage : [UIImage imageNamed:@"btn_save"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [printPDF setValue:[(_printImage) ? _printImage : [UIImage imageNamed:@"btn_print"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        [sharePDF setValue:[(_shareImage) ? _shareImage : [UIImage imageNamed:@"btn_share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        [moreItemsContainer addAction:viewMode];
        [moreItemsContainer addAction:addBookMark];
        [moreItemsContainer addAction:bookMarkList];
        [moreItemsContainer addAction:viewMenu];
        [moreItemsContainer addAction:savePDF];
        [moreItemsContainer addAction:printPDF];
        [moreItemsContainer addAction:sharePDF];
        [moreItemsContainer addAction:cancel];
        moreItemsContainer.view.tintColor = [self getTintColor];
        
        [self presentViewController:moreItemsContainer animated:YES completion:nil];
    }
    else
    {
        moreTVContainer = [[RDMoreTableViewController alloc] init];
        moreTVContainer.modalPresentationStyle = UIModalPresentationPopover;
        [moreTVContainer setPreferredContentSize:CGSizeMake(300, 320)];
        moreTVContainer.delegate = self;
        moreTVContainer.viewModeImage = _viewModeImage;
        moreTVContainer.addBookmarkImage = _addBookmarkImage;
        moreTVContainer.bookmarkImage = _bookmarkImage;
        moreTVContainer.outlineImage = _outlineImage;
        moreTVContainer.saveImage = _saveImage;
        moreTVContainer.printImage = _printImage;
        moreTVContainer.shareImage = _shareImage;
        moreTVContainer.tintColor = [self getTintColor];
        UIPopoverPresentationController *popPresenter = [moreTVContainer
                                                         popoverPresentationController];
        popPresenter.barButtonItem = toolBar.moreButton;
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:moreTVContainer animated:YES completion:nil];
    }
    
}

-(void)selectAction:(int)type{
    [moreTVContainer dismissViewControllerAnimated:YES completion:nil];
    
    switch (type) {
        case 0:
            [self showViewModeTableView];
            break;
        case 1:
            [self composeFile];
            break;
        case 2:
            [self bookmarkList];
            break;
        case 3:
            [self viewMenu];
            break;
        case 4:
            [self savePdf];
            break;
        case 5:
            [self printPdf];
            break;
        case 6:
            [self sharePDF];
            
        default:
            break;
    }
}

- (void)showViewModeTableView
{
    ViewModeTableViewController *vm = [[ViewModeTableViewController alloc] init];
    vm.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        vm.modalPresentationStyle = UIModalPresentationPopover;
        vm.delegate = self;
        vm.preferredContentSize = CGSizeMake(320, (44 * 4) + 10);
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        pop.barButtonItem = toolBar.moreButton;
        
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select View Mode", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction *vert = [UIAlertAction actionWithTitle:NSLocalizedString(@"Vertical", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:0];
        }];
        [vert setValue:[[UIImage imageNamed:@"btn_view_vert"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *horz = [UIAlertAction actionWithTitle:NSLocalizedString(@"Horizontal", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:1];
        }];
        [horz setValue:[[UIImage imageNamed:@"btn_view_horz"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *singleP = [UIAlertAction actionWithTitle:NSLocalizedString(@"Single Page", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:2];
        }];
        [singleP setValue:[[UIImage imageNamed:@"btn_view_single"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *doubleP = [UIAlertAction actionWithTitle:NSLocalizedString(@"Double Page", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:3];
        }];
        [doubleP setValue:[[UIImage imageNamed:@"btn_view_dual"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        
        [action addAction:vert];
        [action addAction:horz];
        [action addAction:singleP];
        [action addAction:doubleP];
        
        [action addAction:cancel];
        
        [self presentViewController:action animated:YES completion:nil];
    }
}

- (void)setReaderViewMode:(int)mode
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    int currentPage = [m_view vGetCurrentPage];
    if( m_view != nil )
    {
        [m_view PDFClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    
    GLOBAL.g_render_mode = mode;
    
    [[NSUserDefaults standardUserDefaults] setInteger:GLOBAL.g_render_mode forKey:@"ViewMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CGRect rect = [self screenRect];
    
    m_view = [[PDFLayoutView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [m_view PDFOpen:m_doc :4 :self];
    pagecount = [m_doc pageCount];
    
    [self.view addSubview:m_view];
    
    m_bSel = false;
    
    [self thumbInit:currentPage];
    [self PDFGoto:currentPage];
    
    [self.view bringSubviewToFront:toolBar];
    [self.view bringSubviewToFront:m_Thumbview];
    [self.view bringSubviewToFront:pageNumLabel];
}

- (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfPath withPath:(BOOL)withPath
{
    return [self addBookMarks:pdfPath :@"" :[NSFileManager defaultManager] pdfName:[GLOBAL.g_pdf_name stringByDeletingPathExtension] withPath:withPath];
}

- (NSMutableArray *)addBookMarks:(NSString *)dpath :(NSString *)subdir :(NSFileManager* )fm pdfName:(NSString *)pdfName withPath:(BOOL)withPath
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

- (void)bookmarkList
{
    BookmarkTableViewController *b = [[BookmarkTableViewController alloc] init];
    b.items = [self loadBookmarkForPdf:GLOBAL.g_pdf_path withPath:YES];
    b.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        //bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:b];
        //bookmarkPopover.popoverContentSize = CGSizeMake(300, 44 * b.items.count);
        
        //[bookmarkPopover presentPopoverFromBarButtonItem:toolBar.moreButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        b.modalPresentationStyle = UIModalPresentationPopover;
        b.delegate = self; 
        b.preferredContentSize = CGSizeMake(320, (44 * 4) + 10);
        
        UIPopoverPresentationController *pop = b.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        pop.barButtonItem = toolBar.moreButton;
        
        [self presentViewController:b animated:YES completion:nil];
    }
    else
    {
        b_outline = true;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:b];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)didSelectItem:(int)pageno {
    [self PDFGoto:pageno];
}

#pragma mark - View Mode

- (void)viewMenu
{
    b_outline =true;
    PDFOutline *root = [m_doc rootOutline];
    if( root )
    {
        OutLineViewController *outlineView = [[OutLineViewController alloc] init];
        //First parameter is root node
        [outlineView setList:m_doc :NULL :root];
        UINavigationController *nav = self.navigationController;
        outlineView.hidesBottomBarWhenPushed = YES;
        [outlineView setJump:self];
        [nav pushViewController:outlineView animated:YES];
    }
}

#pragma mark - Save

- (void)savePdf
{
    if([m_view forceSave])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notice", nil)
                                                                       message:NSLocalizedString(@"Document saved", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Undo

- (void)undoAnnot
{
    [m_view vUndo];
}

#pragma mark - Redo

- (void)redoAnnot
{
    [m_view vRedo];
}

#pragma mark - Draw

- (void)showDrawModeTableView
{
    if (m_bSel == true)
    {
        [m_view vSelEnd];
        m_bSel = false;
    }
    
    DrawModeTableViewController *vm = [[DrawModeTableViewController alloc] init];
    vm.delegate = self;
    vm.lineImage = _lineImage;
    vm.rowImage = _rowImage;
    vm.rectImage = _rectImage;
    vm.ellipseImage = _ellipseImage;
    vm.bitmapImage = _bitmapImage;
    vm.noteImage = _noteImage;
#ifdef SIGNATURE_ENABLED
    vm.signatureImage = _signatureImage;
#endif
    vm.tintColor = [self getTintColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        vm.modalPresentationStyle = UIModalPresentationPopover;
        vm.delegate = self;
#ifdef SIGNATURE_ENABLED
        vm.preferredContentSize = CGSizeMake(200, (44 * 7) + 10);
#else
        vm.preferredContentSize = CGSizeMake(200, (44 * 6) + 10);
#endif
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        if (_hideSearchImage) {
            pop.barButtonItem = [toolBar.bar.items objectAtIndex:1];
        } else {
            pop.barButtonItem = [toolBar.bar.items objectAtIndex:2];
        }
        
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Draw Mode", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *ink = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ink", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:0];
        }];
        [ink setValue:[(_lineImage) ? _lineImage : [UIImage imageNamed:@"btn_annot_ink"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        UIAlertAction *line = [UIAlertAction actionWithTitle:NSLocalizedString(@"Line", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:1];
        }];
        [line setValue:[(_rowImage) ? _rowImage : [UIImage imageNamed:@"btn_annot_line"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        UIAlertAction *rect = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rect", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:2];
        }];
        [rect setValue:[(_rectImage) ? _rectImage : [UIImage imageNamed:@"btn_annot_rect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        UIAlertAction *ellipse = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ellipse", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:3];
        }];
        [ellipse setValue:[(_ellipseImage) ? _ellipseImage : [UIImage imageNamed:@"btn_annot_ellipse"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        UIAlertAction *stamp = [UIAlertAction actionWithTitle:NSLocalizedString(@"Stamp", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:4];
        }];
        [stamp setValue:[(_bitmapImage) ? _bitmapImage : [UIImage imageNamed:@"pdf_custom_stamp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
        
        UIAlertAction *note = [UIAlertAction actionWithTitle:NSLocalizedString(@"Note", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:5];
        }];
        [note setValue:[(_noteImage) ? _noteImage : [UIImage imageNamed:@"btn_annot_note"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
#ifdef SIGNATURE_ENABLED
        UIAlertAction *sign = [UIAlertAction actionWithTitle:NSLocalizedString(@"Signature", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:6];
        }];
        
        [sign setValue:[(_signatureImage) ? _signatureImage : [UIImage imageNamed:@"btn_annot_ink"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forKey:@"image"];
#endif
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        [action addAction:ink];
        [action addAction:line];
        [action addAction:rect];
        [action addAction:ellipse];
        [action addAction:stamp];
        [action addAction:note];
#ifdef SIGNATURE_ENABLED
        [action addAction:sign];
#endif
        [action addAction:cancel];
        action.view.tintColor = [self getTintColor];
        
        [self presentViewController:action animated:YES completion:nil];
    }
}

- (void)didSelectDrawMode:(int)mode
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    switch (mode) {
        case 0:
            [self drawLine];
            break;
        case 1:
            [self drawRow];
            break;
        case 2:
            [self drawRectangle];
            break;
        case 3:
            [self drawEllipse];
            break;
        case 4:
            [self drawImageStart];
            break;
        case 5:
            b_noteAnnot = YES;
            break;
#ifdef SIGNATURE_ENABLED
        case 6:
            [self drawSignature];
            break;
#endif
        default:
            break;
    }
}

#ifdef SIGNATURE_ENABLED
- (void)drawSignature
{
    b_outline = YES;
    AdvSignatureViewController *sign = [[AdvSignatureViewController alloc] init];
    sign.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sign.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:sign animated:YES completion:nil];
}
#endif

#pragma mark - Signature

- (void)presentSignatureViewController
{
    b_outline = YES;
    SignatureViewController *sv = [[SignatureViewController alloc] init];
    sv.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sv.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        sv.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    [self presentViewController:sv animated:YES completion:nil];
}

- (void)didSign
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self->m_view setSignatureImageAtIndex:self->cachedAnnot.getIndex atPage:[self->m_view vGetCurrentPage]];
        [self->m_view vAnnotEnd];
    }];
}

- (NSString *)composeFile
{
    NSString *pdfpath = [GLOBAL.g_pdf_path stringByAppendingPathComponent:GLOBAL.g_pdf_name];
    RDVPos pos;
    [m_view vGetPos:&pos];
    int pageno = pos.pageno;
    NSString *tempName = [[pdfpath lastPathComponent] stringByDeletingPathExtension];
    NSString *tempFile = [tempName stringByAppendingFormat:@"_%d%@",pageno,@".bookmark"];
    
    NSString *fileContent = [NSString stringWithFormat:@"%i",pageno];
    NSString *BookMarkDir = [pdfpath stringByDeletingLastPathComponent];
    
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

-(void)searchView
{
    [toolBar changeToSearchToolBar];
    
    CGRect frame = toolBar.bar.frame;
    frame.origin.y = [self barHeightDistance];
    
    if (m_searchBar) {
        if (SEARCH_LIST == 1) {
            [self showSearchList];
        }
        
        return;
    }
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:frame];
    m_searchBar.delegate = self;
    m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchBar.placeholder = @"Search";
    m_searchBar.keyboardType = UIKeyboardTypeDefault;
    m_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self toolBarStyle];
    
    toolBar.searchButton.enabled = (m_searchBar.text.length > 0);
    
    [self.view addSubview:m_searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    toolBar.searchButton.enabled = (searchText.length > 0);
}

- (void)showDocReadonlyAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable")
                                                                   message:NSLocalizedString(@"This Document is readonly", @"Localizable")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", @"Localizable")
                         style:UIAlertActionStyleDefault
                         handler:nil];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)initDrawToolbar {
    drawToolbar = [UIToolbar new];
    CGRect frame = toolBar.bar.frame;
    drawToolbar.frame = frame;
    drawToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [self toolBarStyle];
}

-(void)drawLine
{
    if(![m_view vInkStart])
    {
        [self showDocReadonlyAlert];
        return;
    }
    
    [self initDrawToolbar];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarButtonItemStylePlain target:self action:@selector(drawLineDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(drawLineCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [toolBar addSubview:drawToolbar];
}
-(void)drawLineDone:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vInkEnd];
}
-(void)drawLineCancel:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vInkCancel];
}
- (void)drawRow
{
    if(![m_view vLineStart])
    {
        [self showDocReadonlyAlert];
        return;
    }
    
    [self initDrawToolbar];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarButtonItemStylePlain target:self action:@selector(drawRowDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(drawRowCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [toolBar addSubview:drawToolbar];
}

- (void)drawRowDone
{
    [m_view vLineEnd];
    [drawToolbar removeFromSuperview];
}

- (void)drawRowCancel
{
    [drawToolbar removeFromSuperview];
    [m_view vLineCancel];
}

-(void)drawRectangle
{
    if(![m_view vRectStart])
    {
        [self showDocReadonlyAlert];
        return;
    }
    
    [self initDrawToolbar];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarButtonItemStylePlain target:self action:@selector(drawRectDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(drawRectCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [toolBar addSubview:drawToolbar];
}
-(void)drawRectDone:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vRectEnd];
}
-(void)drawRectCancel:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vRectCancel];
}
-(void)drawEllipse
{
    if(![m_view vEllipseStart])
    {
        [self showDocReadonlyAlert];
        return;
    }
    
    [self initDrawToolbar];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseDone:)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(drawEllipseCancel:)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [toolBar addSubview:drawToolbar];
}
-(void)drawEllipseDone:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vEllipseEnd];
}
-(void)drawEllipseCancel:(id)sender
{
    [drawToolbar removeFromSuperview];
    [m_view vEllipseCancel];
}

- (void)drawImageStart
{
    if(![m_view vImageStart]){
        [self showDocReadonlyAlert];
        return;
    }
    
    [self initDrawToolbar];
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarButtonItemStylePlain target:self action:@selector(drawImageDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarButtonItemStylePlain target:self action:@selector(drawImageCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [toolBar addSubview:drawToolbar];
}

- (void)drawImageDone
{
    [drawToolbar removeFromSuperview];
    [m_view vImageEnd];
}

- (void)drawImageCancel
{
    [drawToolbar removeFromSuperview];
    [m_view vImageCancel];
}

-(void)addBookMark
{
    int pageno = 0;
    RDVPos pos;
    [m_view vGetPos :&pos];
    pageno = pos.pageno;
    float x = pos.pdfx;
    float y = pos.pdfy;
    NSString *tempFile;
    NSString *tempName;
    tempName = [GLOBAL.g_pdf_name substringToIndex:GLOBAL.g_pdf_name.length-4];
    tempFile = [tempName stringByAppendingFormat:@"%d%@",pageno,@".bookmark"];
    NSString *tempPath;
    tempPath = [GLOBAL.g_pdf_path stringByAppendingFormat:@"%@",GLOBAL.g_pdf_name];
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
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                          message:str2
                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"BookMark Already Exist", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                       message:str2
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)printPdf
{
    NSString *path = [GLOBAL.g_pdf_path stringByAppendingString:GLOBAL.g_pdf_name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                       message:@"PDF file not available"
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSData *myData = [NSData dataWithContentsOfFile:path];
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    if ( pic && [UIPrintInteractionController canPrintData: myData] ) {
        pic.delegate = self;
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.jobName = [GLOBAL.g_pdf_path lastPathComponent];
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
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                       message:@"Cannot print the file"
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Localizable") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    isPrint = YES;
}

- (void)sharePDF
{
    NSURL *url = [NSURL fileURLWithPath:[GLOBAL.g_pdf_path stringByAppendingPathComponent:GLOBAL.g_pdf_name]];
    if(url)
    {
        UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo, UIActivityTypeMessage,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        a.excludedActivityTypes = excludedActivities;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            a.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = a.popoverPresentationController;
            popover.barButtonItem = toolBar.moreButton; // search bar button item
        } else {
            b_outline = true;
        }
        
        [self presentViewController:a animated:YES completion:nil];
        
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Waring", nil)
                                                                       message:NSLocalizedString(@"Error", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", nil)
                             style:UIAlertActionStyleDefault
                             handler:nil];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Search Bar Method
-(void)prevword
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length > 40)
        return;
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getPrevPageFromCurrentPage:pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startSearch:text dir:-1 reset:YES];
            });
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable")
                                                                           message:NSLocalizedString(@"Reached first occurrence", @"Localizable")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self startSearch:text dir:-1 reset:NO];
    }
}

-(void)nextword
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length > 40){
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getNextPageFromCurrentPage:pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startSearch:text dir:1 reset:YES];
            });
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable")
                                                                           message:NSLocalizedString(@"Reached last occurrence", @"Localizable")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        NSString *text = m_searchBar.text;
        [m_searchBar resignFirstResponder];
        if (m_searchBar.text.length > 40)
            return;
        
        [self startSearch:text dir:1 reset:NO];
    }
}

- (void)startSearch:(NSString *)text dir:(int)dir reset:(BOOL)reset
{
    if (reset) {
        findString = nil;
        [m_view vFindEnd];
        b_findStart = NO;
    }
    
    if (!b_findStart) {
        findString = text;
        [m_view vFindStart:text :GLOBAL.g_case_sensitive :GLOBAL.g_match_whole_word];
        b_findStart = YES;
        [m_view vFind:dir];
    } else if (text != nil && text.length > 0) {
        bool stringCmp = false;
        if (findString != NULL) {
            if(GLOBAL.g_case_sensitive)
                stringCmp = [text compare:findString] == NSOrderedSame;
            else
                stringCmp = [text caseInsensitiveCompare:findString] == NSOrderedSame;
        }
        if (!stringCmp) {
            [m_view vFindStart:text :GLOBAL.g_case_sensitive :GLOBAL.g_match_whole_word];
            findString = text;
        }
        
        [m_view vFind:dir];
    }
}

-(void)searchCancel
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] clearSearch];
    }
    
    [m_searchBar resignFirstResponder];
    [m_searchBar removeFromSuperview];
    [toolBar changeToNormalToolBar];
    
    findString = nil;
    [m_view vFindEnd];
    b_findStart = NO;
    m_searchBar = NULL;
    
    [self refreshCurrentPage];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)m_SearchBar
{
    NSString *text = m_SearchBar.text;
    [m_SearchBar resignFirstResponder];
    if (m_SearchBar.text.length > 40)
        return;
    
    if (SEARCH_LIST == 1) {
        [self showSearchList];
    } else {
        [self startSearch:text dir:1 reset:NO];
    }
}

#pragma mark - Search List
- (void)showSearchList
{
    if (SEARCH_LIST == 1) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            toolBar.hidden = YES;
        }
        
        SearchResultTableViewController *viewController = [[SearchResultTableViewController alloc] init];
        viewController.delegate = self;
        viewController.searchedString = m_searchBar.text;
        viewController.doc = m_doc;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            viewController.modalPresentationStyle = UIModalPresentationPopover;
            [viewController setPreferredContentSize:CGSizeMake(400, 600)];
            UIPopoverPresentationController *popover = viewController.popoverPresentationController;
            popover.barButtonItem = (UIBarButtonItem *)[toolBar.bar.items objectAtIndex:0]; // search bar button item
            
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else
        {
            b_outline = YES;
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)didSelectSelectSearchResult:(int)index
{
    if (b_outline) {
        b_outline = NO;
        [self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBarHidden = YES;
        [self goToSearchResult:index];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            [self dismissViewControllerAnimated:YES completion:^{
                [self goToSearchResult:index];
            }];
    }
}

- (void)goToSearchResult:(int)index
{
    [self PDFGoto:index];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSearch:[[RDExtendedSearch sharedInstance] searchTxt] dir:1 reset:YES];
    });
}

#pragma mark - Popup Menu Method
-(void)selectIsStarting
{
    UIBarButtonItem *item = [toolBar.bar.items objectAtIndex:3]; // Selection button
    
    if (alreadySelected)
    {
        [item setTintColor:toolBar.bar.tintColor];
        
        [m_view vSelEnd];
        alreadySelected = false;
    }
    else
    {
        [item setTintColor:[UIColor lightGrayColor]];
        
        [m_view vSelEnd];
        [m_view vSelStart];
        alreadySelected = true;
    }
}

-(void)initialPopupView
{
    UIMenuItem *underline = [[UIMenuItem alloc] initWithTitle:@"UDL" action:@selector(UnderLine:)];
    UIMenuItem *highline = [[UIMenuItem alloc] initWithTitle:@"HGL" action:@selector(HighLight:)];
    UIMenuItem *strike = [[UIMenuItem alloc] initWithTitle:@"STR" action:@selector(StrikeOut:)];
    UIMenuItem *textCopy = [[UIMenuItem alloc] initWithTitle:@"COPY" action:@selector(Copy:)];
    NSArray *itemsMC = [[NSArray alloc] initWithObjects:underline, highline, strike, textCopy, nil];
    selectMenu = [UIMenuController sharedMenuController];
    [selectMenu setMenuItems:itemsMC];
}
-(void)Copy :(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* s = [self->m_view vSelGetText];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = s;
        [self endSelect];
    });
}

-(void)HighLight :(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readOnly) {
            [self showDocReadonlyAlert];
            [self endSelect];
            return;
        }
        //0HighLight
        [self->m_view vSelMarkup :GLOBAL.g_annot_highlight_clr :0];
        [self endSelect];
    });
    
}
-(void)UnderLine :(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readOnly) {
            [self showDocReadonlyAlert];
            [self endSelect];
            return;
        }
        //1UnderLine
        [self->m_view vSelMarkup:GLOBAL.g_annot_underline_clr :1];
        [self endSelect];
    });
}
-(void)StrikeOut :(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->readOnly) {
            [self showDocReadonlyAlert];
            [self endSelect];
            return;
        }
        //2strikethrough
        [self->m_view vSelMarkup :GLOBAL.g_annot_strikeout_clr :2];
        [self endSelect];
    });
}

- (void)endSelect
{
    if(m_bSel){
        m_bSel = false;
        [m_view vSelEnd];
    }
    
    // Toggle selection mode
    alreadySelected = YES;
    [self selectIsStarting];
}

-(void)TextAnnot
{
    b_noteAnnot = NO;
    m_bSel = false;
    b_outline = true;
    [m_view vSelEnd];
    
    cachedAnnot = [m_view vGetTextAnnot:posx :posy];
    textAnnotVC = [[TextAnnotViewController alloc]init];
    [textAnnotVC setDelegate:self];
    
    textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:textAnnotVC];
    [m_view vNoteStart];
    [self presentViewController:navController animated:YES completion:^{
        
    }];
}

-(void)OnSaveTextAnnot:(NSString *)textAnnot subject:(NSString *)subject
{
    if([textAnnot isEqualToString:@""])
    {
        [m_view vNoteEnd];
    }
    else{
        [m_view vNoteEnd];
        if(cachedAnnot){
            [cachedAnnot setPopupSubject:subject];
            [cachedAnnot setPopupText:textAnnot];
        }else{
            [m_view vAddTextAnnot:posx :posy:textAnnot :subject];
        }
    }
}

- (void)refreshStatusBarHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        statusBarHeight = window.safeAreaInsets.top;
    } else {
        statusBarHeight = 20;
    }
}

-(void)refreshStatusBar{
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

#pragma mark - lib methods

- (id)getDoc
{
    return m_doc;
}

- (int)getCurrentPage
{
    return [m_view vGetCurrentPage];
}

- (CGImageRef)imageForPage:(int)pg
{
    CGRect bounds = [self screenRect];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if (bounds.size.height > bounds.size.width) {
            bounds.size.width = bounds.size.height;
            bounds.size.height = [[[[UIApplication sharedApplication] delegate] window] bounds].size.width;
        }
    }
    
    PDFPage *page = [m_doc page:pg];;
    float w = [m_doc pageWidth:pg];
    float h = [m_doc pageHeight:pg];
    int iw = w;
    int ih = h;
    PDF_DIB m_dib = NULL;
    PDF_DIB bmp = Global_dibGet(m_dib, iw, ih);
    float ratiox = 1;
    float ratioy = 1;
    
    if (ratiox>ratioy) {
        ratiox = ratioy;
    }
    
    ratiox = ratiox * 1.0;
    PDF_MATRIX mat = Matrix_createScale(ratiox, -ratiox, 0, h * ratioy);
    Page_renderPrepare(page.handle, bmp);
    Page_render(page.handle, bmp, mat, false, 1);
    Matrix_destroy(mat);
    page = nil;
    
    void *data = Global_dibGetData(bmp);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, iw * ih * 4, NULL);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(iw, ih, 8, 32, iw<<2, cs, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, provider, NULL, FALSE, kCGRenderingIntentDefault);
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, (bounds.size.width - ((bounds.size.width - iw) / 2)) * 1, ih * 1, 8, 0, cs, kCGImageAlphaPremultipliedLast);
    
    
    // Draw ...
    //
    CGContextSetAlpha(context, 1);
    CGContextSetRGBFillColor(context, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)0.0, (CGFloat)1.0 );
    CGContextDrawImage(context, CGRectMake(((bounds.size.width- iw) / 2), 1, iw, ih), imgRef);
    
    
    // Get your image
    //
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    return cgImage;
}

- (void)setThumbnailBGColor:(int)color
{
    [m_Thumbview setThumbBackgroundColor:color];
}

- (void)setThumbGridBGColor:(int)color
{
    gridBackgroundColor = color;
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

- (void)setReaderBGColor:(int)color
{
    [m_view setReaderBackgroundColor:color];
}

- (void)setToolbarColor:(int)color {
    toolbarColor = UIColorFromRGB(color);
}

- (void)setToolbarTintColor:(int)color {
    toolbarTintColor = UIColorFromRGB(color);
}


- (void)setThumbHeight:(float)height
{
    GLOBAL.g_thumbview_height = height;
    CGRect rect = [self screenRect];
    m_Thumbview.frame = CGRectMake(0, rect.size.height - GLOBAL.g_thumbview_height, rect.size.width, GLOBAL.g_thumbview_height);
    [m_Thumbview sizeThatFits:m_Thumbview.frame.size];
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
    
    if (isImmersive) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

#pragma mark - Attachments

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size
{
    return [m_view saveImageFromAnnotAtIndex:index atPage:pageno savePath:path size:size];
}

#pragma mark - Annot render

- (BOOL)addAttachmentFromPath:(NSString *)path
{
    return [m_view addAttachmentFromPath:path];
}

#pragma mark - Flat annot

- (bool)flatAnnotAtPage:(int)page doc:(PDFDoc *)doc
{
    if (doc == nil) {
        doc = [[PDFDoc alloc] init];
        [doc open:[GLOBAL.g_pdf_path stringByAppendingPathComponent:GLOBAL.g_pdf_name] :@""];
    }
    
    if(page >= 0 && page < doc.pageCount)
    {
        PDFPage *ppage = [doc page:page];
        [ppage objsStart];
        if ([ppage flatAnnots]) {
            return [doc save];
        }
    }
    
    return NO;
}

- (bool)flatAnnots
{
    PDFDoc *doc = [[PDFDoc alloc] init];
    if (m_doc == nil) {
        [doc open:[GLOBAL.g_pdf_path stringByAppendingPathComponent:GLOBAL.g_pdf_name] :@""];
    } else {
        doc = m_doc;
    }
    for (int page = 0; page != [doc pageCount]; page++) {
        [self flatAnnotAtPage:page doc:doc];
        if (page == [m_view vGetCurrentPage]) [m_view refreshCurrentPage];
    }
    return nil;
}

#pragma mark - Save document

- (bool)saveDocumentToPath:(NSString *)path
{
    NSString *prefix = @"file://";
    if([path rangeOfString:prefix].location != NSNotFound)
    {
        path = [path substringFromIndex:prefix.length];
    }
    return [m_doc saveAs:path: NO];
}

#pragma mark - Form Manager

- (NSString *)getJSONFormFields
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:m_doc];
    return [fe jsonInfoForAllPages];
}

- (NSString *)getJSONFormFieldsAtPage:(int)page
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:m_doc];
    return [fe jsonInfoForPage:page];
}

- (NSString *)setFormFieldWithJSON:(NSString *)json
{
    RDFormManager *fe = [[RDFormManager alloc] initWithDoc:m_doc];
    
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

#pragma mark - Utils Method

- (void)clearTempFiles
{
    //delete temp files
    for(int i=0; i<[tempfiles count];i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[tempfiles objectAtIndex:i] error:nil];
        [tempfiles removeObjectAtIndex:i];
    }
}

- (float)barHeightDistance
{
    return toolBar.bar.frame.size.height + statusBarHeight;
}

- (CGRect)screenRect
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    if ([self isPortrait]){
        if (rect.size.height < rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    } else{
        if (rect.size.height > rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    
    return rect;
}

- (UIColor *)getBarColor {
    UIColor *barColor = (self.navigationController.navigationBar.barTintColor) ? self.navigationController.navigationBar.barTintColor : [UIColor blackColor];
    
    if (toolbarColor) {
        barColor = toolbarColor;
    }
    
    return barColor;
}

- (UIColor *)getTintColor {
    UIColor *tintColor = (self.navigationController.navigationBar.tintColor) ? self.navigationController.navigationBar.tintColor : [UIColor orangeColor];
    
    if (toolbarTintColor) {
        tintColor = toolbarTintColor;
    }
    
    return tintColor;
}

- (void)toolBarStyle
{
    toolBar.bar.translucent = NO;
    
    //set tint
    toolBar.bar.tintColor = m_searchBar.tintColor = drawToolbar.tintColor = m_slider.tintColor = [self getTintColor];
    toolBar.backgroundColor = toolBar.bar.barTintColor = m_searchBar.barTintColor = drawToolbar.barTintColor = [self getBarColor];
    
    if (@available(iOS 13.0, *)) {
        
    } else {
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = [self getBarColor];
        }
    }
}

- (void)showBars
{
    m_Thumbview.hidden = !GLOBAL.g_navigation_mode;
    m_slider.hidden = GLOBAL.g_navigation_mode;
    [pageNumLabel setHidden:false];
    toolBar.hidden = NO;
    [self prefersStatusBarHidden];
    [m_searchBar setHidden:NO];
    statusBarHidden = NO;
    isImmersive = NO;
    [self.view bringSubviewToFront:toolBar];
    [self.view bringSubviewToFront:m_Thumbview];
    [self refreshStatusBar];
    [self refreshToolbarPosition];
}

- (void)hideBars
{
    m_Thumbview.hidden = YES;
    m_slider.hidden = YES;
    [pageNumLabel setHidden:true];
    toolBar.hidden = YES;
    [m_searchBar resignFirstResponder];
    [m_searchBar setHidden:YES];
    statusBarHidden = YES;
    isImmersive = YES;
    [self refreshStatusBar];
}

- (void)refreshCurrentPage
{
    [m_view refreshCurrentPage];
}


@end

