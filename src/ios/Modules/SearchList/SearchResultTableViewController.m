//
//  SearchResultTableViewController.m
//  MobileReplica
//
//  Created by Emanuele Bortolami on 05/08/14.
//  Copyright (c) 2014 GEAR.it s.r.l. All rights reserved.
//

#import "SearchResultTableViewController.h"
#import "RDExtendedSearch.h"

@implementation SearchResultTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@interface SearchResultTableViewController ()
{
    NSString *searchedString;
}

@end

@implementation SearchResultTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cellLoader = [UINib nibWithNibName:@"SearchResultTableViewCell" bundle:[NSBundle mainBundle]];
    
    self.preferredContentSize = CGSizeMake(self.tableView.bounds.size.width, self.tableView.bounds.size.height);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // PDF Search
    
    items = [[RDExtendedSearch sharedInstance] searchResults];
    searchedString = [[RDExtendedSearch sharedInstance] searchTxt];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResultTableViewCell";
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelItems = [cellLoader instantiateWithOwner:self options:nil];
        cell = [topLevelItems objectAtIndex:0];
    }

    // PDF Search
    
    cell.descLabel.attributedText = [self boldSearchedString:[(RDSearchResult *)[items objectAtIndex:indexPath.row] stringResult]];
    cell.pageLabel.text = [NSString stringWithFormat:@"%i", [(RDSearchResult *)[items objectAtIndex:indexPath.row] page]];
    
    return cell;
}

- (NSAttributedString *)boldSearchedString:(NSString *)string
{
    // PDF Search
    
    NSRange range = [string rangeOfString:searchedString options:NSCaseInsensitiveSearch];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:range];
    
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
    [self.delegate didSelectSelectSearchResult:[(RDSearchResult *)[items objectAtIndex:indexPath.row] page] - 1];
}

@end
