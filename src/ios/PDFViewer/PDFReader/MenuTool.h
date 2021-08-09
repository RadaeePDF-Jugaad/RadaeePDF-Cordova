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
@interface MenuTool : RDMenu

- (id)init:(CGPoint)point :(RDBlock)callback;
- (void)updateIcons:(UIImage *)iUndo :(UIImage *)iRedo :(UIImage *)iSel;
- (void)updateVisible:(BOOL)hideUndo :(BOOL)hideRedo :(BOOL)hideSel;

@end
