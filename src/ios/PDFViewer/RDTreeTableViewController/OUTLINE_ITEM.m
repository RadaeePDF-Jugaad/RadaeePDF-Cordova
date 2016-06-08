//
//  OUTLINE_ITEM.m
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 __Radaee__. All rights reserved.
//


#import "OUTLINE_ITEM.h"

@implementation OUTLINE_ITEM

- (NSString *)label
{
    if (_label)
        return _label;
    else
        return @"";
}

- (NSString *)name
{
    if (_name)
        return _name;
    else
        return @"";
}

- (int)gen
{
    if (_gen)
        return _gen;
    else
        return 0;
}

- (NSString *)url {
    if (_url) {
        return _url;
    } else {
        return [NSNull null];
    }
}

@end
