//
//  UnderLineViewController.h
//  PDFViewer
//
//  Created by Radaee on 13-05-30.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlightColorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(strong,retain)UITableView *partitationTableView;
@property(strong,retain)UITableViewCell *partitationTableViewCell;
@property(strong,retain)NSDictionary *dicData;
@property(strong,retain)NSArray *arrayData;
@property(strong,retain)NSDictionary *checkStatus;



@end
