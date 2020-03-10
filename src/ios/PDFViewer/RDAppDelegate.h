//
//  RDAppDelegate.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 __Radaee__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDFileTableController.h"
#import "BookMarkViewController.h"
#import "SettingViewController.h"
#import "MoreViewController.h"
//#import "PDFVGlobal.h"

@interface RDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) RDFileTableController *viewController;
@property (strong, nonatomic) UITabBarController *tabBarController;

- (BOOL)isPortrait;
@end
