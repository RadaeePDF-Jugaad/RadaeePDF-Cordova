//
//  UINavigationController+autoRotate.m
//  PDFViewer
//
//  Created by Radaee on 13-3-5.
//
//

#import "UINavigationController+autoRotate.h"

@implementation UINavigationController (autoRotate)

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // You do not need this method if you are not supporting earlier iOS Versions
    //return [self.visibleViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
*/
- (BOOL)shouldAutorotate
{
        return [self.visibleViewController shouldAutorotate];
}
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

@end
