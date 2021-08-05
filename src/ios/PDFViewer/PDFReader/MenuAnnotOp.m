//
//  MenuAnnotOp.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuAnnotOp.h"
@implementation MenuAnnotOp
- (UIView *)createItem :(int)tag :(CGFloat)x :(CGFloat)w :(CGFloat)h :(UIImage *)img
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, w, h)];
    [button setImage:img forState:UIControlStateNormal];
    button.tag = tag;
    [button setUserInteractionEnabled:YES];
    [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)tapAction:(UIButton *)tap
{
    if(m_callback) m_callback((int)tap.tag);
}

-(id)init:(PDFAnnot *)annot :(CGPoint)position :(func_annotop)callback
{
    //todo: calcute area.
    
    self = [super init];
    if(self)
    {
        position.y -= 8;
        m_annot = annot;
        m_callback = callback;
        int atype = [m_annot type];
        m_has_perform = (atype == 2 || atype == 17 || atype == 18 || atype == 19 || atype == 25 || atype == 26);
        m_has_edit = (atype == 1 || atype == 4 || atype == 5 || atype == 6 || atype == 7 || atype == 8 || atype == 9 || atype == 10 || atype == 11 || atype == 12 || atype == 13 || atype == 15);
        m_has_remove = (atype != 0);
        m_has_property = (atype != 0 && atype != 2);
        CGFloat iconSize = 40;
        CGFloat width = 0;
        UIView *view;
        if(m_has_perform)
        {
            UIImage *img = [UIImage imageNamed:@"btn_perform"];
            view = [self createItem :0 :width :iconSize :iconSize :img];
            [self addSubview:view];
            width += iconSize;
        }
        if(m_has_edit)
        {
            UIImage *img = [UIImage imageNamed:@"btn_ink"];
            view = [self createItem :1 :width :iconSize :iconSize :img];
            [self addSubview:view];
            width += iconSize;
        }
        if(m_has_remove)
        {
            UIImage *img = [UIImage imageNamed:@"btn_remove"];
            view = [self createItem :2 :width :iconSize :iconSize :img];
            [self addSubview:view];
            width += iconSize;
        }
        if(m_has_property)
        {
            UIImage *img = [UIImage imageNamed:@"btn_prop"];
            view = [self createItem :3 :width :iconSize :iconSize :img];
            [self addSubview:view];
            width += iconSize;
        }
        
        UIImage *img = (annot.isLocked) ? [UIImage imageNamed:@"btn_lock"] : [UIImage imageNamed:@"btn_unlock"];
        view = [self createItem :4 :width :iconSize :iconSize :img];
        [self addSubview:view];
        width += iconSize;
        
        if (@available(iOS 13.0, *)) {
            [self setBackgroundColor:[UIColor systemGray6Color]];
        } else {
            [self setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:0.95f alpha:1.0f]];
        }
        
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
    
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat height = 50;
        
        //check if annot rect origin is equal to screen origin
        if (position.x == 0 && position.y + 8 == 0) {
            self.frame = CGRectMake(8, 8, width, height);
            return self;
        }
        
        //else manage menu annot position
        position.y -= (height - iconSize);
        
        if (position.x + width > screenWidth && position.y - iconSize < 0) {
            self.frame = CGRectMake(position.x - (position.x + width - screenWidth) - 8, 8, width, height);
        } else if (position.x + width > screenWidth) {
            self.frame = CGRectMake(position.x - (position.x + width - screenWidth) - 8, position.y - iconSize, width, height);
        } else if (position.y > screenHeight) {
            self.frame = CGRectMake(position.x, position.y - iconSize - (position.y - screenHeight) - 8, width, height);
        } else if (position.x < 0 && position.y - iconSize > 0){
            self.frame = CGRectMake(8, position.y - iconSize, width, height);
        } else if (position.y - iconSize < 0 && position.x > 0) {
            self.frame = CGRectMake(position.x, 8, width, height);
        } else if (position.x < 0 && position.y - iconSize < 0) {
            self.frame = CGRectMake(8, 8, width, height);
        } else {
            self.frame = CGRectMake(position.x, position.y - iconSize, width, height);
        }
        
    }
    return self;
}
-(PDFAnnot *)annot
{
    return m_annot;
}
-(void)updateIcons:(UIImage *)iPerform :(UIImage *)iRemove
{
    if(m_has_perform && iPerform)
    {
        //item is UILabel, so, can't set icon
        UILabel *view  = self.subviews[0];
    }
    if(m_has_remove && iRemove)
    {
        int idx = 0;
        if(m_has_perform) idx++;
        if(m_has_edit) idx++;
        //item is UILabel, so, can't set icon
        UILabel *view  = self.subviews[idx];
    }
}
@end
