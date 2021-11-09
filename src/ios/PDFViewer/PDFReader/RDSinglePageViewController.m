//
//  ViewController.m
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import "RDSinglePageViewController.h"

@interface RDSinglePageViewController ()

@end

@implementation RDSinglePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mView = [[RDPDFView alloc] initWithFrame:self.view.frame];
    _pdfView = mView.view;
    _pdfView.scrollEnabled = NO;
    _pdfView.singleViewPageNo = _pageViewNo;
    _pdfView.userInteractionEnabled = NO;
//-(BOOL)PDFOpen :(RDPDFDoc *)doc :(int)page_gap :(RDPDFCanvas *)canvas :(id<PDFLayoutDelegate>) del;
    BOOL success = [_pdfView PDFOpen:_doc :4 :mView.canvas :self];
    [self.view addSubview:_pdfView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_pdfView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [_pdfView sizeThatFits:size];
}

- (void)OnAnnotClicked:(RDPDFAnnot *)annot :(float)x :(float)y {
    
}

- (void)OnAnnotCommboBox:(RDVPage *)vp :(NSArray *)dataArray selected:(int)index {
    
}

- (void)OnAnnotEditBox:(CGRect)annotRect :(NSString *)editText :(float)textSize {
    
}

- (void)OnAnnotEnd {
    
}

- (void)OnAnnotGoto:(int)pageno {
    
}

- (void)OnAnnotList:(RDVPage *)vp :(RDPDFAnnot *)annot items:(NSArray *)dataArray selectedIndexes:(NSArray *)indexes {
    
}

- (void)OnAnnotMovie:(NSString *)fileName {
    
}

- (void)OnAnnotOpenURL:(NSString *)url {
    
}

- (void)OnAnnotPopup:(RDPDFAnnot *)annot {
    
}

- (void)OnAnnotSignature:(RDVPage *)vp :(RDPDFAnnot *)annot {
    
}

- (void)OnAnnotSound:(NSString *)fileName {
    
}

- (void)OnDoubleTapped:(float)x :(float)y {
    
}

- (void)OnFound:(bool)found {
    
}

- (void)OnLongPressed:(float)x :(float)y {
    
}

- (void)OnPageChanged:(int)pageno {
    
}

- (void)OnPageUpdated:(int)pageno {
    
}

- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2 {
    
}

- (void)OnSelStart:(float)x :(float)y {
    
}

- (void)OnSingleTapped:(float)x :(float)y {
    
}

- (void)OnAnnotClicked:(RDPDFAnnot *)annot :(PDF_RECT)rect :(float)x :(float)y {
}


- (void)OnAnnotCommboBox:(RDVPage *)vp :(RDPDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selected:(int)index {
}


- (void)OnAnnotEditBox:(RDPDFAnnot *)annot :(CGRect)annotRect :(NSString *)editText :(float)textSize {
}


- (void)OnAnnotList:(RDVPage *)vp :(RDPDFAnnot *)annot :(CGRect)annotRect :(NSArray *)dataArray selectedIndexes:(NSArray *)indexes {
}


- (void)OnAnnotTapped:(RDPDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point {
}


- (void)didTapAnnot:(RDPDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
}

- (void)setNeedsFocusUpdate {
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return NO;
}

- (void)updateFocusIfNeeded {
}

@end
