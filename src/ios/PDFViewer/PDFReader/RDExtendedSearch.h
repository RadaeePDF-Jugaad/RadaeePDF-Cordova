//
//  RDExtendedSearch.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 04/08/14.
//
//

#import <Foundation/Foundation.h>

#import "PDFIOS.h"
#import "RDVGlobal.h"
#import "RDVPage.h"

#define SEARCH_LIST 1

@interface RDSearchResult : NSObject

@property (strong, nonatomic) NSString *stringResult;
@property (nonatomic) int page;

+ (RDSearchResult *)initWithString:(NSString *)stringToShow forPage:(int)page;

@end

@interface RDExtendedSearch : NSObject
{
    RDPDFPage *m_page;
    RDPDFDoc *m_doc;
    RDPDFFinder *m_finder;
    void(^finishBlock)(void);
    void(^progressBlock)(NSMutableArray *, NSMutableArray *);
}

@property (nonatomic) BOOL searching;
@property (nonatomic) BOOL stop;
@property (strong, nonatomic) NSString *searchTxt;
@property (strong, nonatomic) NSMutableArray *searchResults;

+ (RDExtendedSearch *)sharedInstance;

- (BOOL)searchInit:(RDPDFDoc *)doc;
- (void)searchText:(NSString *)text inDoc:(RDPDFDoc *)doc progress:(void (^)(NSMutableArray *occurrences, NSMutableArray *total))progress finish:(void (^)(void))finish;
- (void)addPageSearchResults:(RDPDFFinder *)finder forPage:(int)page progress:(void (^)(NSMutableArray *occurrences, NSMutableArray *total))progress;
- (BOOL)pageIsInSearchResults:(int)page;
- (int)getNextPageFromCurrentPage:(int)page;
- (int)getPrevPageFromCurrentPage:(int)page;
- (void)clearSearch;
- (void)clearSearch:(void (^)(void))finish;
- (void)restoreProgress:(void (^)(NSMutableArray *occurrences, NSMutableArray *total))progress;
- (void)restoreFinish:(void (^)(void))finish;

- (BOOL)occurrenceAlreadyExist:(RDSearchResult *)searchResult;

- (BOOL)hasPrevOccurrences:(int)curPage;
- (BOOL)hasNextOccurrences:(int)curPage;

@end
