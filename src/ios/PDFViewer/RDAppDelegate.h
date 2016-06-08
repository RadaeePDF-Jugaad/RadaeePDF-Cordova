//
//  RDAppDelegate.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 __Radaee__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDFileCollectionViewController.h"
#import "MoreViewController.h"

@class RDFileTableController;
@interface RDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) RDFileCollectionViewController *viewController;

- (BOOL)isPortrait;
@end
