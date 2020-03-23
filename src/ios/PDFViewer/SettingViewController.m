//
//  SettingViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-12-9.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import "SettingViewController.h"
#import "PDFIOS.h"
#import "RDVGlobal.h"

@implementation SettingViewController

@synthesize partitationTableView;
@synthesize partitationTableViewCell;
@synthesize dicData;
@synthesize arrayData;

NSUserDefaults *userDefaults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //[super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *title =[[NSString alloc]initWithFormat:NSLocalizedString(@"Setting", @"Localizable")];
    // Do any additional setup after loading the view from its nib.
    self.title =title;
    UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:@"view_settings_page.png"] tag:0];
    self.tabBarItem = item;
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    GLOBAL.g_case_sensitive = [[NSUserDefaults standardUserDefaults] boolForKey:@"CaseSensitive"];
    GLOBAL.g_match_whole_word = [[NSUserDefaults standardUserDefaults] boolForKey:@"MatchWholeWord"];
    //  g_DarkMode = [userDefaults boolForKey:@"DarkMode"];
    GLOBAL.g_sel_right=[[NSUserDefaults standardUserDefaults] boolForKey:@"SelectTextRight"];
    GLOBAL.g_screen_awake = [[NSUserDefaults standardUserDefaults] boolForKey:@"KeepScreenAwake"];
    GLOBAL.g_ink_color=(int)[[NSUserDefaults standardUserDefaults]  integerForKey:@"InkColor"];
    GLOBAL.g_rect_color = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RectColor"];
    GLOBAL.g_render_mode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"ViewMode"];
    GLOBAL.g_annot_highlight_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"HighlightColor"];
    GLOBAL.g_annot_strikeout_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"StrikeoutColor"];
    GLOBAL.g_annot_underline_clr = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UnderlineColor"];
    GLOBAL.g_render_quality = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RenderQuality"];
    
    self.partitationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,cwidth, cheight-110) style:UITableViewStyleGrouped];
    
    self.partitationTableView.delegate =self;
    self.partitationTableView.dataSource = self;
    
    self.partitationTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.partitationTableView];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"SettingList" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    self.dicData = dictionary;
    
    NSArray *array = [self.dicData allKeys];
    self.arrayData = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [button addTarget:self action:@selector(btnClicked:event:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.partitationTableView.frame = self.view.bounds;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrayData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *stringDataKey = [self.arrayData objectAtIndex:section];
    NSArray *arraySection = [self.dicData objectForKey:stringDataKey];
    return [arraySection count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *key =[self.arrayData objectAtIndex:section];
    
    NSArray *arraySection = [self.dicData objectForKey:key];
    
    static NSString *partitation=nil;
    partitation=[NSString stringWithFormat:@"partitation%ld%ld",(long)[indexPath section],(long)[indexPath row]];
    //   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:partitation];
    
    //  if(cell == nil)
    //  {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:partitation];
    
    //   }
    
    
    
    NSString *label =[arraySection objectAtIndex:row];
    NSString *text;
    if([[label substringToIndex:0] isEqualToString:@"%"])
    {
        text = [label substringFromIndex:2];
    }
    else text = label;
    cell.textLabel.text = text;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    if(indexPath.section==0 &&indexPath.row==0 )
    {
        UISwitch *switchView4 = [[UISwitch alloc]init];
        [switchView4 setOn:GLOBAL.g_case_sensitive];
        [switchView4 addTarget:self action:@selector(updateCaseSensitive:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView4;
    }
    if(indexPath.section==0 &&indexPath.row==1 )
    {
        UISwitch *switchView5 = [[UISwitch alloc]init];
        [switchView5 setOn:GLOBAL.g_match_whole_word];
        [switchView5 addTarget:self action:@selector(updateMatchWholeWord:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView5;
        
    }
    /*if(indexPath.section==1 &&indexPath.row==4)
     {
     UISwitch *switchView1 = [[UISwitch alloc]init];
     [switchView1 setOn:g_DarkMode];
     [switchView1 addTarget:self action:@selector(updateSwitchDarkMode:) forControlEvents:UIControlEventValueChanged];
     cell.accessoryView = switchView1;
     }*/
    
    if(indexPath.section==1 &&indexPath.row==5)
    {
        UISwitch *switchView2 = [[UISwitch alloc]init];
        [switchView2 setOn:GLOBAL.g_sel_right];
        [switchView2 addTarget:self action:@selector(updateSwitchSelRight:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView2;
    }
    if(indexPath.section==1 &&indexPath.row==6)
    {
        UISwitch *switchView3 = [[UISwitch alloc]init];
        [switchView3 setOn:GLOBAL.g_screen_awake];
        [switchView3 addTarget:self action:@selector(updateSwitchScreenAwake:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView3;
    }
    
    
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = [self.arrayData objectAtIndex:section];
    
    NSString *text;
    NSString *temp=[key substringToIndex:1];
    if([temp compare:@"%"] == NSOrderedSame)
    {
        text = [key substringFromIndex:2];
    }
    else text = key;
    
    return text;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow]animated:YES];
    if(indexPath.section==1 &&indexPath.row==0)
    {
        if( underlineColor == nil )
        {
            
            underlineColor = [[UnderLineViewController alloc] initWithNibName:@"UnderLineViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        underlineColor.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:underlineColor animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==1)
    {
        if( renderSet == nil )
        {
            
            renderSet = [[RenderSettingViewController alloc] initWithNibName:@"RenderSettingViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        renderSet.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:renderSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==4)
    {
        if( highlightColor == nil )
        {
            
            highlightColor = [[HighlightColorViewController alloc] initWithNibName:@"HighlightColorViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        highlightColor.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:highlightColor animated:YES];
    }
    
    if(indexPath.section==1 &&indexPath.row==2)
    {
        if( strikeColorSet == nil )
        {
            
            strikeColorSet = [[StrikeoutViewController alloc] initWithNibName:@"StrikeoutViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        strikeColorSet.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:strikeColorSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==8)
    {
        if( lineWidthSet == nil )
        {
            
            lineWidthSet = [[LineMarkViewController alloc] initWithNibName:@"LineMarkViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        lineWidthSet.hidesBottomBarWhenPushed = YES;
        
        [nav pushViewController:lineWidthSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==3)
    {
        if( viewModeSet == nil )
        {
            
            viewModeSet = [[ViewModeViewController alloc] initWithNibName:@"ViewModeViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        viewModeSet.hidesBottomBarWhenPushed = YES;
        
        [nav pushViewController:viewModeSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==7)
    {
        if( inkColorSet == nil )
        {
            
            inkColorSet = [[InkColorViewController alloc] initWithNibName:@"InkColorViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        inkColorSet.hidesBottomBarWhenPushed = YES;
        
        [nav pushViewController:inkColorSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==9)
    {
        if( rectColorSet == nil )
        {
            
            rectColorSet = [[RectColorViewController alloc] initWithNibName:@"RectColorViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        rectColorSet.hidesBottomBarWhenPushed = YES;
        
        [nav pushViewController:rectColorSet animated:YES];
    }
    if(indexPath.section==1 &&indexPath.row==10)
    {
        if( ovalColor == nil )
        {
            
            ovalColor = [[OvalColorViewController alloc] initWithNibName:@"OvalColorViewController" bundle:nil];
        }
        UINavigationController *nav = self.navigationController;
        ovalColor.hidesBottomBarWhenPushed = YES;
        
        [nav pushViewController:ovalColor animated:YES];
    }
    if(indexPath.section ==1 && indexPath.row == 11)
    {
        NSString *str1=NSLocalizedString(@"Alert", @"Localizable");
        NSString *str2=NSLocalizedString(@"Click OK to reset all properties to default", @"Localizable");
        NSString *str3=NSLocalizedString(@"OK", @"Localizable");
        NSString *str4=NSLocalizedString(@"Cancel", @"Localizable");
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:str1
                                   message:str2
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:str3 style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str4 style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%i",buttonIndex);
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"CaseSensitive"];
        GLOBAL.g_case_sensitive = FALSE;
        
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"MatchWholeWord"];
        GLOBAL.g_match_whole_word = FALSE;
        
        [[NSUserDefaults standardUserDefaults] setFloat:0.1f forKey:@"SwipeSpeed"];
        GLOBAL.g_swipe_speed = 0.15f;
        //PDFVS_setSwipeSpeed(g_swipe_speed);
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"RenderQuality"];
        GLOBAL.g_render_quality =1;
        //PDFVS_renderQuality(g_render_quality);
        
        
        GLOBAL.g_swipe_distance = 1.0f;
        [[NSUserDefaults standardUserDefaults] setFloat:GLOBAL.g_swipe_distance forKey:@"SwipeDistance"];
        //PDFVS_setSwipeDis(g_swipe_distance);
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ViewMode"];
        GLOBAL.g_render_mode = 0;
        
        [[NSUserDefaults standardUserDefaults]  setBool:FALSE forKey:@"DarkMode"];
        GLOBAL.g_dark_mode = FALSE;
        // PDFVS_setDarkMode(g_DarkMode);
        
        [[NSUserDefaults standardUserDefaults]  setBool:FALSE forKey:@"SelectTextRight"];
        GLOBAL.g_sel_right = FALSE;
        // PDFVS_textRtol(g_sel_right);
        
        [[NSUserDefaults standardUserDefaults]  setBool:FALSE forKey:@"KeepScreenAwake"];
        GLOBAL.g_screen_awake = FALSE;
        [[UIApplication sharedApplication] setIdleTimerDisabled:GLOBAL.g_screen_awake];
        
        [[NSUserDefaults standardUserDefaults]  setInteger:0xFF000000 forKey:@"InkColor"];
        GLOBAL.g_ink_color = 0xFF000000;
        [[NSUserDefaults standardUserDefaults]  setInteger:0xFF000000 forKey:@"RectColor"];
        GLOBAL.g_rect_color = 0xFF000000;
        GLOBAL.g_ink_width = 2.0f;
        [[NSUserDefaults standardUserDefaults] setFloat:GLOBAL.g_ink_width forKey:@"InkWidth"];
        
        // [userDefaults  setInteger:1 forKey:@"RectColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[self.view setNeedsDisplay];
        [self.partitationTableView reloadData];
    }
}
*/

- (void)btnClicked:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:self.partitationTableView];
    
    NSIndexPath *indexPath = [self.partitationTableView indexPathForRowAtPoint:currentTouchPosition];
    
    if(indexPath != nil)
        
    {
        
        [self tableView:self.partitationTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    /*
     if( settingSpeedView == nil )
     {
     //m_pdf = [[RDPDFViewController alloc] init];
     settingSpeedView = [[SettingSpeedViewController alloc] initWithNibName:@"SettingSpeedViewController" bundle:nil];
     }
     UINavigationController *nav = self.navigationController;
     settingSpeedView.hidesBottomBarWhenPushed = YES;
     [nav pushViewController:settingSpeedView animated:YES];
     */
    
    /*
     UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
     UISwitch *switch1 = (UISwitch *) [cell viewWithTag:@"Night mode"] ;
     if(indexPath.section ==1 && indexPath.row == 4)
     {
     bool b= switch1.isOn;
     PDFVS_setDarkMode(b);
     }
     */
    
}
- (IBAction)updateSwitchDarkMode:(id)sender
{
    UISwitch *switchView = (UISwitch *)sender;
    
    if ([switchView isOn])
    {
        GLOBAL.g_dark_mode = true;
    }
    else
    {
        GLOBAL.g_dark_mode =false;
    }
    //PDFVS_setDarkMode(g_DarkMode);
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_dark_mode forKey:@"DarkMode"];
    //GEAR
    [self saveSettings];
    //END
}

-(IBAction)updateSwitchSelRight:(id)sender
{
    UISwitch *switchView = (UISwitch *)sender;
    
    if ([switchView isOn])
    {
        
        GLOBAL.g_sel_right = true;
    }
    else
    {
        GLOBAL.g_sel_right =false;
        
    }
    //PDFVS_textRtol(g_sel_right);
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_sel_right forKey:@"SelectTextRight"];
    //GEAR
    [self saveSettings];
    //END
    
}
-(IBAction)updateSwitchScreenAwake:(id)sender
{
    UISwitch *switchView = (UISwitch *)sender;
    GLOBAL.g_screen_awake = [switchView isOn];
    [[UIApplication sharedApplication] setIdleTimerDisabled:GLOBAL.g_screen_awake];
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_screen_awake forKey:@"KeepScreenAwake"];
    //GEAR
    [self saveSettings];
    //END
}
- (IBAction) updateCaseSensitive:(id) sender
{
    UISwitch *switchView = (UISwitch *)sender;
    GLOBAL.g_case_sensitive = [switchView isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_case_sensitive forKey:@"CaseSensitive"];
    //GEAR
    [self saveSettings];
    //END
}
- (IBAction) updateMatchWholeWord:(id) sender
{
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn])
    {
        
        GLOBAL.g_match_whole_word = true;
    }
    else
    {
        GLOBAL.g_match_whole_word =false;
        
    }
    [[NSUserDefaults standardUserDefaults] setBool:GLOBAL.g_match_whole_word forKey:@"MatchWholeWord"];
    //GEAR
    [self saveSettings];
    //END
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

//GEAR
- (void)saveSettings
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)performWillRotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect rect =[[UIScreen mainScreen]bounds];
    if ([self isPortrait])
    {
        if (rect.size.height < rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    else
    {
        if (rect.size.height > rect.size.width) {
            
            float height = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width = height;
        }
    }
    
    [self.view setFrame:rect];
    [self.view sizeThatFits:rect.size];
    
}

@end
