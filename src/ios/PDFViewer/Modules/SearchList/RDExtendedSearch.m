//
//  RDExtendedSearch.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 04/08/14.
//
//

#import "RDExtendedSearch.h"

@implementation RDSearchResult

+ (RDSearchResult *)initWithString:(NSString *)stringToShow forPage:(int)page
{
    RDSearchResult *item = [[RDSearchResult alloc] init];
    item.stringResult = stringToShow;
    item.page = page;
    
    return item;
}

@end

@implementation RDExtendedSearch

+ (RDExtendedSearch *)sharedInstance
{
    static RDExtendedSearch *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RDExtendedSearch alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (BOOL)searchInit:(PDFDoc *)doc
{
    m_doc = doc;
    m_finder = NULL;
    
    return YES;
}

- (void)searchText:(NSString *)text inDoc:(PDFDoc *)doc progress:(void (^)(NSMutableArray *, NSMutableArray *))progress finish:(void (^)(void))finish
{
    _searching = YES;
    self.searchResults =  [[NSMutableArray alloc] init];
    self.searchTxt = text;
    [self searchInit:doc];
    progressBlock = progress;
    finishBlock = finish;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < self->m_doc.pageCount; i++) {
            if (self->_stop) {
                self->_searching = NO;
                [self clearSearch:self->finishBlock];
                return;
            }
            if (self->m_doc) {
                self->m_page = [self->m_doc page:i];
                if (self->m_page) {
                    [self->m_page objsStart];
                    self->m_finder = [self->m_page find:text :GLOBAL.g_case_sensitive :GLOBAL.g_match_whole_word];
                    
                    if (self->m_finder.count > 0) {
                        [self addPageSearchResults:self->m_finder forPage:i progress:self->progressBlock];
                    }
                    
                    self->m_page = nil;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        self->_searching = NO;
        if (self->finishBlock) {
            self->finishBlock();
        }
    });
}

- (void)addPageSearchResults:(PDFFinder *)finder forPage:(int)page progress:(void (^)(NSMutableArray *, NSMutableArray *))progress
{
    NSMutableArray *progressResult = [NSMutableArray array];
    for (int i = 0; i < finder.count; i++) {
        
        int firstChar = [finder objsIndex:i];
        int endChar = firstChar + (int)[self.searchTxt length];
        int ichar = firstChar - 25 < 0 ? 0 : firstChar - 25;
        int ichar_end = endChar + 25 < [m_page objsCount] ? endChar + 25 : [m_page objsCount] - 1;

        ichar = [m_page objsAlignWord:ichar :-1];
        ichar_end = [m_page objsAlignWord:ichar_end :1] + 1;
        
        RDSearchResult *searchResult = [RDSearchResult initWithString:[[[m_page objsString:ichar :ichar_end] stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\r" withString:@" "] forPage:page + 1];
        
        if (![self occurrenceAlreadyExist:searchResult]) {
            [self.searchResults addObject:searchResult];
            [progressResult addObject:searchResult];
        }
    }
    
    if (progress) {
        progress(progressResult, [NSMutableArray arrayWithArray:self.searchResults]);
    }
}

- (BOOL)occurrenceAlreadyExist:(RDSearchResult *)searchResult
{
    for (RDSearchResult *issue in self.searchResults) {
        if ([searchResult.stringResult isEqualToString:issue.stringResult] && searchResult.page == issue.page) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)pageIsInSearchResults:(int)page
{
    for (RDSearchResult *issue in self.searchResults) {
        if (issue.page == page) {
            return YES;
        }
    }
    
    return false;
}

- (int)getNextPageFromCurrentPage:(int)page
{
    int i = 0;
    while (i < self.searchResults.count && [(RDSearchResult *)[self.searchResults objectAtIndex:i] page] <= (page + 1)) {
        i++;
    }
    
    if (i >= self.searchResults.count) {
        return -1;
    }
    
    return [(RDSearchResult *)[self.searchResults objectAtIndex:i] page] - 1;
}

- (int)getPrevPageFromCurrentPage:(int)page
{
    int i = (int)self.searchResults.count - 1;
    while (i >= 0 && (page + 1) <= [(RDSearchResult *)[self.searchResults objectAtIndex:i] page]) {
        i--;
    }
    
    if (i >= 0) {
        return [(RDSearchResult *)[self.searchResults objectAtIndex:i] page] - 1;
    }
    
    return -1;
}

- (BOOL)hasPrevOccurrences:(int)curPage
{
    if ([self getPrevPageFromCurrentPage:curPage] > -1) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasNextOccurrences:(int)curPage
{
    if ([self getNextPageFromCurrentPage:curPage] > -1) {
        return YES;
    }
    
    return NO;
}

- (void)clearSearch {
    [self clearSearch:nil];
}

- (void)clearSearch:(void (^)(void))finish
{
    finishBlock = finish;
    
    // controllo se la ricerca è in corso e setto lo stop a true
    // in questo modo posso interrompere la ricerca in esecuzione senza crash
    if (_searching) {
        _stop = YES;
    } else {
        _stop = NO;
        m_page = NULL;
        m_doc = NULL;
        m_finder = NULL;
        [self.searchResults removeAllObjects];
        
        if (finishBlock) {
            finishBlock();
        }
    }
}

- (void)restoreProgress:(void (^)(NSMutableArray *, NSMutableArray *))progress {
    progressBlock = progress;
}

- (void)restoreFinish:(void (^)(void))finish {
    finishBlock = finish;
}

@end
