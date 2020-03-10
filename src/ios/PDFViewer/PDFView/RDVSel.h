#pragma once
#import "PDFObjc.h"

@class RDVCanvas;
@class RDVPage;

@interface RDVSel : NSObject
{
	PDFPage *m_page;
    int m_pgno;
	int m_index1;
	int m_index2;
	bool m_ok;
}
@property(readonly) int pageno;
@property(strong, nonatomic) PDFPage *pdfpage;
-(id)init:(PDFPage *)page :(int)pgno;
-(void)Reset;
-(void)Clear;
-(void)SetSel:(float)x1 : (float)y1 : (float)x2 : (float)y2;
-(bool)SetSelMarkup:(int) type;
-(NSString *)GetSelString;
-(void)DrawSel:(RDVCanvas *)canvas :(RDVPage *)page;
-(void)drawOffScreen :(RDVCanvas *)canvas :(RDVPage *)page :(int)docx :(int)docy;
-(int)startIdx;
-(int)endIdx;
@end
