//
//  PDFHttpStream.m
//  PDFViewer
//
//  Created by strong on 14-3-23.
//
//

#import "PDFHttpStream.h"

@implementation PDFHttpStream

-(id)init
{
    if( self = [super init] )
    {
	    m_file = NULL;
	    m_total = 0;
	    m_pos = 0;
	    m_block_cnt = 0;
	    m_block_flags = NULL;
	    m_url = NULL;
    }
    return self;
}

-(void)dealloc
{
	[self close];
}

-(BOOL)open :(NSString *)url :(NSString *)cache_file;
{
    m_url = [NSURL URLWithString:url];
    m_cache_path = cache_file;
    [self init_length];
    return m_file && m_total > 0;
}

-(void)init_length
{
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:m_url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60.0];
	NSHTTPURLResponse *lenResponse;
	
    [urlRequest setValue:@"Keep-Alive" forHTTPHeaderField:@"Close"];
    
	[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&lenResponse error:nil];
	long len = [[[lenResponse allHeaderFields] objectForKey:@"Content-Length"] intValue];
	m_total = len;
    [NSURLConnection cancelPreviousPerformRequestsWithTarget:urlRequest];
	if( len > 0 )
	{
	    m_file = fopen([m_cache_path UTF8String], "wb+");//read-write cached file.
	    unsigned char tmp[4096];
	    memset( tmp, 0, 4096 );
	    int cur = 0;
	    while( cur < m_total - 4095 )
	    {
	    	fwrite( tmp, 1, 4096, m_file );
	    	cur += 4096;
	    }
	    fwrite( tmp, 1, m_total - cur, m_file );
	    m_block_cnt = (m_total + BLOCK_SIZE - 1)/BLOCK_SIZE;
	    m_block_flags = (unsigned char *)malloc(m_block_cnt * sizeof(unsigned char));
	    memset( m_block_flags, 0, m_block_cnt * sizeof(unsigned char) );//init all flags.
        NSLog(@"END write file at path: %@", m_cache_path);
	}
}

-(bool)writeable
{
    return false;
}

-(void)close 
{
    if( m_file )
    {
        fclose(m_file);
    	m_file = NULL;
    	unlink( [m_cache_path UTF8String] );
   	}
   	if( m_block_flags )
   	{
   		free( m_block_flags );
   		m_block_flags = NULL;
   	}
    m_total = 0;
    m_pos = 0;
    m_block_cnt = 0;
    m_url = NULL;
}

-(bool)download_blocks :(int) start :(int)end
{
	NSLog(@"START Download blocks: %d to %d", start, end);
    bool ret = true;
	while( start < end )
	{
		while( start < end && m_block_flags[start] ) start++;
		int prev = start;
		while( start < end && !m_block_flags[start] ) start++;
		if( start > prev )
		{
			int len = 0;
			int off = prev * BLOCK_SIZE;
		    len = m_total - off;
		    if( len > (start - prev) * BLOCK_SIZE )
		    	len = (start - prev) * BLOCK_SIZE;

		    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:m_url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60 + 30 * (start - prev - 1)];
		    NSHTTPURLResponse *urlResponse;
		    [urlRequest setHTTPMethod:@"GET"];
		    NSString *hval = [NSString stringWithFormat:@"bytes=%i-%i", off, off + len];
		    [urlRequest setValue:hval forHTTPHeaderField:@"Range"];
		    NSError *err;
            NSLog(@"Starting synchronous request to %@ with byte range: %d-%d", m_url, off, off + len);
		    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&err];
		    if(responseData != NULL)
		   	{
		        memset( m_block_flags + prev, 1, start - prev );
			    fseek( m_file, off, SEEK_SET );
	            fwrite( [responseData bytes], 1, len, m_file );
		    }
		    else
		    	ret = false;
		}
	}
	return ret;
}

-(int)read :(void *)data :(int) len
{
	if( !m_file ) return 0;
	int bstart = m_pos / BLOCK_SIZE;
	int bend = (m_pos + len + BLOCK_SIZE - 1)/BLOCK_SIZE;
	if( bend > m_block_cnt ) bend = m_block_cnt;
	int times = 3;
	while( times > 0 && ![self download_blocks:bstart:bend]) times--;
	if( times == 0 ) return 0;
	fseek( m_file, m_pos, SEEK_SET );
	int ret = fread( data, 1, len, m_file );
	m_pos += ret;
	return ret;
}

-(int)write :(const void *)data :(int)len
{
    return 0;
}

-(unsigned long long)position
{
    if( !m_file ) return 0;
    return m_pos;
}

-(unsigned long long)length
{
    if( !m_file ) return 0;
    return m_total;
}

-(bool)seek:(unsigned long long)pos
{
	if( !m_file ) return false;
    if( pos < 0.00000000001 ) pos = 0;
    if( pos > m_total ) pos = m_total;
    if(pos == m_pos) return true;
    m_pos = pos;
    return true;
}

@end
