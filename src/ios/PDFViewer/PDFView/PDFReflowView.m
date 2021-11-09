//
//  PDFReflowView.m
//  PDFViewer
//
//  Created by strong on 14-1-21.
//
//

#import "PDFReflowView.h"

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
-(void)vOpen:(RDPDFDoc *)doc :(NSString *)docPath
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
    if (m_h > 4000) m_h = 4000;//to avoid out of memory.
    CGSize size = CGRectMake(0, 0, m_w/scale, m_h/scale+44).size;
    [self setContentSize:size];
    [imageView setFrame:CGRectMake(0, 0, m_w/scale, m_h/scale)];

    m_dib = [[RDPDFDIB alloc] init:m_w :m_h];
    BOOL b = [m_page reflow:m_dib :gap:gap];
    m_image = [[UIImage alloc] initWithCGImage: [m_dib image]];
    //NSString *filePath = @"/Users/lujinrong/Downloads/image.png";
    //BOOL result =[UIImagePNGRepresentation(m_image)writeToFile:filePath atomically:YES]; //
    [imageView setImage:m_image];
    //CGImageRelease(m_img);
    [self setNeedsDisplay];
}
-(void)vClose
{
    m_doc = NULL;
}

@end
