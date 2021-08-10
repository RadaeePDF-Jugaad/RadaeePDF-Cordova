//
//  PDFPagesView.h
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#pragma once
#import <UIKit/UIKit.h>
#import "UIPageCellView.h"
@class PDFDoc;
@class PDFPage;
@class PDFDIB;

@interface PDFPageCell : NSObject
{
    UIView *m_parent;
    UIPageCellView *m_view;
    PDFDoc *m_doc;
    PDFPage *m_page;
    int m_pageno;
    PDFDIB *m_dib;
    bool m_deleted;
    int m_rotate;
    int m_status;
    CGFloat m_x;
    CGFloat m_y;
    CGFloat m_scale_pix;
    onPageDelete m_del;
}
@property bool deleted;
@property int rotate;
-(id)init:(UIView *)parent :(PDFDoc *) doc :(int)pageno :(onPageDelete)del;
-(bool)updateRotate;
-(void)UISetPos:(CGFloat)x :(CGFloat)y;
-(void)UIRemove;
-(bool)UIRender:(dispatch_queue_t)queue;
-(bool)UICancel:(dispatch_queue_t)queue;
@end

@interface PDFPagesView : UIScrollView<UIScrollViewDelegate>
{
    dispatch_queue_t m_queue;
    PDFDoc *m_doc;
    int m_row_cnt;
    int m_col_cnt;
    int m_gap;
    NSMutableArray *m_cells_org;
    NSMutableArray *m_cells;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)open:(PDFDoc *)doc;
-(bool)modified;
-(void)getEditData:(bool *)dels :(int *)rots;
@end
