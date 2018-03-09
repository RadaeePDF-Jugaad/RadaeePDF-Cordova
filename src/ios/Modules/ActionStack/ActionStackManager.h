//
//  ActionStackManager.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 08/01/18.
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"

@interface ASItem : NSObject

@property (nonatomic) int m_pageno;
@property (nonatomic) int m_idx;

- (instancetype)initWithPage:(int)pgno index:(int)idx;
- (void)undo:(PDFDoc *)doc;
- (void)redo:(PDFDoc *)doc;

@end

@interface ASDel : ASItem

@property (nonatomic) PDF_OBJ_REF hand;

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx;

@end

@interface ASAdd : ASItem

@property (nonatomic) PDF_OBJ_REF hand;

- (instancetype)initWithPage:(int)pgno page:(PDFPage *)page index:(int)idx;

@end

@interface ASMove : ASItem {
    int m_pageno0;
    int m_pageno1;
    PDF_RECT m_rect0;
    PDF_RECT m_rect1;
}

- (instancetype)initWithPage:(int)src_pageno initRect:(PDF_RECT)src_rect destPage:(int)dst_pageno destRect:(PDF_RECT)dst_rect index:(int)idx;

@end

@interface ActionStackManager : NSObject {
    
    NSMutableArray *m_stack;
    int m_pos;
}

- (void)push:(ASItem *)item;

- (ASItem *)undo;
- (ASItem *)redo;

@end
