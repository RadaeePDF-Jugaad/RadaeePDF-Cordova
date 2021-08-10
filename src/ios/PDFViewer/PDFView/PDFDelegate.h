//
//  PDFDelegate.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/5.
//  Copyright © 2020 Radaee. All rights reserved.
//

#ifndef PDFDelegate_h
#define PDFDelegate_h

@protocol PDFOffScreenDelegate <NSObject>
-(void)onDrawOffScreen :(CGContextRef)ctx;
@end

#endif /* PDFDelegate_h */
