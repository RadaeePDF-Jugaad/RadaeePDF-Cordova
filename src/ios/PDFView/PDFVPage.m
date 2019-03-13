//
//  PDFVPage.c
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVPage.h"

@implementation PDFVCache
-(id)init:(PDFDoc *)doc :(int) pageno :(float)scale : (int)w : (int)h
{
    if( self = [super init] )
    {
        m_doc = doc;
        m_pageno = pageno;
		m_page = NULL;
		m_scale = scale;
		m_dibw = w;
		m_dibh = h;
		m_dib = 0;
		m_status = 0;
    }
    return self;
}

-(void)dealloc
{
    [self Clear];
}
-(int)width
{
	return m_dibw;
}

-(int)height
{
	return m_dibh;
}

-(int)Stat
{
    return m_status;
}

-(bool)IsSame:(float)scale : (int)w : (int)h
{
    return (m_scale == scale && m_dibw == w && m_dibh == h);
}

-(void)Clear;
{
    m_page = NULL;
    m_dib = 0;
    m_status = 0;
    NSLog(@"PageNo = %d ,PDFVCache.Clear",m_pageno);
}

-(void)RenderCancel
{
    if( m_status == 0 )
    {
        PDFPage *page = m_page;
        if( page )
            [page renderCancel];
        m_status = 2;
    }
}

-(void)RenderFinish
{
    if( m_status != 2 ) m_status = 1;
}

-(void)Render;
{
    if( m_status == 2 ) return;
    if( !m_page )
        m_page = [m_doc page:m_pageno];
    if( m_dib == 0 )
    {
        PDFDIB *dib = [[PDFDIB alloc] init:m_dibw: m_dibh];
        [m_page renderPrepare:dib];
        m_dib = dib;
    }
    else
        [m_page renderPrepare:m_dib];
	if( m_status == 2 ) return;
    PDFMatrix *mat = [[PDFMatrix alloc] init:m_scale: -m_scale: 0: m_dibh];
    [m_page render:m_dib :mat :GLOBAL.renderQuality];
    [self RenderFinish];
}

-(PDFDIB *)Bmp
{
    return m_dib;
}

-(PDFDIB *)PopBmp
{
    PDFDIB *dib = m_dib;
    m_dib = NULL;
    return dib;
}
-(PDFPage *)Page
{
    return m_page;
}
@end

@implementation PDFVCache1
-(id)init:(PDFDoc *)doc :(int) pageno :(float)scale : (int)w : (int)h
{
    if( self = [super init] )
    {
        m_doc = doc;
        m_pageno = pageno;
		m_page = nil;
		m_scale = scale;
		m_dibw = w;
		m_dibh = h;
		m_dib = 0;
		m_status = 0;
    }
    return self;
}

-(void)dealloc
{
    [self Clear];
}

-(int)Stat
{
    return m_status;
}

-(bool)IsSame:(float) scale :(int) w :(int) h
{
    return (m_scale == scale && m_dibw == w && m_dibh == h);
}

-(void)Clear
{
    m_page = NULL;
    m_dib = 0;
    m_status = 0;
}

-(void) RenderCancel
{
    if( m_status == 0 )
    {
        PDFPage *page = m_page;
        if( page )
            [page renderCancel];
        m_status = 2;
    }
}

-(void)RenderFinish
{
    if( m_status != 2 )
    {
        m_status = 1;
        m_page = NULL;
    }
}

-(void)Render
{
    if( m_status == 2 ) return;
    if( !m_page )
        m_page = [m_doc page:m_pageno];
    if( m_dib == NULL )
    {
        PDFDIB *dib = [[PDFDIB alloc] init:m_dibw :m_dibh];
        [m_page renderPrepare:dib];
        m_dib = dib;
    }
    else
        [m_page renderPrepare:m_dib];
		if( m_status == 2 ) return;
    PDFMatrix *mat = [[PDFMatrix alloc] init:m_scale: -m_scale: 0: m_dibh];
    [m_page render:m_dib :mat :mode_normal];
    [self RenderFinish];
}
-(PDFDIB *)Bmp
{
    return m_dib;
}
@end


@implementation PDFVSel
-(id)init:(PDFPage *)page
{
    if( self = [super init] )
    {
		m_page = page;
		m_index1 = -1;
		m_index2 = -1;
		m_ok = false;
    }
    return self;
}
-(void)dealloc
{
    [self Clear];
}
-(void)Clear
{
    if( m_page != NULL )
    {
        m_page = NULL;
    }
}
-(void)SetSel:(float)x1 :(float) y1 :(float) x2 :(float) y2
{
    if( !m_ok )
    {
        [m_page objsStart];
        m_ok = true;
    }
    m_index1 = [m_page objsGetCharIndex:x1 :y1];
    m_index2 = [m_page objsGetCharIndex:x2 :y2];
    if( m_index1 > m_index2 )
    {
        int tmp = m_index1;
        m_index1 = m_index2;
        m_index2 = tmp;
    }
    m_index1 = [m_page objsAlignWord:m_index1 :-1];
    m_index2 = [m_page objsAlignWord:m_index2 :1];
}
-(void)SetSelWholeWord:(float)x1 :(float) y1 :(float) x2 :(float) y2
{
    if( !m_ok )
    {
        [m_page objsStart];
        m_ok = true;
    }
    m_index1 = [m_page objsGetCharIndex:x1 :y1];
    m_index2 = [m_page objsGetCharIndex:x2 :y2];
    if( m_index1 > m_index2 )
    {
        int tmp = m_index1;
        m_index1 = m_index2;
        m_index2 = tmp;
    }
    m_index1 = [m_page objsAlignWord:m_index1 :-1];
    m_index2 = [m_page objsAlignWord:m_index2 :1];
    
    while (![[[m_page objsString:m_index1 -1 :m_index1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        
        m_index1 = [m_page objsAlignWord:m_index1 -1 :-1];
        
        //NSLog(@"%@", [m_page objsString:m_index1 :m_index2]);
    }
    
    while (![[[m_page objsString:m_index2 :m_index2 +1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        
        m_index2 = [m_page objsAlignWord:m_index2 +1 :1];
        
        //NSLog(@"%@", [m_page objsString:m_index1 :m_index2]);
    }
    
    //NSLog(@"%@", [m_page objsString:m_index1 :m_index2]);
}
-(bool)SetSelMarkup:(int)type :(int)color
{
    if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return false;
    return [m_page addAnnotMarkup :m_index1 :m_index2 :type : color];
}

-(NSString *)GetSelString
{
    if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return nil;
    return [m_page objsString:m_index1 :m_index2];
}

- (int)getStartIndex
{
    return m_index1;
}
- (int)getEndIndex
{
    return m_index2;
}

-(void)DrawSel:(PDFVCanvas *)canvas :(float)scale :(float)page_height :(int)orgx :(int)orgy
{
    if( m_index1 < 0 || m_index2 < 0 || !m_ok ) return;
    PDF_RECT rect;
    PDF_RECT rect_word;
    PDF_RECT rect_draw;
    [m_page objsCharRect:m_index1 :&rect];
    rect_word = rect;
    int tmp = m_index1 + 1;
    while( tmp <= m_index2 )
    {
        [m_page objsCharRect:tmp :&rect];
        float gap = (rect.bottom - rect.top)/2;
        if( rect_word.top == rect.top && rect_word.bottom == rect.bottom &&
           rect_word.right + gap > rect.left && rect_word.left - gap < rect.right )
        {
            if( rect_word.left > rect.left ) rect_word.left = rect.left;
            if( rect_word.right < rect.right ) rect_word.right = rect.right;
        }
        else
        {
            rect_draw.left = rect_word.left * scale;
            rect_draw.top = (page_height - rect_word.bottom) * scale;
            rect_draw.right = rect_word.right * scale;
            rect_draw.bottom = (page_height - rect_word.top) * scale;
            [canvas FillRect:CGRectMake((orgx + rect_draw.left), (orgy + rect_draw.top),
                                        (rect_draw.right - rect_draw.left), (rect_draw.bottom - rect_draw.top)): GLOBAL.g_sel_color ];
            rect_word = rect;
        }
        tmp++;
    }
    rect_draw.left = rect_word.left * scale;
    rect_draw.top = (page_height - rect_word.bottom) * scale;
    rect_draw.right = rect_word.right * scale;
    rect_draw.bottom = (page_height - rect_word.top) * scale;
    [canvas FillRect:CGRectMake((orgx + rect_draw.left), (orgy + rect_draw.top),
                                (rect_draw.right - rect_draw.left), (rect_draw.bottom - rect_draw.top)): GLOBAL.g_sel_color ];
}

-(void)Reset
{
    m_index1 = -1;
    m_index2 = -1;
}
@end

@implementation PDFVPage
-(id)init:(PDFDoc *) doc : (int) pageno
{
    if( self = [super init] )
    {
        m_pageno = pageno;
        m_doc = doc;
        m_cache = nil;
        m_sel = nil;
        m_thumb = nil;
        m_scale = 0;
        m_w = 0;
        m_h = 0;
        m_x = 0;
        m_y = 0;
        m_bmp = nil;
    }
    return self;
}

-(void)dealloc
{
    if( m_cache ) m_cache = nil;
    if( m_thumb ) m_thumb = nil;
    if( m_sel ) m_sel = nil;
}

-(bool)IsCrossed:(int)x : (int)y : (int)w : (int)h
{
    return ( m_x < x + w && m_y < y + h && m_x + m_w > x && m_y + m_h > y );
}

-(bool)SetRect:(int)x : (int)y : (float)scale
{
    if( m_x == x && m_y == y && m_scale == scale ) return false;
    m_x = x;
    m_y = y;
    m_scale = scale;
    float w = [m_doc pageWidth:m_pageno];
    float h = [m_doc pageHeight:m_pageno];
    m_w = (int)(m_scale * w);
    m_h = (int)(m_scale * h);
    return true;
}

-(bool)IsFinished
{
    if( m_cache )
        return [m_cache Stat] == 1;
		if( m_thumb )
			  return [m_thumb Stat] == 1;
    return true;
}

-(int)RenderPrepare
{
    if( m_cache == nil )
    {
        m_cache = [[PDFVCache alloc] init:m_doc :m_pageno: m_scale: m_w: m_h];
        return 0;
    }
    if( [m_cache IsSame:m_scale: m_w: m_h] ) return 1;
    return 2;
}
                   
-(PDFVCache *)CancelRender
{
    if( m_cache == nil ) return nil;
    if( m_sel != nil )
        m_sel = nil;
    PDFVCache *cache = m_cache;
    m_cache = nil;
    [cache RenderCancel];
    return cache;
}
                   
-(void)SetSel:(float)x1 : (float)y1 : (float)x2 : (float)y2
{
    if( m_sel == nil ) m_sel = [[PDFVSel alloc] init:[m_doc page:m_pageno]];
        [m_sel SetSel: [self ToPDFX:x1]: [self ToPDFY:y1]: [self ToPDFX: x2]: [self ToPDFY: y2]];
}

-(void)SetSelWholeWord:(float)x1 : (float)y1 : (float)x2 : (float)y2
{
    if( m_sel == nil )
        m_sel = [[PDFVSel alloc] init:[m_doc page:m_pageno]];
    
    [m_sel SetSelWholeWord: [self ToPDFX:x1]: [self ToPDFY:y1]: [self ToPDFX: x2]: [self ToPDFY: y2]];
}
                   
-(bool)SetSelMarkup:(int)type :(int)color
{
    if( m_sel != nil ) return [m_sel SetSelMarkup:type :color];
    return false;
}
                   
-(NSString *)GetSel
{
    if( m_sel == nil ) return nil;
    return [m_sel GetSelString];
}

-(PDF_RECT )GetSelRect
{
    int start = [m_sel getStartIndex];
    int end = [m_sel getEndIndex];
    
    if (start < 0 || end == 0) {
        PDF_RECT rectNull;
        rectNull.left = rectNull.right = rectNull.top = rectNull.bottom = 0;
        return rectNull;
    }
    
    PDFPage *page = [self GetPage];
    [page objsStart];
    
    PDF_RECT rectStart;
    PDF_RECT rectEnd;
    
    [page objsCharRect:start :&rectStart];
    [page objsCharRect:end :&rectEnd];
    
    PDF_RECT rectSel;
    
    rectSel.left = rectStart.left;
    rectSel.top = rectStart.top;
    rectSel.right = rectEnd.right;
    rectSel.bottom = rectEnd.bottom;
        
    return rectSel;
}
                   
-(void)ClearSel
{
    if( m_sel ) [m_sel Reset];
}
                   
-(void)Draw:(PDFVCanvas *)canvas
{
    if( m_bmp )
    {
        //NSTimeInterval time0 = [[NSDate date] timeIntervalSince1970]*1000;
        [canvas DrawBmp: m_bmp: m_x: m_y: m_w: m_h :([m_cache Stat] == 1)];
        //NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000 - time0;
        //NSLog(@"draw %d time: %d", m_pageno, (int)time1);
    }
    else if( m_cache && [m_cache Bmp] )
    {
        [canvas DrawBmp: [m_cache Bmp]: m_x: m_y :([m_cache Stat] == 1)];
    }
    else
        [canvas FillRect: CGRectMake(m_x, m_y, m_w, m_h): 0xFFFFFFFF];
    if( m_sel )
        [m_sel DrawSel:canvas: m_scale: [m_doc pageHeight:m_pageno]: m_x: m_y];
}

-(int)ThumbPrepare
{
    if( m_thumb == nil )
    {
        m_thumb = [[PDFVCache1 alloc] init: m_doc :m_pageno :m_scale: m_w: m_h];
        return 0;
    }
    return 1;
}

-(PDFVCache1 *)CancelThumb
{
    if( m_thumb == nil ) return nil;
    PDFVCache1 *thumb = m_thumb;
    m_thumb = nil;
    [thumb RenderCancel];
    return thumb;
}

-(void)DrawThumb:(PDFVCanvas *)canvas
{
    if( m_thumb != nil && [m_thumb Bmp] != nil )
        [canvas DrawThumbBmp:[m_thumb Bmp] :m_x :m_y :m_pageno :([m_thumb Stat] == 1)]; // New method
    else
        [canvas FillRect: CGRectMake(m_x, m_y, m_w, m_h): 0xFFFFFFFF];
    if( m_sel != nil )
        [m_sel DrawSel:canvas: m_scale: [m_doc pageHeight:m_pageno]: m_x: m_y];
}

-(bool)NeedBmp
{
    if( m_bmp == nil ) return false;
    if( m_cache != nil )
        return ( [m_cache Stat] != 1 || ![m_cache IsSame:m_scale: m_w: m_h] );
    else
        return true;
}
-(void)DeleteBmp
{
    if( m_bmp != nil )
    {
        m_bmp = nil;
    }
}
-(void)CreateBmp
{
    if( m_cache == nil || [m_cache Stat] != 1 || m_bmp != nil ) return;
    m_bmp = [m_cache PopBmp];
    m_cache = nil;
    if( m_sel != nil )
        m_sel = nil;
}
-(float)ToPDFX:(float)vx
{
    float dibx = vx - m_x;
    return dibx / m_scale;
}
-(float)ToPDFY:(float)vy
{
    float diby = vy - m_y;
    return (m_h - diby) / m_scale;
}
-(float)ToDIBX:(float) x
{
    return x * m_scale;
}
-(float)ToDIBY:(float) y
{
    return ([m_doc pageHeight:m_pageno] - y) * m_scale;
}
-(PDFPage *) GetPage
{
    if( m_cache == nil ) return nil;
    return [m_cache Page];
}
-(int)GetPageNo
{
    return m_pageno;
}
-(int)GetX
{
    return m_x;
}
-(int)GetY
{
    return m_y;
}
-(float)GetScale
{
    return m_scale;
}
-(int)GetVX:(float) scrollx
{
    return m_x - (int)scrollx;
}
-(int)GetVY:(float) scrolly
{
    return m_y - (int)scrolly;
}
-(int)GetWidth
{
    return m_w;
}
-(int)GetHeight
{
    return m_h;
}
-(PDFMatrix *)CreateInvertMatrix:(float) scrollx :(float) scrolly
{
    return [[PDFMatrix alloc] init: 1/m_scale: -1/m_scale: (scrollx - m_x)/m_scale: (m_y + m_h - scrolly)/m_scale ];
}
-(PDFVCache *)Cache
{
    return m_cache;
}
-(PDFVCache1 *)Thumb
{
    return m_thumb;
}

@end
