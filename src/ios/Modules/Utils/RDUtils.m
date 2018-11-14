//
//  RDUtils.m
//  RadaeePDF-Cordova
//
//  Created by Emanuele Bortolami on 26/09/17.
//

#import "RDUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Radaee)

- (NSString *)MD5
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5([self bytes], 32, md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

@end

@implementation NSString (Radaee)

- (NSString *)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end

@implementation RDUtils

#pragma mark - Utils

+ (NSString *)getPDFID:(NSString *)pdfPath password:(NSString *)password
{
    PDFDoc *m_doc = [[PDFDoc alloc] init];
    if ([m_doc open:pdfPath :password] == 0) {
        return [RDUtils getPDFIDForDoc:m_doc];
    }
    
    return @"";
}

+ (NSString *)getPDFIDForDoc:(PDFDoc *)m_doc
{
    if (m_doc) {
        
        NSString *pdfid = [RDUtils getTagId:m_doc];
        
        if (pdfid.length > 0) {
            return pdfid;
        }
        
        unsigned char *pConstChar = malloc(32);
        [m_doc PDFID:pConstChar];
        NSData *data = [NSData dataWithBytes:pConstChar length:32];
        NSLog(@"%@", [data MD5]);
        pdfid = [data MD5];
        
        [RDUtils setTagId:pdfid doc:m_doc];
        
        return pdfid;
    }
    
    return @"";
}

+ (NSString *)getTagId:(PDFDoc *)m_doc
{
    if (m_doc) {
        return [m_doc meta:UUID];
    }
    
    return @"";
}

+ (void)setTagId:(NSString *)tag doc:(PDFDoc *)m_doc
{
    if (m_doc) {
        [m_doc setMeta:UUID :tag];
        [m_doc save];
    }
}

+ (NSDate *)dateFromPdfDate:(NSString *)dateString
{
    if (!dateString || dateString.length == 0) {
        return nil;
    }
    // Remove "D:"
    dateString = [dateString stringByReplacingOccurrencesOfString:@"D:" withString:@""];
    
    // Replace "'" with ":"
    dateString = [dateString stringByReplacingOccurrencesOfString:@"'" withString:@":"];
    
    // Remove the last "'"
    dateString = [dateString substringToIndex:(dateString.length - 1)];
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmssZ"];
    NSDate *date = [dateFormat dateFromString:dateString];
    
    return date;
}

+ (NSString *)pdfDateFromDate:(NSDate *)date
{
    // Convert date object to desired output format
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmssZZZZZ"];
    NSString* dateString = [dateFormat stringFromDate:date];
    
    dateString = [@"D:" stringByAppendingString:[[dateString stringByReplacingOccurrencesOfString:@":" withString:@"'"] stringByAppendingString:@"'"]];
    
    return dateString;
}

@end
