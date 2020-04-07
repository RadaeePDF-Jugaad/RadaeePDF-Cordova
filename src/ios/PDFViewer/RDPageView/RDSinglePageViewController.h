//
//  ViewController.h
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFLayoutView.h"

@interface RDSinglePageViewController : UIViewController <PDFLayoutDelegate>

@property (strong, nonatomic) PDFDoc *doc;
@property (strong, nonatomic) PDFLayoutView *pdfView;
@property (nonatomic) NSUInteger pageViewNo;

@end

