//
//  MenuTool.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "RDMenu.h"
@interface MenuSearch : RDMenu

@property (strong, nonatomic) UISwitch *caseSwitch;
@property (strong, nonatomic) UISwitch *wholeSwitch;
- (id)init:(CGPoint)point :(RDBlock)callback;

@end
