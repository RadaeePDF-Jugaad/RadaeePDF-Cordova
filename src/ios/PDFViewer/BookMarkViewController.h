//
//  BookMarkViewController.h
//  PDFViewer
//
//  Created by Radaee on 12-12-9.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDLoPDFViewController.h"
#import "RDFileTableController.h"
@interface BookMarkViewController : UITableViewController
{
    UINavigationController  *navController;
    NSMutableArray *m_files;
    RDLoPDFViewController *m_pdf1;
    CGImageRef m_img;
    PDF_DOC m_doc;
    PDF_DOC m_thumbdoc;
}

@end
