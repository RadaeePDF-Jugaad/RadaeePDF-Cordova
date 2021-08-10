//
//  BookmarkTableViewController.m
//  RDPDFViewLib
//
//  Created by Emanuele Bortolami on 17/07/15.
//  Copyright (c) 2015 gear.it. All rights reserved.
//

#import "RDBookmarkViewController.h"

@interface RDBookmarkViewController ()

@end

@implementation RDBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableViewHeight.constant = _items.count * 50; //items * number of cells
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *arr = [_items objectAtIndex:indexPath.row];
    
    int pageno = [[arr objectAtIndex:0] intValue];
    pageno++;
    
    cell.textLabel.text = [NSString stringWithFormat:@"Page: %i", pageno];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [_items objectAtIndex:indexPath.row];
    int pageno = [[arr objectAtIndex:0] intValue];
    
    [_delegate didSelectBookmarkAtPage:pageno];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            
            NSArray *row_item = [_items objectAtIndex:indexPath.row];
            NSString *path = [row_item objectAtIndex:1];
            
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:path error:nil];
            
            [_items removeObjectAtIndex:indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
}

- (void)dismissView:(id)sende {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
