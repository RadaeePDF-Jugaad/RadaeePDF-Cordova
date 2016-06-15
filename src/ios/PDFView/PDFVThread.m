//
//  PDFVThread.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVThread.h"

static void *thread_route(void *para)
{
    @autoreleasepool
    {
        PDFVThread *thiz = (__bridge PDFVThread *)para;
        unsigned mid;
        id para1;
        void *para2;
        while( (para1 = [thiz get_msg: &mid: &para2]) != nil )
        {
            switch( mid )
            {
                case 1:
                {
                    
                    PDFVCache *cache = (PDFVCache *)para1;
                    [cache Render];
                    [thiz notify_render:cache];
                    cache = nil;
                }
                    break;
                case 2:
                {
                    [(PDFVCache *)para1 Clear];
                    break;
                }
                case 3:
                {
                    PDFVFinder *finder = (PDFVFinder *)para1;
                    [finder find];
                    [thiz notify_find:finder];
                    finder = nil;
                    break;
                }
                case 4:
                {
                    PDFVCache1 *thumb = (PDFVCache1 *)para1;
                    [thumb Render];
                    [thiz notify_render:nil];
                    thumb = nil;
                    break;
                }
                case 5:
                {
                    PDFVCache1 *thumb = (PDFVCache1 *)para1;
                    [thumb Clear];
                    thumb = nil;
                    break;
                }
            }
        }
    }
    return NULL;
}

@implementation PDFVThread
-(id)init
{
    if( self = [super init] )
    {
		tid = 0;
		queue_cur = 0;
		queue_next = 0;
		m_notified = false;
        queue_locker = [[PDFVLocker alloc] init];
        queue_event = [[PDFVEvent alloc] init];
    }
    return self;
}
-(void)dealloc
{
}

-(bool)create:(id)notifier :(const struct PDFVThreadBack *) disp
{
    if( !tid )
    {
        queue_cur = 0;
        queue_next = 0;
        m_back = *disp;
        m_notifier = notifier;
        int err = pthread_create(&tid, NULL, thread_route, (__bridge void *)(self));
        if(err != 0) return false;
    }
    return true;
}

-(void)notify_render:(PDFVCache *)cache
{
    [m_notifier performSelectorOnMainThread:m_back.OnPageRendered withObject:cache waitUntilDone:NO];
}

-(void)notify_find:(PDFVFinder *)finder
{
    [m_notifier performSelectorOnMainThread:m_back.OnFound withObject:finder waitUntilDone:NO];
}

-(void) destroy;
{
    if( tid )
    {
        [self post_msg: 0xFFFFFFFF: nil: (void *)0xFFFFFFFF];
        pthread_join( tid, NULL );
        tid = 0;
        m_notified = false;
    }
}
-(void)start_render:(PDFVPage *)page
{
    switch( [page RenderPrepare] )
    {
		case 1: break;
		case 2: [self end_render: page]; [self start_render: page]; break;
		default: [self post_msg: 1: [page Cache]: NULL]; break;
    }
}
-(void)end_render:(PDFVPage *)page;
{
    PDFVCache *cache = [page CancelRender];
    if( cache != NULL )
        [self post_msg: 2: cache: NULL];
}
-(void)start_thumb:(PDFVPage *)page
{
    if( [page ThumbPrepare] == 0 )
        [self post_msg:4 :[page Thumb] :NULL];
}
-(void)end_thumb:(PDFVPage *)page
{
    PDFVCache1 *thumb = [page CancelThumb];
    if( thumb )
        [self post_msg:5 :thumb: NULL];
}
-(void)start_find:(PDFVFinder *)finder;
{
    [self post_msg: 3: finder: NULL];
}
-(void)post_msg:(unsigned int)mid : (id)para1 : (void *)para2;
{
    [queue_locker lock];
    struct _QUEUE_NODE *item = queue_items + queue_next;
    item->id = mid;
    m_para1s[queue_next] = para1;
    item->para2 = para2;
    int next = queue_next;
    queue_next = (queue_next+1) & 127;
    if(queue_cur == next)
    {
        if( !m_notified )
        {
            [queue_event notify];
            m_notified = true;
        }
    }
    [queue_locker unlock];
}

-(id)get_msg:(unsigned int *)mid : (void **)para2
{
    [queue_locker lock];
    if( m_notified )
    {
        [queue_event wait];
        m_notified = false;
    }
    if( queue_cur == queue_next )
    {
        [queue_locker unlock];
        [queue_event wait];
        [queue_locker lock];
        m_notified = false;
    }
    struct _QUEUE_NODE *item = queue_items + queue_cur;
    *mid = item->id;
    id ret = m_para1s[queue_cur];
    m_para1s[queue_cur] = nil;
    *para2 = item->para2;
    queue_cur = (queue_cur+1) & 127;
    [queue_locker unlock];
    if( *mid == 0xFFFFFFFF ) ret = nil;
    return ret;
}
@end
