//
//  RDFormManager.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 16/01/17.
//
//

#import "RDFormManager.h"
#import "PDFObjc.h"

@interface RDFormManager() {
    PDFDoc *currentDoc;
}

@end

@implementation RDFormManager

#pragma mark - Init
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

#pragma mark - Set Info

//Set fields with JSON string
- (void)setInfoWithJson:(NSString *)json error:(NSError **)error
{
    if (![currentDoc canSave]) {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:101 userInfo:@{@"readonly-document": @"The PDFDoc instance is readonly"}];
        return;
    }
    
    id dict = [self jsonStructFromString:json];
    
    if ([dict objectForKey:@"Pages"]) {
        NSArray *pages = [dict objectForKey:@"Pages"];
        
        for (NSDictionary *pageDict in pages) {
            [self parsePage:pageDict error:error];
        }
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:102 userInfo:@{@"pages-attribute": @"\"Pages\" attribute is missing"}];
    }
}

//Parse Page Dictionary
- (void)parsePage:(NSDictionary *)page error:(NSError **)error
{
    if ([page objectForKey:@"Page"]) {
        int index = [[page objectForKey:@"Page"] intValue];
        
        if ([page objectForKey:@"Annots"]) {
            NSArray *annots = [page objectForKey:@"Annots"];
            
            PDFPage *pdfPage = [currentDoc page:index];
            [pdfPage objsStart];
            
            for (NSDictionary *annot in annots) {
                [self parseAnnot:annot atPage:pdfPage error:error];
            }
        } else {
           *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:104 userInfo:@{@"annots-attribute": @"\"Annots\" attribute is missing"}];
        }
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:103 userInfo:@{@"page-attribute": @"\"Page\" attribute is missing"}];
    }
}

- (void)parseAnnot:(NSDictionary *)annotDict atPage:(PDFPage *)page error:(NSError **)error
{
    if ([annotDict objectForKey:@"Index"]) {
        //Get annot index
        int index = [[annotDict objectForKey:@"Index"] intValue];
        
        //Check if index is valid
        PDFAnnot *annot = [page annotAtIndex:index];
        
        if (annot) {
            switch ([annot type]) {
                case 3:
                    [self setText:annot withDict:annotDict error:error];
                    break;
                case 20:
                    [self setWidget:annot withDict:annotDict error:error];
                    break;
                    
                default:
                    break;
            }
        } else {
            *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:106 userInfo:@{@"annot-exist": [NSString stringWithFormat:@"Annot at index %i not exist", index]}];
        }
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:105 userInfo:@{@"index-attribute": @"\"Index\" attribute is missing"}];
    }
}

//save the doc
- (void)saveCurrentDoc
{
    if ([currentDoc canSave]) {
        [currentDoc save];
    }
}

// type: 3
- (void)setText:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    if ([self isValidEditText:dict]) {
        [annot setEditText:[self getEditTextValue:dict]];
        [self saveCurrentDoc];
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:107 userInfo:@{@"edittext-attribute": @"\"EditText\" attribute is missing"}];
    }
}

// type: 20
- (void)setWidget:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    switch ([annot fieldType]) {
        case 1:
            [self setButtonField:annot withDict:dict error:error];
            break;
        case 2:
            [self setTextField:annot withDict:dict error:error];
            break;
        case 3:
            [self setChoiceField:annot withDict:dict error:error];
            break;
            
        default:
            break;
    }
}

// type: 20, fieldType: 2
- (void)setTextField:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    [self setText:annot withDict:dict error:error];
}

// type: 20, fieldType: 1
- (void)setButtonField:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    switch ([annot getCheckStatus]) {
        case 0:
        case 1:
            [self setCheckBox:annot withDict:dict error:error];
            break;
        case 2:
        case 3:
            [self setRadioButton:annot withDict:dict error:error];
            break;
            
        default:
            break;
    }
}

// type: 20, fieldType: 2
- (void)setChoiceField:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    //is ComboBox
    if ([annot getComboItemCount] > 0) {
        [self setComboBox:annot withDict:dict error:error];
    }
    
    //is ListSels
    if ([annot getListItemCount] > 0) {
        [self setListSel:annot withDict:dict error:error]; //TODO
    }
}

// type: 20, fieldType: 1, radio
- (void)setRadioButton:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    if ([self isValidRadioButton:dict]) {
        if ([self getRadioValue:dict]) {
            [annot setRadio];
            [self saveCurrentDoc];
        }
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:108 userInfo:@{@"checkstatus-attribute": @"\"CheckStatus\" attribute is missing or is not correct"}];
    }
}

// type: 20, fieldType: 1, checkbox
- (void)setCheckBox:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    if ([self isValidCheckBox:dict]) {
        [annot setCheckValue:[self getCheckBoxValue:dict]];
        [self saveCurrentDoc];
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:108 userInfo:@{@"checkstatus-attribute": @"\"CheckStatus\" attribute is missing or is not correct"}];
    }
}

// type: 20, fieldType: 2, combobox
- (void)setComboBox:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    if ([self isValidComboBox:dict annot:annot]) {
        [annot setComboSel:[self getComboBoxValue:dict]];
        [self saveCurrentDoc];
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:109 userInfo:@{@"combo-attribute": @"\"ComboItemSel\" attribute is missing or is not correct"}];
    }
}

// type: 20, fieldType: 2, list //TODO
- (void)setListSel:(PDFAnnot *)annot withDict:(NSDictionary *)dict error:(NSError **)error
{
    if ([self isValidListSel:dict annot:annot]) {
        //[annot setComboSel:<#(const int *)#> :<#(int)#>
        [self saveCurrentDoc];
    } else {
        *error = [NSError errorWithDomain:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".ErrorDomain"] code:110 userInfo:@{@"combo-attribute": @"\"ComboItemSel\" attribute is missing or is not correct"}];
    }
}

#pragma mark - Get Info

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
        [page objsStart];
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
            
            /*
            int count = [annot getListItemCount];
            if (count > 0) {
                int *sels = (int *)calloc( sizeof(int), [annot getListItemCount]);
                int res = [annot getListSels:sels :count];
                

            }
            */
            
            //[dict setObject:[self valueForField:[NSNumber numberWithInt:[annot getListSels:sels :count]]] forKey:@"ListSels"];
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

#pragma mark - Utils

- (BOOL)isValidEditText:(NSDictionary *)dict
{
    return ([dict objectForKey:@"EditText"]) != nil;
}

- (BOOL)isValidCheckStatus:(NSDictionary *)dict
{
    return ([dict objectForKey:@"CheckStatus"]) != nil;
}

- (BOOL)isValidRadioButton:(NSDictionary *)dict
{
    if ([self isValidCheckStatus:dict]) {
        int checkStatus = [[dict objectForKey:@"CheckStatus"] intValue];
        return (checkStatus == 2 || checkStatus == 3);
    }
    
    return NO;
}

- (BOOL)isValidCheckBox:(NSDictionary *)dict
{
    if ([self isValidCheckStatus:dict]) {
        int checkStatus = [[dict objectForKey:@"CheckStatus"] intValue];
        return (checkStatus == 0 || checkStatus == 1);
    }
    
    return NO;
}

- (BOOL)isValidComboBox:(NSDictionary *)dict annot:(PDFAnnot *)annot
{
    if ([dict objectForKey:@"ComboItemSel"]) {
        int selItem = [[dict objectForKey:@"ComboItemSel"] intValue];
        return (selItem >= 0 && selItem < [annot getComboItemCount]);
    }
    
    return NO;
}

- (BOOL)isValidListSel:(NSDictionary *)dict annot:(PDFAnnot *)annot
{
    if ([dict objectForKey:@"ComboItemSel"]) {
        int selItem = [[dict objectForKey:@"ComboItemSel"] intValue];
        return (selItem >= 0 && selItem < [annot getListItemCount]);
    }
    
    return NO;
}

- (NSString *)getEditTextValue:(NSDictionary *)dict
{
    return [dict objectForKey:@"EditText"];
}

- (BOOL)getRadioValue:(NSDictionary *)dict
{
    return ([[dict objectForKey:@"CheckStatus"] intValue] == 3);
}

- (BOOL)getCheckBoxValue:(NSDictionary *)dict
{
    return ([[dict objectForKey:@"CheckStatus"] intValue] == 1);
}

- (int)getComboBoxValue:(NSDictionary *)dict
{
    return [[dict objectForKey:@"ComboItemSel"] intValue];
}

- (int)getListSelValue:(NSDictionary *)dict
{
    return [[dict objectForKey:@"ComboItemSel"] intValue];
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

//Get JSON info as struct starting from a string
- (id)jsonStructFromString:(NSString *)json
{
    //return nil if JSON is empty
    if (json.length <= 0) {
        return nil;
    }
    
    //Convert string to data
    NSData *dataString = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    //return nil if data is empty
    if (!dataString) {
        return nil;
    }
    
    NSError *error;
    id dict = [NSJSONSerialization JSONObjectWithData:dataString options:NSJSONReadingMutableContainers error:&error];
    
    //return nil if an error occurred
    if (error) {
        return nil;
    }
    
    return dict;
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
