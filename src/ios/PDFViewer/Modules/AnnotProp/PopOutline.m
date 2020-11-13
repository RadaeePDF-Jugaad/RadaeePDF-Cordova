//
//  PopOutline.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/8.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopOutline.h"
#import "PDFObjc.h"
@implementation PopOutlineItem
-(id)init:(CGFloat)y :(PDFOutline *)outline
{
    self = [super initWithFrame:CGRectMake(0, y, 160, 30)];
    if(self)
    {
        m_outline = outline;
        PDFOutline *child = [outline child];
        if(child)
        {
            m_label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 116, 30)];
            m_label.font = [UIFont systemFontOfSize:12];
            m_label.text = [outline label];
            [self addSubview: m_label];
            m_expand = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 36, 30)];
            m_expand.font = [UIFont systemFontOfSize:12];
            m_expand.text = @">";
            [self addSubview:m_expand];
        }
        else
        {
            m_label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 116 + 36, 30)];
            m_label.font = [UIFont systemFontOfSize:12];
            m_label.text = [outline label];
            [self addSubview: m_label];
        }
    }
    return self;
}

-(id)initParent
{
    self = [super initWithFrame:CGRectMake(0, 0, 160, 30)];
    if(self)
    {
        m_expand = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, 116 + 36, 30)];
        m_expand.font = [UIFont systemFontOfSize:12];
        m_expand.text = @"<Parent";
        m_expand.textColor = [UIColor blueColor];
        [self addSubview: m_expand];
    }
    return self;
}

-(PDFOutline *)outline
{
    return m_outline;
}

-(BOOL)isExpand:(CGFloat)x
{
    return (m_expand && x > (4 + 116));
}

@end

@implementation PopOutline
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.8f alpha:1];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.8f alpha:1];
    }
    return self;
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    CGPoint pt = [tap locationInView:mOutlines];
    int idx = (int)(pt.y / 30);
    if(m_callback && m_children && idx < m_children.count)
    {
        PopOutlineItem *child = m_children[idx];
        if(idx == 0 && !child.outline)//tap on parent node.
        {
            if (m_stack.count > 0) [m_stack removeLastObject];
            PDFOutline *upper = (m_stack.count > 0)?[m_stack lastObject]:nil;
            [self expand:upper];
        }
        else
        {
            if([child isExpand:pt.x])//expend next
            {
                [m_stack addObject:child.outline];
                [self expand:child.outline];
            }
            else m_callback(child.outline);
        }
    }
}
-(void)reset
{
    for(UIView *view in m_children)
    {
        [view removeFromSuperview];
    }
    m_children = nil;
}

-(void)expand:(PDFOutline *)node
{
    [self reset];
    m_children = [[NSMutableArray alloc] init];
    PDFOutline *outline;
    CGFloat y = 0;
    if(!node)
    {
        for(outline = [m_doc rootOutline]; outline; outline = outline.next)
        {
            PopOutlineItem *item = [[PopOutlineItem alloc] init:y :outline];
            [mOutlines addSubview:item];
            [m_children addObject:item];
            y += 30;
        }
    }
    else
    {
        PopOutlineItem *back = [[PopOutlineItem alloc] initParent];
        [mOutlines addSubview:back];
        [m_children addObject:back];
        y = 30;
        for(outline = [node child]; outline; outline = outline.next)
        {
            PopOutlineItem *item = [[PopOutlineItem alloc] init:y :outline];
            [mOutlines addSubview:item];
            [m_children addObject:item];
            y += 30;
        }
    }
    mOutlines.contentSize = CGSizeMake(160, y);
}

-(void)setPara:(PDFDoc *)doc :(func_outline)callback
{
    m_doc = doc;
    m_callback = callback;
    m_stack = [[NSMutableArray alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [mOutlines addGestureRecognizer:tap];
    [self expand:nil];
}

@end
