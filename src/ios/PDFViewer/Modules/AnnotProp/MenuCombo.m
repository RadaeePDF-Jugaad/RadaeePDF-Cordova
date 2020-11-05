//
//  MenuCombo.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/8.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuCombo.h"

@implementation MenuCombo
+(UIView *)createItem :(int)tag :(CGFloat)y :(CGFloat)w :(CGFloat )fsize :(NSString *)val
{
    UILabel *vlab = [[UILabel alloc] initWithFrame:CGRectMake(2, y, w - 2, fsize + 2)];
    vlab.text = val;
    [vlab setFont:[UIFont systemFontOfSize:fsize]];
    return vlab;
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    CGPoint pt = [tap locationInView:self];
    if(m_callback) m_callback(pt.y / (m_fsize + 2));
}

-(void)setPara:(CGFloat)w :(CGFloat) fsize :(NSArray *)data :(func_combo)callback
{
    m_callback = callback;
    m_data = data;
    m_fsize = fsize;
    CGFloat item_h = fsize + 2;
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.8f alpha:1];
    
    UIView *view;
    CGFloat y = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];

    int cnt = (int)m_data.count;
    for(int cur = 0; cur < cnt; cur++)
    {
        view = [MenuCombo createItem :cur :y :w :fsize :m_data[cur]];
        [self addSubview:view];
        y += item_h;
    }
    self.contentSize = CGSizeMake(w, y);
}


@end
