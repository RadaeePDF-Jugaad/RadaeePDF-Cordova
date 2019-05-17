//
//  PDFReflowView.m
//  PDFViewer
//
//  Created by strong on 14-1-21.
//
//

#import "PDFReflowView.h"
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;

@implementation PDFReflowView
@synthesize m_image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    imageView = [[UIImageView alloc] initWithFrame:frame];
    if (self) {
       
        m_doc = NULL;
        scale = [[UIScreen mainScreen] scale];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.pagingEnabled =YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = (id<UIScrollViewDelegate>)self;
        self.scrollEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}
-(void)vOpen:(PDFDoc *)doc :(NSString *)docPath
{
    [self vClose];
    if(m_cur_page){
        m_cur_page = 0;
    }
    m_doc = doc;
    [m_doc open:docPath : NULL];
    [self addSubview:imageView];
}


-(void)render :(int)PageNo :(float)ratio
{
    int gap = 5;
    m_page = [m_doc page:PageNo];
    
    m_w = self.frame.size.width*scale;
    m_h = [m_page reflowPrepare:m_w  - gap * 2:scale*ratio] +  gap * 2;
    CGSize size = CGRectMake(0, 0, m_w/scale, m_h/scale+44).size;
    [self setContentSize:size];
    [imageView setFrame:CGRectMake(0, 0, m_w/scale, m_h/scale)];
    
    dib = [[PDFDIB alloc] init:m_w :m_h];
    
    
    [m_page reflow:dib :gap:gap];
    
    void *data = [dib data];
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, m_w * m_h * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    m_img = CGImageCreate( m_w, m_h, 8, 32, m_w<<2, cs, kCGBitmapByteOrder32Big|kCGImageAlphaNoneSkipLast, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease( provider );
    imageView.image = nil;
    
    m_image = [UIImage imageWithCGImage:m_img];
    
    [imageView setImage:m_image];
    CGImageRelease(m_img);
    [self setNeedsDisplay];
}
-(void)vClose
{
    m_doc = NULL;
}

@end
