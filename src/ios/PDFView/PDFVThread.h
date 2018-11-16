#pragma once
#include <pthread.h>
#include "PDFVGlobal.h"
#include "PDFVPage.h"
#include "PDFVFinder.h"

struct PDFVThreadBack
{
    SEL OnPageRendered;
    SEL OnFound;
};

@interface PDFVThread : NSObject
{
    dispatch_queue_t m_queue;
    struct PDFVThreadBack m_back;
    id m_notifier;
}
-(bool)create:(id)notifier :(const struct PDFVThreadBack *)disp;
-(void)destroy;
-(void)start_render:(PDFVPage *)page;
-(void)end_render:(PDFVPage *)page;
-(void)start_find:(PDFVFinder *)finder;
-(void)start_thumb:(PDFVPage *)page;
-(void)end_thumb:(PDFVPage *)page;
-(void)notify_render:(PDFVCache *)cache;
-(void)notify_find:(PDFVFinder *)finder;
@end
