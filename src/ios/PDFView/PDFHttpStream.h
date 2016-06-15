//
//  PDFHttpStream.h
//  PDFViewer
//
//  Created by strong on 14-3-23.
//
//

#import <UIKit/UIKit.h>
#import "PDFIOS.h"
#import "PDFVGlobal.h"

#define BLOCK_SIZE 8192
#define testUrlPath @"http://www.radaee.com/files/test.pdf"

@interface PDFHttpStream : NSObject <PDFStream>
{
    int m_total;
    int m_pos;
    int m_block_cnt;
    unsigned char *m_block_flags;
    NSString *m_cache_path;
    FILE *m_file;
    NSURL *m_url;
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
