#pragma once
#include "PDFObjc.h"
#include "PDFVFinder.h"
#include "PDFVPage.h"
#include "PDFVCanvas.h"
#include "PDFVThread.h"

@protocol PDFVInnerDel <NSObject>
-(void)OnPageChanged:(int)pageno;
-(void)OnPageDisplayed :(CGContextRef)ctx : (PDFVPage *)page;
-(void)OnFound:(PDFVFinder *)finder;
@end

struct PDFV_POS
{
    int pageno;
    float x;
    float y;
};

@interface PDFV : NSObject
{
	int m_x;
	int m_y;
	int m_docw;
	int m_doch;
	int m_w;
	int m_h;
	int m_page_gap;
	int m_page_gap_half;
	//int m_back_clr;
    int m_prange_start;
    int m_prange_end;
    int m_pageno;

	int m_hold_vx;
	int m_hold_vy;
	int m_hold_x;
	int m_hold_y;
	float m_scale;
	float m_scale_min;
	float m_scale_max;
	PDFDoc *m_doc;
	NSMutableArray *m_pages;
	int m_pages_cnt;
	PDFVThread *m_thread;
	PDFVFinder *m_finder;
	id<PDFVInnerDel> m_del;
    
    // custom scales
    float *m_widths;
    float *m_heights;
    float *m_scales_min;
    float *m_scales_max;
    float *m_scales;
}
-(void)vResize:(int)w : (int)h;
-(void)vClose;
-(void)vOpen:(PDFDoc *) doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp;
-(bool)vFindGoto;
-(void)vLayout;
-(void)vGetPos :(struct PDFV_POS *)pos :(int)x :(int)y;
-(void)vSetPos :(const struct PDFV_POS *)pos :(int)x : (int)y;
-(bool)vNeedRefresh;
-(void)vDraw:(PDFVCanvas *)canvas :(bool)zooming;
-(PDFVPage *)vGetPage:(int) pageno;
-(void)vFindStart:(NSString *)pat :(bool)match_case :(bool) whole_word;
-(int)vFind:(int) dir;
-(void)vFindEnd;
-(void)vGetDeltaToCenterPage:(int)pageno :(int *)dx :(int *)dy;
-(void)vMoveTo:(int)x :(int)y;
-(void)vZoomStart;
-(float)vGetScale;
-(float)vGetScale:(int)page;
-(float)vGetScaleMin;
-(float)vGetScaleMin:(int)page;
-(void)vSetScale:(float) scale;
-(void)vSetScale:(float)scale page:(int)page;
-(void)vSetSel:(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)vSetSelWholeWord:(int)x1 : (int)y1 : (int)x2 : (int)y2;
-(void)vClearSel;
-(int)vGetX;
-(int)vGetY;
-(int)vGetDocW;
-(int)vGetDocH;
-(void)vRenderAsync:(int)pageno;
-(void)vRenderSync:(int)pageno;
- (float)getWidth;
- (float)getHeight;
- (CGImageRef )vGetImageRefForPage:(int)pg withWidth:(int)iw andHeight:(int)ih withBackground:(BOOL)hasBackground;
@end

@interface PDFVVert: PDFV
{
}
-(void)vLayout;
@end

@interface PDFVHorz: PDFV
{
	bool m_rtol;
}
-(id)init:(bool)rtol;
-(void)vOpen:(PDFDoc *)doc :(int) page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp;
-(void)vResize:(int)w :(int)h;
-(void)vLayout;
@end


@interface PDFVDual: PDFV
{
	bool *m_vert_dual;
	int m_vert_dual_cnt;
	bool *m_horz_dual;
	int m_horz_dual_cnt;
	bool m_rtol;
	struct PDFCell
	{
		int left;
		int right;
		int page_left;
		int page_right;
	}* m_cells;
	int m_cells_cnt;
}
-(id)init:(bool)rtol :(const bool *)verts :(int)verts_cnt :(const bool *)horzs :(int) horzs_cnt;
-(void)vClose;
-(void)vOpen:(PDFDoc *)doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp;
-(void)vResize:(int)w : (int)h;
-(void)vLayout;
-(void)vGetDeltaToCenterPage:(int)pageno :(int *)dx :(int *)dy;
@end

@interface PDFVThmb: PDFV
{
	int m_orientation;
	int m_sel;
    bool m_rtol;
}
-(id)init:(int)orientation :(bool)rtol;
-(void)vOpen:(PDFDoc *) doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp;
-(void)vClose;
-(void)vLayout;
-(void)vDraw:(PDFVCanvas *)canvas :(bool)zooming;
-(void)vSetSel:(int)pageno;
-(int)vGetSel;
-(void)vRenderAsync:(int)pageno;
-(void)vRenderSync:(int)pageno;
@end

@interface PDFVGrid: PDFV
{
    int m_grid_mode;
    int m_element_height;
    int m_orientation;
    int m_sel;
    bool m_rtol;
}
-(id)init:(int)orientation :(bool)rtol;
-(id)init:(int)orientation :(bool)rtol :(int)height :(int)gridMode;
-(void)vOpen:(PDFDoc *) doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp;
-(void)vClose;
-(void)vLayout;
-(void)vDraw:(PDFVCanvas *)canvas :(bool)zooming;
-(void)vSetSel:(int)pageno;
-(int)vGetSel;
-(void)vRenderAsync:(int)pageno;
-(void)vRenderSync:(int)pageno;
@end
