#pragma once
#include "PDFObjc.h"
#include "PDFVGlobal.h"
#import <QuartzCore/QuartzCore.h>

@interface PDFVCanvas : NSObject
{
    CGContextRef m_ctx;
    float m_scale;
    bool darkMode;
}
-(id)init:(CGContextRef)ctx :(float)scale;
-(void)DrawThumbBmp:(PDFDIB *)dib :(int)x :(int)y :(int)page :(bool)complete;
-(void)DrawBmp : (PDFDIB *)dib : (int)x :(int)y :(bool)complete;
-(void)DrawBmp : (PDFDIB *)dib : (int)x : (int)y : (int)w : (int)h :(bool)complete;
//-(void)Erase: (int) color;
-(void)FillRect:(CGRect)rect : (int)color;
-(CGContextRef)context;
@end
