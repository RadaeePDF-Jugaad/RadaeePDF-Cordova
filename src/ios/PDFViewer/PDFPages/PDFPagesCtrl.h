//
//  PDFPagesCtrl.h
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#pragma once
#import <UIKit/UIKit.h>
#import "PDFPagesView.h"
@class RDPDFDoc;

typedef void(^PagesDone)(const bool *pages_del, const int *pages_rot);

@interface PDFPagesCtrl : UIViewController
{
    __weak IBOutlet PDFPagesView *mPages;
    RDPDFDoc *m_doc;
    PagesDone m_done;
}
- (void)setCallback:(RDPDFDoc *)doc :(PagesDone)done;
- (IBAction)OnBtnBack:(id)sender;
- (IBAction)OnBtnDone:(id)sender;
@end
