//
//
//  PDFVGlobal.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVGlobal.h"

@implementation PDFVLocker
-(id)init
{
    if( self = [super init] )
    {
        pthread_mutex_init( &mutex, NULL );
    }
    return self;
}
-(void)dealloc
{
    pthread_mutex_destroy( &mutex );
}
-(void)lock
{
    pthread_mutex_lock( &mutex );
}
-(void)unlock
{
    pthread_mutex_unlock( &mutex );
}
@end

@implementation PDFVEvent
-(id)init
{
    if( self = [super init] )
    {
        pthread_cond_init( &m_event, NULL );
        pthread_mutex_init( &mutex, NULL );
        flags = 0;
    }
    return self;
}
-(void)dealloc
{
    pthread_cond_destroy( &m_event );
    pthread_mutex_destroy( &mutex );
}
-(void)reset
{
    pthread_mutex_lock( &mutex );
    flags = 0;
    pthread_mutex_unlock( &mutex );
}
-(void)notify
{
    pthread_mutex_lock( &mutex );
    if( flags & 2 )
        pthread_cond_signal( &m_event );
    else
        flags |= 1;
    pthread_mutex_unlock( &mutex );
}
-(void)wait
{
    pthread_mutex_lock( &mutex );
    if( !(flags & 1) )
    {
        flags |= 2;
        pthread_cond_wait( &m_event, &mutex );
        flags &= (~2);
    }
    else
        flags &= (~1);
    pthread_mutex_unlock( &mutex );
}
@end

int g_def_view = 0;
float g_zoom_level = 5;
bool g_static_scale = false;
bool g_paging_enabled = false;
bool g_double_page_enabled = false;
bool g_curl_enabled = false;
bool g_cover_page_enabled = false;
bool g_fit_signature_to_field = true;
bool g_execute_annot_JS = true;
bool g_dark_mode = false;
bool g_annot_lock = false;
bool g_annot_readonly = false;
PDF_RENDER_MODE renderQuality = mode_normal;

uint annotHighlightColor = 0xFFFFFF00;
uint annotUnderlineColor = 0xFF0000FF;
uint annotStrikeoutColor = 0xFFFF0000;
uint annotSquigglyColor = 0xFF00FF00;

NSString *g_author = @"";

void APP_Init()
{
    BOOL isActive = NO;
    int licenseType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"actActivationType"] intValue];
    NSLog(@"LICENSE: %i", licenseType);
    NSLog(@"COMPANY: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"]);
    NSLog(@"EMAIL: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"]);
    NSLog(@"KEY: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"]);
    NSLog(@"BUNDLE: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"]);
    
    switch (licenseType) {
        case 0:
        {
            NSLog(@"standard");
            isActive = Global_activeStandard([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        case 1:
        {
            NSLog(@"professional");
            isActive = Global_activeProfession([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        case 2:
        {
            NSLog(@"premium");
            isActive = Global_activePremium([[[NSUserDefaults standardUserDefaults] objectForKey:@"actBundleId"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actCompany"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actEmail"] UTF8String], [[[NSUserDefaults standardUserDefaults] objectForKey:@"actSerial"] UTF8String]);
            break;
        }
        default:
        {
            NSLog(@"default");
            isActive = NO;
            break;
        }
    }
    
    if (isActive)
        NSLog(@"License active");
    else
        NSLog(@"License not active");
    
    [[NSUserDefaults standardUserDefaults] setBool:isActive forKey:@"actIsActive"];
    
    NSString *cmaps_path = [[NSBundle mainBundle] pathForResource:@"cmaps" ofType:@"dat"];
    NSString *umaps_path = [[NSBundle mainBundle] pathForResource:@"umaps" ofType:@"dat"];
    NSString *cmyk_path = [[NSBundle mainBundle] pathForResource:@"cmyk_rgb" ofType:@"dat"];
    
    // check resources
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: cmaps.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: umaps.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmaps_path]) {
        NSLog(@"Check resources files: cmyk_rgb.dat not found.");
        NSLog(@"Include fdat and cmaps folders as resources (like demo project)");
        return;
    }
    
    Global_setCMapsPath([cmaps_path UTF8String], [umaps_path UTF8String]);
    Global_setCMYKProfile([cmyk_path UTF8String]);
    
    // Add Standard Resources
    NSString *fpath;
    fpath = [[NSBundle mainBundle] pathForResource:@"00" ofType:nil];
    Global_loadStdFont( 0, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"01" ofType:nil];
    Global_loadStdFont( 1, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"02" ofType:nil];
    Global_loadStdFont( 2, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"03" ofType:nil];
    Global_loadStdFont( 3, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"04" ofType:nil];
    Global_loadStdFont( 4, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"05" ofType:nil];
    Global_loadStdFont( 5, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"06" ofType:nil];
    Global_loadStdFont( 6, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"07" ofType:nil];
    Global_loadStdFont( 7, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"08" ofType:nil];
    Global_loadStdFont( 8, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"09" ofType:nil];
    Global_loadStdFont( 9, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"10" ofType:nil];
    Global_loadStdFont( 10, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"11" ofType:nil];
    Global_loadStdFont( 11, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"12" ofType:nil];
    Global_loadStdFont( 12, [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"13" ofType:nil];
    Global_loadStdFont( 13, [fpath UTF8String] );
    
    // Add Standard Fonts
    Global_fontfileListStart();
    fpath = [[NSBundle mainBundle] pathForResource:@"argbsn00lp.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"arimo.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"arimob.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"arimobi.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"arimoi.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"cousine.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"cousineb.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"cousinebi.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"cousinei.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"rdf008.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"rdf013.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"tinos.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"tinosb.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"tinosbi.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    fpath = [[NSBundle mainBundle] pathForResource:@"tinosi.ttf" ofType:nil];
    Global_fontfileListAdd( [fpath UTF8String] );
    
    
    Global_fontfileListEnd();
    
    Global_fontfileMapping("Arial",                    "Arimo");
    Global_fontfileMapping("Arial Bold",              "Arimo Bold");
    Global_fontfileMapping("Arial BoldItalic",       "Arimo Bold Italic");
    Global_fontfileMapping("Arial Italic",            "Arimo Italic");
    Global_fontfileMapping("Arial,Bold",              "Arimo Bold");
    Global_fontfileMapping("Arial,BoldItalic",       "Arimo Bold Italic");
    Global_fontfileMapping("Arial,Italic",            "Arimo Italic");
    Global_fontfileMapping("Arial-Bold",              "Arimo Bold");
    Global_fontfileMapping("Arial-BoldItalic",       "Arimo Bold Italic");
    Global_fontfileMapping("Arial-Italic",            "Arimo Italic");
    Global_fontfileMapping("ArialMT",                  "Arimo");
    Global_fontfileMapping("Calibri",                  "Arimo");
    Global_fontfileMapping("Calibri Bold",            "Arimo Bold");
    Global_fontfileMapping("Calibri BoldItalic",      "Arimo Bold Italic");
    Global_fontfileMapping("Calibri Italic",           "Arimo Italic");
    Global_fontfileMapping("Calibri,Bold",             "Arimo Bold");
    Global_fontfileMapping("Calibri,BoldItalic",      "Arimo Bold Italic");
    Global_fontfileMapping("Calibri,Italic",           "Arimo Italic");
    Global_fontfileMapping("Calibri-Bold",             "Arimo Bold");
    Global_fontfileMapping("Calibri-BoldItalic",      "Arimo Bold Italic");
    Global_fontfileMapping("Calibri-Italic",           "Arimo Italic");
    Global_fontfileMapping("Helvetica",                "Arimo");
    Global_fontfileMapping("Helvetica Bold",          "Arimo Bold");
    Global_fontfileMapping("Helvetica BoldItalic",   "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica Italic",        "Arimo Italic");
    Global_fontfileMapping("Helvetica,Bold",          "Arimo,Bold");
    Global_fontfileMapping("Helvetica,BoldItalic",   "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica,Italic",        "Arimo Italic");
    Global_fontfileMapping("Helvetica-Bold",          "Arimo Bold");
    Global_fontfileMapping("Helvetica-BoldItalic",   "Arimo Bold Italic");
    Global_fontfileMapping("Helvetica-Italic",        "Arimo Italic");
    Global_fontfileMapping("Garamond",                    "Tinos");
    Global_fontfileMapping("Garamond,Bold",              "Tinos Bold");
    Global_fontfileMapping("Garamond,BoldItalic",       "Tinos Bold Italic");
    Global_fontfileMapping("Garamond,Italic",            "Tinos Italic");
    Global_fontfileMapping("Garamond-Bold",              "Tinos Bold");
    Global_fontfileMapping("Garamond-BoldItalic",       "Tinos Bold Italic");
    Global_fontfileMapping("Garamond-Italic",            "Tinos Italic");
    Global_fontfileMapping("Times",                    "Tinos");
    Global_fontfileMapping("Times,Bold",              "Tinos Bold");
    Global_fontfileMapping("Times,BoldItalic",       "Tinos Bold Italic");
    Global_fontfileMapping("Times,Italic",            "Tinos Italic");
    Global_fontfileMapping("Times-Bold",              "Tinos Bold");
    Global_fontfileMapping("Times-BoldItalic",       "Tinos Bold Italic");
    Global_fontfileMapping("Times-Italic",            "Tinos Italic");
    Global_fontfileMapping("Times-Roman",             "Tinos");
    Global_fontfileMapping("Times New Roman",                "Tinos");
    Global_fontfileMapping("Times New Roman,Bold",          "Tinos Bold");
    Global_fontfileMapping("Times New Roman,BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("Times New Roman,Italic",        "Tinos Italic");
    Global_fontfileMapping("Times New Roman-Bold",          "Tinos Bold");
    Global_fontfileMapping("Times New Roman-BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("Times New Roman-Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRoman",                "Tinos");
    Global_fontfileMapping("TimesNewRoman,Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRoman,BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRoman,Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRoman-Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRoman-BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRoman-Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRomanPS",                "Tinos");
    Global_fontfileMapping("TimesNewRomanPS,Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRomanPS,BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRomanPS,Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRomanPS-Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRomanPS-BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRomanPS-Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRomanPSMT",                "Tinos");
    Global_fontfileMapping("TimesNewRomanPSMT,Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRomanPSMT,BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRomanPSMT,Italic",        "Tinos Italic");
    Global_fontfileMapping("TimesNewRomanPSMT-Bold",          "Tinos Bold");
    Global_fontfileMapping("TimesNewRomanPSMT-BoldItalic",   "Tinos Bold Italic");
    Global_fontfileMapping("TimesNewRomanPSMT-Italic",        "Tinos Italic");
    Global_fontfileMapping("Courier",                    "Cousine");
    Global_fontfileMapping("Courier Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier Italic",            "Cousine Italic");
    Global_fontfileMapping("Courier,Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier,BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier,Italic",            "Cousine Italic");
    Global_fontfileMapping("Courier-Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier-BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier-Italic",            "Cousine Italic");
    Global_fontfileMapping("Courier New",                    "Cousine");
    Global_fontfileMapping("Courier New Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier New BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New Italic",            "Cousine Italic");
    Global_fontfileMapping("Courier New,Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier New,BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New,Italic",            "Cousine Italic");
    Global_fontfileMapping("Courier New-Bold",              "Cousine Bold");
    Global_fontfileMapping("Courier New-BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("Courier New-Italic",            "Cousine Italic");
    Global_fontfileMapping("CourierNew",                    "Cousine");
    Global_fontfileMapping("CourierNew Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew Italic",            "Cousine Italic");
    Global_fontfileMapping("CourierNew,Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew,BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew,Italic",            "Cousine Italic");
    Global_fontfileMapping("CourierNew-Bold",              "Cousine Bold");
    Global_fontfileMapping("CourierNew-BoldItalic",       "Cousine Bold Italic");
    Global_fontfileMapping("CourierNew-Italic",            "Cousine Italic");
    
    bool ret;
    ret = Global_setDefaultFont(NULL, "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont(NULL, "BousungEG-Light-GB", true);
    ret = Global_setDefaultFont("GB1", "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont("GB1", "BousungEG-Light-GB", true);
    ret = Global_setDefaultFont("CNS1", "BousungEG-Light-GB", false);
    ret = Global_setDefaultFont("CNS1", "BousungEG-Light-GB", true);
    //radaee don't know which font should used in Japan or Korea, so use "BousungEG"
    //developers may need modify codes below:
    Global_setDefaultFont("Japan1", "BousungEG-Light-GB", false);
    Global_setDefaultFont("Japan1", "BousungEG-Light-GB", true);
    Global_setDefaultFont("Korea1", "BousungEG-Light-GB", false);
    Global_setDefaultFont("Korea1", "BousungEG-Light-GB", true);
    Global_setAnnotFont( "Arimo" );//Global_setAnnotFont( "BousungEG-Light-GB" );
    
    
	Global_setAnnotTransparency(0x200040FF);
	g_def_view = 0;
	renderQuality = mode_normal;
	g_zoom_level = 5;
    g_paging_enabled = false;
    g_double_page_enabled = true;
    g_curl_enabled = false;
    g_cover_page_enabled = false;
    
    g_Ink_Width = 2;
    g_rect_Width = 2;
    g_line_Width = 2;
    g_rect_color = 0xFFFF0000;
    g_line_color = 0xFFFF0000;
    g_ink_color = 0xFFFF0000;
    g_sel_color = 0x400000C0;
    g_oval_color = 0xFF0000FF;
}
