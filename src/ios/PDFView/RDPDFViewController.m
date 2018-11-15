//
//  RDPDFViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "RDPDFViewController.h"
#import "RDAnnotToolBar.h"
#import "RDExtendedSearch.h"
#import "SearchResultTableViewController.h"
#import "OutLineViewController.h"
#import <CoreData/CoreData.h>
#import "TextAnnotViewController.h"
#import <AVKit/AVKit.h>
#import "DrawModeTableViewController.h"
#import "RDMoreTableViewController.h"
#import "BookmarkTableViewController.h"
#import "RDAnnotListViewController.h"
#import "SignatureViewController.h"
#import "ViewModeTableViewController.h"

@interface RDPDFViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,RDToolBarDelegate,DrawModeDelegate,RDMoreTableViewControllerDelegate, SignatureDelegate, ViewModeDelegate, BookmarkTableViewDelegate, RDAnnotListViewControllerDelegate, SearchResultViewControllerDelegate,saveTextAnnotDelegate>
{
    int             selectItem;
    UIPickerView    *pickerView;
    NSArray         *pickViewArr;
    UIButton        *confirmPickerBtn;
    UITextField     *textFd;
    RDAnnotToolBar  *rdToolBar;
    UIToolbar       *searchToolBar;
    UIToolbar       *drawToolbar;
    UISearchBar     *m_searchBar;
    UISlider        *sliderBar;
    UILabel         *pageNumLabel;
    UIAlertController *moreItemsContainer;
    RDMoreTableViewController *moreTVContainer;
    BookmarkTableViewController *b;
    UIPopoverController *bookmarkPopover;
    CGPoint annotTapped;
    RDAnnotListViewController *annotListTV;
    UIMenuController *selectMC;
    BOOL alreadySelected;
}

@end

@implementation RDPDFViewController

@synthesize window = _window;
@synthesize pagenow;
@synthesize pagecount;
@synthesize b_keyboard;

bool b_outline;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;

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
    
    PDFannot = [[PDFAnnot alloc] init];
    b_outline = false;
    b_findStart = NO;
    findString = nil;
    b_lock = NO;
    b_sigleTap =false;
    b_keyboard = false;
    statusBarHidden = NO;
 
    tempfiles = [[NSMutableArray alloc]init];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
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
    
    rdToolBar = [[RDAnnotToolBar alloc] init];
    rdToolBar.m_delegate = self;
    
    // Set images
    rdToolBar.closeImage = _closeImage;
    rdToolBar.searchImage = _searchImage;
    rdToolBar.selectImage = _selectImage;
    rdToolBar.drawImage = _drawImage;
    rdToolBar.undoImage = _undoImage;
    rdToolBar.redoImage = _redoImage;
    rdToolBar.gridImage = _gridImage;
    rdToolBar.deleteImage = _deleteImage;
    rdToolBar.doneImage = _doneImage;
    rdToolBar.removeImage = _removeImage;
    rdToolBar.performImage = _performImage;
    rdToolBar.moreImage = _moreImage;
    rdToolBar.prevImage = _prevImage;
    rdToolBar.nextImage = _nextImage;
    
    // Hide icons
    rdToolBar.hideSearchImage = _hideSearchImage;
    rdToolBar.hideDrawImage = _hideDrawImage;
    rdToolBar.hideSelImage = _hideSelImage;
    rdToolBar.hideUndoImage = _hideUndoImage;
    rdToolBar.hideRedoImage = _hideRedoImage;
    rdToolBar.hideMoreImage = _hideMoreImage;
    rdToolBar.hideGridImage = _hideGridImage;
    [rdToolBar setupToolBarArray];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillAppear:(BOOL)animated 
{
    if (_delegate && [_delegate respondsToSelector:@selector(willShowReader)]) {
        [_delegate willShowReader];
    }
    
    b_findStart = NO;

    [rdToolBar removeFromSuperview];
    [rdToolBar setFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    [self.navigationController.navigationBar addSubview:rdToolBar];
    
    if (searchToolBar != nil) {
        [rdToolBar addSubview:searchToolBar];
        searchToolBar.hidden = NO;
    }
    
    rdToolBar.hidden = NO;
    
    [self toolBarStyle];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(!b_outline)
    {
        [self.navigationController.navigationBar setTranslucent:defaultTranslucent];
        
        if (_delegate && [_delegate respondsToSelector:@selector(willCloseReader)]) {
            [_delegate willCloseReader];
        }
        
       //[m_ThumbView vClose] should before [m_view vClose]
        [m_Thumbview vClose];
        [m_Gridview vClose];
        [m_view vClose];
        m_slider = nil;
    }
    
    [self clearTempFiles];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didShowReader)]) {
        [_delegate didShowReader];
    }
    
    [self pageNumLabelInit:pagenow];
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
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    
    return hi + rect.size.height;
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

- (void)toolBarStyle
{
    defaultTranslucent = self.navigationController.navigationBar.isTranslucent;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    //set tint
    rdToolBar.tintColor = searchToolBar.tintColor = m_searchBar.tintColor = m_slider.tintColor = self.navigationController.navigationBar.tintColor;
    
    rdToolBar.barTintColor = searchToolBar.barTintColor = m_searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;
}

- (void)showBars
{
    m_Thumbview.hidden = NO;
    [pageNumLabel setHidden:false];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [m_searchBar setHidden:NO];
    statusBarHidden = NO;
    isImmersive = NO;
}

- (void)hideBars
{
    m_Thumbview.hidden =YES;
    [pageNumLabel setHidden:true];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [m_searchBar resignFirstResponder];
    [m_searchBar setHidden:YES];
    statusBarHidden = YES;
    isImmersive = YES;
}

- (void)refreshCurrentPage
{
    [m_view refreshCurrentPage];
}

#pragma mark - PDF Init
-(int)PDFOpen:(NSString *)path : (NSString *)pwd
{
    return [self PDFOpen:path :pwd atPage:0 readOnly:NO autoSave:NO author:@""];
}

-(int)PDFOpen:(NSString *)path : (NSString *)pwd atPage:(int)page readOnly:(BOOL)readOnlyEnabled autoSave:(BOOL)autoSaveEnabled author:(NSString *)author;
{
    g_author = author;
    autoSave = autoSaveEnabled;
    pdfPath = [[path stringByDeletingLastPathComponent] mutableCopy];
    pdfName = [[path lastPathComponent] mutableCopy];
    
    [self PDFClose];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc open:path :pwd];
    if ([m_doc canSave]){
        NSString *cacheFile = [[NSTemporaryDirectory() stringByAppendingString:@""] stringByAppendingString:@"cache.dat"];
        [m_doc setCache:cacheFile];
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
    
    CGRect rect = [self screenRect];
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;

    if (page > 0) {
        [self PDFGoto:page];
    }
    
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
    
    CGRect rect = [self screenRect];
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [m_view vOpen:m_doc: (id<PDFViewDelegate>)self];
    pagecount = [m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

-(int)PDFopenMem : (void *)data : (int)data_size :(NSString *)pwd
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
    CGRect rect = [self screenRect];
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount =[m_doc pageCount];
    [self.view addSubview:m_view];
    m_bSel = false;
    return 1;
}

- (void)PDFSeekBarInit:(int)pageno
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

-(void)PDFThumbNailinit:(int)pageno
{
    CGRect boundsc = [self screenRect];
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    if (thumbViewHeight == 0) {
        thumbViewHeight = 99;
    }
    
    m_Thumbview = [[PDFThumbView alloc] initWithFrame:CGRectMake(0, cheight-thumbViewHeight, cwidth, thumbViewHeight)];
    
    [m_Thumbview vOpen :m_doc :(id<PDFThumbViewDelegate>)self];
    [self.view addSubview:m_Thumbview];
    
    [self pageNumLabelInit:pageno];
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
    
    [pageNumLabel setHidden:self.navigationController.navigationBarHidden];
}

- (void)updatePageNumLabel:(int)page
{
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",page];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
}

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
        CGRect frame = self.view.frame;
        m_Gridview = [[PDFGridView alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height, frame.size.width, frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)];
        [m_Gridview vOpen:m_doc :(id<PDFThumbViewDelegate>)self mode:2 elementGap:(gridGap > 0) ? gridGap : 10 elementHeight:(gridElementHeight > 0) ? gridElementHeight : 200 gridMode:gridMode];
        
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
        [m_Gridview vClose];
        m_Gridview = nil;
    }
}

#pragma mark - toolBar Delegate

- (void)closeView
{
    if ([m_view isModified] && !autoSave) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Exiting", nil)
                                                                       message:NSLocalizedString(@"Document modified.\r\nDo you want to save it?", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Yes"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self PDFClose];
                                 [self.navigationController popViewControllerAnimated:YES];
                                 [self dismissViewControllerAnimated:YES completion:nil];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [m_view setModified:NO force:YES];
                                     [self PDFClose];
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
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
        
        UIAlertAction *viewMode = [UIAlertAction actionWithTitle:NSLocalizedString(@"View mode", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
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
        
        UIAlertAction *cancel =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
                                  {
                                      [moreItemsContainer dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [viewMode setValue:[(_viewModeImage) ? _viewModeImage : [UIImage imageNamed:@"btn_view"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [addBookMark setValue:[(_addBookmarkImage) ? _addBookmarkImage : [UIImage imageNamed:@"btn_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [bookMarkList setValue:[(_bookmarkImage) ? _bookmarkImage : [UIImage imageNamed:@"btn_show"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [viewMenu setValue:[(_outlineImage) ? _outlineImage : [UIImage imageNamed:@"btn_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [savePDF setValue:[(_saveImage) ? _saveImage : [UIImage imageNamed:@"btn_save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        [printPDF setValue:[(_printImage) ? _printImage : [UIImage imageNamed:@"btn_print"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        
        [moreItemsContainer addAction:viewMode];
        [moreItemsContainer addAction:addBookMark];
        [moreItemsContainer addAction:bookMarkList];
        [moreItemsContainer addAction:viewMenu];
        [moreItemsContainer addAction:savePDF];
        [moreItemsContainer addAction:printPDF];
        [moreItemsContainer addAction:cancel];
        
        [self presentViewController:moreItemsContainer animated:YES completion:nil];
    }
    else
    {
        moreTVContainer = [[RDMoreTableViewController alloc] init];
        moreTVContainer.modalPresentationStyle = UIModalPresentationPopover;
        [moreTVContainer setPreferredContentSize:CGSizeMake(300, 300)];
        moreTVContainer.delegate = self;
        moreTVContainer.viewModeImage = _viewModeImage;
        moreTVContainer.addBookmarkImage = _addBookmarkImage;
        moreTVContainer.bookmarkImage = _bookmarkImage;
        moreTVContainer.outlineImage = _outlineImage;
        moreTVContainer.saveImage = _saveImage;
        moreTVContainer.printImage = _printImage;
        UIPopoverPresentationController *popPresenter = [moreTVContainer
                                                         popoverPresentationController];
        popPresenter.barButtonItem = rdToolBar.moreButton;
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
        vm.tableView.scrollEnabled = NO;
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        pop.barButtonItem = rdToolBar.moreButton;
        
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select View Mode", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
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
            [self setReaderViewMode:3];
        }];
        [singleP setValue:[[UIImage imageNamed:@"btn_view_single"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *doubleP = [UIAlertAction actionWithTitle:NSLocalizedString(@"Double Page", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setReaderViewMode:4];
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
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    
    switch (mode) {
        case 2:
        {
            g_def_view = 3;
            break;
        }
        case 3:
        {
            g_def_view = 4;
            break;
        }
        default:
            g_def_view = mode;
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:g_def_view forKey:@"ViewMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CGRect rect = [self screenRect];
    
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    [m_view vOpen :m_doc :(id<PDFViewDelegate>)self];
    pagecount = [m_doc pageCount];
    
    if (m_Thumbview) {
        [self.view insertSubview:m_view belowSubview:m_Thumbview];
    }
    
    m_bSel = false;
    
    [self PDFGoto:currentPage];
}

- (NSMutableArray *)loadBookmarkForPdf:(NSString *)pdfPath withPath:(BOOL)withPath
{
    return [self addBookMarks:pdfPath :@"" :[NSFileManager defaultManager] pdfName:[pdfName stringByDeletingPathExtension] withPath:withPath];
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
    b.items = [self loadBookmarkForPdf:pdfPath withPath:YES];
    b.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:b];
        bookmarkPopover.popoverContentSize = CGSizeMake(300, 44 * b.items.count);
        
        [bookmarkPopover presentPopoverFromBarButtonItem:rdToolBar.moreButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        b_outline = true;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:b];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)didSelectItem:(int)pageno {
    [m_view vGoto:pageno];
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
    vm.signatureImage = _signatureImage;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        vm.modalPresentationStyle = UIModalPresentationPopover;
        vm.delegate = self;
        vm.preferredContentSize = CGSizeMake(200, (44 * 6) + 10);
        vm.tableView.scrollEnabled = NO;
        
        UIPopoverPresentationController *pop = vm.popoverPresentationController;
        pop.permittedArrowDirections = UIPopoverArrowDirectionUp;
        if (_hideSearchImage) {
            pop.barButtonItem = [rdToolBar.items objectAtIndex:1];
        } else {
            pop.barButtonItem = [rdToolBar.items objectAtIndex:2];
        }
                
        [self presentViewController:vm animated:YES completion:nil];
    }
    else
    {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Draw Mode", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *ink = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ink", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:0];
        }];
        [ink setValue:[(_lineImage) ? _lineImage : [UIImage imageNamed:@"btn_annot_ink"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *line = [UIAlertAction actionWithTitle:NSLocalizedString(@"Line", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:1];
        }];
        [line setValue:[(_rowImage) ? _rowImage : [UIImage imageNamed:@"btn_annot_line"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *rect = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rect", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:2];
        }];
        [rect setValue:[(_rectImage) ? _rectImage : [UIImage imageNamed:@"btn_annot_rect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *ellipse = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ellipse", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:3];
        }];
        [ellipse setValue:[(_ellipseImage) ? _ellipseImage : [UIImage imageNamed:@"btn_annot_ellipse"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *stamp = [UIAlertAction actionWithTitle:NSLocalizedString(@"Stamp", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:4];
        }];
        [stamp setValue:[(_bitmapImage) ? _bitmapImage : [UIImage imageNamed:@"pdf_custom_stamp"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIAlertAction *note = [UIAlertAction actionWithTitle:NSLocalizedString(@"Note", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:5];
        }];
        [note setValue:[(_noteImage) ? _noteImage : [UIImage imageNamed:@"btn_annot_note"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        /*
        UIAlertAction *sign = [UIAlertAction actionWithTitle:NSLocalizedString(@"Signature", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didSelectDrawMode:6];
        }];
        [sign setValue:[(_signatureImage) ? _signatureImage : [UIImage imageNamed:@"btn_annot_ink"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        */
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        
        [action addAction:ink];
        [action addAction:line];
        [action addAction:rect];
        [action addAction:ellipse];
        [action addAction:stamp];
        [action addAction:note];
        //[action addAction:sign];
        [action addAction:cancel];
        
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
            [self drawImage];
            break;
        case 5:
            b_noteAnnot = YES;
            break;
        //case 6:
            //[self drawSignature];
            //break;
        default:
            break;
    }
}

/*
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
*/

- (NSString *)composeFile
{
    NSString *pdfpath = [pdfPath stringByAppendingPathComponent:pdfName];
    struct PDFV_POS pos;
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
- (void)searchView
{
    searchToolBar = [UIToolbar new];
    [searchToolBar sizeToFit];
    searchToolBar.barStyle = UIBarStyleBlackOpaque;
    UIImage *nextImg = (_nextImage) ? _nextImage : [UIImage imageNamed:@"btn_right"];
    UIImage *prevImg = (_prevImage) ? _prevImage : [UIImage imageNamed:@"btn_left"];
    UIImage *cancelImg = (_removeImage) ? _removeImage : [UIImage imageNamed:@"btn_annot_remove"];
    UIBarButtonItem *nextbutton=[[UIBarButtonItem alloc]initWithImage:nextImg style:UIBarButtonItemStylePlain target:self action:@selector(nextword)];
    nextbutton.width = ICON_WIDTH;
    UIBarButtonItem *prevbutton=[[UIBarButtonItem alloc]initWithImage:prevImg style:UIBarButtonItemStylePlain target:self action:@selector(prevword)];
    prevbutton.width = ICON_WIDTH;
    UIBarButtonItem *cancelbtn=[[UIBarButtonItem alloc]initWithImage:cancelImg style:UIBarButtonItemStylePlain target:self action:@selector(searchCancel)];
    cancelbtn.width = ICON_WIDTH;
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:prevbutton,nextbutton,cancelbtn,nil];
    [searchToolBar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:searchToolBar];
    
    CGRect boundsc = [self screenRect];
    int cwidth = boundsc.size.width;
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, [self barHeightDistance], cwidth, 41)];
    
    m_searchBar.delegate = self;
    m_searchBar.barStyle =UIBarStyleBlackTranslucent;
    m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchBar.placeholder = NSLocalizedString(@"Search", nil);
    m_searchBar.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:m_searchBar];
    
    [self toolBarStyle];
}

- (void)showDocReadonlyAlert
{
    NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
    NSString *str2=NSLocalizedString(@"This Document is readonly", @"Localizable");
    NSString *str3=NSLocalizedString(@"OK", @"Localizable");
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:str1 message:str2 delegate:self cancelButtonTitle:str3 otherButtonTitles:nil,nil];
    [alter show];
}

- (void)drawLine
{
    if(![m_view vInkStart]){
        [self showDocReadonlyAlert];
        return;
    }
    
    drawToolbar = [UIToolbar new];
    [drawToolbar sizeToFit];
    drawToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(drawLineDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(drawLineCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:drawToolbar];
}
- (void)drawLineDone
{
    [m_view vInkEnd];
    [drawToolbar removeFromSuperview];
}
- (void)drawLineCancel
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
    
    drawToolbar = [UIToolbar new];
    [drawToolbar sizeToFit];
    drawToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(drawRowDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(drawRowCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:drawToolbar];
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

- (void)drawRectangle
{
    
    if(![m_view vRectStart]) {
        [self showDocReadonlyAlert];
    }
    
    drawToolbar = [UIToolbar new];
    [drawToolbar sizeToFit];
    drawToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(drawRectangleDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(drawRectangleCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:drawToolbar];
}
- (void)drawRectangleDone
{
    [m_view vRectEnd];
    [drawToolbar removeFromSuperview];
}
- (void)drawRectangleCancel
{
    [drawToolbar removeFromSuperview];
    [m_view vRectCancel];
}
- (void)drawEllipse
{
    
    if(![m_view vEllipseStart]){
        [self showDocReadonlyAlert];
    }
    
    drawToolbar = [UIToolbar new];
    [drawToolbar sizeToFit];
    drawToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(drawEllipseDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(drawEllipseCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:drawToolbar];
}
- (void)drawEllipseDone
{
    [m_view vEllipseEnd];
    [drawToolbar removeFromSuperview];
}
- (void)drawEllipseCancel
{
    [drawToolbar removeFromSuperview];
    [m_view vEllipseCancel];
}
- (void)drawImage
{
    if(![m_view vImageStart]){
        [self showDocReadonlyAlert];
        return;
    }
    
    drawToolbar = [UIToolbar new];
    [drawToolbar sizeToFit];
    drawToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *drawLineDoneBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_done"] style:UIBarStyleBlackOpaque target:self action:@selector(drawImageDone)];
    drawLineDoneBtn.width =30;
    UIBarButtonItem *drawLineCancelBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"btn_annot_remove"] style:UIBarStyleBlackOpaque target:self action:@selector(drawImageCancel)];
    drawLineCancelBtn.width =30;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    
    NSArray *toolbarItem = [[NSArray alloc]initWithObjects:drawLineDoneBtn,spacer,drawLineCancelBtn,nil];
    [drawToolbar setItems:toolbarItem animated:NO];
    [rdToolBar addSubview:drawToolbar];
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
- (void)viewMenu
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

- (void)printPdf
{
    NSString *path = [pdfPath stringByAppendingPathComponent:pdfName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"PDF file not available"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    NSData *myData = [NSData dataWithContentsOfFile:path];
    
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
    else
    {
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Cannot print the file"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alter show];
    }
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = [self screenRect];
    
    [m_view setFrame:rect];
    [m_view sizeThatFits:rect.size];
    
    int cwidth = rect.size.width;
    int cheight = rect.size.height;
    
    [m_Thumbview setFrame:CGRectMake(0, cheight-thumbViewHeight, cwidth, thumbViewHeight)];
    [m_Thumbview sizeThatFits:CGRectMake(0, cheight-thumbViewHeight, cwidth, thumbViewHeight).size];
    [m_Gridview setFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)];
    [m_Gridview sizeThatFits:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height).size];
    [m_slider setFrame:CGRectMake(0, cheight-50, cwidth, 50)];
    [m_slider sizeThatFits:CGRectMake(0, cheight-50, cwidth, 50).size];
    [m_searchBar setFrame:CGRectMake(0, [self barHeightDistance], cwidth, 41)];
    [pageNumLabel setFrame:CGRectMake(0, [self barHeightDistance], 65, 30)];
    [m_Thumbview refresh];
    
    [m_view resetZoomLevel];

    [rdToolBar sizeToFit];
    [searchToolBar sizeToFit];
    
    [m_Thumbview didRotate];
    [m_Gridview didRotate];
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
    int page = (int)round(slider.value);
    if (page <= 0) {
        page = 1;
    }
    if (page >= m_doc.pageCount) {
        page = m_doc.pageCount;
    }
    [self OnPageClicked:page - 1];
}

-(void)OnPageClicked :(int)pageno
{
    [m_view resetZoomLevel];
    [m_view vGoto:pageno];
    pagenow = pageno + 1;
    
    [self updatePageNumLabel:pagenow];
    
    [self hideGridView];
}

-(int)PDFOpenPage:(NSString *)path :(int)pageno :(float)x :(float)y :(NSString *)pwd
{
   
    PDF_ERR err = 0;
    err = [m_doc open:path :pwd];
    switch(err){
        case err_ok:
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }

    CGRect rect = [self screenRect];
    
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
    [self updatePageNumLabel:pagenow];
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
    [rdToolBar removeFromSuperview];
}

#pragma mark - Seach Method
//Add Call Search API
- (void)searchBarSearchButtonClicked:(UISearchBar *)m_SearchBar
{
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    [m_searchBar setFrame:CGRectMake(0,[self barHeightDistance],cwidth,41)];

    NSString *text = m_SearchBar.text;
    [m_SearchBar resignFirstResponder];
    if (m_SearchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        [self showSearchList];
    } else {
        [self startSearch:text dir:1 reset:NO];
    }
}

- (void)prevword
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getPrevPageFromCurrentPage:pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            [self startSearch:text dir:-1 reset:YES];
        }
    } else {
        [self startSearch:text dir:-1 reset:NO];
    }
}

- (void)nextword
{
    NSString *text = m_searchBar.text;
    [m_searchBar resignFirstResponder];
    if (m_searchBar.text.length >40)
    {
        return ;
    }
    
    if (SEARCH_LIST == 1) {
        int i = [[RDExtendedSearch sharedInstance] getNextPageFromCurrentPage:pagenow];
        
        if (i >= 0) {
            [self PDFGoto:i];
            [self startSearch:text dir:1 reset:YES];
        }
    } else {
        NSString *text = m_searchBar.text;
        [m_searchBar resignFirstResponder];
        if (m_searchBar.text.length >40)
        {
            return;
        }
        
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
    
    if(!b_findStart)
    {
        findString =text;
        [m_view vFindStart:text :g_CaseSensitive :g_MatchWholeWord];
        b_findStart = YES;
        [m_view vFind:dir];
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
        [m_view vFind:dir];
    }
}

- (void)searchCancel
{
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] clearSearch];
    }
    
    [m_searchBar resignFirstResponder];
    [m_searchBar removeFromSuperview];
    [searchToolBar removeFromSuperview];
    
    findString = nil;
    [m_view vFindEnd];
    b_findStart = NO;
    m_searchBar = NULL;
    searchToolBar = nil;
}

#pragma mark - Search List
- (void)showSearchList
{
    if (SEARCH_LIST == 1) {
        [[RDExtendedSearch sharedInstance] searchText:m_searchBar.text inDoc:m_doc success:^(NSMutableArray *occurrences) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[[RDExtendedSearch sharedInstance] searchResults] count] > 0) {
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        rdToolBar.hidden = YES;
                        searchToolBar.hidden = YES;
                    }
                   
                    SearchResultTableViewController *viewController = [[SearchResultTableViewController alloc] init];
                    viewController.delegate = self;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        
                        viewController.modalPresentationStyle = UIModalPresentationPopover;
                        UIPopoverPresentationController *popover = viewController.popoverPresentationController;
                        popover.barButtonItem = (UIBarButtonItem *)[searchToolBar.items objectAtIndex:0]; // search bar button item
                        
                        [self presentViewController:viewController animated:YES completion:nil];
                    }
                    else
                    {
                        b_outline = YES;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }
            });
        }];
    }
}

- (void)didSelectSelectSearchResult:(int)index
{
    if (b_outline) {
        b_outline = NO;
        [self.navigationController popViewControllerAnimated:YES];
        [self goToSearchResult:index];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) [self dismissViewControllerAnimated:YES completion:nil];
        [self goToSearchResult:index];
    }
}

- (void)goToSearchResult:(int)index
{
    [m_view resetZoomLevel];
    [self PDFGoto:index];
    [self startSearch:[[RDExtendedSearch sharedInstance] searchTxt] dir:1 reset:YES];
}

- (void)OnPageChanged :(int)pageno
{
    static int prevPage = -1;
    if (_delegate && [_delegate respondsToSelector:@selector(didChangePage:)]) {
        if (pageno != prevPage) {
            prevPage = pageno;
            [_delegate didChangePage:pageno];
        }
    }
    
    pagenow = pageno;
    
    pageno++;
    [self updatePageNumLabel:pageno];
    
    [m_Thumbview vGoto:pageno-1];
}

- (void)OnSingleTapped:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnPage:atPoint:)]) {
        struct PDFV_POS pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
    
    if (b_noteAnnot) {
        posx = x;
        posy = y;
        [self TextAnnot:nil];
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
    b_outline = true;
    m_bSel = false;
    [m_view vSelEnd];
    [self refreshStatusBar];
}

- (void)OnDoubleTapped:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didDoubleTapOnPage:atPoint:)]) {
        struct PDFV_POS pos;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Waring", nil) message:NSLocalizedString(@"Find Over", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    NSString *selectedText = [m_view vSelGetText];
    
    if ([selectedText length] == 0 || [selectedText isEqualToString:@" "]){
        m_bSel = false;
    }
    else {
        //[self becomeFirstResponder];
        m_bSel = true;
        UIMenuItem *underline = [[UIMenuItem alloc] initWithTitle:@"UDL" action:@selector(UnderLine:)];
        UIMenuItem *highline = [[UIMenuItem alloc] initWithTitle:@"HGL" action:@selector(HighLight:)];
        UIMenuItem *strike = [[UIMenuItem alloc] initWithTitle:@"STR" action:@selector(StrikeOut:)];
        UIMenuItem *textCopy = [[UIMenuItem alloc] initWithTitle:@"COPY" action:@selector(Copy:)];
        NSArray *itemsMC = [[NSArray alloc] initWithObjects:underline, highline, strike, textCopy, nil];
        selectMC = [UIMenuController sharedMenuController];
        [selectMC setMenuItems:itemsMC];
        [selectMC setTargetRect:CGRectMake(x2,y2, 0, 0) inView:self.view];
        [selectMC setMenuVisible:YES animated:YES];
    }
}
#pragma mark AnnotToolBar
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
    [rdToolBar changeToNormalToolBar];
    [m_view vAnnotEnd];
}
//enter annotation status.
-(void)OnAnnotClicked:(PDFPage *)page :(PDFAnnot *)annot :(float)x :(float)y
{
    //TEST EditText method
    //if([annot fieldType]==2){
    //    [annot setEditText:@"123"];
    //}
    m_Thumbview.hidden = NO;
    [pageNumLabel setHidden:false];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [m_searchBar setHidden:NO];
    statusBarHidden = NO;
    
    b_outline = true;
    m_bSel = false;
    [self refreshStatusBar];
    PDFannot = annot;
    annot_x  = x;
    annot_y  = y;
    [rdToolBar changeToPerformToolBar];
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
    [rdToolBar changeToNormalToolBar];
}

#pragma mark - PDFView Delegate
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno
{
     [m_view vGoto:pageno];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotPopup:(PDFAnnot *)annot :(NSString *)subj :(NSString *)text
{
    if(text!=nil){
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        [textAnnotVC setSubject:subj];
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

- (void)didTapAnnot:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnAnnotationOfType:atPage:atPoint:)]) {
        [_delegate didTapOnAnnotationOfType:annot.type atPage:page atPoint:point];
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

    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        
        AVPlayer *player = [AVPlayer playerWithURL:urlPath];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        //[playerViewController.player play];//Used to Play On start
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Couldn't find media file", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
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
    if (_delegate && [_delegate respondsToSelector:@selector(didLongPressOnPage:atPoint:)]) {
        [_delegate didLongPressOnPage:(pagenow) atPoint:CGPointMake(x, y)];
    }
    
    //[m_view vSelStart];//start to select
    //m_bSel = true;
}

-(void)OnSingleTapped:(float)x :(float)y :(NSString *)text
{
    [m_searchBar resignFirstResponder];
    [pageNumLabel setHidden:false];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [m_searchBar setHidden:NO];

    b_outline = true;
    m_bSel = false;
    [m_view vSelEnd];
    
    if([text length]>0)
    {
        textAnnotVC = [[TextAnnotViewController alloc]init];
        [textAnnotVC setPos_x:posx];
        [textAnnotVC setDelegate:self];
        [textAnnotVC setPos_y:posy];
        [textAnnotVC setText:text];
        textAnnotVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:textAnnotVC];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
    }
}

-(void)OnSelStart :(float)x :(float)y;
{
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

#pragma mark - Signature

- (void)presentSignatureViewController
{
    SignatureViewController *sv = [[SignatureViewController alloc] init];
    sv.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sv.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:sv animated:YES completion:nil];
}

- (void)didSign
{
    [self dismissViewControllerAnimated:YES completion:^{
        [m_view setSignatureImageAtIndex:PDFannot.getIndex atPage:[m_view vGetCurrentPage]];
        [m_view vAnnotEnd];
    }];
}

- (void)advDidSign:(id)rotation
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [[UIDevice currentDevice] setValue:rotation forKey:@"orientation"];
        }
        
        if([m_view useTempImage]) {
            [self drawImage];
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                           message:@"Could not add empty signature"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
}

- (void)advDidCancelSign:(id)rotation
{
    [self dismissViewControllerAnimated:YES completion:^{
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [[UIDevice currentDevice] setValue:rotation forKey:@"orientation"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:nuri]];
    }
}
-(void)selectIsStarting
{
    UIBarButtonItem *item = [rdToolBar.items objectAtIndex:3]; // Selection button
    
    if (alreadySelected == false)
    {
        [item setTintColor:[UIColor lightGrayColor]];
        
        [m_view vSelEnd];
        [m_view vSelStart];
        alreadySelected = true;
    }
    else
    {
        [item setTintColor:rdToolBar.tintColor];
        
        [m_view vSelEnd];
        alreadySelected = false;
    }
}

-(void)Copy :(id)sender
{
    NSString* s = [m_view vSelGetText];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = s;
    NSLog(@"%@",s);
    if(m_bSel)
    {
        m_bSel = false;
        [m_view vSelEnd];
    }
    
}
-(void)StrikeOut:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //2strikethrough
        [m_view vSelMarkup:annotUnderlineColor :2];
        
        if(m_bSel)
        {
            m_bSel = false;
            [m_view vSelEnd];
        }
        
        // Toggle selection mode
        [self selectIsStarting];
    });
}

-(void)HighLight:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //0HighLight
        [m_view vSelMarkup:annotHighlightColor :0];
        
        if(m_bSel)
        {
            m_bSel = false;
            [m_view vSelEnd];
        }
        
        // Toggle selection mode
        [self selectIsStarting];
    });
}
-(void)UnderLine:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //1UnderLine
        [m_view vSelMarkup:annotUnderlineColor :1];
        
        if(m_bSel)
        {
            m_bSel = false;
            [m_view vSelEnd];
        }
        
        // Toggle selection mode
        [self selectIsStarting];
    });
}

-(void)TextAnnot:(id)sender
{
    b_noteAnnot = NO;
    m_bSel = false;
    b_outline = true;
    [m_view vSelEnd];
    
    PDFannot = [m_view vGetTextAnnot :posx :posy];
    textAnnotVC = [[TextAnnotViewController alloc]init];
    [textAnnotVC setPos_x:posx];
    [textAnnotVC setDelegate:self];
    [textAnnotVC setPos_y:posy];
    
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
        if(PDFannot){
            [PDFannot setPopupSubject:subject];
            [PDFannot setPopupText:textAnnot];
        }else{
            [m_view vAddTextAnnot:posx :posy:textAnnot :subject];
        }
    }
}
//This is a delegate function ,when tap the media annot in pdf file
//will generate a temp file,fileName is temp media path
- (void)OnMovie:(NSString *)fileName
{
    [tempfiles addObject:fileName];

    NSURL *urlPath = [NSURL fileURLWithPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        AVPlayer *player = [AVPlayer playerWithURL:urlPath];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        //[playerViewController.player play];//Used to Play On start
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Couldn't find media file", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)OnSound:(NSString *)fileName
{
    [tempfiles addObject:fileName];
    //open media file
}

//End PopupView action
- (void)OnAnnotCommboBox:(NSArray *)dataArray selected:(int)index
{
    NSLog(@"");
    pickViewArr = dataArray;
    pickerView.hidden = NO;
    confirmPickerBtn.hidden = NO;
    [self.view bringSubviewToFront:confirmPickerBtn];
    [self.view bringSubviewToFront:pickerView];
    [pickerView reloadAllComponents];
    [pickerView selectRow:index inComponent:0 animated:NO];
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
- (void)OnAnnotEditBox :(CGRect)annotRect :(NSString *)editText :(float)textSize
{
    NSLog(@"annotRect = %@",NSStringFromCGRect(annotRect));
    //textFd.adjustsFontSizeToFitWidth = YES;
    textFd.hidden = NO;
    textFd.frame = annotRect;
    textFd.text = editText;
    textFd.backgroundColor = [UIColor whiteColor];
    textFd.font = [UIFont systemFontOfSize:textSize];
    [self.view bringSubviewToFront:textFd];
    [textFd becomeFirstResponder];
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

- (void)setThumbHeight:(float)height
{
    thumbViewHeight = height;
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

- (bool)flatAnnotAtPage:(int)page
{
    PDFPage *ppage = [m_doc page:page];
    if ([ppage flatAnnots]) return YES;
    else return NO;
    
}
- (bool)flatAnnots
{
    for (int page = 0; page != [m_doc pageCount]; page++) {
        [self flatAnnotAtPage:page];
        if (page == [m_view vGetCurrentPage]) [m_view refreshCurrentPage];
    }
    return nil;
}

#pragma mark - Save document

- (bool)saveDocumentToPath:(NSString *)path
{
    if ([m_doc saveAs:path: NO]) return YES;
    else return NO;
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
@end
