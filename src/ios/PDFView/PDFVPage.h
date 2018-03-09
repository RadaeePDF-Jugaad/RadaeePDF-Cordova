#pragma once
#include "PDFObjc.h"
#include "PDFVGlobal.h"
#include "PDFVCanvas.h"

@interface PDFVCache : NSObject
{
	PDFDoc *m_doc;
	int m_pageno;
	PDFPage *m_page;
	float m_scale;
	PDFDIB *m_dib;
	int m_dibw;
	int m_dibh;
	int m_status;
}
-(id)init:(PDFDoc *)doc :(int) pageno :(float)scale :(int)w : (int)h;
-(int)Stat;
-(PDFDIB *)Bmp;
-(PDFDIB *)PopBmp;
-(PDFPage *)Page;
-(int)width;
-(int)height;
-(bool)IsSame:(float) scale : (int) w : (int) h;
-(void)Clear;
-(void)RenderCancel;
-(void)RenderFinish;
-(void)Render;
@end


@interface PDFVCache1 : NSObject
{
	PDFDoc *m_doc;
	int m_pageno;
	PDFPage * m_page;
	float m_scale;
	PDFDIB *m_dib;
	int m_dibw;
	int m_dibh;
	int m_status;
}
-(id)init:(PDFDoc *)doc :(int) pageno :(float)scale :(int)w :(int)h;
-(int)Stat;
-(PDFDIB *)Bmp;
-(bool)IsSame:(float) scale :(int) w :(int) h;
-(void)Clear;
-(void)RenderCancel;
-(void)RenderFinish;
-(void)Render;
@end

@interface PDFVSel : NSObject
{
	PDFPage *m_page;
	int m_index1;
	int m_index2;
	bool m_ok;
}
-(id)init:(PDFPage *)page;
-(void)Reset;
-(void)Clear;
-(void)SetSel:(float)x1 : (float)y1 : (float)x2 : (float)y2;
-(bool)SetSelMarkup:(int)type :(int)color;
-(NSString *)GetSelString;
- (int)getStartIndex;
- (int)getEndIndex;
-(void)DrawSel:(PDFVCanvas *)canvas :(float)scale :(float)page_height :(int)orgx :(int)orgy;
@end

@interface PDFVPage : NSObject
{
	PDFDoc *m_doc;
	PDFVCache *m_cache;
	PDFVSel *m_sel;
	PDFVCache1 *m_thumb;
	int m_pageno;
	float m_scale;
	int m_w;
	int m_h;
	int m_x;
	int m_y;
    PDFDIB *m_bmp;
}
-(id)init:(PDFDoc *)doc :(int)pageno;
-(bool)IsCrossed:(int)x :(int)y :(int)w :(int)h;
-(bool)SetRect:(int)x :(int)y :(float)scale;
-(bool)IsFinished;
-(int)RenderPrepare;
-(PDFVCache *)CancelRender;
-(void)SetSel:(float)x1 :(float)y1 :(float)x2 :(float)y2;
-(void)SetSelWholeWord:(float)x1 : (float)y1 : (float)x2 : (float)y2;
-(bool)SetSelMarkup:(int)type :(int)color;
-(NSString *)GetSel;
-(PDF_RECT )GetSelRect;
-(void)ClearSel;
-(void)Draw:(PDFVCanvas *)canvas;
-(int)ThumbPrepare;
-(PDFVCache1 *)CancelThumb;
-(void)DrawThumb:(PDFVCanvas *)canvas;
-(bool)NeedBmp;
-(void)DeleteBmp;
-(void)CreateBmp;
-(float)ToPDFX:(float)vx;
-(float)ToPDFY:(float)vy;
-(float)ToDIBX:(float)x;
-(float)ToDIBY:(float)y;
-(PDFPage *) GetPage;
-(int)GetPageNo;
-(int)GetX;
-(int)GetY;
-(float)GetScale;
-(int)GetVX:(float) scrollx;
-(int)GetVY:(float) scrolly;
-(int)GetWidth;
-(int)GetHeight;
-(PDFMatrix *)CreateInvertMatrix:(float) scrollx :(float) scrolly;
-(PDFVCache *)Cache;
-(PDFVCache1 *)Thumb;
@end
