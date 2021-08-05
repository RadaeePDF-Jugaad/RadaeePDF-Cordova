//
//  PDFPagesView.m
//  PDFViewer
//
//  Created by Radaee Lou on 2020/8/13.
//

#import <Foundation/Foundation.h>
#import "PDFPagesView.h"
#import "PDFObjc.h"

#define CELL_WIDTH 158
#define CELL_HEIGHT 198
#define CELL_SIZE 158

@implementation PDFPageCell
@synthesize deleted = m_deleted;
@synthesize rotate = m_rotate;
-(id)init:(UIView *)parent :(PDFDoc *) doc :(int)pageno :(onPageDelete)del
{
    self = [super init];
    if(self)
    {
        m_parent = parent;
        m_doc = doc;
        m_pageno = pageno;
        m_scale_pix = [[UIScreen mainScreen] scale];
        m_del = del;
        m_status = 0;
    }
    return self;
}

-(bool)updateRotate
{
    int rot0 = m_rotate >> 16;
    int rot1 = rot0 + [m_view getRotate];
    if(rot1 > 360) rot1 -= 360;
    m_rotate = (rot0 << 16) | rot1;
    return (rot0 != rot1);
}

-(void)UISetPos:(CGFloat)x :(CGFloat)y
{
    m_x = x;
    m_y = y + 8;
    if(!m_view)
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"UIPageCellView" owner:self options:nil];
        m_view = [views lastObject];
        [m_view setPageNo:m_del :m_pageno];
        [m_parent addSubview:m_view];
    }
    [m_view setFrame:CGRectMake(m_x, m_y, CELL_WIDTH, CELL_HEIGHT)];
}

-(void)UIRemove
{
    [m_view UIRemove];
}

-(bool)UIRender:(dispatch_queue_t)queue
{
    if(m_status != 0) return false;
    m_status = 1;
    dispatch_async(queue, ^{
        if (self->m_status < 0) return;
        
        float csize = CELL_SIZE * self->m_scale_pix;
        PDFDoc *doc = self->m_doc;
        int pageno = self->m_pageno;
        PDFPage *page = [doc page:pageno];
        float pw = [doc pageWidth:pageno];
        float ph = [doc pageHeight:pageno];
        float scale1 = csize / pw;
        float scale2 = csize / ph;
        if(scale1 > scale2) scale1 = scale2;
        int iw = pw * scale1;
        int ih = ph * scale1;
        
        PDFDIB *dib = [[PDFDIB alloc] init:iw :ih];
        [dib erase:-1];
        PDFMatrix *mat = [[PDFMatrix alloc] init:scale1 :-scale1 :0 :ih];
        self->m_page = page;
        [page render:dib :mat :2];
        mat = nil;
        if (self->m_status < 0)
        {
            dib = nil;
            page = nil;
        }
        else
        {
            self->m_status = 2;
            self->m_dib = dib;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->m_view UIUpdate: self->m_dib];
            });
        }
    });
    return true;
}

-(bool)UICancel:(dispatch_queue_t)queue
{
    if(m_status <= 0) return false;
    m_status = -1;
    dispatch_async(queue, ^{
        self->m_page = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->m_view UIUpdate: nil];
            self->m_dib = nil;
            self->m_status = 0;
        });
    });
    return true;
}

@end

@implementation PDFPagesView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //self.autoresizesSubviews = YES;
        //self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        [self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];

        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.delegate = self;
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        //self.autoresizesSubviews = YES;
        //self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        [self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];

        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = NO;
        self.delegate = self;
    }
    return self;
}

-(void)dealloc
{
    if(m_queue)
    {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(m_queue);
#endif
        m_queue = nil;
    }
}

-(void)onPagesUpdate
{
    int pcnt = (int)[m_cells_org count];
    m_cells = [[NSMutableArray alloc] init];
    float xstep = m_gap + CELL_WIDTH;
    int pidx = 0;
    for(int pcur = 0; pcur < pcnt; pcur++)
    {
        PDFPageCell *cell = [m_cells_org objectAtIndex:pcur];
        if(cell.deleted)
            [cell UIRemove];
        else
        {
            [m_cells addObject:cell];
            [cell UISetPos:(pidx % m_col_cnt) * xstep + (m_gap >> 1) :CELL_HEIGHT * (pidx / m_col_cnt) + 2];
            pidx++;
        }
    }
    
    pcnt = (int)[m_cells count];
    m_row_cnt = (pcnt + m_col_cnt - 1) / m_col_cnt;
    
    self.contentSize = CGSizeMake(self.frame.size.width, m_row_cnt * CELL_HEIGHT + 4);
}

-(void)onSizeChanged
{
    CGSize screen_sz = self.frame.size;
    float w = screen_sz.width - 4;
    m_col_cnt = ((int)w) / (CELL_WIDTH + 4);
    if(m_col_cnt < 1) m_col_cnt = 1;
    if(m_col_cnt < 2) m_gap = 4;
    else m_gap = (w - m_col_cnt * (CELL_WIDTH + 4)) / m_col_cnt + 4;
    //float step = m_gap + CELL_WIDTH;
    
    int pcnt = (int)[m_cells count];
    m_row_cnt = (pcnt + m_col_cnt - 1) / m_col_cnt;
    
    [self onPagesUpdate];
    self.contentOffset = CGPointZero;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(m_doc)
    {
        [self onSizeChanged];
        [self scrollViewDidScroll:self];
    }
}

-(bool)modified
{
    int pcnt = (int)m_cells_org.count;
    for(int pcur = 0; pcur < pcnt; pcur++)
    {
        PDFPageCell *cell = [m_cells_org objectAtIndex:pcur];
        if (cell.deleted) return true;
        else if ([cell updateRotate]) return true;
    }
    return false;
}

-(void)getEditData:(bool *)dels :(int *)rots
{
    int pcnt = (int)m_cells_org.count;
    for(int pcur = 0; pcur < pcnt; pcur++)
    {
        PDFPageCell *cell = [m_cells_org objectAtIndex:pcur];
        dels[pcur] = cell.deleted;
        [cell updateRotate];
        rots[pcur] = cell.rotate;
    }
}

-(void)open:(PDFDoc *)doc
{
    m_doc = doc;
    int pcnt = [m_doc pageCount];
    m_cells_org = [[NSMutableArray alloc] init];
    m_cells = [[NSMutableArray alloc] init];
    onPageDelete del = ^(int pageno)
    {
        PDFPageCell *cell = [self->m_cells_org objectAtIndex:pageno];
        [cell UICancel:self->m_queue];
        cell.deleted = true;
        [self onPagesUpdate];
        [self scrollViewDidScroll:self];
    };

    for(int pcur = 0; pcur < pcnt; pcur++)
    {
        PDFPageCell *cell = [[PDFPageCell alloc] init:self :m_doc :pcur :del];
        PDFPage *page = [m_doc page:pcur];
        int rot = [page getRotate];
        page = nil;
        cell.rotate = (rot << 16) | rot;
        [m_cells_org addObject:cell];
    }
    [self onSizeChanged];
    [self scrollViewDidScroll:self];
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != self) return;
    CGPoint screen_org = self.contentOffset;
    CGSize screen_sz = self.frame.size;
    int row0 = screen_org.y / CELL_HEIGHT;
    int row1 = (screen_org.y + screen_sz.height) / CELL_HEIGHT;
    int idx0 = row0 * m_col_cnt;
    int idx1 = (row1 + 1) * m_col_cnt;
    int pcnt = (int)[m_cells count];
    if(idx1 > pcnt) idx1 = pcnt;
    int icur = 0;
    while(icur < idx0)
    {
        PDFPageCell *cell = [m_cells objectAtIndex:icur];
        [cell UICancel:m_queue];
        icur++;
    }
    while(icur < idx1)
    {
        PDFPageCell *cell = [m_cells objectAtIndex:icur];
        [cell UIRender:m_queue];
        icur++;
    }
    while(icur < pcnt)
    {
        PDFPageCell *cell = [m_cells objectAtIndex:icur];
        [cell UICancel:m_queue];
        icur++;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return NULL;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}


@end
