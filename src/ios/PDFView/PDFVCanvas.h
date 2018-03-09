#pragma once
#include "PDFObjc.h"
#include "PDFVGlobal.h"
#import <QuartzCore/QuartzCore.h>

@interface PDFVCanvas : NSObject
{
    CGContextRef m_ctx;
    float m_scale;
}
-(id)init:(CGContextRef)ctx :(float)scale;
-(void)DrawThumbBmp:(PDFDIB *)dib :(int)x :(int)y :(int)page;
-(void)DrawBmp : (PDFDIB *)dib : (int)x :(int)y ;
-(void)DrawBmp : (PDFDIB *)dib : (int)x : (int)y : (int)w : (int)h;
//-(void)Erase: (int) color;
-(void)FillRect:(CGRect)rect : (int)color;
-(CGContextRef)context;
@end
