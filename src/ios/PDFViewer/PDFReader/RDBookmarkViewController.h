//
//  BookmarkTableViewController.h
//  RDPDFViewLib
//
//  Created by Emanuele Bortolami on 17/07/15.
//  Copyright (c) 2015 gear.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkTableViewDelegate
- (void)didSelectBookmarkAtPage:(int)page;
@end

@interface RDBookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) id <BookmarkTableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *bookmarkTitle;

- (IBAction)dismissView:(id)sender;

@end
