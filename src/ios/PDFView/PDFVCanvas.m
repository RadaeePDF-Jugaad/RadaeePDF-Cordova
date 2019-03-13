//
//  PDFVCanvas.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVCanvas.h"

@implementation PDFVCanvas
-(id)init:(CGContextRef)ctx :(float)scale
{
    if( self = [super init] )
    {
        m_ctx = ctx;
        m_scale = scale;
        darkMode = GLOBAL.g_dark_mode;
        CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    }
    
    return self;
}

-(void)DrawThumbBmp:(PDFDIB *)dib :(int)x :(int)y :(int)page :(bool)complete
{
    if (darkMode && !complete) {
        return;
    }
    
    NSString *opage = [NSString stringWithFormat:@"%i", page + 1];
    
    Byte *data = (Byte *)[dib data];
    int w = [dib width];
    int h = [dib height];
    
    if (darkMode && ![dib cached]) {
        [dib setCached:YES];
        
        // run through every pixel, a scan line at a time...
        for(int ay = 0; ay < h; ay++)
        {
            // get a pointer to the start of this scan line
            unsigned char *linePointer = &data[ay * w * 4];
            
            // step through the pixels one by one...
            for(int ax = 0; ax < w; ax++)
            {
                // get RGB values. We're dealing with premultiplied alpha
                // here, so we need to divide by the alpha channel (if it
                // isn't zero, of course) to get uninflected RGB. We
                // multiply by 255 to keep precision while still using
                // integers
                int r, g, b;
                if(linePointer[3])
                {
                    r = linePointer[0] * 255 / linePointer[3];
                    g = linePointer[1] * 255 / linePointer[3];
                    b = linePointer[2] * 255 / linePointer[3];
                }
                else
                    r = g = b = 0;
                
                // perform the colour inversion
                r = 255 - r;
                g = 255 - g;
                b = 255 - b;
                
                int avg = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
                r = g = b = avg;
                
                // multiply by alpha again, divide by 255 to undo the
                // scaling before, store the new values and advance
                // the pointer we're reading pixel data from
                linePointer[0] = r * linePointer[3] / 255;
                linePointer[1] = g * linePointer[3] / 255;
                linePointer[2] = b * linePointer[3] / 255;
                linePointer += 4;
            }
        }
    }
    
    
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, w * h * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( w, h, 8, 32, w<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    CGContextSaveGState(m_ctx);
    float tmp = 1/m_scale;
    CGContextTranslateCTM(m_ctx, x * tmp, (y + h) * tmp);
    CGContextScaleCTM(m_ctx, tmp, -tmp);
    CGContextDrawImage(m_ctx, CGRectMake(0, 0, w, h), img);
    
    // Add the page number
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    CGContextTranslateCTM(m_ctx, 0.0f, h);
    CGContextScaleCTM(m_ctx, 1.0f, -1.0f);
    
    // Set font and color
    [opage drawInRect:CGRectMake(0, h/2 - h/5, w, h/5) withAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:h/5], NSForegroundColorAttributeName: [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f], NSParagraphStyleAttributeName: paragraphStyle}];
    
    CGContextRestoreGState(m_ctx);
    CGImageRelease(img);
}

-(void)DrawBmp:(PDFDIB *)dib :(int)x :(int)y :(bool)complete
{
    Byte *data = (Byte *)[dib data];
    int w = [dib width];
    int h = [dib height];
    
    if (darkMode && !complete) {
        [self FillRect:CGRectMake(x, y, w, h) :0xFF000000];
        return;
    }
    
    if (darkMode && ![dib cached]) {
        [dib setCached:YES];
        
        // run through every pixel, a scan line at a time...
        for(int ay = 0; ay < h; ay++)
        {
            // get a pointer to the start of this scan line
            unsigned char *linePointer = &data[ay * w * 4];
            
            // step through the pixels one by one...
            for(int ax = 0; ax < w; ax++)
            {
                // get RGB values. We're dealing with premultiplied alpha
                // here, so we need to divide by the alpha channel (if it
                // isn't zero, of course) to get uninflected RGB. We
                // multiply by 255 to keep precision while still using
                // integers
                int r, g, b;
                if(linePointer[3])
                {
                    r = linePointer[0] * 255 / linePointer[3];
                    g = linePointer[1] * 255 / linePointer[3];
                    b = linePointer[2] * 255 / linePointer[3];
                }
                else
                    r = g = b = 0;
                
                // perform the colour inversion
                r = 255 - r;
                g = 255 - g;
                b = 255 - b;
                
                int avg = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
                r = g = b = avg;
                
                // multiply by alpha again, divide by 255 to undo the
                // scaling before, store the new values and advance
                // the pointer we're reading pixel data from
                linePointer[0] = r * linePointer[3] / 255;
                linePointer[1] = g * linePointer[3] / 255;
                linePointer[2] = b * linePointer[3] / 255;
                linePointer += 4;
            }
        }
    }
    
    
    
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, w * h * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( w, h, 8, 32, w<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    CGContextSaveGState(m_ctx);
    float tmp = 1/m_scale;
    CGContextTranslateCTM(m_ctx, x * tmp, (y + h) * tmp);
    CGContextScaleCTM(m_ctx, tmp, -tmp);
    CGContextDrawImage(m_ctx, CGRectMake(0, 0, w, h), img);
    
    CGContextRestoreGState(m_ctx);
    CGImageRelease(img);
}
-(void)DrawBmp:(PDFDIB *)dib :(int)x :(int)y :(int)w :(int)h :(bool)complete
{
    if (darkMode && !complete) {
        [self FillRect:CGRectMake(x, y, w, h) :0xFFFFFFFF];
        return;
    }
    
    Byte *data = (Byte *)[dib data];
    int dw = [dib width];
    int dh = [dib height];
    
    if (darkMode && ![dib cached]) {
        [dib setCached:YES];
        
        // run through every pixel, a scan line at a time...
        for(int ay = 0; ay < dh; ay++)
        {
            // get a pointer to the start of this scan line
            unsigned char *linePointer = &data[ay * dw * 4];
            
            // step through the pixels one by one...
            for(int ax = 0; ax < dw; ax++)
            {
                // get RGB values. We're dealing with premultiplied alpha
                // here, so we need to divide by the alpha channel (if it
                // isn't zero, of course) to get uninflected RGB. We
                // multiply by 255 to keep precision while still using
                // integers
                int r, g, b;
                if(linePointer[3])
                {
                    r = linePointer[0] * 255 / linePointer[3];
                    g = linePointer[1] * 255 / linePointer[3];
                    b = linePointer[2] * 255 / linePointer[3];
                }
                else
                    r = g = b = 0;
                
                // perform the colour inversion
                r = 255 - r;
                g = 255 - g;
                b = 255 - b;
                
                int avg = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
                r = g = b = avg;
                
                // multiply by alpha again, divide by 255 to undo the
                // scaling before, store the new values and advance
                // the pointer we're reading pixel data from
                linePointer[0] = r * linePointer[3] / 255;
                linePointer[1] = g * linePointer[3] / 255;
                linePointer[2] = b * linePointer[3] / 255;
                linePointer += 4;
            }
        }
    }
    
    
    
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, dw * dh * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( dw, dh, 8, 32, dw<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    CGContextSaveGState(m_ctx);
    float tmp = 1/m_scale;
    CGContextTranslateCTM(m_ctx, x * tmp, (y + h) * tmp);
    CGContextScaleCTM(m_ctx, tmp, -tmp);
    //NSTimeInterval time0 = [[NSDate date] timeIntervalSince1970]*1000;
    CGContextDrawImage(m_ctx, CGRectMake(0, 0, w, h), img);
    //NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000 - time0;
    //NSLog(@"drawimg %d", (int)time1);
    CGContextRestoreGState(m_ctx);
    CGImageRelease(img);
}

-(void)FillRect:(CGRect) rect :(int) color
{
    if(darkMode && color == 0xFFFFFFFF)
        color = 0xFF000000;
    
    CGFloat clr[4];
    clr[0] = ((Byte *)&color)[2] / 255.0f;
    clr[1] = ((Byte *)&color)[1] / 255.0f;
    clr[2] = ((Byte *)&color)[0] / 255.0f;
    clr[3] = ((Byte *)&color)[3] / 255.0f;
    float tmp = 1/m_scale;
    rect.origin.x *= tmp;
    rect.origin.y *= tmp;
    rect.size.width *= tmp;
    rect.size.height *= tmp;
    CGContextSetFillColor(m_ctx, clr);
    CGContextFillRect(m_ctx, rect);
}
-(CGContextRef)context
{
    return m_ctx;
}
@end
