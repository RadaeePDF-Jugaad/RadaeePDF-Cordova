//
//  UIIconView.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/13.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "UIIconView.h"
#import "PDFPopupCtrl.h"
#import "PDFDialog.h"

const char *g_note_icon_names[] =
{
    "Note",
    "Comment",
    "Key",
    "Help",
    "NewParagraph",
    "Paragraph",
    "Insert",
    "Check",
    "Circle",
    "Cross",
    "CrossHairs",
    "RightArrow",
    "RightPointer",
    "Star",
    "UpArrow",
    "UpLeftArrow"
};

const char *g_attach_icon_names[] =
{
    "PushPin",
    "Graph",
    "Paperclip",
    "Tag"
};

@implementation UIIconBtn
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_icon = 0;
        m_vc = nil;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_icon = 0;
        m_vc = nil;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)updateIcon:(int)icon
{
    m_icon = icon;
    m_dib = [[PDFDIB alloc] init:48 :48];
    [m_dib erase:-1];
    Global_drawAnnotIcon(m_atype, m_icon, [m_dib handle]);
    self.image = [[UIImage alloc] initWithCGImage:[m_dib image]];
}

-(void)setIcon:(PDFAnnot *)annot :(UIViewController *)vc
{
    m_atype = [annot type];
    m_vc = vc;
    [self updateIcon:[annot getIcon]];
}

-(int)icon
{
    return m_icon;
}

#define ICON_WIDTH 150
#define ICON_HEIGHT 40
-(void)tapItem:(UITapGestureRecognizer *)tap
{
    CGPoint pt = [tap locationInView:m_view];
    
    [self updateIcon:pt.y / ICON_HEIGHT];
    [m_popup dismiss];
}

-(void)tapAction:(id)sendor
{
    UIView *container = [(PDFDialog *)m_vc popView];
    container.hidden = YES;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame = [self convertRect:frame toView:m_vc.view];
    //frame.origin.x += frame.size.width;
    frame.size.width = ICON_WIDTH;
    int items_cnt = 0;
    if(m_atype == 1)
        items_cnt = 16;
    else if(m_atype == 17)
        items_cnt = 4;
    frame.size.height = items_cnt * ICON_HEIGHT;
    CGRect rect = m_vc.view.frame;
    if(frame.origin.y + frame.size.height > rect.origin.y + rect.size.height)
        frame.origin.y = rect.origin.y + rect.size.height - frame.size.height - 20;
    if(frame.origin.x + frame.size.width > rect.size.width)
        frame.origin.x = frame.origin.x - ((frame.origin.x + frame.size.width) - rect.size.width);
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];
    view.contentSize = CGSizeMake(ICON_WIDTH, 16 + items_cnt * ICON_HEIGHT);
    view.scrollEnabled = YES;
    view.clipsToBounds = YES;
    //UIView *view = [[UIView alloc] initWithFrame: frame];
    m_view = view;

    m_dibs = [[NSMutableArray alloc] init];
    UIImageView *lv;
    UILabel *lab;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
    UIFont *font = [UIFont systemFontOfSize:15];
    [view addGestureRecognizer:tap];
    if(m_atype == 1)
    {
        for(int cur = 0; cur < items_cnt; cur++)
        {
            lv = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8 + cur * ICON_HEIGHT, ICON_HEIGHT, ICON_HEIGHT)];
            lv.tag = 0;
            PDFDIB *dib = [[PDFDIB alloc] init:48 :48];
            [dib erase:-1];
            Global_drawAnnotIcon(m_atype, cur, [dib handle]);
            [m_dibs addObject:dib];
            lv.image = [[UIImage alloc] initWithCGImage:[dib image]];
            [view addSubview:lv];

            lab = [[UILabel alloc] initWithFrame:CGRectMake(16 + ICON_HEIGHT, 8 + cur * ICON_HEIGHT, ICON_WIDTH - ICON_HEIGHT, ICON_HEIGHT)];
            lab.tag = 0;
            lab.text = [NSString stringWithUTF8String:g_note_icon_names[cur]];
            [lab setFont:font];
            [view addSubview:lab];
        }
    }
    else if(m_atype == 17)
    {
        for(int cur = 0; cur < items_cnt; cur++)
        {
            lv = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8 + cur * ICON_HEIGHT, ICON_HEIGHT, ICON_HEIGHT)];
            lv.tag = 0;
            lv.clipsToBounds = YES;
            PDFDIB *dib = [[PDFDIB alloc] init:48 :48];
            [dib erase:-1];
            Global_drawAnnotIcon(m_atype, cur, [dib handle]);
            [m_dibs addObject:dib];
            lv.image = [[UIImage alloc] initWithCGImage:[dib image]];
            [view addSubview:lv];
            
            lab = [[UILabel alloc] initWithFrame:CGRectMake(16 + ICON_HEIGHT, 8 + cur * ICON_HEIGHT, ICON_WIDTH - ICON_HEIGHT, ICON_HEIGHT)];
            lab.tag = 0;
            lab.text = [NSString stringWithUTF8String:g_attach_icon_names[cur]];
            [lab setFont:font];
            [view addSubview:lab];
        }
    }
    
    UILShadowView *bgView = [[UILShadowView alloc] initWithFrame:container.frame];
    [bgView addSubview:view];
    bgView.center = container.center;
    m_popup = [[PDFPopupCtrl alloc] init:bgView];
    [m_popup setDismiss:^{
        container.hidden = NO;
    }];
    [m_vc presentViewController:m_popup animated:NO completion:nil];
}
@end
