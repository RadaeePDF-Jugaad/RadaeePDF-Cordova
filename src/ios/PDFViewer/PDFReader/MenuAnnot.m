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
    @{@"Ink": [UIImage imageNamed:@"btn_annot_ink"]},
    @{@"Line": [UIImage imageNamed:@"btn_annot_line"]},
    @{@"Note": [UIImage imageNamed:@"btn_annot_note"]},
    @{@"Rectangle": [UIImage imageNamed:@"btn_annot_rect"]},
    @{@"Ellipse": [UIImage imageNamed:@"btn_annot_ellipse"]},
    @{@"Stamp": [UIImage imageNamed:@"btn_annot_stamp"]},
    @{@"Editbox": [UIImage imageNamed:@"btn_edit_box"]},
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
