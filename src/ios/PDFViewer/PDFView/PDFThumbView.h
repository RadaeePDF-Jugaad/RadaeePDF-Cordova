//
//  PDFThumbView.h
//  PDFViewer
//
//  Created by strong on 2016/12/11.
//
//

#import "PDFLayoutView.h"

@protocol PDFThumbViewDelegate <NSObject>
- (void)OnPageClicked :(int) pageno;
@end

@class RDPDFThumb;
@interface PDFThumbView : PDFLayoutView
{
    id<PDFThumbViewDelegate> m_delegate;
    int m_sel_pno;
    UIFont *m_font;
    UIColor *m_color;
    NSMutableParagraphStyle *m_pstyle;
}
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (BOOL)PDFOpen :(PDFDoc *)doc :(int)page_gap :(RDPDFCanvas *)canvas :(id<PDFThumbViewDelegate>)del;
- (void)PDFUpdatePage:(int)pageno;
- (void)PDFSetBGColor:(int)color;
- (void)PDFSaveView;
- (void)PDFRestoreView;
@end
