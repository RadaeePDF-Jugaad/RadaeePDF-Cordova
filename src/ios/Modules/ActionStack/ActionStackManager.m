//
//  ActionStackManager.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 08/01/18.
//

#import "ActionStackManager.h"

@implementation ASItem

- (instancetype)initWithPage:(int)pgno index:(int)idx
{
    _m_pageno = pgno;
    _m_idx = idx;
    
    return self;
}

- (void)undo:(PDFDoc *)doc
{}

- (void)redo:(PDFDoc *)doc
{}

@end

@implementation ASDel

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx
{
    self = [super initWithPage:pgno index:idx];
    _hand = [[page annotAtIndex:idx] getRef];

    return self;
}

#pragma mark - Override
- (void)undo:(PDFDoc *)doc
{
    PDFPage *page = [doc page:self.m_pageno];
    [page objsStart];
    [page addAnnot:_hand];
    page = nil;
}

- (void)redo:(PDFDoc *)doc
{
    PDFPage *page = [doc page:self.m_pageno];
    [page objsStart];
    PDFAnnot *annot = [page annotAtIndex:self.m_idx];
    [annot removeFromPage];
    page = nil;
}

@end

@implementation ASAdd

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx
{
    self = [super initWithPage:pgno index:idx];
    _hand = [[page annotAtIndex:idx] getRef];
    
    return self;
}

#pragma mark - Override
- (void)undo:(PDFDoc *)doc
{
    PDFPage *page = [doc page:self.m_pageno];
    [page objsStart];
    PDFAnnot *annot = [page annotAtIndex:self.m_idx];
    [annot removeFromPage];
}

- (void)redo:(PDFDoc *)doc
{
    PDFPage *page = [doc page:self.m_pageno];
    [page objsStart];
    bool b = [page addAnnot:_hand];
}

@end

@implementation ASMove

- (instancetype)initWithPage:(int)src_pageno initRect:(PDF_RECT)src_rect destPage:(int)dst_pageno destRect:(PDF_RECT)dst_rect index:(int)idx
{
    self = [super initWithPage:-1 index:idx];
    
    m_pageno0 = src_pageno;
    m_rect0 = src_rect;
    
    m_pageno1 = dst_pageno;
    m_rect1 = dst_rect;
    
    return self;
}

#pragma mark - Override
- (void)undo:(PDFDoc *)doc
{
    self.m_pageno = m_pageno0;
    if (self.m_pageno == m_pageno1) {
        PDFPage *page = [doc page:self.m_pageno];
        [page objsStart];
        PDFAnnot *annot = [page annotAtIndex:self.m_idx];
        [annot setRect:&m_rect0];
        page = nil;
    } else {
        PDFPage *page0 = [doc page:m_pageno0];
        PDFPage *page1 = [doc page:m_pageno1];
        [page0 objsStart];
        [page1 objsStart];
        PDFAnnot *annot = [page1 annotAtIndex:self.m_idx];
        [annot MoveToPage:page0 :&m_rect0];
        self.m_idx = page1.annotCount;
        page0 = nil;
        page1 = nil;
    }
}

- (void)redo:(PDFDoc *)doc
{
    self.m_pageno = m_pageno1;
    if (self.m_pageno == m_pageno1) {
        PDFPage *page = [doc page:self.m_pageno];
        [page objsStart];
        PDFAnnot *annot = [page annotAtIndex:self.m_idx];
        [annot setRect:&m_rect1];
        page = nil;
    } else {
        PDFPage *page0 = [doc page:m_pageno0];
        PDFPage *page1 = [doc page:m_pageno1];
        [page0 objsStart];
        [page1 objsStart];
        PDFAnnot *annot = [page0 annotAtIndex:(page0.annotCount - 1)];
        [annot MoveToPage:page1 :&m_rect1];
        page0 = nil;
        page1 = nil;
    }
}

@end

@implementation ActionStackManager

- (instancetype)init
{
    m_stack = [[NSMutableArray alloc] init];
    m_pos = -1;
    
    return self;
}

- (void)push:(ASItem *)item
{    
    m_pos++;
    for (int i = (int)(m_stack.count - 1); i >= m_pos; i--) {
        [m_stack removeObjectAtIndex:i];
    }
    [m_stack addObject:item];
}

- (ASItem *)undo
{
    if (m_pos < 0) return nil;
    ASItem *item = [m_stack objectAtIndex:m_pos];
    m_pos--;
    return item;
}

- (ASItem *)redo
{
    if(m_pos > (int)(m_stack.count - 2)) return nil;
    m_pos++;
    ASItem *item = [m_stack objectAtIndex:m_pos];
    return item;
}

@end
