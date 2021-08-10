#import "RDVPage.h"
#import "RDVThread.h"
#import "RDVCache.h"

@implementation RDVPage
@synthesize pageno = m_pageno;
@synthesize x = m_x;
@synthesize y = m_y;
@synthesize w = m_w;
@synthesize h = m_h;
@synthesize scale = m_scale;
@synthesize thumbMode = m_thumb;

-(id)init :(PDFDoc *) doc :(int) pageno :(int) cw :(int) ch
{
    if( self = [super init] )
    {
		m_doc = doc;
        m_page = nil;
		m_pageno = pageno;
		m_caches = NULL;
		m_x = 0;
		m_y = 0;
		m_w = 0;
		m_h = 0;
	    if((cw & 1) > 0) cw++;
	    if((ch & 1) > 0) ch++;
	    m_cw = cw;
	    m_ch = ch;
	    m_x0 = 0;
	    m_y0 = 0;
	    m_x1 = 0;
	    m_y1 = 0;
	    m_xb0 = 0;
	    m_yb0 = 0;
	    m_scale = 0;
	    m_need_clip = false;
        m_layer = nil;
	}
	return self;
}
-(void)vLayerInit : (CALayer *)root
{
    if(m_layer) return;
    m_layer = [[CAShapeLayer alloc] init];
    m_layer.backgroundColor = (GLOBAL.g_dark_mode) ? [UIColor blackColor].CGColor : [UIColor whiteColor].CGColor;
    [m_layer removeAllAnimations];
    float pscale = 1.0f / [[UIScreen mainScreen] scale];
    m_layer.frame = CGRectMake(m_x * pscale, m_y * pscale, m_w * pscale, m_h * pscale);
    [root addSublayer:m_layer];
}
-(void)vLayerDel
{
    if(!m_layer) return;
    [m_layer removeFromSuperlayer];
    m_layer = nil;
}

- (PDFPage *)GetPage
{
    if(!m_page) m_page = [m_doc page:m_pageno];
    return m_page;
}

-(int)GetX
{
    return m_x;
}
-(int)GetY
{
    return m_y;
}
-(float)GetPDFX :(int) vx
{
	return (vx - m_x)/m_scale;
}

-(float)GetPDFY :(int) vy
{
	return (m_y + m_h - vy)/m_scale;
}

-(int)GetVX :(float) pdfx
{
	return (int)(pdfx * m_scale) + m_x;
}
-(int)GetVY :(float) pdfy
{
	return m_h + m_y - (int)(pdfy * m_scale);
}
-(int)GetWidth
{
    return m_w;
}
-(int)GetHeight
{
    return m_h;
}
-(float)GetScale
{
    return m_scale;
}
-(float)ToPDFX :(int) vx :(int) scrollx
{
	float dibx = scrollx + vx - m_x;
	return dibx / m_scale;
}
-(float)ToPDFY :(int) vy :(int) scrolly
{
	float diby = scrolly + vy - m_y;
	return (m_h - diby) / m_scale;
}
-(int)ToDIBX :(float) pdfx
{
	return pdfx * m_scale;
}
-(int)ToDIBY :(float) pdfy
{
    return ([m_doc pageHeight :m_pageno] - pdfy) * m_scale;
}
-(float)ToPDFSize :(int) val
{
	return (float)val / m_scale;
}
-(PDFMatrix *)CreateInvertMatrix :(float) scrollx :(float) scrolly
{
	return [[PDFMatrix alloc] init :1/m_scale :-1/m_scale :(scrollx - m_x)/m_scale :(m_y + m_h - scrolly)/m_scale];
}

-(PDFMatrix *)CreateIMatrix :(float) scrollx :(float) scrolly :(float)scale
{
    return [[PDFMatrix alloc] init :scale/m_scale :-scale/m_scale :(scrollx - m_x) * scale/m_scale :(m_y + m_h - scrolly) * scale/m_scale];
}

-(void)blocks_destroy :(RDVThread *) thread
{
	if (!m_caches) return;
	int xcur = 0;
	int ycur = 0;
	int xcnt = [m_caches cols];
	int ycnt = [m_caches rows];
	for(ycur = 0; ycur < ycnt; ycur++)
	{
		for(xcur = 0; xcur < xcnt; xcur++)
		{
            [thread end_render :[m_caches get :xcur :ycur]];
            //[thread end_render :[m_caches get :xcur :ycur]];
		}
	}
	m_caches = NULL;
}

-(void)blocks_create;
{
	int xcnt = m_w / m_cw;
	int ycnt = m_h / m_ch;
	int xtail = m_w % m_cw;
	int ytail = m_h % m_ch;
	if(xtail > (m_cw>>1)) xcnt++;
	if(ytail > (m_ch>>1)) ycnt++;
	if(xcnt <= 0) xcnt = 1;
	if(ycnt <= 0) ycnt = 1;
	m_caches = [[RDVCacheSet alloc] init :xcnt :ycnt];
	RDVCache *cache;
	int xcur;
	int ycur;
	int yval = 0;
	int xval;
	for( ycur = 0; ycur < ycnt - 1; ycur++ )
	{
		xval = 0;
		for(xcur = 0; xcur < xcnt - 1; xcur++)
		{
			cache = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :xval :yval :m_cw :m_ch];
            cache.thumbMode = m_thumb;
			[m_caches set :xcur :ycur :cache];
			xval += m_cw;
		}
		cache = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :xval :yval :m_w - xval :m_ch];
        cache.thumbMode = m_thumb;
        [m_caches set :xcur :ycur :cache];
		yval += m_ch;
	}
	xval = 0;
	for(xcur = 0; xcur < xcnt - 1; xcur++)
	{
		cache = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :xval :yval :m_cw :m_h - yval];
        cache.thumbMode = m_thumb;
        [m_caches set :xcur :ycur :cache];
		xval += m_cw;
	}
	cache = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :xval :yval :m_w - xval :m_h - yval];
    cache.thumbMode = m_thumb;
    [m_caches set :xcur :ycur :cache];
}

-(void)vDestroy :(RDVThread *) thread;
{
    [self vLayerDel];
    [self vZoomEnd :thread];
    [self blocks_destroy :thread];
    if(m_layer)
    {
        [m_layer removeFromSuperlayer];
        m_layer = nil;
    }
}

-(void)vLayout :(int) vx :(int) vy :(float) scale :(bool) clip
{
	m_x = vx;
	m_y = vy;
	m_scale = scale;
	int vw = (int)([m_doc pageWidth :m_pageno] * scale);
	int vh = (int)([m_doc pageHeight :m_pageno] * scale);
    if( vw > (m_cw<<2) || vh > (m_ch<<2)) clip = true;
	if(vw != m_w || vh != m_h || !m_caches)
	{
        m_need_clip = true;
		m_w = vw;
		m_h = vh;
	}
    float pscale = 1.0f / [[UIScreen mainScreen] scale];
    //start to remove all implict animation
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if(m_layer) m_layer.frame = CGRectMake(m_x * pscale, m_y * pscale, m_w * pscale, m_h * pscale);
    [CATransaction commit];
}

-(void)vClips :(RDVThread *) thread :(bool) clip;
{
    if(m_need_clip)
    {
        m_need_clip = false;
        [self blocks_destroy :thread];
        if( m_w > (m_cw<<2) || m_h > (m_ch<<2)) clip = true;
        if (clip)
            [self blocks_create];
        else
        {
            m_caches = [[RDVCacheSet alloc] init :1 :1];
            RDVCache *cache = [[RDVCache alloc] init :m_doc :m_pageno :m_scale :0 :0 :m_w :m_h];
            cache.thumbMode = m_thumb;
            [m_caches set :0 :0 :cache];
        }
    }
}

-(void)vEndPage :(RDVThread *) thread
{
    [self vZoomEnd :thread];
    PDFPage *page = m_page;
    m_page = nil;
    [thread end_page:page];
	if (!m_caches) return;
	int xcur = 0;
	int ycur = 0;
	int xcnt = [m_caches cols];
	int ycnt = [m_caches rows];
	for(ycur = 0; ycur < ycnt; ycur++)
	{
		for(xcur = 0; xcur < xcnt; xcur++)
		{
			RDVCache *cache = [m_caches get :xcur :ycur];
			if ([cache vIsRendering]) [m_caches set :xcur :ycur :[cache vClone]];
			[thread end_render :cache];
		}
	}
}
-(NSMutableArray *)vBackCache
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    if (m_caches_zoom)
    {
        RDVCacheSet *zcaches = m_caches_zoom;
        m_caches_zoom = nil;
        int xcur = 0;
        int ycur = 0;
        int xcnt = [zcaches cols];
        int ycnt = [zcaches rows];
        //remove all zoom cache in backing thread.
        for(ycur = 0; ycur < ycnt; ycur++)
        {
            for(xcur = 0; xcur < xcnt; xcur++)
            {
                RDVCache *cache = [zcaches get :xcur :ycur];
                [ret addObject:cache];
            }
        }
    }
    if (!m_caches) return nil;
    int xcur = 0;
    int ycur = 0;
    int xcnt = [m_caches cols];
    int ycnt = [m_caches rows];
    for(ycur = 0; ycur < ycnt; ycur++)
    {
        for(xcur = 0; xcur < xcnt; xcur++)
        {
            RDVCache *cache = [m_caches get :xcur :ycur];
            [m_caches set :xcur :ycur :[cache vClone]];
            if ([cache vIsRendering] || [cache vIsRenderFinished])
                [ret addObject:cache];
        }
    }
    return ret;
}

-(void)vBackEnd :(RDVThread *) thread :(NSMutableArray *)arr
{
    if(!arr) return;
    int cnt = (int)[arr count];
    int cur = 0;
    for(cur = 0; cur < cnt; cur++) [thread end_render:[arr objectAtIndex:cur]];
}

-(bool)vFinished
{
	if (!m_caches) return false;
	int xcnt = [m_caches cols];
	int ycnt = [m_caches rows];
	for( int ycur = 0; ycur < ycnt; ycur++ )
	{
		for( int xcur = 0; xcur < xcnt; xcur++ )
		{
			RDVCache *cache = [m_caches get :xcur :ycur];
			if ([cache vIsRendering])
                return false;
		}
	}
	return true;
}

-(void)get_xyb0 :(int) vx :(int) vy :(int) vw :(int) vh :(int) xcnt :(int) ycnt
{
    m_x0 = m_x - vx;
    m_y0 = m_y - vy;
    m_x1 = m_x0 + m_w + m_cw;
    m_y1 = m_y0 + m_h + m_ch;
    if( m_x1 > vw ) m_x1 = vw;
    if( m_y1 > vh ) m_y1 = vh;
    m_xb0 = 0;
    while( m_xb0 < xcnt && m_x0 <= -[m_caches get :m_xb0 :0].w )
    {
        m_x0 += [m_caches get :m_xb0 :0].w;
        m_xb0++;
    }
    m_yb0 = 0;
    while( m_yb0 < ycnt && m_y0 <= -[m_caches get :0 :m_yb0].h )
    {
        m_y0 += [m_caches get :0 :m_yb0].h;
        m_yb0++;
    }
}
-(void)end_render_xb :(RDVThread *) thread :(int) xb0 :(int) xb1 :(int) yb
{
    while(xb0 < xb1)
    {
        RDVCache *cache = [m_caches get :xb0 :yb];
        if ([cache vIsRendering]) [m_caches set :xb0 :yb :[cache vClone]];
        [thread end_render :cache];
        xb0++;
    }
}

-(void)end_render_yb :(RDVThread *) thread :(int) yb0 :(int) yb1 :(int) xcnt
{
    while(yb0 < yb1)
    {
        [self end_render_xb :thread :0 :xcnt :yb0];
        yb0++;
    }
}

-(void)vRenderAsync :(RDVThread *) thread :(int) vx :(int) vy :(int) vw :(int) vh;
{
	if(!m_caches) return;
	int xcnt = [m_caches cols];
	int ycnt = [m_caches rows];
    [self get_xyb0 :vx :vy :vw :vh :xcnt :ycnt];
	int xb0 = m_xb0;
	int yb0 = m_yb0;
    int x0 = m_x0;
    int y0 = m_y0;
	int ycur = yb0;
	int xcur;
    [self end_render_yb :thread :0 :yb0 :xcnt];
	for(int yval = y0; yval < m_y1 && ycur < ycnt; ycur++)
	{
        [self end_render_xb :thread :0 :xb0 :ycur];
        xcur = xb0;
		for(int xval = x0; xval < m_x1 && xcur < xcnt; xcur++)
		{
            RDVCache *vc = [m_caches get :xcur :ycur];
            if ([vc vIsRendering]) [m_caches set :xcur :ycur :vc.vClone];
            [thread end_render :vc];
            vc = [m_caches get :xcur :ycur];
			[thread start_render :vc];
			xval += vc.w;
		}
        [self end_render_xb :thread :xcur :xcnt :ycur];
		yval += [m_caches get :0 :ycur].h;
	}
    [self end_render_yb :thread :ycur :ycnt :xcnt];
}

-(void)vRenderSync :(RDVThread *) thread :(int) vx :(int) vy :(int) vw :(int) vh;
{
	if (!m_caches) return;
	int xcnt = [m_caches cols];
	int ycnt = [m_caches rows];
    [self get_xyb0 :vx :vy :vw :vh :xcnt :ycnt];
    int xb0 = m_xb0;
    int yb0 = m_yb0;
    int x0 = m_x0;
    int y0 = m_y0;
	int ycur = yb0;
	int xcur;
    [self end_render_yb :thread :0 :yb0 :xcnt];
	for(int yval = y0; yval < m_y1 && ycur < ycnt; ycur++)
	{
        [self end_render_xb :thread :0 :xb0 :ycur];
        xcur = xb0;
		for(int xval = x0; xval < m_x1 && xcur < xcnt; xcur++)
		{
            RDVCache *vc = [m_caches get :xcur :ycur];
            [vc vStart];
			[vc vRender];
            [vc vDraw:m_layer];
			xval += vc.w;
		}
        [self end_render_xb :thread :xcur :xcnt :ycur];
		yval += [m_caches get :0 :ycur].h;
	}
    [self end_render_yb :thread :ycur :ycnt :xcnt];
}

-(void)vDraw :(RDVThread *) thread :(int) vx :(int) vy :(int) vw :(int) vh
{
    if (!m_caches) return;
    
    int xcnt = [m_caches cols];
    int ycnt = [m_caches rows];
    [self get_xyb0 :vx :vy :vw :vh :xcnt :ycnt];
    int xb0 = m_xb0;
    int yb0 = m_yb0;
    int x0 = m_x0;
    int y0 = m_y0;
    int ycur = yb0;
    int xcur;
    [self end_render_yb :thread :0 :yb0 :xcnt];
    for(int yval = y0; yval < m_y1 && ycur < ycnt; ycur++)
    {
        [self end_render_xb :thread :0 :xb0 :ycur];
        xcur = xb0;
        for(int xval = x0; xval < m_x1 && xcur < xcnt; xcur++)
        {
            RDVCache *vc = [m_caches get :xcur :ycur];
            [thread start_render :vc];
            [vc vDraw :m_layer];
            
            xval += vc.w;
        }
        [self end_render_xb :thread :xcur :xcnt :ycur];
        yval += [m_caches get :0 :ycur].h;
    }
    [self end_render_yb :thread :ycur :ycnt :xcnt];
}

-(void)get_zoom_xyb0 :(float) zoom :(int) vx :(int) vy :(int) vw :(int) vh :(int) xcnt :(int) ycnt
{
    m_x0 = m_x - vx;
    m_y0 = m_y - vy;
    m_x1 = m_x0 + m_w + m_cw;
    m_y1 = m_y0 + m_h + m_ch;
    if( m_x1 > vw ) m_x1 = vw;
    if( m_y1 > vh ) m_y1 = vh;
    m_xb0 = 0;
    while( m_xb0 < xcnt && m_x0 <= -[m_caches_zoom get :m_xb0 :0].w * zoom )
    {
        m_x0 += [m_caches_zoom get :m_xb0 :0].w * zoom;
        m_xb0++;
    }
    m_yb0 = 0;
    while( m_yb0 < ycnt && m_y0 <= -[m_caches_zoom get :0 :m_yb0].h * zoom )
    {
        m_y0 += [m_caches_zoom get :0 :m_yb0].h * zoom;
        m_yb0++;
    }
}

-(bool)vDrawZoom :(float)scale
{
    if (!m_caches_zoom) return false;
    int xcnt = [m_caches_zoom cols];
    int ycnt = [m_caches_zoom rows];
    int ycur;
    int xcur;
    for(ycur = 0; ycur < ycnt; ycur++)
    {
        for(xcur = 0; xcur < xcnt; xcur++)
        {
            RDVCache *vc = [m_caches_zoom get :xcur :ycur];
            if(vc) [vc vDrawZoom :m_layer :scale];
        }
    }
    return true;
}

-(void)vZoomStart
{
    if(!m_caches_zoom) m_caches_zoom = m_caches;
    m_caches = nil;
}

-(void)vZoomEnd :(RDVThread *) thread
{
    if (!m_caches_zoom) return;
    RDVCacheSet *zcaches = m_caches_zoom;
    m_caches_zoom = nil;
    int xcur = 0;
    int ycur = 0;
    int xcnt = [zcaches cols];
    int ycnt = [zcaches rows];
    //start to remove all implict animation
    for(ycur = 0; ycur < ycnt; ycur++)
    {
        for(xcur = 0; xcur < xcnt; xcur++)
        {
            [thread end_render:[zcaches get :xcur :ycur]];
        }
    }
}

@end
