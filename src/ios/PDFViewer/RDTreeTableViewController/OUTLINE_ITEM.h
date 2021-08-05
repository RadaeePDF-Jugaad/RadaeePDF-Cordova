//
//  OUTLINE_ITEM.h
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 Radaee. All rights reserved.
//


#import <Foundation/Foundation.h>

@class PDFOutline;

@interface OUTLINE_ITEM : NSObject
@property(nonatomic,strong) NSString *label;
@property(nonatomic,strong) NSString *url;   // Param in Satiz JSON
@property(nonatomic,strong) NSString *name;  // Param in Satiz JSON
@property(nonatomic,strong) NSString *link;
@property(nonatomic,assign) int gen;         // Param in Satiz JSON
@property(nonatomic,strong) NSMutableArray *childIndexes;
@property(nonatomic,assign) int dest;
@property(nonatomic,assign) int level;
@property(nonatomic,strong) PDFOutline *child;
@end
