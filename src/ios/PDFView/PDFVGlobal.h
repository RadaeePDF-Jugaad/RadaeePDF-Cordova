#pragma once
#import <pthread.h>
#import "PDFIOS.h"
#import "RDGlobal.h"

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
extern int g_def_view;
extern float g_zoom_level;
extern bool g_static_scale;
extern bool g_paging_enabled;
extern bool g_double_page_enabled;
extern bool g_curl_enabled;
extern bool g_cover_page_enabled;
extern bool g_fit_signature_to_field;
extern bool g_execute_annot_JS;
extern bool g_dark_mode;
extern bool g_annot_lock;
extern bool g_annot_readonly;
extern PDF_RENDER_MODE renderQuality;

extern uint annotHighlightColor;
extern uint annotUnderlineColor;
extern uint annotStrikeoutColor;
extern uint annotSquigglyColor;

extern NSString *g_author;
