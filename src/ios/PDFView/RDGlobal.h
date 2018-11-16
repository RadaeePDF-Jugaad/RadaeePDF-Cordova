//
//  RDGlobal.h
//  PDFViewer
//
//  Created by strong on 2018/3/4.
//

#import <Foundation/Foundation.h>

@interface RDGlobal : NSObject

extern int   g_PDF_ViewMode;

extern float g_swipe_speed;
extern float g_swipe_distance;
extern int   g_render_quality;
extern bool  g_DarkMode;
extern bool  g_CaseSensitive;
extern bool  g_MatchWholeWord;
extern bool  g_sel_right;
extern bool  g_ScreenAwake;
extern int   g_render_quality;
extern NSUserDefaults *userDefaults;

extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_ellipse_color;
extern uint g_oval_color;

extern NSString *text;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;

extern float g_Ink_Width;
extern float g_rect_Width;
extern float g_line_Width;
extern uint g_rect_color;
extern uint g_line_color;
extern uint g_ink_color;
extern uint g_sel_color;
extern uint g_oval_color;

@end
