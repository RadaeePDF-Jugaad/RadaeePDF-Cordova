//
//  SearchResultTableViewController.h
//  MobileReplica
//
//  Created by Emanuele Bortolami on 05/08/14.
//  Copyright (c) 2014 GEAR.it s.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;

@end

@protocol SearchResultViewControllerDelegate <NSObject>

- (void)didSelectSelectSearchResult:(int)index;

@end

@interface SearchResultTableViewController : UITableViewController
{
    UINib *cellLoader;
    NSMutableArray *items;
}

@property (nonatomic, weak) id <SearchResultViewControllerDelegate> delegate;

@end
