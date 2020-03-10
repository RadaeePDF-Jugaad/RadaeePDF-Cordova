//
//  RDPageViewController.h
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RDPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (int)PDFOpenAtPath:(NSString *)path withPwd:(NSString *)pwd;

@end

NS_ASSUME_NONNULL_END
