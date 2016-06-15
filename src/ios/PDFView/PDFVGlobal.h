#pragma once
#import <pthread.h>
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
extern int g_def_view;
extern float g_zoom_level;
extern PDF_RENDER_MODE renderQuality;

extern int g_MatchWholeWord;
extern int g_CaseSensitive;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;

extern float g_Ink_Width;
extern float g_rect_Width;
extern uint g_rect_color;
extern uint g_ink_color;
extern uint g_sel_color;
extern uint g_oval_color;
extern uint annotHighlightColor;
extern uint annotUnderlineColor;
extern uint annotStrikeoutColor;
extern uint annotSquigglyColor;

extern bool g_paging_enabled;
extern bool g_double_page_enabled;
