//
//  PopOutline.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/8.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
@class PDFOutline;
@class PDFDoc;
@interface PopOutlineItem : UIView
{
    UILabel *m_label;
    UILabel *m_expand;//go child
    PDFOutline *m_outline;
}
-(id)init:(CGFloat)y :(PDFOutline *)outline;
-(id)initParent;
-(PDFOutline *)outline;
-(BOOL)isExpand:(CGFloat)x;
@end

typedef void(^func_outline)(PDFOutline *);
@interface PopOutline : UIView
{
    __weak IBOutlet UIScrollView *mOutlines;
    NSMutableArray *m_children;
    NSMutableArray *m_stack;
    PDFDoc *m_doc;
    func_outline m_callback;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setPara:(PDFDoc *)doc :(func_outline)callback;
@end
