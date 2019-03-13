#pragma once
#import <pthread.h>
#import "RDGlobal.h"
#import "PDFIOS.h"

@interface PDFVLocker :NSObject
{
    pthread_mutex_t mutex;
}
-(void)lock;
-(void)unlock;
@end

@interface PDFVEvent :NSObject
{
    unsigned int flags;
    pthread_cond_t m_event;
    pthread_mutex_t mutex;
}
-(void)reset;
-(void)notify;
-(void)wait;
@end

void APP_Init();
