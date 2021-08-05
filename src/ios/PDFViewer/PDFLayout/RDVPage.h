#pragma once
#import "PDFObjc.h"

@class RDVThread;
@class RDVCache;
@class RDVCacheSet;

@interface RDVPage : NSObject
{
    PDFPage *m_page;
	RDVCacheSet *m_caches;
    RDVCacheSet *m_caches_zoom;
    CALayer *m_layer;
    PDFDoc *m_doc;
	int m_pageno;
	int m_x;
	int m_y;
	int m_w;
	int m_h;
    int m_cw;
    int m_ch;
    int m_x0;
    int m_y0;
    int m_x1;
    int m_y1;
    int m_xb0;
    int m_yb0;
	float m_scale;
    bool m_need_clip;
    bool m_thumb;
}
@property(readonly) int pageno;
@property(readonly) int x;
@property(readonly) int y;
@property(readonly) int w;
@property(readonly) int h;
@property(readonly) float scale;
@property bool thumbMode;

-(id)init :(PDFDoc *) doc :(int) pageno :(int) cw :(int) ch;
-(void)vLayerInit : (CALayer *)root;
-(void)vLayerDel;
- (PDFPage *)GetPage;
-(int)GetX;
-(int)GetY;
-(float)GetPDFX :(int) vx;
-(float)GetPDFY :(int) vy;
-(int)GetVX :(float) pdfx;
-(int)GetVY :(float) pdfy;
-(int)GetWidth;
-(int)GetHeight;
-(float)GetScale;
-(float)ToPDFX :(int) x :(int) scrollx;
-(float)ToPDFY :(int) y :(int) scrolly;
-(int)ToDIBX :(float) pdfx;
-(int)ToDIBY :(float) pdfy;
-(float)ToPDFSize :(int) val;
-(PDFMatrix *)CreateInvertMatrix :(float) scrollx :(float) scrolly;
-(PDFMatrix *)CreateIMatrix :(float) scrollx :(float) scrolly :(float)scale;
-(void)vDestroy :(RDVThread *) thread;
-(void)vLayout :(int) x :(int) y :(float) scale :(bool) clip;
-(void)vClips :(RDVThread *) thread :(bool) clip;
-(void)vEndPage :(RDVThread *) thread;
-(NSMutableArray *)vBackCache;
-(void)vBackEnd :(RDVThread *) thread :(NSMutableArray *)arr;
-(bool)vFinished;
-(void)vRenderAsync :(RDVThread *) thread :(int) docx :(int) docy :(int) vw :(int) vh;
-(void)vRenderSync :(RDVThread *) thread :(int) docx :(int) docy :(int) vw :(int) vh;
-(void)vDraw :(RDVThread *) thread :(int) docx :(int) docy :(int) vw :(int) vh;
-(bool)vDrawZoom :(float)scale;
-(void)vZoomStart;
-(void)vZoomEnd :(RDVThread *) thread;
@end
