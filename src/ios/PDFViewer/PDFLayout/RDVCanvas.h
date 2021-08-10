//
//  RDVCanvas.h
//  RDPDFReader
//
//  Created by Radaee on 2016/11/24.
//  Copyright © 2016年 radaee. All rights reserved.
//
#pragma once
#import "PDFObjc.h"

@interface RDVCanvas :NSObject
{
    CGContextRef m_ctx;
    float m_scale_pix;
}
@property(readonly) CGContextRef ctx;
@property(readonly) float scale_pix;
-(id)init :(CGContextRef)context :(float)pix_scale;
-(void)FillRect:(CGRect)rect : (int)color;
@end
