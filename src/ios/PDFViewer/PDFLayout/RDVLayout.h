//
//  RDVLayout.h
//  RDPDFReader
//
//  Created by Radaee on 16/11/20.
//  Copyright © 2016年 radaee. All rights reserved.
//
#pragma once
#import "PDFObjc.h"

@class RDVPage;
@class RDVThread;
@class RDVCanvas;
@class RDVSel;
@class RDVFinder;

typedef struct _RDVPos
{
    int pageno;
    float pdfx;
    float pdfy;
}RDVPos;

@protocol RDVLayoutDelegate <NSObject>
- (void)RDVOnPageRendered:(int)pageno;
- (void)RDVOnFound:(RDVFinder *)finder;
@end

@interface RDVLayout :NSObject
{
    PDFDoc *m_doc;
    NSMutableArray *m_pages;
    int m_pages_cnt;
    RDVThread *m_thread;
    float m_scale;
    float m_scale_min;
    float m_scale_max;
    int m_w;
    int m_h;
    int m_docx;
    int m_docy;
    int m_docw;
    int m_doch;
    int m_cellw;
    int m_cellh;
    int m_page_gap;
    int m_disp_pg1;
    int m_disp_pg2;
    RDVPos m_zoom_pos;
    bool m_zooming;
    int m_zoom_pg1;
    int m_zoom_pg2;
    RDVFinder *m_finder;
    id<RDVLayoutDelegate> m_del;
    CALayer *m_rlayer;
    
    // custom scales
    float *m_scales_min;
    float *m_scales_max;
    float *m_scales;
}
@property(readonly) int docx;
@property(readonly) int docy;
@property(readonly) int docw;
@property(readonly) int doch;
@property(readonly) int vw;
@property(readonly) int vh;
@property(readonly) float zoomMin;
@property(readonly) float zoomMax;
@property(readonly) float zoom;
@property(readonly) RDVFinder *finder;
@property(readonly) int cur_pg1;
@property(readonly) int cur_pg2;

-(id)init :(id<RDVLayoutDelegate>)del;
-(void)vOpen :(PDFDoc *)doc :(int)page_gap :(CALayer *)rlay;
-(void)vClose;
-(void)vResize :(int)vw :(int)vh;
-(void)vGetPos :(int)vx :(int)vy :(RDVPos *)pos;
-(void)vSetPos :(int)vx :(int)vy :(const RDVPos *)pos;
-(void)vMoveTo :(int)docx :(int)docy;
-(RDVPage *)vGetPage :(int)pageno;
-(void)vDraw :(RDVCanvas *)canvas;
-(float)vGetScaleMin:(int)page;
-(void)vZoomStart;
-(void)vZooming:(float)zoom;
-(void)vZoomConfirm;
-(void)vGotoPage:(int)pageno;
-(void)vRenderAsync:(int)pageno;
-(void)vRenderSync:(int)pageno;
-(void)vFindStart:(NSString *)pat :(bool)match_case :(bool) whole_word;
-(int)vFind:(int) dir;
-(void)vFindEnd;
-(bool)vFindGoto;
-(bool)vCanPaging;
@end

typedef enum _PAGE_ALIGN
{
    align_left = 0,
    align_right = 1,
    align_hcenter = 2,
    align_top = 3,
    align_bot = 4,
    align_vcenter = 5,
}PAGE_ALIGN;

@interface RDVLayoutVert :RDVLayout
{
    PAGE_ALIGN m_align;
}
-(void)vSetAlign :(PAGE_ALIGN) align;
@end

@interface RDVLayoutHorz :RDVLayout
{
    PAGE_ALIGN m_align;
    bool       m_rtol;
    bool       m_thumb;
}
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol;
-(void)vSetAlign :(PAGE_ALIGN) align;
@end

@interface RDVLayoutThumb :RDVLayoutHorz
{
}
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol;
@end

@interface RDVLayoutGrid :RDVLayout
{
    PAGE_ALIGN m_align;
    int        m_grid_mode;
    int        m_height;
    bool       m_thumb;
}
-(id)init :(id<RDVLayoutDelegate>)del :(int)height :(int)mode;
@end

@interface RDVLayoutDual :RDVLayout
{
    PAGE_ALIGN m_align;
    bool       m_rtol;
    int        m_cells_cnt;
    bool       *m_vert_dual;
    int        m_vert_dual_cnt;
    bool      *m_horz_dual;
    int        m_horz_dual_cnt;
    int        m_cell_w;
    struct PDFCell
    {
        int left;
        int right;
        int page_left;
        int page_right;
    }* m_cells;
}
-(id)init :(id<RDVLayoutDelegate>)del :(bool)rtol :(const bool *)verts :(int)verts_cnt :(const bool *)horzs :(int) horzs_cnt;
-(void)vSetAlign :(PAGE_ALIGN) align;
@end

@interface RDVLayoutSingle :RDVLayout
{
    PAGE_ALIGN m_align;
    bool       m_rtol;
    bool       m_thumb;
    int        pageViewNo;
}
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol :(int)pageno;
-(void)vSetAlign :(PAGE_ALIGN) align;
-(void)vOpen :(PDFDoc *)doc :(int)page_gap :(CALayer *)rlay :(int)pageno;
@end
