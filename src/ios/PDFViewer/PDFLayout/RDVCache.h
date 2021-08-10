//
//  VCache.h
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//
#pragma once
#import "PDFObjc.h"

@interface RDVCache : NSObject
{
    PDFDoc *m_doc;
    PDFPage *m_page;
    int m_pageno;
    float m_scale_pix;
    float m_scale;
    int m_dibx;
    int m_diby;
    int m_dibw;
    int m_dibh;
    int m_status;//1 mean render finished without cancel, -1 mean render cancelled, others: 0
    bool m_render;//true if rendering request is posted, false means rendering request never posted.
    bool m_thumb;
    PDF_DIB m_dib;//use PDF_DIB in direct may has better performance.
    CALayer *m_layer;
}
@property int x;
@property int y;
@property int w;
@property int h;
@property int pageno;
@property bool thumbMode;

-(id)init:(PDFDoc *)doc :(int)pageno :(float) scale :(int)dibx :(int)diby :(int)dibw :(int)dibh;
-(RDVCache *)vClone;
-(bool)vStart;
-(bool)vEnd;
-(bool)vIsRenderFinished;
-(bool)vIsRendering;
-(void)vRender;
-(void)vDestroy;
-(void)vDestroyLayer;
-(void)vDraw :(CALayer *)canvas;
-(void)vDrawZoom :(CALayer *)parent :(float)scale;
@end

@interface RDVCacheSet : NSObject
{
    NSMutableArray *m_dat;
    int m_cols;
    int m_rows;
}
@property(readonly) int cols;
@property(readonly) int rows;
-(id)init :(int)cols :(int) rows;
-(RDVCache *)get :(int)col :(int) row;
-(void)set :(int)col :(int) row :(RDVCache *)cache;
@end

