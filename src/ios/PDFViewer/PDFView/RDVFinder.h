#pragma once
#import "PDFObjc.h"

#define DRAW_ALL 0

@class RDVEvent;
@class RDVPage;
@class RDVCanvas;

@interface RDVFinder : NSObject
{
	NSString *m_str;
	bool m_case;
	bool m_whole;
	int m_page_no;
	int m_page_find_index;
	int m_page_find_cnt;
	PDFPage *m_page;
	PDFDoc *m_doc;
	
	PDFFinder *m_finder;
	
	int m_dir;
	bool is_cancel;
	bool is_notified;
	bool is_waitting;
	RDVEvent *m_eve;
}
-(void)find_start:(PDFDoc *)doc :(int)page_start :(NSString *)str :(bool)match_case :(bool) whole;
-(int)find_prepare:(int) dir;
-(int)find;
-(bool)find_get_pos:(PDF_RECT *)rect;//get current found's bound.
-(void)find_draw:(RDVCanvas *)canvas :(RDVPage *)page;//draw current found
-(void)find_draw_all:(RDVCanvas *)canvas :(RDVPage *)page;//draw all occurrences found
-(int)find_get_page;//get current found's page NO
-(void)find_end;
-(void)drawOffScreen :(RDVCanvas *)canvas :(RDVPage *)page :(int)docx :(int)docy;
@end
