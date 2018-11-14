//
//  RDGlobal.m
//  PDFViewer
//
//  Created by strong on 2018/3/4.
//

#import "RDGlobal.h"

@implementation RDGlobal

NSString *text;
NSMutableString *pdfName;
NSMutableString *pdfPath;

int g_PDF_ViewMode;
float g_swipe_speed;
float g_swipe_distance;
int g_render_quality;
bool g_DarkMode;
bool  g_CaseSensitive;
bool g_MatchWholeWord;
bool g_sel_right;
bool g_ScreenAwake;
int g_render_quality;
NSUserDefaults *userDefaults;

float g_Ink_Width = 2;
float g_rect_Width = 2;
float g_line_Width = 2;
uint g_rect_color = 0xFFFF0000;
uint g_line_color = 0xFFFF0000;
uint g_ink_color = 0xFFFF0000;
uint g_sel_color = 0x400000C0;
uint g_oval_color = 0xFF0000FF;

@end
