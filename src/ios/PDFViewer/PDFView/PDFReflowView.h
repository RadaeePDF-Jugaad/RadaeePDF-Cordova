//
//  PDFReflowView.h
//  PDFViewer
//
//  Created by strong on 14-1-21.
//
//

#import <UIKit/UIKit.h>
#import "RDPDFViewController.h"


@interface PDFReflowView : UIScrollView
{
    PDFDoc *m_doc;
    PDFPage *m_page;
    CGImageRef m_img;
    UIImageView *imageView;
    UIImage *m_image;
    float scale;
    CGImageRef ori_img;
    //NSTimer *m_timer;
    bool m_modified;
    int m_w;
    int m_h;
    int m_cur_page;
    PDFDIB *dib;
}

@property (copy) UIImage *m_image;

-(void)vOpen:(PDFDoc *)doc :(NSString *)docPath;
//-(void)vOpenPage:(PDFDoc *)doc :(int)pageno :(float)x :(float)y;
//-(void)vGoto:(int)pageno;
-(void)vClose;
-(void)render :(int)PageNo :(float)ratio;
@end
