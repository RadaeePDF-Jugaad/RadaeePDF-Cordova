#pragma once
#include <pthread.h>
#import "PDFObjc.h"

@class RDVLocker;
@class RDVEvent;
@class RDVCache;
@class RDVFinder;

struct RDVThreadBack
{
    SEL OnCacheRendered;
    SEL OnCacheDestroy;
    SEL OnFound;
};

@interface RDVThread : NSObject
{
    dispatch_queue_t m_queue;
    struct RDVThreadBack m_back;
    id m_notifier;
}
-(bool)create:(id)notifier :(const struct RDVThreadBack*)disp;
-(void)destroy;
-(void)start_render:(RDVCache *)cache;
-(void)end_render:(RDVCache *)cache;
-(void)start_find:(RDVFinder *)finder;
-(void)end_page:(PDFPage *)page;

-(void)notify_render:(RDVCache *)cache;
-(void)notify_dealloc:(RDVCache *)cache;
-(void)notify_find:(RDVFinder *)finder;
@end
