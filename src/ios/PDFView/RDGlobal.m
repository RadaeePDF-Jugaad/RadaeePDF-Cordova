//
//  RDGlobal.m
//  PDFViewer
//
//  Created by strong on 2018/3/4.
//

#import "RDGlobal.h"
#import "PDFIOS.h"

@implementation RDGlobal

+ (RDGlobal *)sharedInstance
{
    static RDGlobal *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RDGlobal alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)setup {
    _renderQuality = mode_normal;
    
    _g_def_view = 0;
    _g_zoom_level = 5;
    _g_Ink_Width = 2;
    _g_rect_Width = 2;
    _g_line_Width = 2;
    _g_swipe_speed = 0.15f;
    _g_swipe_distance= 1.0f;
    _g_render_quality = 1;
    
    _g_rect_color = 0xFFFF0000;
    _g_line_color = 0xFFFF0000;
    _g_ink_color = 0xFFFF0000;
    _g_sel_color = 0x400000C0;
    _g_oval_color = 0xFF0000FF;
    _annotHighlightColor = 0xFFFFFF00;
    _annotUnderlineColor = 0xFF0000FF;
    _annotStrikeoutColor = 0xFFFF0000;
    _annotSquigglyColor = 0xFF00FF00;
    
    _g_static_scale = false;
    _g_paging_enabled = false;
    _g_double_page_enabled = false;
    _g_curl_enabled = false;
    _g_cover_page_enabled = false;
    _g_fit_signature_to_field = true;
    _g_execute_annot_JS = true;
    _g_dark_mode = false;
    _g_annot_lock = true;
    _g_annot_readonly = true;
    _g_paging_enabled = false;
    _g_double_page_enabled = true;
    _g_curl_enabled = false;
    _g_cover_page_enabled = false;
    _g_CaseSensitive = false;
    _g_MatchWholeWord = false;
    _g_DarkMode =false;
    _g_sel_right=false;
    _g_ScreenAwake = false;
    _g_auto_launch_link = true;
    
    _g_author = @"";
}

@end
