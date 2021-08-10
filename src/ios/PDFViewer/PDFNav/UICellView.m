//
//  UICellView.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICellView.h"
#import "RDVGlobal.h"

@interface UICellView() {
    __weak IBOutlet UIImageView *mImg;
    __weak IBOutlet UILabel *mLabel;
    __weak IBOutlet UIButton *mDelete;
    NSString *m_path;
    RDVLocker *m_locker;

    func_delete m_delete;
    PDFDIB *m_dib;//rendered thumb
    int m_dibw;
    int m_dibh;
}

@end

@implementation UICellView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_path = nil;
        m_dib = nil;
        m_locker = [[RDVLocker alloc] init];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        m_path = nil;
        m_dib = nil;
        m_locker = [[RDVLocker alloc] init];
    }
    return self;
}

- (IBAction)OnDelete:(id)sender {
    if(m_delete) m_delete(self);
}

-(void)UILoad : (NSString *)fname :(NSString *)path :(CGRect)frame :(UIImage *)def
{
    self.frame = frame;
    [mLabel setText:fname];
    m_path = path;
    float pix = [[UIScreen mainScreen] scale];
    m_dibw = pix * frame.size.width;
    m_dibh = pix * frame.size.width;
    [self setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1]];
    [mImg setContentMode:UIViewContentModeScaleAspectFit];
    [mImg setImage:def];
}

-(void)UISetDelete:(func_delete)callback
{
    m_delete = callback;
    if(!callback) mDelete.hidden = YES;
}
-(void)UIDelete
{
    [m_locker lock];
    unlink([m_path UTF8String]);
    [m_locker unlock];
}

-(void)UIUpdate
{
    if(m_dib)
    {
        CGImageRef image = [m_dib image];
        [mImg setImage:[[UIImage alloc] initWithCGImage:image]];
        CGImageRelease(image);
        //m_dib = nil;
    }
}

-(void)BKRender
{
    [m_locker lock];
    PDFDoc *doc = [[PDFDoc alloc] init];
    int err = [doc open:m_path :nil];
    if(!err)
    {
        PDFPage *page = [doc page:0];
        float pw = [doc pageWidth:0];
        float ph = [doc pageHeight:0];
        float scale0 = m_dibw / pw;
        float scale1 = m_dibh / ph;
        if(scale0 > scale1) scale0 = scale1;
        pw *= scale0;
        ph *= scale0;
        int dibw = (int)(pw + 0.5f);
        int dibh = (int)(ph + 0.5f);
        m_dib = [[PDFDIB alloc] init: dibw :dibh];
        [page renderPrepare:m_dib];
        if(![page renderThumb:m_dib])
        {
            PDFMatrix *mat = [[PDFMatrix alloc] init:scale0 :-scale0 :0 :dibh];
            [page render:m_dib :mat :2];
            mat = nil;
        }
        page = nil;
    }
    doc = nil;
    [m_locker unlock];
}

-(PDFDoc *)UIGetDoc : (NSString *)pswd :(int *)err
{
    [m_locker lock];
    PDFDoc *doc = [[PDFDoc alloc] init];
    *err = [doc open:m_path :pswd];
    [m_locker unlock];
    return doc;
}

@end
