//
//  RDMoreTableViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 10/01/18.
//

#import "RDMoreTableViewController.h"

@interface RDMoreTableViewController ()
{
    NSArray *actionTitle;
    NSArray *actionImage;
}

@end

@implementation RDMoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *viewMode = (_viewModeImage) ? _viewModeImage : [UIImage imageNamed:@"btn_view"];
    UIImage *addBookMark = (_addBookmarkImage) ? _addBookmarkImage : [UIImage imageNamed:@"btn_add"];
    UIImage *bookMarkList = (_bookmarkImage) ? _bookmarkImage : [UIImage imageNamed:@"btn_show"];
    UIImage *viewMenu = (_outlineImage) ? _outlineImage : [UIImage imageNamed:@"btn_outline"];
    UIImage *savePDF = (_saveImage) ? _saveImage : [UIImage imageNamed:@"btn_save"];
    UIImage *printPDF = (_printImage) ? _printImage : [UIImage imageNamed:@"btn_print"];
    UIImage *share = (_shareImage) ? _shareImage : [UIImage imageNamed:@"btn_save"];
    
    actionTitle = [NSArray arrayWithObjects:NSLocalizedString(@"View Mode", nil),NSLocalizedString(@"Add Bookmark", nil), NSLocalizedString(@"Bookmark List", nil), NSLocalizedString(@"View Menu", nil), NSLocalizedString(@"Save", nil), NSLocalizedString(@"Print", nil), NSLocalizedString(@"Share", nil), nil];
    actionImage = [NSArray arrayWithObjects:viewMode, addBookMark, bookMarkList, viewMenu, savePDF, printPDF, share, nil];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return actionTitle.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellID];
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [actionTitle objectAtIndex:indexPath.row]];
    cell.imageView.image = [actionImage objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < 7) {
        [_delegate selectAction:(int)indexPath.row];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
