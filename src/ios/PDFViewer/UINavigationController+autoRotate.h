//
//  UINavigationController+autoRotate.h
//  PDFViewer
//
//  Created by Radaee on 13-3-5.
//
//

#import <UIKit/UIKit.h>

@interface UINavigationController (autoRotate)

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;
- (BOOL)isPortrait;

@end
