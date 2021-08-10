//
//  PDFHttpStream.m
//  PDFViewer
//
//  Created by strong on 14-3-23.
//
//

#import "PDFHttpStream.h"
#import "objc/objc-sync.h"

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
        m_buf_pos = 0;
        m_stask = nil;
    }
    return self;
}

-(void)dealloc
{
	[self close];
}

+(void)dis_release:(dispatch_object_t)obj
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(obj);
#endif
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //100-199: temp status
    //200-299: some status like succeeded/empty content/reset/created/accepted.
    //300-399: some redirect status
    //400-???: error codes.
    if (httpResponse.statusCode >= 400)
    {
        dispatch_semaphore_signal(m_event);
        return;//error code, not continue session.
    }
    //completionHandler(NSURLSessionResponseAllow);//continue to process session.
    completionHandler(NSURLSessionResponseBecomeDownload);//continue to process session.
    int len = (int)response.expectedContentLength;
    [self init_len:len];
    dispatch_semaphore_signal(m_event);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if(dataTask == m_stask)
    {
        int dlen = (int)[data length];
        const Byte *dat = [data bytes];
        while(dlen >= BLOCK_SIZE - m_buf_pos)
        {
            objc_sync_enter(self);
            if(!m_block_flags[m_block_pos])
            {
                fseek(m_file, m_block_pos * BLOCK_SIZE, SEEK_SET);
                memcpy(m_buf, dat, BLOCK_SIZE - m_buf_pos);
                fwrite(m_buf, BLOCK_SIZE, 1, m_file);
                m_block_flags[m_block_pos] = true;
            }
            objc_sync_exit(self);
            dat += BLOCK_SIZE - m_buf_pos;
            dlen -= BLOCK_SIZE - m_buf_pos;
            m_block_pos++;
            m_buf_pos = 0;
        }
        memcpy(m_buf, dat, dlen);
        m_buf_pos = dlen;
        if(BLOCK_SIZE * m_block_pos + m_buf_pos >= m_total)
        {
            if(!m_block_flags[m_block_pos])
            {
                fseek(m_file, m_block_pos * BLOCK_SIZE, SEEK_SET);
                fwrite(m_buf, m_buf_pos, 1, m_file);
                m_block_flags[m_block_pos] = true;
            }
            [m_stask cancel];
        }
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
}

-(BOOL)open :(NSString *)url :(NSString *)cache_file;
{
    m_url = [NSURL URLWithString:url];
    m_cache_path = cache_file;

    m_event = dispatch_semaphore_create(0);
    //start backing thread.
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:m_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60 + 30 * m_total / BLOCK_SIZE];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    m_queue = [[NSOperationQueue alloc] init];
    m_queue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:m_queue];//callback in current queue
    m_stask = [session dataTaskWithRequest:request];
    [m_stask resume];
    dispatch_semaphore_wait(m_event,DISPATCH_TIME_FOREVER);
    [PDFHttpStream dis_release :m_event];
    m_event = nil;
    return m_file && m_total > 0;
}

-(void)init_len:(int)len
{
    m_total = len;
    if( len > 0 )
    {
        m_file = fopen([m_cache_path UTF8String], "wb+");//read-write cached file.
        unsigned char tmp[8192];
        memset( tmp, 0, 8192 );
        int cur = 0;
        while( cur < m_total - 8191 )
        {
            fwrite( tmp, 8192, 1, m_file );
            cur += 8192;
        }
        fwrite( tmp, m_total - cur, 1, m_file );
        m_block_cnt = (m_total + BLOCK_SIZE - 1)/BLOCK_SIZE;
        m_block_flags = (unsigned char *)calloc(m_block_cnt, sizeof(unsigned char));
        NSLog(@"%d",m_block_cnt);
        NSLog(@"END write file at path: %@", m_cache_path);
    }
}

-(bool)writeable
{
    return false;
}

-(void)close 
{
    if(m_stask)
    {
        [m_stask cancel];
        m_stask = nil;
    }
    if(m_queue)
    {
        [m_queue cancelAllOperations];
        [m_queue waitUntilAllOperationsAreFinished];
        m_queue = nil;
    }
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
    bool ret = true;
	while( start < end )
	{
        objc_sync_enter(self);
		while( start < end && m_block_flags[start] ) start++;
		int prev = start;
		while( start < end && !m_block_flags[start] ) start++;
        objc_sync_exit(self);
		if( start > prev )
		{
            NSLog(@"START Download blocks: %d to %d", prev, start);
			int len = 0;
			int off = prev * BLOCK_SIZE;
		    len = m_total - off;
		    if( len > (start - prev) * BLOCK_SIZE )
		    	len = (start - prev) * BLOCK_SIZE;

		    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:m_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60 + 30 * (start - prev - 1)];
		    [urlRequest setHTTPMethod:@"GET"];
		    NSString *hval = [NSString stringWithFormat:@"bytes=%i-%i", off, off + len - 1];
		    [urlRequest setValue:hval forHTTPHeaderField:@"Range"];
            //[urlRequest setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];

            dispatch_semaphore_t swait = dispatch_semaphore_create(0);
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = nil;
            dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data)
                {
                    const Byte *bdat = data.bytes;
                    int blen = (int)data.length;
                    objc_sync_enter(self);
                    fseek(self->m_file, off, SEEK_SET);
                    fwrite(bdat, blen, 1, self->m_file);
                    int ib = prev;
                    while(ib < start) self->m_block_flags[ib++] = true;
                    objc_sync_exit(self);
                }
                [dataTask cancel];
                dispatch_semaphore_signal(swait);
            }];
            [dataTask resume];
            dispatch_semaphore_wait(swait,DISPATCH_TIME_FOREVER);
            [PDFHttpStream dis_release :swait];
            swait = nil;
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
	while( times > 0 && ![self download_blocks :bstart :bend]) times--;
	if( times == 0 ) return 0;
	fseek( m_file, m_pos, SEEK_SET );
	int ret = (int)fread( data, 1, len, m_file );
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
    if( pos < 0 ) pos = 0;
    if( pos > m_total ) pos = m_total;
    if(pos == m_pos) return true;
    m_pos = (int)pos;
    return true;
}

@end
