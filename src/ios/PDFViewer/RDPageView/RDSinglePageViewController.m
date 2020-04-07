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
    _pdfView = [[PDFLayoutView alloc] initWithFrame:self.view.frame];
    _pdfView.scrollEnabled = NO;
    _pdfView.pageViewNo = _pageViewNo;
    _pdfView.userInteractionEnabled = NO;
    BOOL success = [_pdfView PDFOpen:_doc :4 :self];
    [self.view addSubview:_pdfView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_pdfView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [_pdfView sizeThatFits:size];
}

- (void)OnAnnotClicked:(PDFAnnot *)annot :(float)x :(float)y {
    
}

- (void)OnAnnotCommboBox:(NSArray *)dataArray selected:(int)index {
    
}

- (void)OnAnnotEditBox:(CGRect)annotRect :(NSString *)editText :(float)textSize {
    
}

- (void)OnAnnotEnd {
    
}

- (void)OnAnnotGoto:(int)pageno {
    
}

- (void)OnAnnotList:(PDFAnnot *)annot items:(NSArray *)dataArray selectedIndexes:(NSArray *)indexes {
    
}

- (void)OnAnnotMovie:(NSString *)fileName {
    
}

- (void)OnAnnotOpenURL:(NSString *)url {
    
}

- (void)OnAnnotPopup:(PDFAnnot *)annot {
    
}

- (void)OnAnnotSignature:(PDFAnnot *)annot {
    
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

- (void)didTapAnnot:(PDFAnnot *)annot atPage:(int)page atPoint:(CGPoint)point {
    
}

@end
