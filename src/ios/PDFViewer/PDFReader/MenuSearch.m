//
//  MenuSearch.m
//  PDFViewer
//
//  Created by Federico Vellani on 25/06/2020.
//

#import <Foundation/Foundation.h>
#import "MenuSearch.h"
#import "RDVGlobal.h"

@implementation MenuSearch

- (id)init:(CGPoint)point :(RDBlock)callback
{
    _caseSwitch = [[UISwitch alloc] init];
    _wholeSwitch = [[UISwitch alloc] init];
    _caseSwitch.on = GLOBAL.g_case_sensitive;
    _wholeSwitch.on = GLOBAL.g_match_whole_word;
    [_caseSwitch addTarget:self action:@selector(changeSwitch) forControlEvents:UIControlEventValueChanged];
    [_wholeSwitch addTarget:self action:@selector(changeSwitch) forControlEvents:UIControlEventValueChanged];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:
    @{@"Case sensitive": _caseSwitch},
    @{@"Match whole word": _wholeSwitch}, nil];
    
    return [super initWithSwitch:point :callback :items];
}

- (void)changeSwitch {
    GLOBAL.g_case_sensitive = _caseSwitch.on;
    GLOBAL.g_match_whole_word = _wholeSwitch.on;
}

@end
