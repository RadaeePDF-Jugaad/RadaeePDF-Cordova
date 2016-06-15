#pragma once
#import "PDFIOS.h"
#import "PDFVGlobal.h"
#include "PDFVPage.h"

@interface PDFVFinder : NSObject
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
	PDFVEvent *m_eve;
}
-(void)find_start:(PDFDoc *)doc :(int)page_start :(NSString *)str :(bool)match_case :(bool) whole;
-(int)find_prepare:(int) dir;
-(int)find;
-(bool)find_get_pos:(PDF_RECT *)rect;//get current found's bound.
-(void)find_draw:(PDFVCanvas *)canvas :(PDFVPage *)page;//draw current found
-(int)find_get_page;//get current found's page NO
-(void)find_end;
@end
