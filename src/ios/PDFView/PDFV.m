//
//  PDFV.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFV.h"

@implementation PDFV

-(id)init
{
    if( self = [super init] )
    {
		m_x = 0;
		m_y = 0;
		m_docw = 0;
		m_doch = 0;
		m_w = 0;
		m_h = 0;
		m_scale = 0;
		m_doc = nil;
		m_pages = nil;
		m_pages_cnt = 0;
        m_prange_start = 0;
        m_prange_end = 0;
        m_pageno = -1;
		m_page_gap = 0;
		m_page_gap_half = 0;
        
		m_hold_vx = 0;
		m_hold_vy = 0;
		m_hold_x = 0;
		m_hold_y = 0;
		//m_back_clr = 0xFFCCCCCC;
        m_pages = nil;
        m_thread = [[PDFVThread alloc] init];
        m_finder = [[PDFVFinder alloc] init];
        m_del = nil;
    }
    return self;
}
-(void)dealloc
{
    [self vClose];
}
-(void)vResize:(int)w :(int) h;
{
    if( w <= 0 || h <= 0 ) return;
    m_w = w;
    m_h = h;
    [self vLayout];
}
-(void)vClose
{
    
    [m_thread destroy];
    if( m_pages )
    {
        [m_pages removeAllObjects];
        m_pages = nil;
        m_pages_cnt = 0;
    }
    m_x = 0;
    m_y = 0;
    m_docw = 0;
    m_doch = 0;
    m_w = 0;
    m_h = 0;
    m_scale = 0;
    m_scale_min = 0;
    m_scale_max = 0;
    m_doc = nil;
    m_pages = nil;
    m_pages_cnt = 0;
    m_del = nil;
}
-(void)vOpen:(PDFDoc *) doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    m_doc = doc;
    //m_back_clr = back_clr;
    
    m_x = 0;
    m_y = 0;
    m_docw = 0;
    m_doch = 0;
    m_scale = 0;
    m_scale_min = 0;
    m_scale_max = 0;
    m_page_gap = page_gap&(~1);
    m_page_gap_half = (m_page_gap>>1);
    
    m_pages_cnt = [m_doc pageCount];
    m_pages = [[NSMutableArray alloc] init];
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = [[PDFVPage alloc] init:m_doc :cur];
        [m_pages addObject:vpage];
        cur++;
    }
    [m_thread create :notifier:disp];
    m_del = notifier;
    [self vLayout];
}

- (float)getWidth
{
    return [m_doc pageWidth:m_pageno] * m_scale;
}

- (float)getHeight
{
    return [m_doc pageHeight:m_pageno] * m_scale;
}

-(int)vGetPage:(int)x :(int)y
{
    return 0;
}

-(void)vFlushRange
{
    int pageno1 = [self vGetPage:0 :0];
    int pageno2 = [self vGetPage:m_w :m_h];
    if (pageno1 >= 0 && pageno2 >= 0)
    {
        if (pageno1 > pageno2)
        {
            int tmp = pageno1;
            pageno1 = pageno2;
            pageno2 = tmp;
        }
        pageno2++;
        if (m_prange_start < pageno1)
        {
            int start = m_prange_start;
            int end = pageno1;
            if (end > m_prange_end) end = m_prange_end;
            while (start < end)
            {
                PDFVPage *vpage = m_pages[start];
                [m_thread end_render :vpage];
                [vpage DeleteBmp];
                vpage = nil;
                start++;
            }
        }
        if (m_prange_end > pageno2)
        {
            int start = pageno2;
            int end = m_prange_end;
            if (start < m_prange_start) start = m_prange_start;
            while (start < end)
            {
                PDFVPage *vpage = m_pages[start];
                [m_thread end_render :vpage];
                [vpage DeleteBmp];
                vpage = nil;
                start++;
            }
        }
    }
    else
    {
        int start = m_prange_start;
        int end = m_prange_end;
        while (start < end)
        {
            PDFVPage *vpage = m_pages[start];
            [m_thread end_render:vpage];
            [vpage DeleteBmp];
            vpage = nil;
            start++;
        }
    }
    m_prange_start = pageno1;
    m_prange_end = pageno2;
    pageno1 = [self vGetPage :m_w/4 :m_h/4];
    if (m_del && pageno1 != m_pageno)
        [m_del OnPageChanged:m_pageno = pageno1];
}

-(bool) vFindGoto
{
    if( m_pages == NULL ) return false;
    int pg = [m_finder find_get_page];
    if( pg < 0 || pg >= [m_doc pageCount] ) return false;
    PDF_RECT pos;
    if( ![m_finder find_get_pos:&pos] ) return false;
    PDFVPage *vpage = m_pages[pg];
    pos.left = [vpage ToDIBX:pos.left] + [vpage GetX];
    pos.top = [vpage ToDIBY:pos.top] + [vpage GetY];
    pos.right = [vpage ToDIBX:pos.right] + [vpage GetX];
    pos.bottom = [vpage ToDIBY:pos.bottom] + [vpage GetY];
    float x = m_x;
    float y = m_y;
    if( x > pos.left - m_w/8 ) x = pos.left - m_w/8;
    if( x < pos.right - m_w*7/8 ) x = pos.right - m_w*7/8;
    if( y > pos.top - m_h/8 ) y = pos.top - m_h/8;
    if( y < pos.bottom - m_h*7/8 ) y = pos.bottom - m_h*7/8;
    if( x > m_docw - m_w ) x = m_docw - m_w;
    if( x < 0 ) x = 0;
    if( y > m_doch - m_h ) y = m_doch - m_h;
    if( y < 0 ) y = 0;
    m_x = x;
    m_y = y;
    return true;
}

-(void)vGetPos:(struct PDFV_POS *)pos :(int)x :(int)y
{
    if( !pos ) return;
    int pageno = [self vGetPage:x:y];
    pos->pageno = pageno;
    if( pageno < 0 )
    {
        pos->x = 0;
        pos->y = 0;
    }
    else
    {
        PDFVPage *vpage = m_pages[pageno];
        pos->x = [vpage ToPDFX:x + m_x];
        pos->y = [vpage ToPDFY:y + m_y];
    }
}
-(void)vSetPos:(const struct PDFV_POS *)pos :(int)x :(int) y
{
    if( m_w <= 0 || m_h <= 0 || !m_pages ) return;
    PDFVPage *cur = m_pages[pos->pageno];
    m_x = [cur GetX] + [cur ToDIBX:pos->x] - x;
    m_y = [cur GetY] + [cur ToDIBY:pos->y] - y;
}

-(bool)vNeedRefresh
{
    int cur = m_prange_start;
    int end = m_prange_end;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        if( ![vpage IsFinished] ) return true;
        cur++;
    }
    return false;
}
-(void)vDraw :(PDFVCanvas *)canvas :(bool)zooming
{
    if( m_w <= 0 || m_h <= 0 || ! m_pages ) return;
    //NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000;
    //[canvas FillRect:CGRectMake(0, 0, m_w, m_h) :m_back_clr];
    int find_page = [m_finder find_get_page];
    int cur = 0;
    int end = 0;
    if( zooming )
    {
	    cur = m_prange_start;
	    end = m_prange_end;
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage Draw: canvas];
            if( cur == find_page ) {
                [m_finder find_draw_all:canvas :vpage];
                //[m_finder find_draw:canvas : vpage];
            }
            vpage = nil;
            cur++;
        }
    }
    else
    {
        [self vFlushRange];
        cur = m_prange_start;
        end = m_prange_end;
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            if( ![vpage NeedBmp] ) [vpage DeleteBmp];
            [m_thread start_render:vpage];
            [vpage Draw: canvas];
            if( cur == find_page ) {
                [m_finder find_draw_all:canvas :vpage];
                //[m_finder find_draw:canvas : vpage];
            }
            vpage = nil;
            cur++;
        }
    }
    if( m_del )
    {
	    cur = m_prange_start;
	    end = m_prange_end;
	    while( cur < end )
	    {
            PDFVPage *vpage = m_pages[cur];
	        [m_del OnPageDisplayed:[canvas context]:vpage];
            vpage = nil;
	    	cur++;
	    }
	}
    //NSTimeInterval time2 = [[NSDate date] timeIntervalSince1970]*1000 - time1;
    //NSLog(@"render time: %d", (int)time2);
    //time2 = 0;
}
-(PDFVPage *)vGetPage:(int) pageno
{return m_pages[pageno];}
-(void)vFindStart:(NSString *)pat : (bool)match_case :(bool)whole_word
{
    struct PDFV_POS pos;
    [self vGetPos:&pos: m_w / 2: m_h / 2];
    [m_finder find_start :m_doc :pos.pageno :pat :match_case :whole_word];
}
-(int)vFind:(int) dir
{
    if( m_pages == nil ) return -1;
    int ret = [m_finder find_prepare:dir];
    if( ret == 1 )
    {
    	[m_del OnFound:m_finder];
        [self vFindGoto];
        return 0;//succeeded
    }
    if( ret == 0 )
    {
        return -1;//failed
    }
    
    [m_thread start_find: m_finder];
    return 1;
}
-(void)vFindEnd
{
    if( m_pages == NULL ) return;
    [m_finder find_end];
}

-(void)vRenderAsync:(int)pageno
{
    [m_thread end_render:m_pages[pageno]];
    [m_pages[pageno] DeleteBmp];
    [m_thread start_render:m_pages[pageno]];
}
-(void)vRenderSync:(int)pageno
{
    [m_thread end_render:m_pages[pageno]];
    [m_pages[pageno] DeleteBmp];
    [m_pages[pageno] RenderPrepare];
    [[m_pages[pageno] Cache] Render];
}

-(void)vGetDeltaToCenterPage:(int)pageno : (int *)dx : (int *)dy
{
    if( m_pages == NULL || m_doc == NULL || m_w <= 0 || m_h <= 0 ) return;
    PDFVPage *vpage = m_pages[pageno];
    int left = [vpage GetX] - m_page_gap/2;
    int top = [vpage GetY] - m_page_gap/2;
    int w = [vpage GetWidth] + m_page_gap;
    int h = [vpage GetHeight] + m_page_gap;
    int x = left + (w - m_w)/2;
    int y = top + (h - m_h)/2;
    *dx = x - m_x;
    *dy = y - m_y;
}

-(void)vMoveTo:(int)x :(int)y
{
    m_x = x;
    m_y = y;
}

-(void)vZoomStart
{
    int cur = m_prange_start;
    int end = m_prange_end;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage DeleteBmp];
        [vpage CreateBmp];
        [m_thread end_render:vpage];
        cur++;
    }
}
-(float)vGetScale
{return m_scale;}
-(float)vGetScaleMin
{
    return m_scale_min;
}
-(void)vSetScale:(float) scale
{
    m_scale = scale;
    [self vLayout];
}
-(void)vSetSel:(int)x1 : (int)y1 : (int)x2 : (int)y2
{
    struct PDFV_POS pos;
    [self vGetPos: &pos: x1: y1];
    if( pos.pageno < 0 ) return;
    PDFVPage *vpage = m_pages[pos.pageno];
    [vpage SetSel: x1 + m_x :y1 + m_y :x2 + m_x :y2 + m_y];
}
-(void)vSetSelWholeWord:(int)x1 : (int)y1 : (int)x2 : (int)y2
{
    struct PDFV_POS pos;
    [self vGetPos: &pos: x1: y1];
    if( pos.pageno < 0 ) return;
    PDFVPage *vpage = m_pages[pos.pageno];
    [vpage SetSelWholeWord: x1 + m_x :y1 + m_y :x2 + m_x :y2 + m_y];
}
-(void)vClearSel
{
    int cur = m_prange_start;
    int end = m_prange_end;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage ClearSel];
        cur++;
    }
}
-(void)vLayout
{
}
-(int)vGetX
{
    return m_x;
}
-(int)vGetY
{
    return m_y;
}
-(int)vGetDocW
{
    return m_docw;
}
-(int)vGetDocH
{
    return m_doch;
}
@end

@implementation PDFVVert
-(void)vLayout
{
    if( m_w <= 0 || m_h <= 0 || !m_pages ) return;
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    m_scale_min = (m_w - m_page_gap) / sz.cx;
    m_scale_max = m_scale_min * g_zoom_level;
    if( m_scale < m_scale_min ) m_scale = m_scale_min;
    if( m_scale > m_scale_max ) m_scale = m_scale_max;
    int cur = 0;
    int end = m_pages_cnt;
    int left = m_page_gap_half;
    int top = m_page_gap_half;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage SetRect:left:top:m_scale];
        top += [vpage GetHeight] + m_page_gap;
        cur++;
    }
    m_docw = sz.cx * m_scale;
    m_doch = top - m_page_gap_half;
}

-(int)vGetPage:(int) vx : (int) vy
{
    if (!m_pages || m_pages_cnt <= 0) return -1;
    int left = 0;
    int right = m_pages_cnt - 1;
    int y = (int)m_y + vy;
    int gap = m_page_gap >> 1;
    while (left <= right)
    {
        int mid = (left + right) >> 1;
        PDFVPage *pg1 = m_pages[mid];
        if (y < [pg1 GetY] - gap)
        {
            right = mid - 1;
        }
        else if (y > [pg1 GetY] + [pg1 GetHeight] + gap)
        {
            left = mid + 1;
        }
        else
        {
            return mid;
        }
    }
    if (right < 0) return 0;
    else return m_pages_cnt - 1;
}
@end

@implementation PDFVHorz
-(id)init:(bool)rtol
{
    if( self = [super init] )
    {
        m_rtol = rtol;
    }
    return self;
}
-(void)vOpen:(PDFDoc *) doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *) disp;
{
    [super vOpen :doc :page_gap :notifier :disp];
    if( m_rtol ) m_x = m_docw;
}

-(void)vResize:(int)w : (int)h
{
    bool set = (m_rtol && (m_w <= 0 || m_h <= 0));
    [super vResize : w : h];
    if( set ) m_x = m_docw;
}
-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    int cur = 0;
    int cnt = [m_doc pageCount];
    m_scale_min = ((float)(m_h - m_page_gap)) / sz.cy;
    m_scale_max = m_scale_min * g_zoom_level;
    if( m_scale < m_scale_min ) m_scale = m_scale_min;
    if( m_scale > m_scale_max ) m_scale = m_scale_max;
    
    int left = m_page_gap_half;
    int top = m_page_gap_half;
    m_docw = 0;
    m_doch = 0;
    if( m_rtol )
    {
        cur = cnt - 1;
        while( cur >= 0 )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            left += [vpage GetWidth] + m_page_gap;
            if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
            cur--;
        }
    }
    else
    {
        cur = 0;
        while( cur < cnt )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            left += [vpage GetWidth] + m_page_gap;
            if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
            cur++;
        }
    }
    m_docw = left;
}

-(int)vGetPage:(int) vx :(int) vy
{
    if (!m_pages || m_pages_cnt <= 0) return -1;
    int left = 0;
    int right = m_pages_cnt - 1;
    int gap = m_page_gap >> 1;
    int x = (int)m_x + vx;
    if (!m_rtol)//ltor
    {
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            PDFVPage *pg1 = m_pages[mid];
            if (x < [pg1 GetX] - gap)
            {
                right = mid - 1;
            }
            else if (x > [pg1 GetX] + [pg1 GetWidth] + gap)
            {
                left = mid + 1;
            }
            else
            {
                return mid;
            }
        }
    }
    else//rtol
    {
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            PDFVPage *pg1 = m_pages[mid];
            if (x < [pg1 GetX] - gap)
            {
                left = mid + 1;
            }
            else if (x > [pg1 GetX] + [pg1 GetWidth] + gap)
            {
                right = mid - 1;
            }
            else
            {
                return mid;
            }
        }
    }
    if (right < 0) return 0;
    else return m_pages_cnt - 1;
}
@end

@implementation PDFVDual
-(id)init:(bool)rtol : (const bool *)verts : (int)verts_cnt : (const bool *)horzs : (int)horzs_cnt;
{
    if( self = [super init] )
    {
        if( verts && verts_cnt > 0 )
        {
            m_vert_dual = (bool *)malloc( sizeof( bool ) * verts_cnt );
            memcpy( m_vert_dual, verts, sizeof( bool ) * verts_cnt );
            m_vert_dual_cnt = verts_cnt;
        }
        else
        {
            m_vert_dual = NULL;
            m_vert_dual_cnt = 0;
        }
        if( horzs && horzs_cnt > 0 )
        {
            m_horz_dual = (bool *)malloc( sizeof( bool ) * horzs_cnt );
            memcpy( m_horz_dual, horzs, sizeof( bool ) * horzs_cnt );
            m_horz_dual_cnt = horzs_cnt;
        }
        else
        {
            m_horz_dual = NULL;
            m_horz_dual_cnt = 0;
        }
        m_cells = NULL;
        m_cells_cnt = 0;
        m_rtol = rtol;
    }
    return self;
}
-(void)vClose
{
    [super vClose];
    if( m_cells )
    {
        free( m_cells );
        m_cells = NULL;
        m_cells_cnt = 0;
    }
    if( m_vert_dual )
    {
        free( m_vert_dual );
        m_vert_dual = NULL;
        m_vert_dual_cnt = 0;
    }
    if( m_horz_dual )
    {
        free( m_horz_dual );
        m_horz_dual = NULL;
        m_horz_dual_cnt = 0;
    }
}
-(void)vOpen:(PDFDoc *)doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    [super vOpen:doc: page_gap: notifier: disp];
    if( m_rtol ) m_x = m_docw;
}
-(void)vResize:(int)w : (int)h
{
    bool set = (m_rtol && (m_w <=0 || m_h <= 0));
    [super vResize :w :h];
    if( set ) m_x = m_docw;
}
-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    int pcur = 0;
    int pcnt = [m_doc pageCount];
    int ccur = 0;
    int ccnt = 0;
    float max_w = 0;
    float max_h = 0;
    if( m_h > m_w )//vertical
    {
        while( pcur < pcnt )
        {
            if( m_vert_dual != NULL && ccnt < m_vert_dual_cnt && m_vert_dual[ccnt] && pcur < pcnt - 1 )
            {
                float w = [m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                h = [m_doc pageHeight:pcur + 1];
                if( max_h < h ) max_h = h;
                pcur += 2;
            }
            else
            {
                float w = [m_doc pageWidth:pcur];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                pcur++;
            }
            ccnt++;
        }
        float scale1 = ((float)(m_h - m_page_gap)) / max_h;
        m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
        if( m_scale_min > scale1 ) m_scale_min = scale1;
        m_scale_max = m_scale_min * g_zoom_level;
        if( m_scale < m_scale_min ) m_scale = m_scale_min;
        if( m_scale > m_scale_max ) m_scale = m_scale_max;
        m_doch = (int)(max_h * m_scale) + m_page_gap;
        if( m_doch < m_h ) m_doch = m_h;
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pcur = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( m_vert_dual != NULL && ccur < m_vert_dual_cnt && m_vert_dual[ccur] && pcur < pcnt - 1 )
            {
                w = (int)( ([m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1]) * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = pcur + 1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2:(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                [m_pages[pcur + 1] SetRect:[m_pages[pcur] GetX] + [m_pages[pcur] GetWidth]:
                                        (m_doch - [m_doc pageHeight:pcur+1] * m_scale) / 2: m_scale];
                pcur += 2;
            }
            else
            {
                w = (int)( [m_doc pageWidth:pcur] * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                pcur++;
            }
            left += cw;
            cell++;
            ccur++;
        }
        m_docw = left;
    }
    else
    {
        while( pcur < pcnt )
        {
            if( (m_horz_dual == NULL || ccnt >= m_horz_dual_cnt || m_horz_dual[ccnt]) && pcur < pcnt - 1 )
            {
                float w = [m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                h = [m_doc pageHeight:pcur + 1];
                if( max_h < h ) max_h = h;
                pcur += 2;
            }
            else
            {
                float w = [m_doc pageWidth:pcur];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                pcur++;
            }
            ccnt++;
        }
        m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
        float scale = ((float)(m_h - m_page_gap)) / max_h;
        if( m_scale_min > scale ) m_scale_min = scale;
        m_scale_max = m_scale_min * g_zoom_level;
        if( m_scale < m_scale_min ) m_scale = m_scale_min;
        if( m_scale > m_scale_max ) m_scale = m_scale_max;
        m_doch = (int)(max_h * m_scale) + m_page_gap;
        if( m_doch < m_h ) m_doch = m_h;
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pcur = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( (m_horz_dual == NULL || ccur >= m_horz_dual_cnt || m_horz_dual[ccur]) && pcur < pcnt - 1 )
            {
                w = (int)( ([m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1]) * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = pcur + 1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                [m_pages[pcur + 1] SetRect:[m_pages[pcur] GetX] + [m_pages[pcur] GetWidth]:
                        (int)(m_doch - [m_doc pageHeight:pcur+1] * m_scale) / 2: m_scale];
                pcur += 2;
            }
            else
            {
                w = (int)( [m_doc pageWidth:pcur] * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2:
                        (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                pcur++;
            }
            left += cw;
            cell++;
            ccur++;
        }
        m_docw = left;
    }
    if( m_rtol )
    {
        struct PDFCell *ccur = m_cells;
        struct PDFCell *cend = ccur + m_cells_cnt;
        while( ccur < cend )
        {
            int tmp = ccur->left;
            ccur->left = m_docw - ccur->right;
            ccur->right = m_docw - tmp;
            if( ccur->page_right >= 0 )
            {
                tmp = ccur->page_left;
                ccur->page_left = ccur->page_right;
                ccur->page_right = tmp;
            }
            ccur++;
        }
        int cur = 0;
        int end = m_pages_cnt;
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            int x = m_docw - ([vpage GetX] + [vpage GetWidth]);
            int y = [vpage GetY];
            [vpage SetRect: x: y: m_scale];
            cur++;
        }
    }
}

-(int)vGetPage:(int) vx :(int) vy
{
    if (!m_pages || m_pages_cnt <= 0) return -1;
    int left = 0;
    int right = m_cells_cnt - 1;
    int x = (int)m_x + vx;
    if (!m_rtol)//ltor
    {
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            struct PDFCell *pg1 = m_cells + mid;
            if (x < pg1->left)
            {
                right = mid - 1;
            }
            else if (x > pg1->right)
            {
                left = mid + 1;
            }
            else
            {
                PDFVPage *vpage = m_pages[pg1->page_left];
                if (pg1->page_right >= 0 && x > [vpage GetX] + [vpage GetWidth])
                    return pg1->page_right;
                else
                    return pg1->page_left;
            }
        }
    }
    else//rtol
    {
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            struct PDFCell *pg1 = m_cells + mid;
            if (x < pg1->left)
            {
                left = mid + 1;
            }
            else if (x > pg1->right)
            {
                right = mid - 1;
            }
            else
            {
                PDFVPage *vpage = m_pages[pg1->page_left];
                if (pg1->page_right >= 0 && x > [vpage GetX] + [vpage GetWidth])
                    return pg1->page_right;
                else
                    return pg1->page_left;
            }
        }
    }
    if (right < 0)
    {
        return 0;
    }
    else
    {
        return m_pages_cnt - 1;
    }
}

-(void)vGetDeltaToCenterPage:(int)pageno : (int *)dx : (int *)dy
{
    if( m_pages == NULL || m_doc == NULL || m_w <= 0 || m_h <= 0 ) return;
    struct PDFCell *ccur = m_cells;
    struct PDFCell *cend = ccur + m_cells_cnt;
    while( ccur < cend )
    {
        if( pageno == ccur->page_left || pageno == ccur->page_right )
        {
            int left = ccur->left;
            int w = ccur->right - left;
            int x = left + (w - m_w)/2;
            *dx = x - m_x;
            break;
        }
        ccur++;
    }
}

@end

@implementation PDFVThmb
-(id)init:(int)orientation :(bool)rtol
{
    return [self init:orientation :rtol :0 :0];
}

-(id)init:(int)orientation :(bool)rtol :(int)height :(int)gridMode
{
    if( self = [super init] )
    {
        m_orientation = orientation;
        m_rtol = rtol;
        m_element_height = height;
        m_grid_mode = gridMode;
        if (orientation == 2) {
            m_sel = -1;
        }
        
        if( rtol && orientation == 0 ) m_x = 0x7FFFFFFF;
    }
    return self;
}

-(void)vOpen:(PDFDoc *)doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    [super vOpen :doc :page_gap :notifier :disp];
    if( m_rtol && (m_orientation == 0 || m_orientation == 2) ) m_x = 0x7FFFFFFF;
}

-(void)vClose
{
    [super vClose];
		m_sel = 0;
}

-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    int cur = 0;
    int cnt = [m_doc pageCount];
   	PDF_SIZE sz = [m_doc getPagesMaxSize];
    if( m_orientation == 0 )//horz
    {
        m_scale_min = ((float)(m_h - m_page_gap)) / sz.cy;
        m_scale_max = m_scale_min * g_zoom_level;
        m_scale = m_scale_min;
        
        int left = m_w/2;
        int top = m_page_gap / 2;
        cur = 0;
        m_docw = 0;
        m_doch = 0;
        if( m_rtol )
        {
            cur = cnt - 1;
            while( cur >= 0 )
            {
                PDFVPage *vpage = m_pages[cur];
                [vpage SetRect:left: top: m_scale];
                left += [vpage GetWidth] + m_page_gap;
                if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
                cur--;
            }
            m_docw = left + m_w/2;
        }
        else
        {
            while( cur < cnt )
            {
                PDFVPage *vpage = m_pages[cur];
                [vpage SetRect:left: top: m_scale];
                left += [vpage GetWidth] + m_page_gap;
                if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
                cur++;
            }
            m_docw = left + m_w/2;
        }
    }
    else if (m_orientation == 1)
    {
        m_scale_min = ((float)(m_w - m_page_gap)) / sz.cx;
        m_scale_max = m_scale_min * g_zoom_level;
        m_scale = m_scale_min;
        
        int left = m_page_gap / 2;
        int top = m_h/2;
        cur = 0;
        m_docw = 0;
        m_doch = 0;
        while( cur < cnt )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            top += [vpage GetHeight] + m_page_gap;
            if( m_docw < [vpage GetWidth] ) m_docw = [vpage GetWidth];
            cur++;
        }
        m_doch = top + m_h/2;
    } else {
        m_scale_min = (((float)(m_element_height)) / sz.cy);
        m_scale_max = m_scale_min * g_zoom_level;
        m_scale = m_scale_min;
        
        float elementWidth = (sz.cx * m_scale);
        int cols;
        
        switch (m_grid_mode) {
            case 0:
                cols = (m_w / (elementWidth + m_page_gap)); //full screen
                break;
            case 1:
                cols = m_w / ((elementWidth + m_page_gap ) * 2); //justify center
                break;
            default:
                cols = (m_w / (elementWidth + m_page_gap)); //full screen
                break;
        }
        
        float gap = (m_w - ((cols * elementWidth) + (m_page_gap * (cols - 1)))) / 2;
        
        
       
        int left = gap;
        int top = m_page_gap / 2;
        cur = 0;
        m_docw = 0;
        m_doch = 0;
        
        while( cur < cnt )
        {
            for (int i = 0; i < cols; i++) {
                if (cur >= cnt) break;
                PDFVPage *vpage = m_pages[cur];
                [vpage SetRect :left: top: m_scale];
                left += [vpage GetWidth] + m_page_gap;
                if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
                cur++;
            }
            
            left = gap;
            top += m_page_gap + (sz.cy * m_scale);
            m_doch = top + (sz.cy * m_scale);
        }
        m_docw = m_w;
    }
}

-(int)vGetPage:(int) vx :(int) vy
{
	if( !m_pages || m_pages_cnt <= 0 ) return -1;
	if(m_orientation == 0 && !m_rtol )//ltor
	{
		int left = 0;
		int right = m_pages_cnt - 1;
		int x = m_x + vx;
		int gap = m_page_gap>>1;
		while( left <= right )
		{
			int mid = (left + right)>>1;
			PDFVPage *pg1 = m_pages[mid];
			if( x < [pg1 GetX] - gap )
			{
				right = mid - 1;
			}
			else if( x > [pg1 GetX] + [pg1 GetWidth] + gap )
			{
				left = mid + 1;
			}
			else
			{
				return mid;
			}
		}
		if( right < 0 ) return 0;
		else return m_pages_cnt - 1;
	}
	else if( m_orientation == 0 )//rtol
	{
		int left = 0;
		int right = m_pages_cnt - 1;
		int x = m_x + vx;
		int gap = m_page_gap>>1;
		while( left <= right )
		{
			int mid = (left + right)>>1;
			PDFVPage *pg1 = m_pages[mid];
			if( x < [pg1 GetX] - gap )
			{
				left = mid + 1;
			}
			else if( x > [pg1 GetX] + [pg1 GetWidth] + gap )
			{
				right = mid - 1;
			}
			else
			{
				return mid;
			}
		}
		if( right < 0 ) return 0;
		else return m_pages_cnt - 1;
	}
	else if( m_orientation == 1 )
	{
		int left = 0;
		int right = m_pages_cnt - 1;
		int y = m_y + vy;
		int gap = m_page_gap>>1;
		while( left <= right )
		{
			int mid = (left + right)>>1;
			PDFVPage *pg1 = m_pages[mid];
			if( y < [pg1 GetY] - gap )
			{
				right = mid - 1;
			}
			else if( y > [pg1 GetY] + [pg1 GetHeight] + gap )
			{
				left = mid + 1;
			}
			else
			{
				return mid;
			}
		}
		if( right < 0 ) return 0;
		else return m_pages_cnt - 1;
    } else 	{   // grid
        
        int left = 0;
        int right = m_pages_cnt - 1;
        int x = m_x + vx;
        int y = m_y + vy;
        int gap = m_page_gap>>1;
        
        while( left <= right )
        {
            int mid = (left + right)>>1;
            PDFVPage *pg1 = m_pages[mid];
            
            if (y < ([pg1 GetY] - gap))
            {
                right = mid - 1;
            }
            else if(y > ([pg1 GetY] + [pg1 GetHeight] + gap))
            {
                left = mid + 1;
            }
            else
            {
                if( x < [pg1 GetX] )
                {
                    right = mid - 1;
                }
                else if( x > [pg1 GetX] + [pg1 GetWidth] + gap )
                {
                    left = mid + 1;
                }
                else
                {
                    return mid;
                }
            }
        }
        if( right < 0 ) return 0;
        //else if(left > 0 && left < m_pages_cnt) return left;
        else return m_pages_cnt - 1;
    }
}

-(void)vFlushRange
{
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    float elementWidth = (sz.cx * m_scale);
    int cols;
    switch (m_grid_mode) {
        case 0:
            cols = (m_w / (elementWidth + m_page_gap)); //full screen
            break;
        case 1:
            cols = m_w / ((elementWidth + m_page_gap ) * 2); //justify center
            break;
        default:
            cols = (m_w / (elementWidth + m_page_gap)); //full screen
            break;
    }
    float gap = (m_w - ((cols * elementWidth) + (m_page_gap * (cols - 1)))) / 2;
    gap += 5;
    
	int pageno1 = [self vGetPage: gap :0];
	int pageno2 = [self vGetPage:m_w - gap :m_h];
	if( pageno1 >= 0 && pageno2 >= 0 )
	{
		if( pageno1 > pageno2 )
		{
			int tmp = pageno1;
			pageno1 = pageno2;
			pageno2 = tmp;
		}
		pageno2++;
		if( m_prange_start < pageno1 )
		{
			int start = m_prange_start;
			int end = pageno1;
			if( end > m_prange_end ) end = m_prange_end;
			while( start < end )
			{
				[m_thread end_thumb: m_pages[start]];
				start++;
			}
		}
		if( m_prange_end > pageno2 )
		{
			int start = pageno2;
			int end = m_prange_end;
			if( start < m_prange_start ) start = m_prange_start;
			while( start < end )
			{
				[m_thread end_thumb:m_pages[start]];
				start++;
			}
		}
	}
	else
	{
		int start = m_prange_start;
		int end = m_prange_end;
		while( start < end )
		{
			[m_thread end_thumb:m_pages[start]];
			start++;
		}
	}
	m_prange_start = pageno1;
	m_prange_end = pageno2;
	pageno1 = [self vGetPage:m_w/4:m_h/4];
	if( m_del && pageno1 != m_pageno )
	{
		[m_del OnPageChanged:m_pageno = pageno1];
	}	
}

-(void)vDraw:(PDFVCanvas *)canvas :(bool)zooming
{
    if( m_w <= 0 || m_h <= 0 || !m_doc ) return;
    [self vFlushRange];
    int cur = m_prange_start;
    int end = m_prange_end;
    
    //NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000;
    //[canvas FillRect:CGRectMake(0, 0, m_w, m_h) :m_back_clr];
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [m_thread start_thumb:vpage];
        [vpage DrawThumb:canvas];
        cur++;
    }
    
    if( m_del )
    {
	    cur = m_prange_start;
	    end = m_prange_end;
	    while( cur < end )
	    {
	        PDFVPage *vpage = m_pages[cur];
	        [m_del OnPageDisplayed:[canvas context]:vpage];
	    	cur++;
	    }
	}
    
    if (m_orientation < 2) {
        PDFVPage *vpage = m_pages[m_sel];
        int left = [vpage GetX];
        int top = [vpage GetY];
        [canvas FillRect:CGRectMake(left, top, [vpage GetWidth], [vpage GetHeight]) :g_sel_color];
    }

    //NSTimeInterval time2 = [[NSDate date] timeIntervalSince1970] * 1000 - time1;
    //time2 = 0;
}
-(void)vSetSel:(int)pageno
{
    if( !m_doc ) return;
    if( pageno >= 0 && pageno < [m_doc pageCount] )
        m_sel = pageno;
}
-(int)vGetSel
{
    return m_sel;
}

-(void)vRenderAsync:(int)pageno
{
    [m_thread end_thumb:m_pages[pageno]];
    [m_thread start_thumb:m_pages[pageno]];
}

-(void)vRenderSync:(int)pageno
{
    [m_thread end_thumb:m_pages[pageno]];
    [m_pages[pageno] ThumbPrepare];
    [[m_pages[pageno] Thumb] Render];
}

@end
