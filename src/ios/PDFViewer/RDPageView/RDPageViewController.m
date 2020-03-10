//
//  RDPageViewController.m
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import "RDPageViewController.h"

@interface RDPageViewController ()
{
    PDFDoc *doc;
}

@end

@implementation RDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    
    UIViewController *vc = [self viewControllerAtIndex:0];
    [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (int)PDFOpenAtPath:(NSString *)path withPwd:(NSString *)pwd
{
    doc = [[PDFDoc alloc] init];
    int err_code = [doc open:path :pwd];
    switch(err_code)
    {
        case err_ok:
            return 1;
            break;
        case err_password:
            return 2;
            break;
        default: return 0;
    }
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    ViewController *viewController = [[ViewController alloc] init];
    viewController.doc = doc;
    viewController.pageViewNo = index;
    return viewController;
}

#pragma mark - Page View Controller Data Source

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [doc pageCount];
}
 
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ViewController*) viewController).pageViewNo;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}
 
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ViewController*) viewController).pageViewNo;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == doc.pageCount) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
