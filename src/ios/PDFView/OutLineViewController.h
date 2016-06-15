//
//  OutLineViewController.h
//  PDFViewer
//
//  Created by Radaee on 13-1-20.
//  Copyright (c) 2013年 __Radaee__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RDPDFViewController.h"
#import "PDFIOS.h"
#import "OUTLINE_ITEM.h"
#import <CoreData/CoreData.h>
#import "PDFView.h"
//#import "PDFV.h"

@class RDPDFViewController;
@interface OutLineViewController : UIViewController
{
    UINavigationController *navController;
    NSMutableArray *m_files;
    RDPDFViewController *m_jump;
    PDFDoc *m_doc;

    PDFOutline *m_first;
    PDFOutline *m_parent;
    OUTLINE_ITEM *outline_item;
    OutLineViewController *outlineView;
}

@property(strong,retain)UITableView *outlineTableView;
@property(strong,retain)UITableViewCell *outlineTableViewCell;
@property(strong,retain)NSDictionary *dicData;
@property(strong,retain)NSArray *arrayData;
-(void)setList:(PDFDoc *)doc :(PDFOutline *)parent :(PDFOutline *)first;

@property (nonatomic, retain) NSArray *arrayOriginal;
@property (nonatomic, retain) NSMutableArray *arForTable;

-(void)setJump:(RDPDFViewController *)view;
@end
