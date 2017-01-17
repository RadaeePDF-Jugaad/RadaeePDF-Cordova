//
//  RDFormExtractor.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 16/01/17.
//
//

#import <Foundation/Foundation.h>

@interface RDFormExtractor : NSObject

- (instancetype)initWithDoc:(id)doc;
- (NSString *)jsonInfoForAllPages;
- (NSString *)jsonInfoForPage:(int)page;

@end
