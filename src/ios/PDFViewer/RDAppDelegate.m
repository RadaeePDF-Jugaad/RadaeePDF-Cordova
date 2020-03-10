//
//  RDAppDelegate.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 __Radaee__. All rights reserved.
//

#import "RDAppDelegate.h"
#import "PDFIOS.h"
#import "RDVGlobal.h"

@implementation RDAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navController;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"actBundleId"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Radaee" forKey:@"actCompany"];
    [[NSUserDefaults standardUserDefaults] setObject:@"radaee_com@yahoo.cn" forKey:@"actEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:@"89WG9I-HCL62K-H3CRUZ-WAJQ9H-FADG6Z-XEBCAO" forKey:@"actSerial"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"actActivationType"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [RDVGlobal Init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([self isPortrait]) {
        NSLog(@"portrait");
    }
    else
    {
        NSLog(@"landscape");
    }
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    NSMutableArray *localControllesArray = [[NSMutableArray alloc]initWithCapacity:4];
    RDFileTableController *ctl = [[RDFileTableController alloc] initWithNibName:@"RDFileTableController" bundle:nil];
     navController = [[UINavigationController alloc] initWithRootViewController:ctl];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [localControllesArray addObject:navController];
    
    BookMarkViewController *bmctl=[[BookMarkViewController alloc]initWithNibName:@"BookMarkViewController" bundle:nil];
    navController = [[UINavigationController alloc]initWithRootViewController:bmctl];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    NSString *title1 =[[NSString alloc]initWithFormat:NSLocalizedString(@"Marks", @"Localizable")];
    
    UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:title1 image:[UIImage imageNamed:@"manage_mark.png"] tag:1 ];
    bmctl.tabBarItem = item1;
    [localControllesArray addObject:navController];
    
    SettingViewController *settingCtl = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    navController = [[UINavigationController alloc]initWithRootViewController:settingCtl];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    NSString *title2 =[[NSString alloc]initWithFormat:NSLocalizedString(@"Setting", @"Localizable")];
    
    UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:title2 image:[UIImage imageNamed:@"view_settings_page.png"] tag:2 ];
    settingCtl.tabBarItem = item2;
    [localControllesArray addObject:navController];
    
    
    NSString *title4 =[[NSString alloc]initWithFormat:NSLocalizedString(@"More", @"Localizable")];
    // Do any additional setup after loading the view from its nib.
   
   
    
    MoreViewController *moreCtl = [[MoreViewController alloc]initWithNibName:@"MoreViewController" bundle:nil];
    navController = [[UINavigationController alloc]initWithRootViewController:moreCtl];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:title4 image:[UIImage imageNamed:@"view_about.png"] tag:3 ];
    moreCtl.tabBarItem = item3;
    [localControllesArray addObject:navController];
    
    tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers =localControllesArray;
    
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[RDFileTableController alloc] initWithNibName:@"RDFileTableController" bundle:nil];
    } else
    {
        self.viewController = [[RDFileTableController alloc] initWithNibName:@"RDFileTableController" bundle:nil];
    }
     */
    
    // Preloads keyboard so there's no lag on initial keyboard appearance.
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    
    [self customizeAppearance];
    
   self.window.rootViewController = self.tabBarController;
     [self.window makeKeyAndVisible];
    return YES;
}

- (void)customizeAppearance
{
    [[UINavigationBar appearance] setTintColor:[UIColor orangeColor]];
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    [[UIToolbar appearance] setTintColor:[UIColor orangeColor]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - Device orientation
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}
@end
