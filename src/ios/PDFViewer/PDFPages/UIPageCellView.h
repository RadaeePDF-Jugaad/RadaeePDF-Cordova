//
//  UIPageCellView.h
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#pragma once
#import <UIKit/UIKit.h>
@class RDPDFDIB;

typedef void(^onPageDelete)(int pageno);
@interface UIPageCellView : UIView
{
    __weak IBOutlet UIImageView *mImg;
    __weak IBOutlet UIView *mTools;
    int m_rotate;
    int m_pageno;
    onPageDelete m_del;
}
- (void)UIUpdate:(RDPDFDIB *)dib;
- (void)UIRemove;
- (void)setPageNo:(onPageDelete)del :(int)pageno;
- (int)getRotate;
- (IBAction)OnPageDelete:(id)sender;
- (IBAction)OnPageRotate:(id)sender;
@end
