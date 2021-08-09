//
//  PDFReaderCtrl.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/5.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFPagesCtrl.h"
#import "PDFReaderCtrl.h"
#import "PDFPopupCtrl.h"
#import "PDFDialog.h"
#import "MenuVMode.h"
#import "MenuTool.h"
#import "MenuAnnot.h"
#import "MenuSearch.h"
#import "MenuAnnotOp.h"
#import "MenuCombo.h"
#import "DlgAnnotPropComm.h"
#import "DlgAnnotPropMarkup.h"
#import "DlgAnnotPropLine.h"
#import "DlgAnnotPropIcon.h"
#import "RDAnnotPickerViewController.h"
#import "RDExtendedSearch.h"
#import "RDMetaDataViewController.h"
#import "PDFLayoutView.h"
#import "PDFThumbView.h"
#import "SignatureViewController.h"

@interface PDFReaderCtrl () <PDFLayoutDelegate, PDFThumbViewDelegate, SearchResultViewControllerDelegate, RDPopupTextViewControllerDelegate, RDTreeViewControllerDelegate, SignatureDelegate>
@end

@implementation PDFReaderCtrl
- (void)show_error:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:conform];
    [self presentViewController:alert animated:YES completion:nil];
}

- (PDFDoc *)getDoc
{
    return m_doc;
}

- (void)loadPDF
{
    if(m_view) return;
    m_view = [_mView view];
    [self thumbInit];
    [m_view PDFOpen:m_doc :4 :[_mView canvas] :self];
    [m_thumb PDFOpen:m_doc :2 :[_mThumb canvas] :self];
    [self enter_none];
}

- (void)setDoc:(PDFDoc *)doc
{
    m_doc = doc;
    [self loadPDF];
}

- (void)setDoc:(PDFDoc *)doc :(int)pageno :(BOOL)readonly
{
    m_readonly = readonly;
    m_page_cnt = [m_doc pageCount];
    [self setDoc:doc];
    [m_view setReadOnly:readonly];
    [self PDFGoto:pageno];
}

- (void)thumbInit
{
    m_thumb = (PDFThumbView *)[_mThumb view];
    
    if (GLOBAL.g_thumbview_height) {
        _thumbHeightConstraint.constant = GLOBAL.g_thumbview_height;
    }
    
    if (!GLOBAL.g_navigation_mode) {
        _mSlider.minimumValue = 1;
        _mSlider.maximumValue = m_doc.pageCount;
        _mSlider.value = self.PDFCurPage + 1;
        _mSliderLabel.text = [NSString stringWithFormat:@"%i/%i", self.PDFCurPage, m_doc.pageCount];
        [_mSlider addTarget:self action:@selector(OnSliderValueChange:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (GLOBAL.g_navigation_mode) {
         [self->_mBarThumbButton setImage:[UIImage imageNamed:@"btn_thumb"]];
    } else {
        [self->_mBarThumbButton setImage:[UIImage imageNamed:@"btn_slider"]];
    }
    
}

- (void)PDFGoto:(int)pageno
{
    if (pageno < 0) pageno = 0;
    if (pageno > m_doc.pageCount - 1) pageno = m_doc.pageCount - 1;
    [m_view vGoto:pageno];
    [self thumbGoTo:pageno];
}

- (void)thumbGoTo:(int)pageno
{
    if (!GLOBAL.g_navigation_mode) {
           _mSlider.value = pageno +1;
           [self setSliderText:(int)_mSlider.value];
       } else {
           [m_thumb vGoto:pageno];
       }
}

- (int)PDFCurPage
{
    return [m_view vGetCurrentPage];
}

- (void)showBars
{
    [self prefersStatusBarHidden];
    [self enter_none];
}

- (void)hideBars
{
    _mThumb.hidden = YES;
    _mSliderView.hidden = YES;
    [self enter_immersive];
}

- (void)setImmersive:(BOOL)immersive
{
    if (immersive) [self hideBars];
    else [self showBars];
}

- (void)setFirstPageCover:(BOOL)cover
{
    [m_view setFirstPageCover:cover];
}

- (void)setDoubleTapZoomMode:(int)mode
{
    [m_view setDoubleTapZoomMode:mode];
}

- (void)setThumbnailBGColor:(int)color
{
    [m_thumb PDFSetBGColor:color];
}

- (void)setReaderBGColor:(int)color
{
    [m_view PDFSetGBColor:color];
}

- (BOOL)addAttachmentFromPath:(NSString *)path
{
    return [m_view addAttachmentFromPath:path];
}

- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size
{
    return [m_view saveImageFromAnnotAtIndex:index atPage:pageno savePath:path size:size];
}

+ (bool)flatAnnotAtPage:(int)page doc:(PDFDoc *)doc
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
        [PDFReaderCtrl flatAnnotAtPage:page doc:doc];
        if (page == [m_view vGetCurrentPage]) [m_view refreshCurrentPage];
    }
    return nil;
}

- (bool)saveDocumentToPath:(NSString *)path
{
    if([path containsString:@"file://"])
    {
        NSString *filePath = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            filePath = [documentsDirectory stringByAppendingPathComponent:filePath];
            return [m_doc saveAs:filePath: NO];
        }
    }
    return [m_doc saveAs:path: NO];
}

- (void)refreshCurrentPage
{
    [m_view refreshCurrentPage];
}

- (void)enter_none
{
    [_mBarNoneTop setHidden:NO];
    [_mBarNoneBottom setHidden:NO];
    [_mBarAnnot setHidden:YES];
    [_mBarSearchTop setHidden:YES];
    [_mBarSearchBottom setHidden:YES];
    if (!GLOBAL.g_navigation_mode) {
        [_mThumb setHidden:YES];
        [_mSliderView setHidden:NO];
    } else {
        [_mThumb setHidden:NO];
        [_mSliderView setHidden:YES];
    }
}

- (void)enter_annot
{
    [_mBarNoneTop setHidden:YES];
    [_mBarNoneBottom setHidden:YES];
    [_mBarAnnot setHidden:NO];
    [_mBarSearchTop setHidden:YES];
    [_mBarSearchBottom setHidden:YES];
    [_mThumb setHidden:YES];
    _mBarAnnotDoneButton.enabled = YES;
    if (m_annot_type == 2 || m_annot_type == 5) {
        _mBarAnnotColorButton.enabled = NO;
    } else {
        _mBarAnnotColorButton.enabled = YES;
    }
}

- (void)enter_annot_edit
{
    [_mBarNoneTop setHidden:YES];
    [_mBarNoneBottom setHidden:YES];
    [_mBarAnnot setHidden:YES];
    [_mBarSearchTop setHidden:YES];
    [_mBarSearchBottom setHidden:YES];
    [_mThumb setHidden:YES];
}

- (void)enter_search
{
    CGRect rect = _mBarNoneTop.frame;
    _mBarSearchTop.frame = rect;
    [_mBarNoneTop setHidden:YES];
    [_mBarNoneBottom setHidden:YES];
    [_mBarAnnot setHidden:YES];
    [_mBarSearchTop setHidden:NO];
    [_mBarSearchBottom setHidden:NO];
    [_mThumb setHidden:YES];
    
    [_mSearchText becomeFirstResponder];
    [_mSearchText addTarget:self action:@selector(search_forward:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // This could be in an init method.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchKeyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSearchKeyboardHiding:) name:UIKeyboardWillHideNotification object:nil];
    

    searchTapNone = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:searchTapNone];
    
    searchTapField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enter_search)];
    [_mSearchText addGestureRecognizer:searchTapField];
}

-(void)dismissKeyboard
{
    [_mSearchText resignFirstResponder];
}

- (void)onSearchKeyboardFrameChanged:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    if ([_mSearchText isFirstResponder]) {
        [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
           if (keyboardFrameBeginRect.origin.y > keyboardFrameEndRect.origin.y) {
               self->_mBarSearchBottom.transform = CGAffineTransformMakeTranslation(0, - keyboardFrameEndRect.size.height);
           } else {
               self->_mBarSearchBottom.transform = CGAffineTransformIdentity;
           }
        } completion:nil];
    }
}

- (void)onSearchKeyboardHiding:(NSNotification*)notification {
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
       self->_mBarSearchBottom.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)enter_select
{
    [_mBarNoneTop setHidden:YES];
    [_mBarNoneBottom setHidden:YES];
    [_mBarAnnot setHidden:NO];
    [_mBarSearchTop setHidden:YES];
    [_mBarSearchBottom setHidden:YES];
    [_mThumb setHidden:YES];
    _mBarAnnotDoneButton.enabled = NO;
    _mBarAnnotColorButton.enabled = NO;
    m_annot_type = 100;
}

- (void)enter_immersive
{
    [_mBarNoneTop setHidden:YES];
    [_mBarNoneBottom setHidden:YES];
    [_mBarAnnot setHidden:YES];
    [_mBarSearchTop setHidden:YES];
    [_mBarSearchBottom setHidden:YES];
    if (!GLOBAL.g_navigation_mode) {
        [_mSliderView setHidden:YES];
    } else {
        [_mThumb setHidden:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPDF];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.navigationController)
        self.navigationController.navigationBarHidden = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(willShowReader)]) {
        [_delegate willShowReader];
    }
    // Set images
    if(_closeImage)
        _mBtnBack.image = _closeImage;
    if(_doneImage)
        _mBtnDone.image = _doneImage;
    if(_removeImage)
        _mBtnCancel.image = _removeImage;
    if(_prevImage)
        _mBtnPrev.image = _prevImage;
    if(_nextImage)
        _mBtnNext.image = _nextImage;
    
    _fileName.text = [GLOBAL.g_pdf_name stringByDeletingPathExtension];
    _fileName.textColor = _mBarNoneTop.tintColor;
    [self initialPopupView];
    
    _mBarNoneBottomWidthConstraint.constant = 250;
    
    [self setBarButtonVisibility];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didShowReader)]) {
        [_delegate didShowReader];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (m_view == nil && _delegate && [_delegate respondsToSelector:@selector(didCloseReader)]) {
        [_delegate didCloseReader];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if ([m_popup isViewLoaded]) {
        [self dismissViewControllerAnimated:NO completion:^{
            self->m_popup = nil;
        }];
    }
}

- (void)setBarButtonVisibility {
    if (_hideSearchImage) {
        NSMutableArray *noneToolbarItems = [_mBarNoneTop.items mutableCopy];
        [noneToolbarItems removeObject:_searchItem];
        [_mBarNoneTop setItems:noneToolbarItems];
    }
    
    if (_hideDrawImage || ![m_doc canSave]) {
        NSMutableArray *noneToolbarItems = [_mBarNoneBottom.toolbar.items mutableCopy];
        [noneToolbarItems removeObject:_annotItem];
        [_mBarNoneBottom.toolbar setItems:noneToolbarItems];
        _mBarNoneBottomWidthConstraint.constant -= _annotItem.image.size.width*2;
    }
    
    if (_hideViewImage) {
        NSMutableArray *noneToolbarItems = [_mBarNoneBottom.toolbar.items mutableCopy];
        [noneToolbarItems removeObject:_viewItem];
        [_mBarNoneBottom.toolbar setItems:noneToolbarItems];
        _mBarNoneBottomWidthConstraint.constant -= _viewItem.image.size.width*2;
    }
    
    if (_hideThumbImage) {
        NSMutableArray *noneToolbarItems = [_mBarNoneBottom.toolbar.items mutableCopy];
        [noneToolbarItems removeObject:_thumbItem];
        [_mBarNoneBottom.toolbar setItems:noneToolbarItems];
        _mBarNoneBottomWidthConstraint.constant -= _thumbItem.image.size.width*2;
    }
    
    if (_hideMoreImage) {
        NSMutableArray *noneToolbarItems = [_mBarNoneBottom.toolbar.items mutableCopy];
        [noneToolbarItems removeObject:_moreItem];
        [_mBarNoneBottom.toolbar setItems:noneToolbarItems];
        _mBarNoneBottomWidthConstraint.constant -= _moreItem.image.size.width*2;
    }
}

- (void)closeView
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self PDFClose];
}

- (void)PDFClose
{
    if (_delegate && [_delegate respondsToSelector:@selector(willCloseReader)] && m_doc != nil) {
        [_delegate willCloseReader];
    }
    [m_view PDFClose];
    [m_thumb PDFClose];
    _fileName.text = @"";
    m_view = nil;
    m_thumb = nil;
    if(self.navigationController) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)back_pressed:(id)sender
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

- (IBAction)mode_pressed:(id)sender
{
    PDFLayoutView *vw = m_view;
    PDFReaderCtrl *thiz = self;
    //CGRect from = [self buttonRect:sender];
    
    if (showingThumb) {
        [self thumb_pressed:nil];
    }

    MenuVMode *view = [[MenuVMode alloc] init:CGPointMake(self.view.center.x-125, _mBarNoneBottom.frame.origin.y) :^(int vmode){
        switch(vmode)
        {
            case 1:
                [vw PDFSetVMode:1];
                break;
            case 2:
                [vw PDFSetVMode:3];
                break;
            case 3:
                [vw PDFSetVMode:4];
                break;
            default:
                [vw PDFSetVMode:0];
                break;
        }
        [thiz->m_popup dismiss];
    }];
    m_popup = [[PDFPopupCtrl alloc] init:view];
    [self presentViewController:m_popup animated:YES completion:nil];
}

-(void)OnMeta
{
    RDMetaDataViewController *metaViewController = [[RDMetaDataViewController alloc] initWithNibName:@"RDMetaDataViewController" bundle:nil];
    metaViewController.doc = m_doc;
    metaViewController.autoSave = NO;
    metaViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    metaViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:metaViewController animated:YES completion:nil];
    [m_view setModified:YES force:NO];
}

-(void)OnOutline
{
    if(!m_doc.rootOutline)
    {
        [self show_error:@"This PDF file has no outlines!"];
        return;
    }
    RDTreeViewController *treeViewController = [[RDTreeViewController alloc] initWithNibName:@"RDTreeViewController" bundle:nil];
    treeViewController.doc = m_doc;
    treeViewController.delegate = self;
    
    treeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    treeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:treeViewController animated:YES completion:nil];
}

- (IBAction)search_pressed:(id)sender
{
    [self enter_search];
}

- (void)thumb_pressed:(id)sender
{
    int safeAreaBottom = 0;
    if (@available(iOS 11.0, *))
        safeAreaBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        if (self->showingThumb) {
            self->_mSliderView.transform = CGAffineTransformIdentity;
            self->_mThumb.transform = CGAffineTransformIdentity;
            self->_mBarNoneBottom.transform = CGAffineTransformIdentity;
            self->showingThumb = NO;
        } else {
            self->_mSliderView.transform = CGAffineTransformMakeTranslation(0, -self->_mSliderView.frame.size.height - safeAreaBottom);
            self->_mBarNoneBottom.transform = CGAffineTransformMakeTranslation(0,-self->_mSliderView.frame.size.height - safeAreaBottom);
            self->_mThumb.transform = CGAffineTransformMakeTranslation(0, -self->_mThumb.frame.size.height - safeAreaBottom);
            self->_mBarNoneBottom.transform = CGAffineTransformMakeTranslation(0,-self->_mThumb.frame.size.height - safeAreaBottom);
            self->showingThumb = YES;
        }
    } completion:nil];
}

- (IBAction)tool_pressed:(id)sender
{
    PDFLayoutView *vw = m_view;
    PDFReaderCtrl *thiz = self;
    //CGRect from = [self buttonRect:sender];
    
    if (showingThumb) {
        [self thumb_pressed:nil];
    }
    
    MenuTool *view = [[MenuTool alloc] init:CGPointMake(self.view.center.x-125, _mBarNoneBottom.frame.origin.y) :^(int tool){
        [thiz->m_popup dismiss];
        switch(tool)
        {
            case 0:
                [vw vUndo];
                break;
            case 1:
                [vw vRedo];
                break;
            case 2:
                if ([self->m_view canSaveDocument]) {
                    [thiz enter_select];
                    [vw vSelStart];
                }
                break;
            case 3:
                [thiz OnMeta];
                break;
            case 4:
                [thiz OnOutline];
                break;
            case 5:
                if (GLOBAL.g_navigation_mode) {
                    GLOBAL.g_navigation_mode = 0;
                } else {
                    GLOBAL.g_navigation_mode = 1;
                }
                [self thumbInit];
                [self thumbGoTo:self.PDFCurPage];
                [self enter_none];
                break;
            case 6:
                if (GLOBAL.g_dark_mode) {
                    GLOBAL.g_dark_mode = false;
                } else {
                    GLOBAL.g_dark_mode = true;
                }
                [self->m_view refreshCurrentPage];
                break;
            case 7:
            {
                PDFPagesCtrl *pages = [[UIStoryboard storyboardWithName:@"PDFPagesCtrl" bundle:nil] instantiateViewControllerWithIdentifier:@"rdpdfpages"];
                [pages setCallback:self->m_doc :^(const bool *pages_del, const int *pages_rot)
                {
                    [self->m_view PDFSaveView];
                    [self->m_thumb PDFSaveView];
                    int pcnt = [self->m_doc pageCount];
                    int pcur = pcnt;
                    while(pcur > 0)
                    {
                        pcur--;
                        if(pages_del[pcur]) [self->m_doc removePage:pcur];
                        else if((pages_rot[pcur] >> 16) != (pages_rot[pcur] & 0xffff))
                        {
                            int deg = (pages_rot[pcur] & 0xffff) - (pages_rot[pcur] >> 16);
                            if(deg < 0) deg += 360;
                            PDFPage *page = [self->m_doc page:pcur];
                            int rotate = [page getRotate];
                            [self->m_doc setPageRotate:pcur :rotate + deg];
                        }
                    }
                    [self->m_thumb PDFRestoreView];
                    [self->m_view PDFRestoreView];
                }];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    pages.modalPresentationStyle = UIModalPresentationFullScreen;
                else
                    pages.modalPresentationStyle = UIModalPresentationFormSheet;
                
                [self presentViewController:pages animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }];
    [view updateIcons:_undoImage :_redoImage :_selectImage];
    if (![m_doc canSave]) {
        [view updateVisible:YES :YES :YES];
    }
    
    if (view.frame.size.height > (self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height - 50 - 50 - 10)) {
        m_popup = [[PDFPopupCtrl alloc] init:[self getScrollViewWithMenu:view]];
    } else {
        m_popup = [[PDFPopupCtrl alloc] init:view];
    }
    [self presentViewController:m_popup animated:YES completion:nil];
}

- (IBAction)annot_pressed:(id)sender
{
    if ([m_view canSaveDocument]) {
        //CGRect rect = _mBarNoneTop.frame;
        PDFLayoutView *vw = m_view;
        PDFReaderCtrl *thiz = self;
        //CGRect from = [self buttonRect:sender];
        
        if (showingThumb) {
            [self thumb_pressed:nil];
        }
        
        MenuAnnot *view = [[MenuAnnot alloc] init:CGPointMake(self.view.center.x-125, _mBarNoneBottom.frame.origin.y) :^(int type){
            thiz->m_annot_type = type;
            switch(type)
            {
                case 1://line
                    [vw vLineStart];
                    break;
                case 2://note
                    [vw vNoteStart];
                    break;
                case 3://erctangle
                    [vw vRectStart];
                    break;
                case 4://ellipse
                    [vw vEllipseStart];
                    break;
                case 5://stamp
                    [vw vImageStart];
                    break;
                case 6://editbox
                    [vw vEditboxStart];
                    break;
                case 100:
                    [vw vSelStart];
                    break;
                default://ink
                    [vw vInkStart];
                    break;
            }
            [thiz->m_popup dismiss];
            [self enter_annot];
        }];
        [view updateIcons:_drawImage];
        
        if (view.frame.size.height > (self.view.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height - 50 - 50 - 10)) {
            m_popup = [[PDFPopupCtrl alloc] init:[self getScrollViewWithMenu:view]];
        } else {
            m_popup = [[PDFPopupCtrl alloc] init:view];
        }
        [self presentViewController:m_popup animated:YES completion:nil];
    }
}

- (void)OnEditboxOK
{
    [m_view vEditboxEnd];
    [self enter_none];
}

- (IBAction)annot_ok:(id)sender
{
    switch(m_annot_type)
    {
        case 1://line
            [m_view vLineEnd];
            break;
        case 2://note
            [m_view vNoteEnd];
            break;
        case 3://erctangle
            [m_view vRectEnd];
            break;
        case 4://ellipse
            [m_view vEllipseEnd];
            break;
        case 5://stamp
            [m_view vImageEnd];
            break;
        case 6://editbox
            [m_view vEditboxEnd];
            break;
        case 100:
            [m_view vSelEnd];
            break;
        default://ink
            [m_view vInkEnd];
            break;
    }
    [self enter_none];
}
- (IBAction)annot_cancel:(id)sender
{
    switch(m_annot_type)
    {
        case 1://line
            [m_view vLineCancel];
            break;
        case 2://note
            [m_view vNoteCancel];
            break;
        case 3://erctangle
            [m_view vRectCancel];
            break;
        case 4://ellipse
            [m_view vEllipseCancel];
            break;
        case 5://stamp
            [m_view vImageCancel];
            break;
        case 6://editbox
            [m_view vEditboxCancel];
            break;
        case 100:
            [m_view vSelEnd];
            break;
        default://ink
            [m_view vInkCancel];
            break;
    }
    [self enter_none];
}

- (IBAction)annot_color:(id)sender
{
    RDAnnotPickerViewController *pickerViewController = [[RDAnnotPickerViewController alloc] initWithNibName:@"RDAnnotPickerViewController" bundle:nil];
    pickerViewController.annotType = m_annot_type;
    pickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    pickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

- (IBAction)search_result_pressed:(id)sender
{
    if (_mSearchText.text.length == 0) {
        return;
    }
    
    SearchResultViewController *viewController = [[SearchResultViewController alloc] initWithNibName:@"SearchResultViewController" bundle:nil];
    viewController.delegate = self;
    viewController.searchedString = _mSearchText.text;
    viewController.doc = m_doc;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)search_backward:(id)sender
{
    NSString *pat = _mSearchText.text;
    if(!pat || pat.length <= 0) return;
    if (!m_fstr)
        [m_view vFindStart:pat :GLOBAL.g_match_whole_word :GLOBAL.g_case_sensitive];
    [m_view vFind:-1];
}

- (IBAction)search_forward:(id)sender
{
    NSString *pat = _mSearchText.text;
    if(!pat || pat.length <= 0) return;
    if (!m_fstr)
        [m_view vFindStart:pat :GLOBAL.g_match_whole_word :GLOBAL.g_case_sensitive];
    [m_view vFind:1];
}

- (IBAction)search_tool_pressed:(id)sender
{
    MenuSearch *view = [[MenuSearch alloc] init:CGPointMake(_mBarNoneBottom.frame.origin.x, _mBarNoneBottom.frame.origin.y) :nil];
    m_popup = [[PDFPopupCtrl alloc] init:view];
    [self presentViewController:m_popup animated:YES completion:nil];
}

- (IBAction)search_cancel:(id)sender
{
    [_mSearchText resignFirstResponder];
    _mSearchText.text = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeGestureRecognizer:searchTapNone];
    [self.view removeGestureRecognizer:searchTapField];
    [[RDExtendedSearch sharedInstance] clearSearch];
    [m_view vFindEnd];
    [self refreshCurrentPage];
    [self enter_none];
}

- (RDMenu *)getScrollViewWithMenu:(RDMenu *)menu
{
    CGFloat x = self.view.center.x - menu.frame.size.width / 2;
        CGFloat y = [[UIApplication sharedApplication] statusBarFrame].size.height + 50 + 10;
    CGFloat height = self.view.frame.size.height - y - (self.view.frame.size.height - _mBarNoneBottom.frame.origin.y) - 10;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, menu.frame.size.width, height)];
    [menu setFrame:CGRectMake(0, 0, menu.frame.size.width, menu.frame.size.height)];
    [scrollView addSubview:menu];
    scrollView.layer.cornerRadius = 10.0f;
    scrollView.contentSize = CGSizeMake(menu.frame.origin.x, menu.frame.size.height);
    
    RDMenu *rdMenu = [[RDMenu alloc] initWithFrame:CGRectMake(x, y, menu.frame.size.width, height)];
    rdMenu.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    rdMenu.layer.cornerRadius = 10.0f;
    rdMenu.layer.shadowRadius = 10.0f;
    
    [rdMenu addSubview:scrollView];
    
    return rdMenu;
}

#pragma mark - PDFThumbViewDelegate

- (void)OnPageClicked :(int) pageno
{
    [m_view vGoto:pageno];
}

#pragma mark - Slider

- (void)setSliderText:(int)value {
    _mSliderLabel.text = [NSString stringWithFormat:@"%i/%i", value, m_doc.pageCount];
}

-(void)OnSliderValueChange:(UISlider*)slider forEvent:(UIEvent*)event
{
    [self updateSlider:slider.value goto:NO];
    UITouch *touchEvent = [[event allTouches] anyObject];
    if (touchEvent.phase == UITouchPhaseEnded) {
        [self updateSlider:slider.value goto:YES];
    }
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

#pragma mark - MenuController

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)initialPopupView
{
    UIMenuItem *underline = [[UIMenuItem alloc] initWithTitle:@"UDL" action:@selector(underline:)];
    UIMenuItem *highline = [[UIMenuItem alloc] initWithTitle:@"HGL" action:@selector(highlight:)];
    UIMenuItem *strike = [[UIMenuItem alloc] initWithTitle:@"STR" action:@selector(strikeOut:)];
    UIMenuItem *squiggly = [[UIMenuItem alloc] initWithTitle:@"SQG" action:@selector(squiggly:)];
    UIMenuItem *copyText = [[UIMenuItem alloc] initWithTitle:@"COPY" action:@selector(copyText:)];
    NSArray *itemsMC = [[NSArray alloc] initWithObjects:underline, highline, strike, squiggly, copyText, nil];
    selectMenu = [UIMenuController sharedMenuController];
    [selectMenu setMenuItems:itemsMC];
}
-(void)copyText:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString* s = [self->m_view vSelGetText];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = s;
        [self endSelect];
    });
}

-(void)highlight:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //0HighLight
        [self->m_view vSelMarkup:0];
        [self endSelect];
    });
    
}
-(void)underline:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //1UnderLine
        [self->m_view vSelMarkup:1];
        [self endSelect];
    });
}
-(void)strikeOut:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //2strikethrough
        [self->m_view vSelMarkup:2];
        [self endSelect];
    });
}
-(void)squiggly:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //4squiggly
        [self->m_view vSelMarkup:4];
        [self endSelect];
    });
}

- (void)endSelect
{
    [self enter_none];
    [m_view vSelEnd];
}


#pragma mark - PDFLayoutDelegate

- (void)OnPageChanged :(int)pageno
{
    static int prevPage = -1;
    if (_delegate && [_delegate respondsToSelector:@selector(didChangePage:)]) {
        if (pageno != prevPage) {
            prevPage = pageno;
            [_delegate didChangePage:pageno];
        }
    }
    [self thumbGoTo:pageno];
}
- (void)OnPageUpdated :(int)pageno
{
    [m_thumb PDFUpdatePage:pageno];
}

- (void)OnLongPressed:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didLongPressOnPage:atPoint:)]) {
        RDVPos pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didLongPressOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
}

- (void)OnSingleTapped:(float)x :(float)y
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnPage:atPoint:)]) {
        RDVPos pos;
        [m_view vGetPos:&pos x:x y:y];
        [_delegate didTapOnPage:pos.pageno atPoint:CGPointMake(x, y)];
    }
    
    if(_mBarNoneTop.hidden)
    {
        [self showBars];
    }
    else
    {
        [self hideBars];
    }
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
        [_delegate didSearchTerm:_mSearchText.text found:found];
    }
    
    if(!found)
    {
        [self show_error:@"No more found!"];
    }
}

- (void)OnSelStart:(float)x :(float)y
{
}

- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2
{
    NSString *s = [m_view vSelGetText];
    NSLog(@"OnSelEnd select text = %@",s);
    if(s)
    {
        //popup a menu
        [selectMenu setTargetRect:CGRectMake(x2 * m_view.zoomScale, y2 * m_view.zoomScale, 0, 0) inView:m_view];
        [selectMenu setMenuVisible:YES animated:YES];
    }
}

-(void)OnAnnotEdit:(PDFAnnot *)annot
{
    [self hideBars];
    RDPopupTextViewController *popupTextViewController = [[RDPopupTextViewController alloc] initWithNibName:@"RDPopupTextViewController" bundle:nil];
    popupTextViewController.annot = annot;
    popupTextViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    popupTextViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:popupTextViewController animated:YES completion:nil];
}
-(void)OnAnnotProp:(PDFAnnot *)annot
{
    int atype = [annot type];
    if(atype == 4 || atype == 8)//line and polyline
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DlgAnnotPropLine" owner:self options:nil];
        DlgAnnotPropLine *view = [views lastObject];
        
        PDFLayoutView *vw = m_view;
        PDFDialog *dlg = [[PDFDialog alloc] init:view :CGRectMake(0, 0, 300, 410) :YES :^(BOOL is_ok){
            if (is_ok)
            {
                [view updateAnnot];
                [vw vAnnotEnd];
                [vw vUpdateAnnotPage];
                [vw setModified:YES force:NO];
            }
            else
                [vw vAnnotEnd];
        }];
        [view setAnnot:annot :dlg];
        [self presentViewController:dlg animated:NO completion:nil];
    }
    else if(atype >= 9 && atype <= 12)//markup
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DlgAnnotPropMarkup" owner:self options:nil];
        DlgAnnotPropMarkup *view = [views lastObject];
        
        PDFLayoutView *vw = m_view;
        PDFDialog *dlg = [[PDFDialog alloc] init:view :CGRectMake(0, 0, 300, 210) :YES :^(BOOL is_ok)
        {
            if (is_ok)
            {
                [view updateAnnot];
                [vw vAnnotEnd];
                [vw vUpdateAnnotPage];
                [vw setModified:YES force:NO];
            }
            else
                [vw vAnnotEnd];
        }];
        [view setAnnot:annot :dlg];
        [self presentViewController:dlg animated:NO completion:nil];
    }
    else if(atype == 1 || atype == 17)//sticky note and file attachment.
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DlgAnnotPropIcon" owner:self options:nil];
        DlgAnnotPropIcon *view = [views lastObject];
        PDFLayoutView *vw = m_view;
        PDFDialog *dlg = [[PDFDialog alloc] init:view :CGRectMake(0, 0, 300, 210) :YES :^(BOOL is_ok){
            if (is_ok)
            {
                [view updateAnnot];
                [vw vAnnotEnd];
                [vw vUpdateAnnotPage];
                [vw setModified:YES force:NO];
            }
            else
                [vw vAnnotEnd];
        }];
        [view setAnnot:annot :dlg];
        [self presentViewController:dlg animated:NO completion:nil];
    }
    else
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DlgAnnotPropComm" owner:self options:nil];
        DlgAnnotPropComm *view = [views lastObject];
        [view hasFill:(atype != 15)];

        PDFLayoutView *vw = m_view;
        PDFDialog *dlg = [[PDFDialog alloc] init:view :CGRectMake(0, 0, 300, 310) :YES :^(BOOL is_ok){
            if (is_ok)
            {
                [view updateAnnot];
                [vw vAnnotEnd];
                [vw vUpdateAnnotPage];
                [vw setModified:YES force:NO];
            }
            else
                [vw vAnnotEnd];
        }];
        [view setAnnot:annot :dlg];
        [self presentViewController:dlg animated:NO completion:nil];
    }
}

- (void)OnAnnotClicked:(PDFAnnot *)annot :(CGRect)annotRect :(float)x :(float)y
{
    int atype = [annot type];
    PDFLayoutView *vw = m_view;
    PDFReaderCtrl *thiz = self;
    if(atype != 3 && atype != 20)
    {
        if (annotRect.size.width > [[UIScreen mainScreen] bounds].size.width && annotRect.origin.y < [[UIScreen mainScreen] bounds].origin.y) {
            annotRect.origin = [[UIScreen mainScreen] bounds].origin;
        }
        m_menu_op = [[MenuAnnotOp alloc] init :annot :annotRect.origin :^(int opt){
            switch(opt)
            {
                case 0://perform
                    [vw vAnnotPerform];
                    break;
                case 1://edit
                    [thiz OnAnnotEdit:thiz->m_menu_op.annot];
                    break;
                case 2://remove
                    [vw vAnnotRemove];
                    break;
                case 3://property
                    [thiz OnAnnotProp:thiz->m_menu_op.annot];
                    break;
                case 4: //lock/unlock
                    [annot setLocked:![annot isLocked]];
                    break;
            }
            if(thiz->m_menu_op)
            {
                [thiz->m_menu_op removeFromSuperview];
                thiz->m_menu_op = nil;
            }
        }];
        [m_menu_op updateIcons:_performImage :_deleteImage];
        [_mView addSubview:m_menu_op];
    }
    [self enter_annot_edit];
}
//notified when annotation status end.
- (void)OnAnnotEnd
{
    if(m_menu_op)
    {
        [m_menu_op removeFromSuperview];
        m_menu_op = nil;
    }
    [self showBars];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotGoto:(int)pageno
{
    [m_view vGoto:pageno];
    [self thumbGoTo:pageno];
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotOpenURL:(NSString *)url
{
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
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
- (void)OnAnnotMovie:(NSString *)_fileName
{
    /*
    [tempfiles addObject:_fileName];
    NSURL *urlPath = [NSURL fileURLWithPath:_fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_fileName]) {
        AVPlayerViewController *avvc = [[AVPlayerViewController alloc] init];
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
     */
}
//this mehod fired only when vAnnotPerform method invoked.
- (void)OnAnnotSound:(NSString *)_fileName
{
    //[tempfiles addObject:_fileName];
}

- (void)OnAnnotEditBox:(PDFAnnot *)annot :(CGRect)annotRect :(NSString *)editText :(float)textSize
{
    PDFPopupCtrl *pop;
    if([annot getEditType] == 3)//multi-line
    {
        UITextView *text = [[UITextView alloc] init];
        pop = [[PDFPopupCtrl alloc] init:text];
        CGRect rect = [_mView convertRect:annotRect toView: pop.view];
        text.frame = rect;
        text.text = editText;
        text.backgroundColor = [UIColor whiteColor];
        text.textColor = [UIColor blackColor];
        text.font = [UIFont systemFontOfSize:textSize];
        PDFLayoutView *vw = m_view;
        [pop setDismiss:^{
            [annot setEditText:text.text];
            [vw vUpdateAnnotPage];
            [vw vAnnotEnd];
            [vw setModified:YES force:NO];
        }];
    }
    else
    {
        UITextField *text = [[UITextField alloc] init];
        pop = [[PDFPopupCtrl alloc] init:text];
        CGRect rect = [_mView convertRect:annotRect toView: pop.view];
        text.frame = rect;
        text.text = editText;
        text.backgroundColor = [UIColor whiteColor];
        text.textColor = [UIColor blackColor];
        text.font = [UIFont systemFontOfSize:textSize];
        PDFLayoutView *vw = m_view;
        [pop setDismiss:^{
            [annot setEditText:text.text];
            [vw vUpdateAnnotPage];
            [vw vAnnotEnd];
            [vw setModified:YES force:NO];
        }];
    }
    [self presentViewController:pop animated:NO completion:nil];
}

- (void)OnAnnotCommboBox:(PDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selected:(int)index
{
    MenuCombo *view = [[MenuCombo alloc] init];
    PDFPopupCtrl *pop = [[PDFPopupCtrl alloc] init:view];
    [pop setDismiss:^{
        [self->m_view vAnnotEnd];
    }];

    CGFloat fsize = [m_view vGetScale] * 12 / [m_view vGetPixSize];
    CGRect rect = [_mView convertRect:annotRect toView: pop.view];
    int max_cnt = (dataArray.count > 5) ? 5 : (int)dataArray.count;//max 5 items height for scrollView
    rect.origin.y += rect.size.height;
    rect.size.height = (fsize + 2) * max_cnt;
    
    view.frame = rect;
    PDFLayoutView *vw = m_view;
    [view setPara:rect.size.width :fsize :dataArray :^(int idx){
        [annot setComboSel:idx];
        [vw vUpdateAnnotPage];
        [vw vAnnotEnd];
        [vw setModified:YES force:NO];
        [pop dismiss];
    }];
    [self presentViewController:pop animated:NO completion:nil];
}

- (void)OnAnnotList:(PDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selectedIndexes:(NSArray *)indexes
{
    MenuCombo *view = [[MenuCombo alloc] init];
    PDFPopupCtrl *pop = [[PDFPopupCtrl alloc] init:view];
    [pop setDismiss:^{
        [self->m_view vAnnotEnd];
    }];

    CGFloat fsize = [m_view vGetScale] * 12 / [m_view vGetPixSize];
    CGRect rect = [_mView convertRect:annotRect toView: pop.view];
    
    view.frame = rect;
    PDFLayoutView *vw = m_view;
    [view setPara:rect.size.width :fsize :dataArray :^(int idx){
        int sels[1] = {idx};
        [annot setListSels:sels :1];
        [vw vUpdateAnnotPage];
        [vw vAnnotEnd];
        [vw setModified:YES force:NO];
        [pop dismiss];
    }];
    [self presentViewController:pop animated:NO completion:nil];
}

- (void)OnAnnotTapped:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapOnAnnotationOfType:atPage:atPoint:)]) {
        [_delegate didTapOnAnnotationOfType:annot.type atPage:page atPoint:point];
    }
}

#pragma mark - Signature

- (void)OnAnnotSignature:(PDFAnnot *)annot {
    
    NSString *annotImage = [m_view getImageFromAnnot:annot];
    NSString *emptyImage = [m_view emptyImageFromAnnot:annot];
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:annotImage error:nil];
    NSDictionary *emptyAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:emptyImage error:nil];
    
    if (attr.fileSize != emptyAttr.fileSize) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", @"Localizable") message:NSLocalizedString(@"Signature already exist. Do you want delete it?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self presentSignatureViewController:[annot getIndex]];
        }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->m_view vAnnotEnd];
        }];
              
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentSignatureViewController:[annot getIndex]];
    }
}

- (void)presentSignatureViewController:(int)annotIdx
{
    SignatureViewController *sv = [[SignatureViewController alloc] init];
    sv.delegate = self;
    sv.annotIdx = annotIdx;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sv.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        sv.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    [self presentViewController:sv animated:YES completion:nil];
}

- (void)didSign:(int)annotIdx
{
    [self dismissViewControllerAnimated:YES completion:^{
        PDFPage *page = [self->m_doc page:[self->m_view vGetCurrentPage]];
        [self->m_view setSignatureImageAtIndex:annotIdx atPage:[self->m_view vGetCurrentPage]];
        PDF_DOC_FORM hand = Document_newForm([self->m_doc handle]);
        PDFDocForm *docForm = [[PDFDocForm alloc] init:[self->m_doc handle] :hand];
        PDF_RECT rect;
        [[page annotAtIndex:annotIdx] getRect:&rect];
        NSString *certPath = [[[NSBundle mainBundle] pathForResource:@"PDFRes" ofType:nil] stringByAppendingPathComponent:@"test.pfx"];
        int success = [page sign:docForm :&rect :certPath :@"111111" :@"" :@"" :@"" :@""];
        [self onDismissSignView];
    }];
}

- (void)onDismissSignView
{
    [m_view vAnnotEnd];
    [self refreshCurrentPage];
}

#pragma mark - Search list delegate
- (void)didSelectSelectSearchResult:(int)index
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self goToSearchResult:index];
    }];
}

- (void)goToSearchResult:(int)index
{
    [self PDFGoto:index];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSearch:[[RDExtendedSearch sharedInstance] searchTxt] dir:1 reset:YES];
    });
}

- (void)startSearch:(NSString *)text dir:(int)dir reset:(BOOL)reset
{
    NSString *findString;
    BOOL b_findStart = NO;
    
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

#pragma mark - Popup text delegate
- (void)onDismissPopupTextViewEdited:(BOOL)edited
{
    [m_view vAnnotEnd];
    [m_view vUpdateAnnotPage];
    if (edited) {
        [m_view setModified:YES force:NO];
    }
}

#pragma mark - RDTreeTableview delegate

- (void)didSelectDest:(OUTLINE_ITEM *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([item dest]) {
            [self PDFGoto:[item dest]];
        }
    }];
}

#pragma mark - Utils

- (CGRect)buttonRect:(UIBarButtonItem *)item {
    UIView *v = [item valueForKey:@"view"];
    CGRect fromRect = [_mBarNoneTop convertRect:v.frame toView:self.view];
    if (fromRect.origin.x + rd_menu_width > self.view.bounds.size.width) {
        fromRect.origin.x = self.view.bounds.size.width - rd_menu_width - 8;
    }
    return fromRect;
}

- (CGPoint)pdfPointsFromScreenPoints:(int)x :(int)y
{
    RDVPos pos;
    [m_view vGetPos:&pos x:x y:y];
    CGPoint pdfPoints;
    pdfPoints.x = pos.pdfx;
    pdfPoints.y = pos.pdfy;
    return pdfPoints;
}

- (CGPoint)screenPointsFromPdfPoints:(float)x :(float)y :(int)pageNum
{
    return [m_view screenPointsFromPdfPoints:x :y :pageNum];
}

- (NSArray *)pdfRectFromScreenRect:(CGRect)screenRect
{
    PDF_RECT pdfrect = [m_view pdfRectFromScreenRect:screenRect];
    NSArray *rect = [NSArray arrayWithObjects:[NSNumber numberWithFloat:pdfrect.top],[NSNumber numberWithFloat:pdfrect.left],[NSNumber numberWithFloat:pdfrect.right],[NSNumber numberWithFloat:pdfrect.bottom], nil];
    return rect;
}

- (CGRect)screenRectFromPdfRect:(float)top :(float)left :(float)right :(float)bottom :(int)pageNum
{
    return [m_view screenRectFromPdfRect:top :left :right :bottom :pageNum];
}


@end
