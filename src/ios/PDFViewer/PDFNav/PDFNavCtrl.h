//
//  PDFNavCtrl.h
//  RDPDFReader
//
//  Created by Radaee on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//
#import "PDFNavThumb.h"
#import <UIKit/UIKit.h>
@interface PDFNavCtrl : UIViewController
{
    __weak IBOutlet PDFNavThumb *mNav;
    __weak IBOutlet UISegmentedControl *mTab;
}
- (IBAction)OnUpdate:(id)sender;
@end

