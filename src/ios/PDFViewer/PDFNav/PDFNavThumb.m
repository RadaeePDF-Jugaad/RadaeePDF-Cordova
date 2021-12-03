//
//  PDFNavThumb.m
//  RDPDFReader
//
//  Created by Radaee on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//
#import "PDFNavThumb.h"
#import "PDFObjc.h"
#import <Foundation/Foundation.h>

UIImage *g_nav_refresh;
UIImage *g_nav_def;

@implementation PDFNavThumb
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //self.autoresizesSubviews = YES;
        //self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        [self setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1]];
        m_cancel = false;
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
        [self setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1]];
        m_cancel = false;
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self refresh];
}

-(void)dealloc
{
    m_cancel = true;
    if(m_queue)
    {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(m_queue);
#endif
        m_queue = nil;
    }
}

-(void)reset
{
    m_cancel = true;
    if(m_queue)
    {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(m_queue);
#endif
        m_queue = nil;
    }
    m_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    m_cancel = false;
}

#define CELL_WIDTH 128
#define CELL_HEIGHT 142
-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if(OnPDFOpen) OnPDFOpen(tap.view);
}

-(void)tapRefresh:(UITapGestureRecognizer *)tap
{
    [self refresh];
}

-(void)setCallback:(func_nav)pdf_open :(func_delete)pdf_delete
{
    OnPDFOpen = pdf_open;
    OnPDFDelete = pdf_delete;
}

-(void)setDir:(NSString *)dir
{
    [self reset];
    if(!dir || [dir length] == 0) return;
    m_cur_dir = dir;
    CGRect rect = self.bounds;
    float w = rect.size.width;
    int col_cnt = ((int)w) / CELL_WIDTH;
    if(col_cnt < 1) col_cnt = 1;
    float gap = (w - col_cnt * CELL_WIDTH) / col_cnt;
    float step = gap + CELL_WIDTH;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirArray = [fm contentsOfDirectoryAtPath:dir error:nil];
    float x = gap * 0.5f;
    float y = 4;
    int col = 0;
    Boolean *cancel = &m_cancel;
    
    if(!g_nav_refresh) g_nav_refresh = [UIImage imageNamed:@"nav_refresh"];
    if(!g_nav_def) g_nav_def = [UIImage imageNamed:@"nav_def"];

    //add first refresh button.
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"UICellView" owner:self options:nil];
    UICellView *view = [views lastObject];
    [view UILoad:@"." :@"." :CGRectMake(x, y, CELL_WIDTH, CELL_HEIGHT) :g_nav_refresh];
    [view UISetDelete:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRefresh:)];
    [view addGestureRecognizer:tap];
    [self addSubview:view];
    x += step;
    col++;
    if(col >= col_cnt)
    {
        x = gap * 0.5f;
        y += CELL_HEIGHT + 4;
        col = 0;
    }

    for(NSString *fname in dirArray)
    {
        NSString *sExt = [fname substringFromIndex:[fname length] - 4];
        if(![sExt compare: @".pdf"])
        {
            NSString *sFile = [dir stringByAppendingPathComponent:fname];
            views = [[NSBundle mainBundle] loadNibNamed:@"UICellView" owner:self options:nil];
            view = [views lastObject];
            [view UILoad:fname :sFile :CGRectMake(x, y, CELL_WIDTH, CELL_HEIGHT) :g_nav_def];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [view UISetDelete:OnPDFDelete];

            dispatch_async(m_queue, ^{
                if (*cancel) return;
                [view BKRender];//render in backing thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view UIUpdate];
                });
            });

            [self addSubview:view];
            x += step;
            col++;
            if(col >= col_cnt)
            {
                x = gap * 0.5f;
                y += CELL_HEIGHT + 4;
                col = 0;
            }
        }
    }
    if(col > 0) y += CELL_HEIGHT + 4;
    if(y < rect.size.height)
        y = rect.size.height;
    self.contentSize = CGSizeMake(rect.size.width, y);
}

-(void)refresh
{
    [self setDir:m_cur_dir];
}
@end
