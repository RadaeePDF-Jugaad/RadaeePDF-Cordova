//
//  RDUtils.h
//  RadaeePDF-Cordova
//
//  Created by Emanuele Bortolami on 26/09/17.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"

#define UUID @"UUID"

@interface NSData (Radaee)

- (NSString *)MD5;

@end

@interface NSString (Radaee)

- (NSString *)MD5;

@end

@interface RDUtils : NSObject

+ (NSString *)getPDFID:(NSString *)pdfPath password:(NSString *)password;
+ (NSString *)getPDFIDForDoc:(PDFDoc *)m_doc;
+ (NSDate *)dateFromPdfDate:(NSString *)dateString;
+ (NSString *)pdfDateFromDate:(NSDate *)date;

@end
