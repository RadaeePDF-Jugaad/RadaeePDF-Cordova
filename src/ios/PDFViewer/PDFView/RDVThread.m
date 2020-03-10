#import "RDVThread.h"
#import "RDVCache.h"
#import "RDVGlobal.h"
#import "RDVFinder.h"

@implementation RDVThread
-(id)init
{
    if( self = [super init] )
    {
        m_queue = nil;
    }
    return self;
}
-(void)dealloc
{
    [self destroy];
}

-(bool)create:(id)notifier :(const struct RDVThreadBack *) disp
{
    if(m_queue) return true;
    m_back = *disp;
    m_notifier = notifier;
    m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    return true;
}

-(void)notify_render:(RDVCache *)cache
{
    [m_notifier performSelectorOnMainThread:m_back.OnCacheRendered withObject:cache waitUntilDone:NO];
}

-(void)notify_dealloc:(RDVCache *)cache
{
    [m_notifier performSelectorOnMainThread:m_back.OnCacheDestroy withObject:cache waitUntilDone:NO];
}

-(void)notify_find:(RDVFinder *)finder
{
    [m_notifier performSelectorOnMainThread:m_back.OnFound withObject:finder waitUntilDone:NO];
}


-(void) destroy;
{
    if(m_queue)
    {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(m_queue);
#endif
        m_queue = nil;
    }
}
-(void)start_render:(RDVCache *)cache
{
    if (![cache vStart]) return;
    dispatch_async(m_queue, ^{
        [cache vRender];
        [self notify_render:cache];
    });
}
-(void)end_render:(RDVCache *)cache;
{
    if (!cache || ![cache vEnd]) return;
    //why we using backing thread to notify UI thread to destroy cache?
    //imaging that this cache is rendering on backing thread.
    //if destroy on UI thread directly, the data in cache is not synchronized,
    //using backing thread to nitify UI thread, can ensure render->destroy order.
    dispatch_async(m_queue, ^{
        //it must delete CALayer in main UI thread, so we send cache object to main thread.
        [self notify_dealloc:cache];
    });
}
-(void)start_find:(RDVFinder *)finder;
{
    dispatch_async(m_queue, ^{
        [finder find];
        [self notify_find:finder];
    });
}
@end
