//
//  RDUtils.h
//  RadaeePDF-Cordova
//
//  Created by Emanuele Bortolami on 26/09/17.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "RDVGlobal.h"

#define UUID @"UUID"

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

@interface RDFileItem : NSObject
-(id)init:(NSString *)help :(NSString *)path :(int)level;
@property NSString *help;
@property NSString *path;
@property int level;
@property RDVLocker *locker;
@end

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
+ (UIColor *)invertColor:(UIColor *)color;
+ (id)getGlobalFromString:(NSString *)string;
+ (void)setGlobalFromString:(NSString *)string withValue:(id)value;
+ (UIColor *)radaeeWhiteColor;
+ (UIColor *)radaeeBlackColor;
@end
