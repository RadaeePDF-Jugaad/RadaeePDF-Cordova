//
//  RDGlobal.h
//  PDFViewer
//
//  Created by strong on 2018/3/4.
//

#import <Foundation/Foundation.h>

#define GLOBAL [RDGlobal sharedInstance]

@interface RDGlobal : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSMutableString *pdfName;
@property (strong, nonatomic) NSMutableString *pdfPath;
@property (strong, nonatomic) NSString *g_author;

@property (nonatomic) int g_render_quality;
@property (nonatomic) uint g_rect_color;
@property (nonatomic) uint g_line_color;
@property (nonatomic) uint g_ink_color;
@property (nonatomic) uint g_sel_color;
@property (nonatomic) uint g_oval_color;

@property (nonatomic) bool g_DarkMode;
@property (nonatomic) bool  g_CaseSensitive;
@property (nonatomic) bool g_MatchWholeWord;
@property (nonatomic) bool g_sel_right;
@property (nonatomic) bool g_ScreenAwake;

@property (nonatomic) float g_Ink_Width;
@property (nonatomic) float g_rect_Width;
@property (nonatomic) float g_line_Width;
@property (nonatomic) float g_swipe_speed;
@property (nonatomic) float g_swipe_distance;

@property (nonatomic) int g_def_view;
@property (nonatomic) float g_zoom_level;
@property (nonatomic) bool g_static_scale;
@property (nonatomic) bool g_paging_enabled;
@property (nonatomic) bool g_double_page_enabled;
@property (nonatomic) bool g_curl_enabled;
@property (nonatomic) bool g_cover_page_enabled;
@property (nonatomic) bool g_fit_signature_to_field;
@property (nonatomic) bool g_execute_annot_JS;
@property (nonatomic) bool g_dark_mode;
@property (nonatomic) bool g_annot_lock;
@property (nonatomic) bool g_annot_readonly;
@property (nonatomic) bool g_auto_launch_link;
@property (nonatomic) int renderQuality;

@property (nonatomic) uint annotHighlightColor;
@property (nonatomic) uint annotUnderlineColor;
@property (nonatomic) uint annotStrikeoutColor;
@property (nonatomic) uint annotSquigglyColor;

+ (RDGlobal *)sharedInstance;
- (void)setup;

@end
