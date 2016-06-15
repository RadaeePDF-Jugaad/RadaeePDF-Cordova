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
	pthread_t tid;
	void *m_para;
	struct _QUEUE_NODE
	{
		unsigned int id;
		void *para2;
	}queue_items[128];
    id m_para1s[128];
	int queue_cur;
	int queue_next;
	bool m_notified;
	PDFVLocker *queue_locker;
	PDFVEvent *queue_event;
    struct PDFVThreadBack m_back;
    id m_notifier;
    UIView *m_view;
}
-(bool)create:(id)notifier :(const struct PDFVThreadBack *)disp;
-(void)destroy;
-(void)start_render:(PDFVPage *)page;
-(void)end_render:(PDFVPage *)page;
-(void)start_find:(PDFVFinder *)finder;
-(void)start_thumb:(PDFVPage *)page;
-(void)end_thumb:(PDFVPage *)page;
-(id)get_msg:(unsigned int *) mid :(void **)para2;
-(void)notify_render:(PDFVCache *)cache;
-(void)notify_find:(PDFVFinder *)finder;
@end