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
    RDPDFViewController *container;
}

@end

@implementation RDMoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *addBookMark = [UIImage imageNamed:@"btn_add.png"];
    UIImage *bookMarkList = [UIImage imageNamed:@"btn_show.png"];
    UIImage *viewMenu = [UIImage imageNamed:@"btn_outline.png"];
    UIImage *savePDF = [UIImage imageNamed:@"btn_save.png"];
    UIImage *printPDF = [UIImage imageNamed:@"btn_print.png"];
    
    actionTitle = [NSArray arrayWithObjects:@"Add book mark", @"Book mark list", @"TOC", @"Save", @"Print", nil];
    actionImage = [NSArray arrayWithObjects:addBookMark, bookMarkList, viewMenu, savePDF, printPDF, nil];
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
    
    if (indexPath.row < 5) {
        [_delegate selectAction:(int)indexPath.row];
    } else {
        [_delegate selectAction:5];
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
