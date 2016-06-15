//
//  BookmarkTableViewController.h
//  RDPDFViewLib
//
//  Created by Emanuele Bortolami on 17/07/15.
//  Copyright (c) 2015 gear.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkTableViewDelegate
- (void)didSelectItem:(int)page;
@end

@interface BookmarkTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) id <BookmarkTableViewDelegate> delegate;

@end
