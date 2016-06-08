//
//  PDFReflowView.h
//  PDFViewer
//
//  Created by strong on 14-1-21.
//
//

#import <UIKit/UIKit.h>
#import "PDFReaderCtrl.h"
#import "PDFObjc.h"

@interface PDFReflowView : UIScrollView
{
    RDPDFDoc *m_doc;
    RDPDFPage *m_page;
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
    RDPDFDIB *m_dib;
}

@property (copy) UIImage *m_image;

-(void)vOpen:(RDPDFDoc *)doc :(NSString *)docPath;
//-(void)vOpenPage:(RDPDFDoc *)doc :(int)pageno :(float)x :(float)y;
//-(void)vGoto:(int)pageno;
-(void)vClose;
-(void)render :(int)PageNo :(float)ratio;
@end
