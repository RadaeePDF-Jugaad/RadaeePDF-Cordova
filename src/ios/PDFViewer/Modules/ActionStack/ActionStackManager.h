//
//  ActionStackManager.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 08/01/18.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"

@interface ASItem : NSObject

@property (nonatomic) bool reorder;
@property (nonatomic) int m_pageno;
@property (nonatomic) int m_idx;
@property (nonatomic) PDF_OBJ_REF hand;

- (instancetype)initWithPage:(int)pgno index:(int)idx;
- (void)undo:(PDFDoc *)doc;
- (void)redo:(PDFDoc *)doc;

@end

@interface ASDel : ASItem

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx;

@end

@interface ASAdd : ASItem

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx;

@end

@interface ASMove : ASItem {
    PDF_RECT m_rect0;
    PDF_RECT m_rect1;
}

@property (nonatomic) int m_pageno0;
@property (nonatomic) int m_pageno1;

- (instancetype)initWithPage:(int)src_pageno initRect:(PDF_RECT)src_rect destPage:(int)dst_pageno destRect:(PDF_RECT)dst_rect index:(int)idx ref:(PDF_OBJ_REF)ref;

@end

@interface ActionStackManager : NSObject {
    
    NSMutableArray *m_stack;
    int m_pos;
    BOOL busy;
}

- (void)push:(ASItem *)item;

- (ASItem *)undo;
- (ASItem *)redo;

- (void)orderIndexes:(ASItem *)item;
- (void)orderOnDel:(ASItem *)item;

@end
