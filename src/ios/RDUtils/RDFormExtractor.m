//
//  RDFormExtractor.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 16/01/17.
//
//

#import "RDFormExtractor.h"
#import "PDFObjc.h"

@interface RDFormExtractor() {
    PDFDoc *currentDoc;
}

@end

@implementation RDFormExtractor

//Init with PDFDoc instance
- (instancetype)initWithDoc:(id)doc
{
    self = [super init];
    
    if (self) {
        if ([doc isKindOfClass:[PDFDoc class]]) {
            currentDoc = doc;
        }
    }
    
    return self;
}

//Get JSON string for a single page
- (NSString *)jsonInfoForPage:(int)page
{
    //Check if PDFDoc instance exist
    if (!currentDoc) {
        return @"";
    }
    
    int pageCount = [currentDoc pageCount];
    
    //Check if the page index exist
    if (page >= 0 && page <= pageCount) {
        PDFPage *docPage = [currentDoc page:page];
        NSMutableDictionary *dict = [self infoForPage:docPage];
        NSString *jsonString = [self jsonStringFromDict:dict];
        
        return jsonString;
    }
    
    return @"";
}

//Get JSON string for all pages
- (NSString *)jsonInfoForAllPages
{
    //Check if PDFDoc instance exist
    if (!currentDoc) {
        return @"";
    }
    
    NSMutableDictionary *dict = [self infoForAllPages];
    return [self jsonStringFromDict:dict];
}

//Get annotations info for all pages
- (NSMutableDictionary *)infoForAllPages
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    int pageCount = [currentDoc pageCount];
    
    for (int i = 0; i < pageCount; i++) {
        PDFPage *page = [currentDoc page:i];
        if ([page annotCount] > 0) {
            [dict setObject:[self infoForPage:page] forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
    
    return dict;
}

//Get annotations info for a single page
- (NSMutableDictionary *)infoForPage:(PDFPage *)page
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    int annotCount = [page annotCount];
    
    for (int i = 0; i < annotCount; i++) {
        NSDictionary *element = [self infoForAnnot:[page annotAtIndex:i]];
        
        if (element) {
            [dict setObject:element forKey:[NSString stringWithFormat:@"%i", i]];
        }
    }
    
    return dict;
}

//Create the single annotation info dictionary
- (NSDictionary *)infoForAnnot:(PDFAnnot *)annot
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([self canStoreAnnot:annot]) {
        @try {
            [dict setObject:[self valueForField:[annot fieldName]] forKey:@"fieldName"];
            [dict setObject:[self valueForField:[annot fieldNameWithNO]] forKey:@"fieldNameWithNO"];
            [dict setObject:[self valueForField:[annot fieldFullName]] forKey:@"fieldFullName"];
            [dict setObject:[self valueForField:[annot fieldFullName2]] forKey:@"fieldFullName2"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot fieldType]]] forKey:@"fieldType"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getEditType]]] forKey:@"editType"];
            [dict setObject:[self valueForField:[annot getEditText]] forKey:@"editText"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getComboSel]]] forKey:@"comboSel"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getComboItemCount]]] forKey:@"comboItemCount"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getCheckStatus]]] forKey:@"checkStatus"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getSignStatus]]] forKey:@"signStatus"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot type]]] forKey:@"type"];
        } @catch (NSException *exception) {
            dict = nil;
        }
        
        return dict;
    }
    
    return nil;
}

//Return string value for field
- (id)valueForField:(id)field
{
    if ([field isKindOfClass:[NSString class]]) {
        return [NSString stringWithString:(NSString *)field];
    }
    
    if ([field isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)field;
        if ([num doubleValue] >= 0) {
            return [NSString stringWithFormat:@"%d", num.intValue];
        }
        
        return @"";
    }
    
    return @"";
}

//Get JSON info as string starting from a NSDictionaty struct
- (NSString *)jsonStringFromDict:(NSDictionary *)dict
{
    if ([dict count] > 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return jsonString;
    }
    
    return @"";
}

//Check if the annot is an editText or a Widget
- (BOOL)canStoreAnnot:(PDFAnnot *)annot
{
    int annotType = [annot type];
    return (annotType == 0 || annotType == 3 || annotType == 20);
}

@end
