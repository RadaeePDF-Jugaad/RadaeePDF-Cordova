//
//  RDAnnotListTableViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 17/01/18.
//

#import "RDAnnotListViewController.h"

@interface RDAnnotListViewController ()
{
    NSMutableArray *selectedRows;
    NSNumber *row;
    UITapGestureRecognizer *tapOut;
}

@end

@implementation RDAnnotListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedRows = [[NSMutableArray alloc] init];
    for (int i=0; i!=[_annotSelected count];i++)
    {
        [selectedRows addObject:[_annotSelected objectAtIndex:i]];
    }
    row = [[NSNumber alloc] init];
    UITapGestureRecognizer *tapOut = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endChecking:)];
    [self.view addGestureRecognizer:tapOut];
    [tapOut setCancelsTouchesInView:NO];
    
    if (self.tableView.frame.size.height <= 300.0) [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width,(44.0f*([_annotList count])))];
    
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
    return _annotList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    cell.textLabel.text = [_annotList objectAtIndex:indexPath.row];
    
    if ([_annotSelected containsObject:[NSNumber numberWithInteger: indexPath.row]])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    row = [NSNumber numberWithInt:(int)indexPath.row];
    if (_multiSel == TRUE)
    {
        if ([_annotSelected containsObject:row])
        {
            [_annotSelected removeObject:row];
        }
        else
        {
            [_annotSelected addObject:row];
        }
    }
    
    else
    {
        [_annotSelected removeAllObjects];
        [_annotSelected addObject:row];
    }
    
    [_tableView reloadData];
}
/*
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (_multiSel == FALSE) [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellStyleDefault;
}
*/
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)endChecking:(UITapGestureRecognizer*)tap
{
    CGPoint point = [tap locationInView:_tableView];
    [_tableView convertPoint:point fromView:self.view.window];
    if (point.x<0 || point.y<0 || point.x > _tableView.frame.size.width || point.y > _tableView.frame.size.height) [_delegate listCheckedAt:_annotSelected];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
