//
//  UIPageCellView.m
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#import <Foundation/Foundation.h>
#import "UIPageCellView.h"
#import "PDFObjc.h"

@implementation UIPageCellView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [mTools setFrame:CGRectMake(mTools.frame.origin.x, mTools.frame.origin.y, mImg.frame.size.width, mTools.frame.size.height)];
}

- (void)UIUpdate:(PDFDIB *)dib
{
    if(!dib) [mImg setImage:nil];
    else [mImg setImage:[UIImage imageWithCGImage:[dib image]]];
}

- (void)UIRemove
{
    [mImg setImage:nil];
    [self removeFromSuperview];
}

- (void)setPageNo:(onPageDelete)del :(int)pageno
{
    m_del = del;
    m_pageno = pageno;
}

- (int)getRotate
{
    return m_rotate;
}

- (IBAction)OnPageDelete:(id)sender {
    m_del(m_pageno);
}

- (IBAction)OnPageRotate:(id)sender {
    CGAffineTransform transform = CGAffineTransformRotate(mImg.transform, M_PI * 0.5);
    mImg.transform = transform;
    m_rotate += 90;
    m_rotate %= 360;
}
@end
