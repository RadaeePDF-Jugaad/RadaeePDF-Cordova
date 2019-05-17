//
//  OutLineViewController.h
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 __Radaee__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PDFIOS.h"
#import "OUTLINE_ITEM.h"
#import <CoreData/CoreData.h>
#import "RDLoPDFViewController.h"

@interface OutLineViewController : UIViewController
{
    NSMutableArray         *m_files;
    PDFDoc                 *m_doc;
    PDFOutline             *m_first;
    PDFOutline             *m_parent;
    OUTLINE_ITEM           *outline_item;
    RDLoPDFViewController  *m_jump;
    OutLineViewController  *outlineView;
}

@property(strong, nonatomic) UITableView     *outlineTableView;
@property(strong, nonatomic) UITableViewCell *outlineTableViewCell;
@property(strong, nonatomic) NSDictionary    *dicData;
@property(strong, nonatomic) NSArray         *arrayData;
@property(strong, nonatomic) NSArray         *arrayOriginal;
@property(strong, nonatomic) NSMutableArray  *arForTable;

- (void)setJump :(RDLoPDFViewController *)view;
- (void)setList :(PDFDoc *)doc :(PDFOutline *)parent :(PDFOutline *)first;
@end
