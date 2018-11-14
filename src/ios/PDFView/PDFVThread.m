//
//  PDFVThread.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVThread.h"

@implementation PDFVThread
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

-(bool)create:(id)notifier :(const struct PDFVThreadBack *) disp
{
    if(m_queue) return true;
    m_back = *disp;
    m_notifier = notifier;
    m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
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
    if(m_queue) m_queue = nil;
}
-(void)start_render:(PDFVPage *)page
{
    switch( [page RenderPrepare] )
    {
		case 1: break;
		case 2: [self end_render: page]; [self start_render: page]; break;
		default:
        {
            PDFVCache *cache = [page Cache];
            dispatch_async(m_queue, ^{
                [cache Render];
                [self notify_render:cache];
            });
        }
            break;
    }
}
-(void)end_render:(PDFVPage *)page;
{
    PDFVCache *cache = [page CancelRender];
    if(cache)
    {
        dispatch_async(m_queue, ^{
            [cache Clear];
        });
    }
}
-(void)start_thumb:(PDFVPage *)page
{
    if( [page ThumbPrepare] == 0 )
    {
        PDFVCache1 *thumb = [page Thumb];
        dispatch_async(m_queue, ^{
            [thumb Render];
            [self notify_render:nil];
        });
    }
}
-(void)end_thumb:(PDFVPage *)page
{
    PDFVCache1 *thumb = [page CancelThumb];
    if( thumb )
    {
        dispatch_async(m_queue, ^{
            [thumb Clear];
        });
    }
}
-(void)start_find:(PDFVFinder *)finder;
{
    dispatch_async(m_queue, ^{
        [finder find];
        [self notify_find:finder];
    });
}

@end
