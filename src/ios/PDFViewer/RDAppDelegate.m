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
    [[UIBarButtonItem appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UIButton appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UIButton appearance] setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [[UIImageView appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UITableViewCell appearance] setTintColor:[RDUtils radaeeIconColor]];
    
    
    g_id = [[NSBundle mainBundle] bundleIdentifier];
    g_company = @"radaee";
    g_mail = @"radaeepdf@gmail.com";
    g_serial = @"OBT5ZN-9SJHWQ-9ZOU9E-OQ31K2-5R5V9L-KM0Y1L";
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
    self.window.backgroundColor = [RDUtils radaeeWhiteColor];
    NSMutableArray *localControllesArray = [[NSMutableArray alloc]initWithCapacity:4];
    RDFileCollectionViewController *ctl = [[RDFileCollectionViewController alloc] initWithNibName:@"RDFileCollectionViewController" bundle:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:ctl];
    [localControllesArray addObject:navController];
    
    NSString *title4 =[[NSString alloc]initWithFormat:NSLocalizedString(@"More", @"Localizable")];
    // Do any additional setup after loading the view from its nib.
    MoreViewController *moreCtl = [[MoreViewController alloc]initWithNibName:@"MoreViewController" bundle:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:moreCtl];
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:title4 image:[UIImage imageNamed:@"btn_info"] tag:3 ];
    moreCtl.tabBarItem = item3;
    [localControllesArray addObject:navController];
    
    tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers =localControllesArray;
    
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
    [[UINavigationBar appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UITabBar appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UIToolbar appearance] setTintColor:[RDUtils radaeeIconColor]];
    [[UISwitch appearance] setTintColor:[RDUtils radaeeIconColor]];
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
