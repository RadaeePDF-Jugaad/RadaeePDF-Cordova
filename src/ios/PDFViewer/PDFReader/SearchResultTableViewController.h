//
//  SearchResultTableViewController.h
//  MobileReplica
//
//  Created by Emanuele Bortolami on 05/08/14.
//  Copyright (c) 2014 GEAR.it s.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDExtendedSearch.h"

@protocol SearchResultViewControllerDelegate <NSObject>

- (void)didSelectSelectSearchResult:(int)index;

@end

@interface SearchResultViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UILabel *footerLabel;
    UINib *cellLoader;
    NSMutableArray *items;
}

@property (strong, nonatomic) NSString *searchedString;
@property (strong, nonatomic) PDFDoc *doc;
@property (nonatomic, weak) id <SearchResultViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
