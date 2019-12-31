//
//  VCache.m
//  RDPDFReader
//
//  Created by Radaee on 16/11/19.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDVCache.h"

@implementation RDVCache
@synthesize x = m_dibx;
@synthesize y = m_diby;
@synthesize w = m_dibw;
@synthesize h = m_dibh;
@synthesize pageno = m_pageno;
@synthesize thumbMode = m_thumb;

-(id)init:(PDFDoc *)doc :(int)pageno :(float) scale :(int)dibx :(int)diby :(int)dibw :(int)dibh;
{
    if( self = [super init] )
    {
        m_doc = doc;
        m_pageno = pageno;
        m_page = NULL;
        m_scale = scale;
        m_dibx = dibx;
        m_diby = diby;
        m_dibw = dibw;
        m_dibh = dibh;
        m_dib = NULL;
        m_status = 0;
        m_render = false;
        m_layer = nil;
        m_scale_pix = [[UIScreen mainScreen] scale];
    }
    return self;
}

-(RDVCache *)vClone
{
    RDVCache *vc = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :m_dibx :m_diby :m_dibw :m_dibh];
    vc.thumbMode = m_thumb;
    return vc;
}

-(bool)vStart
{
    if(!m_render)
    {
        m_render = true;
        m_status = 0;
        return true;
    }
    else
        return false;
}

-(bool)vEnd
{
    if(m_render)
    {
        m_render = false;
        if(m_status <= 0) m_status = -1;
        if(m_page) [m_page renderCancel];
        return true;
    }
    else
        return false;
}

-(bool)vIsRenderFinished
{
    return (m_render && m_status > 0);
}

-(bool)vIsRendering
{
    return (m_render && m_status == 0);
}

-(void)vRender
{
    if(m_status < 0) return;
    if(m_dib)//this condition shall never happen.
    {
        PDF_DIB dib = m_dib;
        m_dib = NULL;
        Global_dibFree(dib);
        //NSString *smsg = [NSString stringWithFormat:@"free dib from vRender w:%d h:%d", m_dibw, m_dibh];
        //NSLog(smsg);
    }
    PDF_DIB dib = Global_dibGet(NULL, m_dibw, m_dibh);//use PDF_DIB in direct may has better performance.
    //NSString *smsg = [NSString stringWithFormat:@"alloc dib w:%d h:%d", m_dibw, m_dibh];
    //NSLog(smsg);
    PDFPage *page = [m_doc page :m_pageno];
    Page_renderPrepare([page handle], dib);
    if(m_status < 0)
    {
        Global_dibFree(dib);
        return;
    }
    m_page = page;
    //if(!m_thumb) m_page = page;
    PDF_MATRIX mat = Matrix_createScale(m_scale, -m_scale, -m_dibx, [m_doc pageHeight :m_pageno] * m_scale - m_diby);
    Page_render([page handle],  dib, mat, true, 2);
    Matrix_destroy(mat);
    if (GLOBAL.g_dark_mode && m_status >= 0)
    {
        Byte *data = Global_dibGetData(dib);
        int w = Global_dibGetWidth(dib);
        int h = Global_dibGetHeight(dib);
        //invert pixel and convert to gray, we have a faster way:
        Byte *data_cur = data;
        Byte *data_end = data + w * h * 4;
        while(data_cur < data_end)
        {
            //alpha channel always is 255;
            int gray = (306 * (255 - data_cur[2]) + 601 * (255 - data_cur[1]) + 117 * (255 - data_cur[0]))>>10;
            data_cur[0] = data_cur[1] = data_cur[2] = gray;
            data_cur += 4;
        }
    }
    if(m_status >= 0)
    {
        m_status = 1;
        m_dib = dib;
    }
    else Global_dibFree(dib);
}

//the layer object must create and destroy on main thread.
-(void)vDestroyLayer
{
    if(m_layer)
    {
        [m_layer removeFromSuperlayer];
        m_layer.contents = nil;
        m_layer = nil;
    }
}

-(void)vDestroy;
{
    m_status = 0;
    m_page = nil;
    m_render = false;
    Global_dibFree(m_dib);
    m_dib = NULL;
}

void RDDataProviderReleaseDataCallback(void *info, const void *data, size_t size)
{
    //int w = Global_dibGetWidth((PDF_DIB)info);
    //int h = Global_dibGetHeight((PDF_DIB)info);
    //NSString *smsg = [NSString stringWithFormat:@"free dib from CALayer w:%d h:%d", w, h];
    //NSLog(smsg);
    Global_dibFree((PDF_DIB)info);
}
extern void rdcpy_ints(unsigned int *dst, const unsigned int *src, int len);

-(CALayer *)ProLayer
{
    if(m_layer) return m_layer;
    PDF_DIB dib = m_dib;//use PDF_DIB in direct may has better performance.
    if(![self vIsRenderFinished] || !dib) return nil;

    m_dib = NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithData( dib, Global_dibGetData(dib), m_dibw * m_dibh * 4, RDDataProviderReleaseDataCallback );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( m_dibw, m_dibh, 8, 32, m_dibw<<2, cs,
                                   kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst,
                                   provider, NULL, FALSE, kCGRenderingIntentDefault );
    
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    m_layer = [[CALayer alloc] init];
    [m_layer removeAllAnimations];
    m_layer.contents = (__bridge id)img;
    CGImageRelease(img);
    return m_layer;
}

//the layer object must create and destroy on main thread.
-(void)vDraw :(CALayer *)canvas
{
    if(m_layer) return;//already tiled.
    if([self ProLayer])//just finished
    {
        float scale_mul = 1.0f/m_scale_pix;
        m_layer.frame = CGRectMake(scale_mul * m_dibx, scale_mul * m_diby, scale_mul * m_dibw, scale_mul * m_dibh);
        [canvas addSublayer:m_layer];
    }
}

-(void)vDrawZoom :(CALayer *)parent :(float)scale
{
    float scale_mul = scale / (m_scale_pix * m_scale);
    CGRect rect = CGRectMake(scale_mul * m_dibx,
                             scale_mul * m_diby,
                             scale_mul * m_dibw,
                             scale_mul * m_dibh);
    if(m_layer)
    {
        m_layer.frame = rect;
    }
    else if([self ProLayer])//just finished
    {
        m_layer.frame = rect;
        [parent addSublayer:m_layer];
    }
}

-(void)dealloc
{
    [self vDestroyLayer];
    [self vDestroy];
    m_doc = NULL;
}
@end


@implementation RDVCacheSet
@synthesize cols = m_cols;
@synthesize rows = m_rows;
-init
{
    if( self = [super init] )
    {
        m_dat = NULL;
        m_cols = 0;
        m_rows = 0;
    }
    return self;
}

-(id)init :(int)cols :(int) rows
{
    if( self = [super init] )
    {
        m_dat = [[NSMutableArray alloc] initWithCapacity :cols];
        int col;
        for(col = 0; col < cols; col++)
        {
            NSMutableArray *colo = [[NSMutableArray alloc] initWithCapacity :rows];
            [m_dat setObject:colo atIndexedSubscript:col];
            //[m_dat addObject:colo];
        }
        m_cols = cols;
        m_rows = rows;
    }
    return self;
}
-(void)dealloc
{
    m_dat = nil;
    m_cols = 0;
    m_rows = 0;
}

-(RDVCache *)get :(int)col :(int) row
{
    NSMutableArray *colo = (NSMutableArray *)[m_dat objectAtIndex :col];
    return (RDVCache *)[colo objectAtIndex :row];
}
                                             
-(void)set :(int)col :(int) row :(RDVCache *)cache
{
    NSMutableArray *colo = (NSMutableArray *)[m_dat objectAtIndex :col];
    [colo setObject:cache atIndexedSubscript:row];
    //[colo replaceObjectAtIndex :row withObject:cache];
}

@end

