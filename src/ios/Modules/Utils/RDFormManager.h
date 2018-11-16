//
//  RDFormManager.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 16/01/17.
//
//

#import <Foundation/Foundation.h>

@interface RDFormManager : NSObject

//init
- (instancetype)initWithDoc:(id)doc;

//Getter
- (NSString *)jsonInfoForAllPages;
- (NSString *)jsonInfoForPage:(int)page;

//Setter
- (void)setInfoWithJson:(NSString *)json error:(NSError **)error;

@end
