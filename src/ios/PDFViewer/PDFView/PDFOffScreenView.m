//
//  PDFOffScreenView.m
//  PDFViewer
//
//  Created by Radaee on 2016/12/6.
//
//

#import <Foundation/Foundation.h>
#import "PDFOffScreenView.h"
#import "RDVGlobal.h"


@implementation PDFOffScreenView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_del = nil;
    }
    return self;
}

-(void)setDelegate :(id<PDFOffScreenDelegate>)del;
{
    m_del = del;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(m_del)
        [m_del onDrawOffScreen:ctx];
}

@end
