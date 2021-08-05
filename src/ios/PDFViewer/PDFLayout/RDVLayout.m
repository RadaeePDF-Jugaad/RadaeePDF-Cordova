//
//  RDVLayout.m
//  RDPDFReader
//
//  Created by radaee on 16/11/20.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDVGlobal.h"
#import "RDVLayout.h"
#import "RDVThread.h"
#import "RDVCache.h"
#import "RDVCanvas.h"
#import "RDVPage.h"
#import "RDVFinder.h"
#import "PDFThumbView.h"

@implementation RDVLayout
@synthesize docx = m_docx;
@synthesize docy = m_docy;
@synthesize docw = m_docw;
@synthesize doch = m_doch;
@synthesize vw = m_w;
@synthesize vh = m_h;

@synthesize zoomMin = m_scale_min;
@synthesize zoomMax = m_scale_max;
@synthesize zoom = m_scale;
@synthesize finder = m_finder;
@synthesize cur_pg1 = m_disp_pg1;
@synthesize cur_pg2 = m_disp_pg2;

-(id)init :(id<RDVLayoutDelegate>)del
{
    self = [super init];
    if(self)
    {
        m_doc = nil;
        m_pages = nil;
        m_thread = nil;
        m_rlayer = nil;
        m_docx = 0;
        m_docy = 0;
        m_docw = 0;
        m_doch = 0;
        m_disp_pg1 = -1;
        m_disp_pg2 = -1;
        m_scale = 1;
        m_zooming = 0;
        m_scales = NULL;
        m_scales_min = NULL;
        m_scales_max = NULL;
        m_finder = [[RDVFinder alloc] init];
        m_del = del;
        CGRect srect = [[UIScreen mainScreen] bounds];
        float sscale = [[UIScreen mainScreen] scale];
        m_cellw = srect.size.width * sscale;
        m_cellh = srect.size.height * sscale;
        if(m_cellh > m_cellw) m_cellh = m_cellw;
        else m_cellw = m_cellh;
        if(m_cellw >= 2048)
        {
            m_cellw = 2048;
            m_cellh = 2048;
        }
        else if(m_cellw >= 1024)
        {
            m_cellw = 1024;
            m_cellh = 1024;
        }
        else
        {
            m_cellw = 512;
            m_cellh = 512;
        }
    }
    return self;
}

-(void)dealloc
{
    [self vClose];
}

-(void)ProOnRenderFinished :(RDVCache *)cache
{
    if (m_del && [m_del respondsToSelector:@selector(RDVOnPageRendered:)]) {
        if (![m_del isKindOfClass:[PDFThumbView class]]) {
            [m_del RDVOnPageRendered:cache.pageno];
        }
    }
}

 -(void)ProOnRenderDestroy :(RDVCache *)cache
 {
     [CATransaction begin];
     //[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
     [CATransaction setDisableActions :YES];
     [cache vDestroyLayer];
     [CATransaction commit];
     [cache vDestroy];
     cache = nil;
 }


-(void)ProLayout
{
    [self vCalculateScales];
}

-(void)ProRefreshDispRange
{
    //RDVPage *vp1 = [self ProGetPage :-m_w :-m_h];
    //RDVPage *vp2 = [self ProGetPage :m_w<<1 :m_h<<1];
    RDVPage *vp1 = [self ProGetPage :-m_cellw :-m_cellh];
    RDVPage *vp2 = [self ProGetPage :m_w + m_cellw :m_h + m_cellh];
    if(!vp1 || !vp2) return;
    int pg1 = [vp1 pageno];
    int pg2 = [vp2 pageno];
    if(pg1 > pg2)
    {
        int tmp = pg1;
        pg1 = pg2;
        pg2 = tmp;
    }
    pg2++;
    
    if(m_zooming)
    {
        m_disp_pg1 = pg1;
        m_disp_pg2 = pg2;
    }
    else
    {
        if(m_disp_pg1 >= 0 && m_disp_pg2 >= 0)//need to cancel previous range pages.
        {
            int pgno1 = m_disp_pg1;
            int pgno2 = (pg1 > m_disp_pg2)?m_disp_pg2:pg1;
            while(pgno1 < pgno2)
            {
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pgno1];
                [vp vEndPage:m_thread];
                [vp vLayerDel];
                pgno1++;
            }
            pgno1 = (m_disp_pg1 > pg2)?m_disp_pg1:pg2;
            pgno2 = m_disp_pg2;
            while(pgno1 < pgno2)
            {
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pgno1];
                [vp vEndPage:m_thread];
                [vp vLayerDel];
                pgno1++;
            }
        }
        m_disp_pg1 = pg1;
        m_disp_pg2 = pg2;
        while(pg1<pg2)
        {
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
            [vp vClips:m_thread :true];
            pg1++;
        }
    }
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    return nil;
}

-(void)ProOnFound :(RDVFinder *)finder
{
    if(m_del)
        [m_del RDVOnFound:finder];
}

-(void)vOpen :(PDFDoc *)doc :(int)page_gap :(CALayer *)rlay
{
    if (!doc) return;
    m_doc = doc;
    m_page_gap = page_gap;
    if (m_page_gap < 0) m_page_gap = 0;
    if (m_page_gap & 1) m_page_gap &= (~1);
    m_rlayer = rlay;
    m_pages_cnt = [m_doc pageCount];
    m_pages = [[NSMutableArray alloc] initWithCapacity:m_pages_cnt];
    int pageno = 0;
    while(pageno < m_pages_cnt)
    {
        RDVPage *vp = [[RDVPage alloc] init :m_doc :pageno :m_cellw :m_cellh];
        [m_pages setObject:vp atIndexedSubscript:pageno];
        pageno++;
    }

    m_thread = [[RDVThread alloc] init];
    struct RDVThreadBack callback;
    callback.OnCacheRendered = @selector(ProOnRenderFinished:);
    callback.OnCacheDestroy = @selector(ProOnRenderDestroy:);
    callback.OnFound = @selector(ProOnFound:);
    [m_thread create:self :&callback];
    
    // custom scales
    m_scales = malloc(m_pages_cnt * sizeof(float) * 3);
    m_scales_min = m_scales + m_pages_cnt;
    m_scales_max = m_scales_min + m_pages_cnt;
    
    [self ProLayout];
}

-(void)vClose
{
    if(m_thread)
    {
        if(m_pages)
        {
            int cur = 0;
            int cnt = m_pages_cnt;
            for(cur = 0; cur < cnt; cur++)
            {
                RDVPage *vp = [m_pages objectAtIndex:cur];
                [vp vDestroy:m_thread];
            }
            m_pages = nil;
        }

        [m_thread destroy];
        m_thread = nil;
        m_pages_cnt = 0;
        m_doc = nil;
        m_scale = 1;
    }
    if(m_scales)//do not forgot to free memory.
    {
        free(m_scales);
        m_scales = NULL;
        m_scales_min = NULL;
        m_scales_max = NULL;
    }
}

-(void)vResize :(int)vw :(int)vh
{
    m_w = vw;
    m_h = vh;
    m_scale = 1;
    [self ProLayout];
}

-(void)vGetPos:(int)vx :(int)vy :(RDVPos *)pos
{
    if(!pos) return;
    RDVPage *vp = [self ProGetPage:vx :vy];
    if(vp)
    {
        pos->pageno = [vp pageno];
        pos->pdfx = [vp ToPDFX :vx :m_docx];
        pos->pdfy = [vp ToPDFY :vy :m_docy];
    }
}

-(void)vSetPos :(int)vx :(int)vy :(const RDVPos *)pos
{
    if(!pos || pos->pageno < 0 || m_docw <= 0 || m_doch <= 0)
        return;
    RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pos->pageno];
    [self vMoveTo :[vp GetVX:pos->pdfx] - vx :[vp GetVY:pos->pdfy] - vy];
}

-(void)vMoveTo :(int)docx :(int)docy
{
	if(docx + m_w > m_docw)
		docx = m_docw - m_w;
	if(docy + m_h > m_doch)
		docy = m_doch - m_h;
	if(docx < 0) docx = 0;
	if(docy < 0) docy = 0;
  
	m_docx = docx;
	m_docy = docy;
}

-(RDVPage *)vGetPage :(int)pageno
{
    if(pageno < 0 || pageno >= m_pages_cnt) return nil;
    return (RDVPage *)[m_pages objectAtIndex:pageno];
}

-(void)vDraw :(RDVCanvas *)canvas
{
    //start to remove all implict animation
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    int find_page = [m_finder find_get_page];
    if(m_zooming)
    {
    	int pg1 = m_zoom_pg1;
    	int pg2 = m_zoom_pg2;
        while(pg1 < pg2)
        {
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
            [vp vDrawZoom :m_scales[pg1]];
            if( pg1 == find_page )
                [m_finder find_draw_all:canvas :vp];
            pg1++;
        }
    }
    else
    {
        [self ProRefreshDispRange];
	    int pg1 = m_disp_pg1;
	    int pg2 = m_disp_pg2;
	    int docx = m_docx - m_cellw;
	    int docy = m_docy - m_cellh;
	    int lw = m_w + m_cellw * 2;
	    int lh = m_h + m_cellh * 2;
        while(pg1 < pg2)
        {
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
            [vp vLayerInit:m_rlayer];
            [vp vDrawZoom :m_scales[pg1]];
            [vp vDraw :m_thread :docx :docy :lw :lh];
            if([vp vFinished]) [vp vZoomEnd :m_thread];
            if( pg1 == find_page )
                [m_finder find_draw_all:canvas :vp];
            pg1++;

        }
    }
    //all drawing are finished, now we commit all layers to GPU.
    [CATransaction commit];
}

-(float)vGetScaleMin:(int)page
{
    return m_scales_min[page];
}

-(void)vZoomStart
{
    [self vGetPos :m_w>>1 :m_h>>1 :&m_zoom_pos];
    m_zooming = true;
    m_zoom_pg1 = m_disp_pg1;
    m_zoom_pg2 = m_disp_pg2;
    int pg1 = m_zoom_pg1;
    while(pg1 < m_zoom_pg2)
    {
        RDVPage *vp = [m_pages objectAtIndex:pg1];
        [vp vZoomStart];
        pg1++;
    }
}

-(void)vZooming:(float)zoom
{
    if(!m_zooming) return;
    m_scale = zoom;
    [CATransaction begin];
    [CATransaction setDisableActions :YES];
    [self ProLayout];
    //[self vSetPos :m_w>>1 :m_h>>1 :&m_zoom_pos]; // commented to allow zoom in dynamic position (not only center)
    [CATransaction commit];
}

-(void)vZoomConfirm
{
    if(!m_zooming) return;
    m_zooming = false;
    [self ProLayout];
    //[self vSetPos :m_w>>1 :m_h>>1 :&m_zoom_pos]; // commented to allow zoom in dynamic position (not only center)
    int pg1 = m_zoom_pg1;
    int pg2 = m_disp_pg1;
    while(pg1 < pg2)
    {
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
        [vp vZoomEnd :m_thread];
        pg1++;
    }
    pg1 = m_disp_pg2;
    pg2 = m_zoom_pg2;
    while(pg1 < pg2)
    {
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
        [vp vZoomEnd :m_thread];
        pg1++;
    }
}

-(void)vGotoPage:(int)pageno
{
    RDVPos pos;
    pos.pdfx = 0;
    pos.pdfy = [m_doc pageHeight:pageno];
    pos.pageno = pageno;
    [self vSetPos:m_page_gap / 2 :m_page_gap / 2 :&pos];
}

-(void)vRenderAsync:(int)pageno
{
    RDVPage *vp = (RDVPage *)m_pages[pageno];
    NSMutableArray *caches = [vp vBackCache];
    [vp vRenderAsync :m_thread :m_docx - m_cellw :m_docy - m_cellw :m_w + m_cellw * 2 :m_h + m_cellh * 2];
    [vp vBackEnd :m_thread :caches];
}

-(void)vRenderSync:(int)pageno
{
    RDVPage *vp = (RDVPage *)m_pages[pageno];
    NSMutableArray *caches = [vp vBackCache];//get all rendered caches of page
    [CATransaction begin];
    //[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [CATransaction setDisableActions :YES];
    [vp vRenderSync :m_thread :m_docx - m_cellw :m_docy - m_cellw :m_w + m_cellw * 2 :m_h + m_cellh * 2];//display all new caches over old cache
    [CATransaction commit];
    [vp vBackEnd :m_thread :caches];//delete all old caches.
}

-(void)vFindStart:(NSString *)pat : (bool)match_case :(bool)whole_word
{
    RDVPos pos;
    [self vGetPos :m_w/2 :m_h/2 :&pos];
    [m_finder find_start :m_doc :pos.pageno :pat :match_case :whole_word];
}
-(int)vFind:(int) dir
{
    if( m_pages == nil ) return -1;
    int ret = [m_finder find_prepare:dir];
    if( ret == 1 )
    {
        //[m_del OnFound:m_finder];
        //[self vFindGoto];
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
-(bool)vFindGoto
{
    if( m_pages == NULL ) return false;
    int pg = [m_finder find_get_page];
    if( pg < 0 || pg >= [m_doc pageCount] ) return false;
    PDF_RECT pos;
    if( ![m_finder find_get_pos:&pos] ) return false;
    RDVPage *vpage = m_pages[pg];
    pos.left = [vpage GetVX:pos.left];
    pos.top = [vpage GetVY:pos.top];
    pos.right = [vpage GetVX:pos.right];
    pos.bottom = [vpage GetVY:pos.bottom];
    float x = m_docx;
    float y = m_docy;
    if( x > pos.left - m_w/8 ) x = pos.left - m_w/8;
    if( x < pos.right - m_w*7/8 ) x = pos.right - m_w*7/8;
    if( y > pos.top - m_h/8 ) y = pos.top - m_h/8;
    if( y < pos.bottom - m_h*7/8 ) y = pos.bottom - m_h*7/8;
    if( x > m_docw - m_w ) x = m_docw - m_w;
    if( x < 0 ) x = 0;
    if( y > m_doch - m_h ) y = m_doch - m_h;
    if( y < 0 ) y = 0;
    m_docx = x;
    m_docy = y;
    return true;
}
-(bool)vCanPaging
{
    return false;
}

- (void)vLoadPageLayout:(int)pcur width:(float)w height:(float)h
{
    [self vLoadPageLayout:pcur width:w height:h vert:NO];
}

- (void)vLoadPageLayout:(int)pcur width:(float)w height:(float)h vert:(BOOL)vert
{
    float scale1 = ((float)(m_w - m_page_gap)) / w;
    float scale2 = ((float)(m_h - m_page_gap)) / h;
    if( scale1 > scale2 && !vert) scale1 = scale2;
    
    m_scales_min[pcur] = scale1;
    m_scales_max[pcur] = m_scales_min[pcur] * GLOBAL.g_layout_zoom_level;
    m_scales[pcur] = m_scale * m_scales_min[pcur];
    
    if( m_scales[pcur] < m_scales_min[pcur] ) m_scales[pcur] = m_scales_min[pcur];
    if( m_scales[pcur] > m_scales_max[pcur] ) m_scales[pcur] = m_scales_max[pcur];
}

- (void)vCalculateScales {
    BOOL vert = [self isKindOfClass:[RDVLayoutVert class]];
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    for (int i = 0; i < m_pages_cnt; i++) {
        float w = (GLOBAL.g_static_scale) ? sz.cx : [m_doc pageWidth:i];
        float h = (GLOBAL.g_static_scale) ? sz.cy : [m_doc pageHeight:i];
        
        [self vLoadPageLayout:i width:w height:h vert:vert];
    }
}

@end

@implementation RDVLayoutVert
-(id)init :(id<RDVLayoutDelegate>)del
{
    self = [super init :del];
    if(self)
    {
        m_align = align_left;
    }
    return self;
}

-(void)vSetAlign :(PAGE_ALIGN) align
{
    m_align = align;
    [self ProLayout];
}

-(void)ProLayout
{
    if(m_w <= 0 || m_h <= 0) return;
    [super ProLayout];
    
    int pageno = 0;
    int docy = m_page_gap >> 1;
    m_docw = m_w * m_scale;
    
    while(pageno < m_pages_cnt)
    {
        switch (m_align)
        {
            case align_left:
            {
                int ph = [m_doc pageHeight:pageno] * m_scales[pageno];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                [vp vLayout:m_page_gap>>1 :docy :m_scales[pageno] :true];
                docy += ph;
                docy += m_page_gap;
                break;
            }
            case align_right:
            {
                int ph = [m_doc pageHeight:pageno] * m_scales[pageno];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                [vp vLayout:(m_docw - (m_page_gap >> 1)) :docy :m_scales[pageno] :true];
                docy += ph;
                docy += m_page_gap;
                break;
            }
            default:
            {
                int pw = [m_doc pageWidth:pageno] * m_scales[pageno];
                int ph = [m_doc pageHeight:pageno] * m_scales[pageno];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                [vp vLayout:(m_docw - pw) >> 1 :docy :m_scales[pageno] :true];
                docy += ph;
                docy += m_page_gap;
                break;
            }
        }
        
        pageno++;
    }
    
    m_doch = docy - (m_page_gap>>1);
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    if( m_docw <= 0 || m_doch <= 0)
        return nil;
    int docy = m_docy + vy;
    int left = 0;
    int right = m_pages_cnt - 1;
    while(left <= right)
    {
        int mid = (left + right)>>1;
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:mid];
        if(docy > ([vp y] + [vp h] + (m_page_gap >> 1)))
            left = mid + 1;
        else if(docy < ([vp y] - (m_page_gap >> 1)))
            right = mid - 1;
        else
            return vp;
    }
    return [m_pages objectAtIndex:((right < 0)?0:right)];
}

@end


@implementation RDVLayoutHorz
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol
{
    self = [super init :del];
    if(self)
    {
        m_align = align_vcenter;
        m_rtol = rtol;
        m_thumb = false;
    }
    return self;
}

-(void)vSetAlign :(PAGE_ALIGN) align
{
    m_align = align;
    [self ProLayout];
}

-(void)ProLayout
{
    if(m_w <= 0 || m_h <= 0) return;
    [super ProLayout];
    
    int pageno = 0;
    m_docw = 0;
    pageno = 0;
    int docx = (m_thumb) ? m_w >> 1 : m_page_gap >> 1;
    m_doch = m_h * m_scale;
    
    while(pageno < m_pages_cnt)
    {
        int cur = (m_rtol) ? m_pages_cnt - 1 - pageno : pageno;
        
        if (m_thumb) {
            m_scales[cur] = m_scales_min[cur];
        }
        
        switch (m_align)
        {
            case align_top:
            {
                int pw = [m_doc pageWidth:cur] * m_scales[cur];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cur];
                vp.thumbMode = m_thumb;
                [vp vLayout :docx :m_page_gap>>1 :m_scales[cur] :true];
                docx += pw;
                docx += m_page_gap;
                break;
            }
            case align_bot:
            {
                int pw = [m_doc pageWidth:cur] * m_scales[cur];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cur];
                vp.thumbMode = m_thumb;
                [vp vLayout :docx :(m_doch - (m_page_gap >> 1)) :m_scales[cur] :true];
                docx += pw;
                docx += m_page_gap;
                break;
            }
            default:
            {
                int pw = [m_doc pageWidth:cur] * m_scales[cur];
                int ph = [m_doc pageHeight:cur] * m_scales[cur];
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cur];
                vp.thumbMode = m_thumb;
                [vp vLayout :docx :(m_doch - ph) >> 1 :m_scales[cur] :true];
                docx += pw;
                docx += m_page_gap;
                break;
            }
        }
        
        pageno++;
    }
    
    m_docw = (m_thumb) ? docx + (m_w/2) : docx - (m_page_gap>>1);
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    if( m_docw <= 0 || m_doch <= 0)
        return nil;
    int docx = m_docx + vx;
    int left = 0;
    int right = m_pages_cnt - 1;
    while(left <= right)
    {
        int mid = (left + right)>>1;
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:mid];
        if(docx > ([vp x] + [vp w] + (m_page_gap >> 1)))
            if (m_rtol)
                right = mid - 1;
            else
                left = mid + 1;
        else if(docx < ([vp x] - (m_page_gap >> 1)))
            if (m_rtol)
                left = mid + 1;
            else
                right = mid - 1;
        else
            return vp;
    }
    return [m_pages objectAtIndex:((right < 0)?0:right)];
}

@end


@implementation RDVLayoutThumb
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol
{
    self = [super init :del];
    if(self)
    {
        m_align = align_vcenter;
        m_rtol = rtol;
        m_thumb = true;
    }
    return self;
}

-(void)ProRefreshDispRange
{
    //RDVPage *vp1 = [self ProGetPage :-m_w :-m_h];
    //RDVPage *vp2 = [self ProGetPage :m_w<<1 :m_h<<1];
    RDVPage *vp1 = [self ProGetPage :0 :0];
    RDVPage *vp2 = [self ProGetPage :m_w :m_h];
    if(!vp1 || !vp2) return;
    int pg1 = [vp1 pageno];
    int pg2 = [vp2 pageno];
    if(pg1 > pg2)
    {
        int tmp = pg1;
        pg1 = pg2;
        pg2 = tmp;
    }
    pg2++;
    
    if(m_zooming)
    {
        m_disp_pg1 = pg1;
        m_disp_pg2 = pg2;
    }
    else
    {
        if(m_disp_pg1 >= 0 && m_disp_pg2 >= 0)//need to cancel previous range pages.
        {
            int pgno1 = m_disp_pg1;
            int pgno2 = (pg1 > m_disp_pg2)?m_disp_pg2:pg1;
            while(pgno1 < pgno2)
            {
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pgno1];
                [vp vEndPage:m_thread];
                [vp vLayerDel];
                pgno1++;
            }
            pgno1 = (m_disp_pg1 > pg2)?m_disp_pg1:pg2;
            pgno2 = m_disp_pg2;
            while(pgno1 < pgno2)
            {
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pgno1];
                [vp vEndPage:m_thread];
                [vp vLayerDel];
                pgno1++;
            }
        }
        m_disp_pg1 = pg1;
        m_disp_pg2 = pg2;
        while(pg1 < pg2)
        {
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1];
            [vp vClips:m_thread :true];
            pg1++;
        }
    }
}

@end

@implementation RDVLayoutGrid

-(id)init:(id<RDVLayoutDelegate>)del :(int)height :(int)mode
{
    self = [super init :del];
    if(self)
    {
        m_align = mode;
        m_thumb = true;
        m_height = height;
    }
    return self;
}

-(void)vSetAlign :(PAGE_ALIGN) align
{
    m_align = align;
    [self ProLayout];
}

//TODO
-(void)ProLayout
{
    if(m_w <= 0 || m_h <= 0) return;
    [super ProLayout];
    
    int pageno = 0;
    m_docw = 0;
    pageno = 0;
    int docx = m_page_gap >> 1;
    int docy = m_page_gap >> 1;
    m_doch = m_h * m_scale;
    
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    
    m_scale_min = (((float)(m_height)) / sz.cy);
    m_scale_max = m_scale_min * GLOBAL.g_layout_zoom_level;
    m_scale = m_scale_min;
    
    float elementWidth = (sz.cx * m_scale);
    int cols;
    
    switch (m_align)
    {
        case align_left:
        {
            cols = (m_w / (elementWidth + m_page_gap)); //full screen
            break;
        }
        case align_vcenter:
        {
            cols = m_w / ((elementWidth + m_page_gap ) * 2); //justify center
            break;
        }
        default:
        {
            cols = m_w / ((elementWidth + m_page_gap ) * 2); //justify center
            break;
        }
    }
    
    while(pageno < m_pages_cnt)
    {
        for (int i = 0; i < cols; i++) {
            if (pageno >= m_pages_cnt) break;
            int pw = [m_doc pageWidth:pageno] * m_scales[pageno];
            int ph = [m_doc pageHeight:pageno] * m_scales[pageno];
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
            vp.thumbMode = m_thumb;
            [vp vLayout :docx :(m_h - ph) >> 1 :m_scales[pageno] :true];
            docx += pw + m_page_gap;
            if( m_h < ph ) m_h = ph;
            pageno++;
        }
        
        docx = m_page_gap >> 1;
        docy += m_page_gap + (sz.cy * m_scale);
        m_doch = docy + (sz.cy * m_scale);
        
        pageno++;
    }
    
    m_docw = m_w;
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    if( m_docw <= 0 || m_doch <= 0)
        return nil;
    int docx = m_docx + vx;
    int left = 0;
    int right = m_pages_cnt - 1;
    while(left <= right)
    {
        int mid = (left + right)>>1;
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:mid];
        if(docx > ([vp x] + [vp w] + (m_page_gap >> 1)))
            left = mid + 1;
        else if(docx < ([vp x] - (m_page_gap >> 1)))
            right = mid - 1;
        else
            return vp;
    }
    return [m_pages objectAtIndex:((right < 0)?0:right)];
}

@end


@implementation RDVLayoutDual
-(id)init :(id<RDVLayoutDelegate>)del :(bool)rtol :(const bool *)verts :(int)verts_cnt :(const bool *)horzs :(int) horzs_cnt
{
    self = [super init :del];
    if(self)
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


-(void)vSetAlign :(PAGE_ALIGN) align
{
    m_align = align;
    [self ProLayout];
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

-(void)ProLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    
    int pageno = 0;
    int pcnt = [m_doc pageCount];
    float maxh = 0;
    //float maxw = 0;
    int ccur = 0;
    int ccnt = 0;
    m_cell_w = 0;
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    float max_w_dual = 0;
    
    if (GLOBAL.g_static_scale) {
        while( pageno < pcnt ) {
            float w = [m_doc pageWidth:pageno] + [m_doc pageWidth:pageno + 1];
            if( max_w_dual < w ) max_w_dual = w;
            
            pageno += 2;
        }
        pageno = 0;
    }

    if (m_h > m_w){
        //vertical
        while( pageno < pcnt )
        {
            if( m_vert_dual != NULL && ccnt < m_vert_dual_cnt && m_vert_dual[ccnt] && pageno < pcnt - 1 )
            {
                if (GLOBAL.g_static_scale) {
                    [self vLoadPageLayout:pageno width:max_w_dual height:sz.cy];
                } else {
                    float w = [m_doc pageWidth:pageno] + [m_doc pageWidth:pageno + 1];
                    float h1 = [m_doc pageHeight:pageno];
                    float h2 = [m_doc pageHeight:pageno + 1];
                    float h = (h1 > h2) ? h1 : h2;
                    
                    [self vLoadPageLayout:pageno width:w height:h];
                    m_scales_min[pageno+1] = m_scales_min[pageno];
                    m_scales_max[pageno+1] = m_scales_max[pageno];
                    m_scales[pageno+1] = m_scales[pageno];
                }
   
                pageno += 2;
            }
            else
            {
                if (GLOBAL.g_static_scale) {
                    [self vLoadPageLayout:pageno width:sz.cx height:sz.cy];
                } else {
                    float w = [m_doc pageWidth:pageno];
                    float h = [m_doc pageHeight:pageno];
                    
                    [self vLoadPageLayout:pageno width:w height:h];
                }
                pageno++;
            }
            ccnt++;
        }
        
        m_doch = m_h * m_scale;
        
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pageno = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( m_vert_dual != NULL && ccur < m_vert_dual_cnt && m_vert_dual[ccur] && pageno < pcnt - 1 ){
                w = (int)( ([m_doc pageWidth:pageno] + [m_doc pageWidth:pageno + 1]) * m_scales[pageno] );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pageno;
                cell->page_right = pageno + 1;
                cell->left = left;
                cell->right = left + cw;
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                RDVPage *vp_next = (RDVPage *)[m_pages objectAtIndex:pageno+1];
                [vp vLayout :left + (cw - w)/2:(m_doch - [m_doc pageHeight:pageno] * m_scales[pageno]) / 2 :m_scales[pageno] :true];
                [vp_next vLayout :vp.x + vp.w :(m_doch - [m_doc pageHeight:pageno+1] * m_scales[pageno]) / 2  :m_scales[pageno] :true];
                pageno += 2;
            }else{
                w = (int)( [m_doc pageWidth:pageno] * m_scales[pageno] );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pageno;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                [vp vLayout :left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pageno] * m_scales[pageno]) / 2 :m_scales[pageno] :true];
                pageno++;
            }
            if(m_cell_w < cw) m_cell_w = cw;
            left += cw;
            cell++;
            ccur++;
        }
        m_docw = left;
    }else{
        //horizon
        while(pageno < m_pages_cnt)
        {
            float pgh = [m_doc pageHeight:pageno];
            if(maxh < pgh) maxh = pgh;
          
            if( (m_horz_dual == NULL || ccnt >= m_horz_dual_cnt || m_horz_dual[ccnt]) && pageno < m_pages_cnt - 1 ){
                if (GLOBAL.g_static_scale) {
                    [self vLoadPageLayout:pageno width:max_w_dual height:sz.cy];
                } else {
                    float w = [m_doc pageWidth:pageno] + [m_doc pageWidth:pageno + 1];
                    float h1 = [m_doc pageHeight:pageno];
                    float h2 = [m_doc pageHeight:pageno + 1];
                    float h = (h1 > h2) ? h1 : h2;
                    
                    [self vLoadPageLayout:pageno width:w height:h];
                    m_scales_min[pageno+1] = m_scales_min[pageno];
                    m_scales_max[pageno+1] = m_scales_max[pageno];
                    m_scales[pageno+1] = m_scales[pageno];
                }
                pageno += 2;
            }else{
                if (GLOBAL.g_static_scale) {
                    [self vLoadPageLayout:pageno width:sz.cx height:sz.cy];
                } else {
                    float w = [m_doc pageWidth:pageno];
                    float h = [m_doc pageHeight:pageno];
                    
                    [self vLoadPageLayout:pageno width:w height:h];
                }
                pageno++;
            }
            ccnt++;
        }
        
        m_doch = m_h * m_scale;
        
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pageno = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( (m_horz_dual == NULL || ccur >= m_horz_dual_cnt || m_horz_dual[ccur]) && pageno < m_pages_cnt - 1 )
            {
                w = (int)( ([m_doc pageWidth:pageno] + [m_doc pageWidth:pageno + 1]) * m_scales[pageno] );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pageno;
                cell->page_right = pageno + 1;
                cell->left = left;
                cell->right = left + cw;
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                RDVPage *vp_next = (RDVPage *)[m_pages objectAtIndex:pageno+1];
                [vp vLayout :left + (cw - w)/2 : (int)(m_doch - [m_doc pageHeight:pageno] * m_scales[pageno]) / 2 :m_scales[pageno] :true];
                [vp_next vLayout :vp.x + vp.w : (int)(m_doch - [m_doc pageHeight:pageno+1] * m_scales[pageno]) / 2:m_scales[pageno] :true];
                pageno += 2;
            }
            else
            {
                w = (int)( [m_doc pageWidth:pageno] * m_scales[pageno] );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pageno;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pageno];
                [vp vLayout :left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pageno] * m_scales[pageno]) / 2 :m_scales[pageno] :true];
 
                pageno++;
            }
            if(m_cell_w < cw) m_cell_w = cw;
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
        while( cur < end ){
            RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cur];
      
            int x = m_docw - (vp.x + vp.w);
            int y = vp.y;
            [vp vLayout:x :y :m_scales[pageno] :true];
            cur++;
        }
    }
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    if( m_docw <= 0 || m_doch <= 0)
        return nil;
    
    int left = 0;
    int right = m_cells_cnt - 1;
    int x = (int)m_docx + vx;
    
    if(!m_rtol){
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            struct PDFCell *cmid = m_cells + mid;
            if (x < cmid->left){
                right = mid - 1;
            }else if (x > cmid->right){
                left = mid + 1;
            }else{
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cmid->page_left];
                if (cmid->page_right >= 0 && x > vp.x + vp.w)
                    return  (RDVPage *)[m_pages objectAtIndex:cmid->page_right];
                else
                    return vp;
            }
        }
    }else{
        while (left <= right)
        {
            int mid = (left + right) >> 1;
            struct PDFCell *pg1 = m_cells + mid;
            if (x < pg1->left){
                left = mid + 1;
            }else if (x > pg1->right){
                right = mid - 1;
            }else{
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:pg1->page_left];
                if (pg1->page_right >= 0 && x > vp.x + vp.w)
                    return (RDVPage *)[m_pages objectAtIndex:pg1->page_right];
                else
                    return vp;
            }
        }
    }
    if (right < 0){
        return m_pages[0];
    }else{
        return m_pages[m_pages.count - 1];
    }
}

-(void)vGotoPage:(int)pageno
{
    struct PDFCell *ccur = m_cells;
    struct PDFCell *cend = ccur + m_cells_cnt;
    while(ccur < cend)
    {
        if(ccur->page_left == pageno || ccur->page_right == pageno)
        {
            m_docx = ccur->left;
            if(ccur->page_right == pageno && m_cell_w > m_w)
            {
                RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:ccur->page_right];
                m_docx = [vp x];
            }
            return;
        }
        ccur++;
    }
}

-(bool)vFindGoto
{
    if( m_pages == NULL ) return false;
    int pg = [m_finder find_get_page];
    if( pg < 0 || pg >= [m_doc pageCount] ) return false;
    PDF_RECT pos;
    if( ![m_finder find_get_pos:&pos] ) return false;
    [self vGotoPage :pg];
    RDVPage *vpage = m_pages[pg];
    pos.left = [vpage GetVX:pos.left];
    pos.top = [vpage GetVY:pos.top];
    pos.right = [vpage GetVX:pos.right];
    pos.bottom = [vpage GetVY:pos.bottom];
    float x = m_docx;
    float y = m_docy;
    if( x > pos.left - m_w/8 ) x = pos.left - m_w/8;
    if( x < pos.right - m_w*7/8 ) x = pos.right - m_w*7/8;
    if( y > pos.top - m_h/8 ) y = pos.top - m_h/8;
    if( y < pos.bottom - m_h*7/8 ) y = pos.bottom - m_h*7/8;
    if( x > m_docw - m_w ) x = m_docw - m_w;
    if( x < 0 ) x = 0;
    if( y > m_doch - m_h ) y = m_doch - m_h;
    if( y < 0 ) y = 0;
    m_docx = x;
    m_docy = y;
    return true;
}

-(bool)vCanPaging
{
    return (m_cell_w <= m_w);
}

@end

@implementation RDVLayoutSingle
-(id)init :(id<RDVLayoutDelegate>)del :(BOOL)rtol :(int)pageno
{
    self = [super init :del];
    if(self)
    {
        m_align = align_vcenter;
        m_rtol = rtol;
        m_thumb = false;
        pageViewNo = pageno;
    }
    return self;
}

-(void)vSetAlign :(PAGE_ALIGN) align
{
    m_align = align;
    [self ProLayout];
}

-(void)ProLayout
{
    if(m_w <= 0 || m_h <= 0) return;
    [self vCalculateScales];
    
    m_docw = 0;
    //int pageno = pageViewNo;
    int docx = (m_thumb) ? m_w >> 1 : m_page_gap >> 1;
    m_doch = m_h * m_scale;
    
    int cur = 0;
    
    int pw = [m_doc pageWidth:pageViewNo] * m_scales[0];
    int ph = [m_doc pageHeight:pageViewNo] * m_scales[0];
    
    docx = (m_w - m_page_gap/2 - pw)/2;
    
    RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:cur];
    vp.thumbMode = m_thumb;
    [vp vLayout :docx :(m_doch - ph) >> 1 :m_scales[0] :true];
    docx += pw;
    docx += m_page_gap;
 
    m_docw = m_w;
}

-(RDVPage *)ProGetPage :(int)vx :(int)vy
{
    if( m_docw <= 0 || m_doch <= 0)
        return nil;
    return [m_pages objectAtIndex:0];
}

-(void)vOpen :(PDFDoc *)doc :(int)page_gap :(CALayer *)rlay :(int)pageno
{
    if (!doc) return;
    m_doc = doc;
    m_page_gap = page_gap;
    if (m_page_gap < 0) m_page_gap = 0;
    if (m_page_gap & 1) m_page_gap &= (~1);
    m_rlayer = rlay;
    m_pages_cnt = 1;
    m_pages = [NSMutableArray array];
    
    RDVPage *vp = [[RDVPage alloc] init :m_doc :pageno :m_cellw :m_cellh];
    [m_pages addObject:vp];
    
    m_thread = [[RDVThread alloc] init];
    struct RDVThreadBack callback;
    callback.OnCacheRendered = @selector(ProOnRenderFinished:);
    callback.OnCacheDestroy = @selector(ProOnRenderDestroy:);
    callback.OnFound = @selector(ProOnFound:);
    [m_thread create:self :&callback];
    
    // custom scales
    m_scales = malloc(m_pages_cnt * sizeof(float) * 3);
    m_scales_min = m_scales + m_pages_cnt;
    m_scales_max = m_scales_min + m_pages_cnt;
    
    [self ProLayout];
}

-(void)ProRefreshDispRange
{
    RDVPage *vp1 = (RDVPage *)[m_pages objectAtIndex:0];
    RDVPage *vp2 = (RDVPage *)[m_pages objectAtIndex:0];
    if(!vp1 || !vp2) return;
    int pg1 = [vp1 pageno];
    int pg2 = [vp2 pageno];
    if(pg1 > pg2)
    {
        int tmp = pg1;
        pg1 = pg2;
        pg2 = tmp;
    }
    pg2++;
    
    if(m_zooming)
    {
        m_disp_pg1 = pg1;
        m_disp_pg2 = pg2;
    }
    else
    {
        m_disp_pg1 = 0;
        m_disp_pg2 = 1;
        
        RDVPage *vp = (RDVPage *)[m_pages objectAtIndex:0];
        [vp vClips:m_thread :true];
    }
}

- (void)vCalculateScales {
    BOOL vert = [self isKindOfClass:[RDVLayoutVert class]];
    PDF_SIZE sz = [m_doc getPagesMaxSize];
    for (int i = 0; i < m_pages_cnt; i++) {
        float w = (GLOBAL.g_static_scale) ? sz.cx : [m_doc pageWidth:pageViewNo];
        float h = (GLOBAL.g_static_scale) ? sz.cy : [m_doc pageHeight:pageViewNo];
        [self vLoadPageLayout:i width:w height:h vert:vert];
    }
}

@end
