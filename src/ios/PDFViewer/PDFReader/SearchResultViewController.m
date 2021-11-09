//
//  SearchResultTableViewController.m
//  MobileReplica
//
//  Created by Emanuele Bortolami on 05/08/14.
//  Copyright (c) 2014 GEAR.it s.r.l. All rights reserved.
//

#import "SearchResultViewController.h"
#import "RDExtendedSearch.h"
#import "RDUtils.h"

@implementation SearchResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    items = [NSMutableArray array];
    self.tableView.backgroundColor = [RDUtils radaeeWhiteColor];
    self.tableView.layer.cornerRadius = 10.0f;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    void(^progressBlock)(NSMutableArray *, NSMutableArray *) = ^(NSMutableArray *occurrences, NSMutableArray *total){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self->items.count != (total.count - occurrences.count)) {
                for (id occ in occurrences) {
                    [total removeObject:occ];
                }
                self->items = total;
                [self.tableView reloadData];
            }
            
            if (occurrences.count > 0) {
                NSLog(@"--- SEARCHED PAGE: %i ---", [(RDSearchResult *)[occurrences objectAtIndex:0] page]);
                [self.tableView beginUpdates];
                [self->items addObjectsFromArray:occurrences];
                NSMutableArray *indexPaths = [NSMutableArray array];
                for (int i = 0; i < occurrences.count; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:(self->items.count - occurrences.count) + i inSection:0]];
                }
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [self updateFooterText];
                
                [self.tableView endUpdates];
            }
        });
    };
    
    void(^finishBlock)(void) = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"--- SEARCH FINISHED ---");
            [self updateFooterText];
            // ricerca sincrona
            /*dispatch_async(dispatch_get_main_queue(), ^{
             if ([[RDExtendedSearch sharedInstance] searchResults].count > 0) {
             items = [[RDExtendedSearch sharedInstance] searchResults];
             [self.tableView reloadData];
             }
             });*/
        });
    };

    if ([[RDExtendedSearch sharedInstance] searchResults].count == 0 || ![[[RDExtendedSearch sharedInstance] searchTxt] isEqualToString:_searchedString]) {
        [[RDExtendedSearch sharedInstance] clearSearch:^{
            // ricerca asincrona
            NSLog(@"--- SEARCH START ---");
            [[RDExtendedSearch sharedInstance] searchText:self->_searchedString inDoc:self->_doc progress:^(NSMutableArray *occurrences, NSMutableArray *total) {
                progressBlock(occurrences, total);
            } finish:^{
                finishBlock();
            }];
        }];
    } else {
        [[RDExtendedSearch sharedInstance] restoreProgress:^(NSMutableArray *occurrences, NSMutableArray *total) {
            progressBlock(occurrences, total);
        }];
        
        [[RDExtendedSearch sharedInstance] restoreFinish:^{
            finishBlock();
        }];
        
        if (![[RDExtendedSearch sharedInstance] searching]) {
            NSLog(@"--- NOT SEARCHING ---");
            items = [[RDExtendedSearch sharedInstance] searchResults];
            [self updateFooterText];
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFooterText {
    footerLabel.text = ([[RDExtendedSearch sharedInstance] searching]) ? [NSString stringWithFormat:NSLocalizedString(@"Searching... (%i)", nil), (int)items.count] : [NSString stringWithFormat:NSLocalizedString(@"%i occurrences", nil), (int)items.count];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.font = [UIFont boldSystemFontOfSize:14];
    footerLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self updateFooterText];
    
    return footerLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [RDUtils radaeeWhiteColor];
    }

    // PDF Search
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    pageLabel.text = [NSString stringWithFormat:@"%i", [(RDSearchResult *)[items objectAtIndex:indexPath.row] page]];
    pageLabel.font = [UIFont boldSystemFontOfSize:17];
    pageLabel.textAlignment = NSTextAlignmentRight;
    
    cell.textLabel.attributedText = [self boldSearchedString:[(RDSearchResult *)[items objectAtIndex:indexPath.row] stringResult]];
    cell.textLabel.numberOfLines = 0;
    
    cell.accessoryView = pageLabel;
    
    return cell;
}

- (NSAttributedString *)boldSearchedString:(NSString *)string
{
    // PDF Search
    
    NSRange range = [string rangeOfString:_searchedString options:NSCaseInsensitiveSearch];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
    
    return attrString;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // PDF Search
    [self.delegate didSelectSelectSearchResult:[(RDSearchResult *)[items objectAtIndex:indexPath.row] page]-1];
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
