//
//  OUTLINE_ITEM.h
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 Radaee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PDFObjc.h"

@interface OUTLINE_ITEM : NSObject
{
    
}
@property(strong,retain)NSString *label;
@property(nonatomic,assign)int dest;
@property(strong,readwrite)PDFOutline *child;
@end
