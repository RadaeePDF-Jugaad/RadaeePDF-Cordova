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
        return @"Document not set";
    }
    
    int pageCount = [currentDoc pageCount];
    
    //Check if the page index exist
    if (page >= 0 && page <= pageCount) {
        PDFPage *docPage = [currentDoc page:page];
        NSDictionary *dict = [self infoForPage:docPage number:page];
        
        NSString *jsonString = [self jsonStringFromDict:dict];
        
        return jsonString;
    }
    
    return @"Page index error";
}

//Get JSON string for all pages
- (NSString *)jsonInfoForAllPages
{
    //Check if PDFDoc instance exist
    if (!currentDoc) {
        return @"Document not set";
    }
    
    NSDictionary *dict = [self infoForAllPages];
    return [self jsonStringFromDict:dict];
}

//Get annotations info for all pages
- (NSDictionary *)infoForAllPages
{
    NSMutableArray *arr = [NSMutableArray array];
    
    int pageCount = [currentDoc pageCount];
    
    for (int i = 0; i < pageCount; i++) {
        PDFPage *page = [currentDoc page:i];
        if ([page annotCount] > 0) {
            [arr addObject:[self infoForPage:page number:i]];
        }
    }
    
    return @{@"Pages" : arr};
}

//Get annotations info for a single page
- (NSDictionary *)infoForPage:(PDFPage *)page number:(int)pageNumber
{
    NSMutableArray *arr = [NSMutableArray array];
    
    int annotCount = [page annotCount];
    
    for (int i = 0; i < annotCount; i++) {
        NSDictionary *element = [self infoForAnnot:[page annotAtIndex:i]];
        
        if (element) {
            [arr addObject:element];
        }
    }
    
    return @{@"Page" : [NSNumber numberWithInt:pageNumber], @"Annots" : arr};
}

//Create the single annotation info dictionary
- (NSDictionary *)infoForAnnot:(PDFAnnot *)annot
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([self canStoreAnnot:annot]) {
        @try {
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getIndex]]] forKey:@"Index"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot type]]] forKey:@"Type"];
            [dict setObject:[self valueForField:[annot fieldName]] forKey:@"FieldName"];
            [dict setObject:[self valueForField:[annot fieldNameWithNO]] forKey:@"FieldNameWithNO"];
            [dict setObject:[self valueForField:[annot fieldFullName]] forKey:@"FieldFullName"];
            [dict setObject:[self valueForField:[annot fieldFullName2]] forKey:@"FieldFullName2"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot fieldType]]] forKey:@"FieldType"];
            [dict setObject:[self valueForField:[annot getPopupLabel]] forKey:@"PopupLabel"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getCheckStatus]]] forKey:@"CheckStatus"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getComboSel]]] forKey:@"ComboItemSel"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getComboItemCount]]] forKey:@"ComboItemCount"];
            //[dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getListSels:<#(int *)#> :<#(int)#>]]] forKey:@"ListSels"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getListItemCount]]] forKey:@"ListItemCount"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getEditType]]] forKey:@"EditType"];
            [dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getSignStatus]]] forKey:@"SignStatus"];
            [dict setObject:[self valueForField:[annot getEditText]] forKey:@"EditText"];
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
