//
//  MenuVMode.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuVMode.h"
@implementation MenuVMode

- (id)init:(CGPoint)point :(RDBlock)callback
{
    NSArray *items = @[
    @{@"Vertical": [UIImage imageNamed:@"btn_view_vert"]},
    @{@"Horizon": [UIImage imageNamed:@"btn_view_horz"]},
    @{@"Single Page": [UIImage imageNamed:@"btn_view_single"]},
    @{@"Dual Page": [UIImage imageNamed:@"btn_view_dual"]}
    ];
    
    return [super init:point :callback :items];
}

@end
