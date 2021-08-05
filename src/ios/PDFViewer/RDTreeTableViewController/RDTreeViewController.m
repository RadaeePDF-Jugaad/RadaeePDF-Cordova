//
//  RDTreeViewController.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 31/05/2019.
//

#import "RDTreeViewController.h"
#import "RDUtils.h"

@interface RDTreeViewController () {

    NSMutableArray *items;
}

@end

@implementation RDTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [RDUtils radaeeWhiteColor];
    self.tableView.layer.cornerRadius = 10.0f;
    
    items = [NSMutableArray array];
    
    // Primo livello
    PDFOutline *root = [_doc rootOutline];
    while(root)
    {
        OUTLINE_ITEM *item = [self itemWithObject:root];
        item.level = 0;
        root = [root next];
        [items addObject:item];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (OUTLINE_ITEM *)itemWithObject:(PDFOutline *)obj {
    OUTLINE_ITEM *outline_item = [[OUTLINE_ITEM alloc]init];
    outline_item.label = [obj label];
    outline_item.dest = [obj dest];
    outline_item.child = [obj child];
    return outline_item;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    RDTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RDTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.outlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, tableView.frame.size.width - 60, 50)];
        cell.arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [cell.arrowImage setImage:[[UIImage imageNamed:@"btn_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        cell.outlineLabel.numberOfLines = 0;
        cell.outlineLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.outlineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell addSubview:cell.outlineLabel];
        [cell addSubview:cell.arrowImage];
        cell.backgroundColor = [RDUtils radaeeWhiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setupWithItem:[items objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OUTLINE_ITEM *selectedItem = (OUTLINE_ITEM *)[items objectAtIndex:indexPath.row];
    if ([selectedItem child]) {
        // controllo se ho già degli indici salvati (vuol dire che sto già mostrando i child
        [self.tableView beginUpdates];
        if (selectedItem.childIndexes) {
            RDTreeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell resetArrow];
            [self closeChild:selectedItem atIndex:(int)indexPath.row];
        } else {
            RDTreeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell rotateArrow];
            [self openChild:selectedItem atIndex:(int)indexPath.row];
        }
        [self.tableView endUpdates];
    } else {
        if (_delegate) {
            [_delegate didSelectDest:selectedItem];
        }
    }
}

- (void)openChild:(OUTLINE_ITEM *)item atIndex:(int)index {
    PDFOutline *outline = [[items objectAtIndex:index] child];
    if (!outline) {
        return;
    }
    NSMutableArray *indexPaths = [NSMutableArray array];
    while(outline)
    {
        index++;
        OUTLINE_ITEM *child = [self itemWithObject:outline];
        child.level = item.level + 1;
        outline = [outline next];
        [items insertObject:child atIndex:index];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    
    if (indexPaths.count > 0) {
        item.childIndexes = indexPaths;
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

- (void)closeChild:(OUTLINE_ITEM *)item atIndex:(int)index {
    int i = index + 1;
    NSMutableArray *indexPaths = [NSMutableArray array];
    while (i < items.count) {
        OUTLINE_ITEM *it = [items objectAtIndex:i];
        if (it.level > item.level) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        } else {
            break;
        }
        i++;
    }
    
    for (i = (int)indexPaths.count - 1; i >= 0; i--) {
        [items removeObjectAtIndex:[[indexPaths objectAtIndex:i] row]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    item.childIndexes = nil;
}

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
