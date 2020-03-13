//
//  RDFileTableController.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 __Radaee__. All rights reserved.


#import <UIKit/UIKit.h>
#import "sys/utsname.h"
#import "PDFHttpStream.h"
#import "RDLoPDFViewController.h"
#import "RDPDFReflowViewController.h"
#import "RDPageViewController.h"
#import "RDVGlobal.h"
#import "PDFHttpStream.h"

@interface PDFFileStream : NSObject<PDFStream>
{
    FILE *m_file;
    bool m_writable;
}
-(bool)writeable;
-(int)read: (void *)buf :(int)len;
-(int)write:(const void *)buf :(int)len;
-(unsigned long long)position;
-(unsigned long long)length;
-(bool)seek:(unsigned long long)pos;
@end

@interface RDFileTableController : UITableViewController <UIApplicationDelegate>
{
    RDLoPDFViewController *m_pdf;
    RDPDFReflowViewController *m_pdfR;
    RDPageViewController *m_pdfP;
    NSMutableArray *m_files;
    void *buffer;
    PDFHttpStream *httpStream;
}
@end




