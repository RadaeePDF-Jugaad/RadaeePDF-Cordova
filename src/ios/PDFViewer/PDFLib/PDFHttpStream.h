//
//  PDFHttpStream.h
//  PDFViewer
//
//  Created by strong on 14-3-23.
//
//

#import <UIKit/UIKit.h>
#import "PDFIOS.h"
#import "RDVGlobal.h"

#define BLOCK_SIZE 4096
#define testUrlPath @"https://www.radaeepdf.com/documentation/MRBrochoure.pdf"
@interface PDFHttpStream : NSObject <PDFStream, NSURLSessionDelegate>
{
    int m_total;
    int m_pos;
    int m_block_cnt;
    int m_block_pos;
    unsigned char *m_block_flags;
    NSString *m_cache_path;
    FILE *m_file;
    NSURL *m_url;
    dispatch_semaphore_t m_event;

    NSURLSessionDataTask *m_stask;
    NSOperationQueue *m_queue;
    unsigned char m_buf[BLOCK_SIZE];
    int m_buf_pos;
}
-(id)init;
-(BOOL)open :(NSString *)url :(NSString *)cache_file;
-(void)close;
-(bool)writeable;
-(int)read: (void *)buf :(int)len;
-(int)write:(const void *)buf :(int)len;
-(unsigned long long)position;
-(unsigned long long)length;
-(bool)seek:(unsigned long long)pos;
@end
