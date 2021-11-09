//
//  MenuAnnot.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuAnnot.h"
@implementation MenuAnnot

- (id)init:(CGPoint)point :(RDBlock)callback
{
    NSArray *items = @[
    @{NSLocalizedString(@"Ink", nil): [UIImage imageNamed:@"btn_annot_ink"]},
    @{NSLocalizedString(@"Line", nil): [UIImage imageNamed:@"btn_annot_line"]},
    @{NSLocalizedString(@"Note", nil): [UIImage imageNamed:@"btn_annot_note"]},
    @{NSLocalizedString(@"Rect", nil): [UIImage imageNamed:@"btn_annot_rect"]},
    @{NSLocalizedString(@"Ellipse", nil): [UIImage imageNamed:@"btn_annot_ellipse"]},
    @{NSLocalizedString(@"Stamp", nil): [UIImage imageNamed:@"btn_annot_stamp"]},
    @{NSLocalizedString(@"Editbox", nil): [UIImage imageNamed:@"btn_edit_box"]},
    @{NSLocalizedString(@"Polygon", nil): [UIImage imageNamed:@"btn_polygon"]},
    @{NSLocalizedString(@"Polyline", nil): [UIImage imageNamed:@"btn_polyline"]},
    ];
    
    return [super init:point :callback :items];
}

- (void)updateIcons:(UIImage *)iInk
{
    UIImage *img;
    if(img = iInk)
    {
        UIView *view = self.subviews[0];
        UIImageView *image = view.subviews[0];
        image.image = img;
    }
}

@end
