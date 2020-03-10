//
//  RDVCanvas.m
//  RDPDFReader
//
//  Created by Radaee on 2016/11/24.
//  Copyright © 2016年 radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDVCanvas.h"
@implementation RDVCanvas
@synthesize ctx = m_ctx;
@synthesize scale_pix = m_scale_pix;
-(id)init :(CGContextRef)context :(float)pix_scale
{
    self = [super init];
    if(self)
    {
        m_ctx = context;
        m_scale_pix = pix_scale;
    }
    return self;
}

-(void)FillRect:(CGRect) rect :(int) color
{
    CGFloat clr[4];
    clr[0] = ((Byte *)&color)[2] / 255.0f;
    clr[1] = ((Byte *)&color)[1] / 255.0f;
    clr[2] = ((Byte *)&color)[0] / 255.0f;
    clr[3] = ((Byte *)&color)[3] / 255.0f;
    CGContextSetFillColor(m_ctx, clr);
    CGContextFillRect(m_ctx, rect);
}

@end
