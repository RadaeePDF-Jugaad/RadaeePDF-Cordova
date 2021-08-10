//
//  MenuCombo.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/8.
//  Copyright © 2020 Radaee. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void(^func_combo)(int);
@interface MenuCombo : UIScrollView
{
    func_combo m_callback;
    NSArray *m_data;
    CGFloat m_fsize;
}
-(void)setPara:(CGFloat)w :(CGFloat) fsize :(NSArray *)data :(func_combo)callback;
@end
