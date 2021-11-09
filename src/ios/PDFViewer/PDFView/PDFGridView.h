//
//  PDFThumbView.h
//  PDFViewer
//
//  Created by strong on 2016/12/11.
//
//

#import "PDFLayoutView.h"
#import "PDFThumbView.h"

@interface PDFGridView : PDFLayoutView
{
    id<PDFThumbViewDelegate> m_delegate;
    int m_sel_pno;
    int thumbBackgroundColor;
}
- (id)initWithFrame:(CGRect)frame;
- (BOOL)PDFOpen :(RDPDFDoc *)doc :(int)page_gap :(id<PDFLayoutDelegate>)del;
- (void)PDFUpdatePage:(int)pageno;
- (void)setThumbBackgroundColor:(int)color;
@end
