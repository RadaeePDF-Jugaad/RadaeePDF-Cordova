//
//  RDPDFReflowViewController.h
//  PDFViewer
//
//  Created by strong on 14-1-19.
//
//

#import <UIKit/UIKit.h>
#import "PDFIOS.h"
#import <CoreData/CoreData.h>
#import "PDFReflowView.h"
#import "PDFObjc.h"

@interface RDPDFReflowViewController : UIViewController
{
    PDFReflowView *m_view;
    RDPDFDoc *m_doc;
    RDPDFPage *m_page;
    CGImageRef m_img;
    int m_cur_page;
    UIImage *img;
    int pageCount;
    float ratio;
}
@property (strong ,nonatomic)UIToolbar *toolBar;
@property (strong,nonatomic)UIImageView *imageView;

-(int)PDFOpen:(NSString *)path :(NSString *)pswd;
//-(int)PDFOpenPage:(NSString *)path :(int)pageno : (float)x :(float)y :(NSString *)pwd;
//-(BOOL)PDFGoto:(int)pageno;
- (BOOL)isPortrait;
@end
