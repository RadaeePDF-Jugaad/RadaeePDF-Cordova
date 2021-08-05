//
//  MenuTool.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuTool.h"
#import "RDVGlobal.h"
@implementation MenuTool

- (id)init:(CGPoint)point :(RDBlock)callback
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:
    @{@"Undo": [UIImage imageNamed:@"btn_undo"]},
    @{@"Redo": [UIImage imageNamed:@"btn_redo"]},
    @{@"Selection": [UIImage imageNamed:@"btn_select"]},
    @{@"Meta": [UIImage imageNamed:@"btn_meta"]},
    @{@"Outlines": [UIImage imageNamed:@"btn_outline"]},
    @{@"Slider": [UIImage imageNamed:@"btn_slider"]},
    @{@"Night mode": [UIImage imageNamed:@"btn_night_mode"]},
    @{@"Manage pages": [UIImage imageNamed:@"btn_manage_page"]},
                             nil];
    
    if (!GLOBAL.g_navigation_mode) {
        items[5] = @{@"Thumbnail": [UIImage imageNamed:@"btn_thumb"]};
    }
    if (GLOBAL.g_dark_mode) {
        items[6] = @{@"Light mode": [UIImage imageNamed:@"btn_light_mode"]};
    }
    
    return [super init:point :callback :items];
}

- (void)updateIcons:(UIImage *)iUndo :(UIImage *)iRedo :(UIImage *)iSel
{
    UIImage *icon;
    if(icon = iUndo)//undo
    {
        UIView *view = self.subviews[0];
        UIImageView *img = view.subviews[0];
        img.image = icon;
    }
    if(icon = iRedo)//redo
    {
        UIView *view = self.subviews[1];
        UIImageView *img = view.subviews[0];
        img.image = icon;
    }
    if(icon = iSel)//select
    {
        UIView *view = self.subviews[2];
        UIImageView *img = view.subviews[0];
        img.image = icon;
    }
}

- (void)updateVisible:(BOOL)hideUndo :(BOOL)hideRedo :(BOOL)hideSel
{
    int hcnt = 0;
    UIView *view = self.subviews[0];
    view.hidden = hideUndo;
    if (hideUndo) {
        hcnt++;
        for (int c = 1; c != self.subviews.count; c++) {
            CGRect rect = [(UIView *)[self.subviews objectAtIndex:c] frame];
            rect.origin.y -= rd_menu_height;
            [(UIView *)[self.subviews objectAtIndex:c] setFrame:rect];
        }
    }
    
    view = self.subviews[1];
    view.hidden = hideRedo;
    
    if (hideRedo) {
        hcnt++;
        for (int c = 2; c != self.subviews.count; c++) {
            CGRect rect = [(UIView *)[self.subviews objectAtIndex:c] frame];
            rect.origin.y -= rd_menu_height;
            [(UIView *)[self.subviews objectAtIndex:c] setFrame:rect];
        }
    }

    view = self.subviews[2];
    view.hidden = hideSel;
    if (hideSel) {
            hcnt++;
        for (int c = 3; c != self.subviews.count; c++) {
            CGRect rect = [(UIView *)[self.subviews objectAtIndex:c] frame];
            rect.origin.y -= rd_menu_height;
            [(UIView *)[self.subviews objectAtIndex:c] setFrame:rect];
        }
    }
    
    CGRect rect = self.frame;
    rect.origin.y += hcnt * rd_menu_height;
    rect.size.height -= hcnt * rd_menu_height;
    self.frame = rect;
}
@end
