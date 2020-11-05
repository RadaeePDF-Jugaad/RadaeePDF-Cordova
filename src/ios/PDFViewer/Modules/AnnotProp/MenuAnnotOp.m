//
//  MenuAnnotOp.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuAnnotOp.h"
@implementation MenuAnnotOp
+(UIView *)createItem :(int)tag :(CGFloat)x :(CGFloat)w :(NSString *)val :(UIFont *)font
{
    UILabel *vlab = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, w, 24)];
    vlab.tag = tag;
    vlab.text = val;
    vlab.textAlignment = NSTextAlignmentCenter;
    [vlab setFont:font];
    [vlab setUserInteractionEnabled:YES];
    return vlab;
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if(m_callback) m_callback((int)tap.view.tag);
}

-(id)init:(PDFAnnot *)annot :(CGPoint)position :(func_annotop)callback
{
    //todo: calcute area.
    
    self = [super init];
    if(self)
    {
        m_annot = annot;
        m_callback = callback;
        int atype = [m_annot type];
        m_has_pdfform = (atype == 2 || atype == 17 || atype == 18 || atype == 19 || atype == 25 || atype == 26);
        m_has_edit = (atype == 1 || atype == 4 || atype == 5 || atype == 6 || atype == 7 || atype == 8 || atype == 9 || atype == 10 || atype == 11 || atype == 12 || atype == 13 || atype == 15);
        m_has_remove = (atype != 0);
        m_has_property = (atype != 0 && atype != 2);
        CGFloat width = 0;
        UIView *view;
        UITapGestureRecognizer *tap;
        UIFont *font = [UIFont systemFontOfSize:12];
        NSDictionary *attributes = @{NSFontAttributeName :font};
        if(m_has_pdfform)
        {
            NSString *sval = @"Perform";
            CGSize tsize = [sval boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
            tsize.width += 8;
            view = [MenuAnnotOp createItem :0 :width :tsize.width :sval :font];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [self addSubview:view];
            width += tsize.width;
        }
        if(m_has_edit)
        {
            NSString *sval = @"Edit";
            CGSize tsize = [sval boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
            tsize.width += 8;
            view = [MenuAnnotOp createItem :1 :width :tsize.width :sval :font];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [self addSubview:view];
            width += tsize.width;
        }
        if(m_has_remove)
        {
            NSString *sval = @"Remove";
            CGSize tsize = [sval boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
            tsize.width += 8;
            view = [MenuAnnotOp createItem :2 :width :tsize.width :sval :font];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [self addSubview:view];
            width += tsize.width;
        }
        if(m_has_property)
        {
            NSString *sval = @"Property";
            CGSize tsize = [sval boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
            tsize.width += 8;
            view = [MenuAnnotOp createItem :3 :width :tsize.width :sval :font];
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [self addSubview:view];
            width += tsize.width;
        }
        self.frame = CGRectMake(position.x, position.y - 24, width, 24);
        [self setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.9f]];
    }
    return self;
}
-(PDFAnnot *)annot
{
    return m_annot;
}
@end
