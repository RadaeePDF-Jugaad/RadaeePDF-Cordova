//
//  DrawModeTableViewController.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 29/12/17.
//

#import "DrawModeTableViewController.h"

@interface DrawModeTableViewController ()

@end

@implementation DrawModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = NSLocalizedString(@"Ink", nil);
            cell.imageView.image = (_lineImage) ? _lineImage : [UIImage imageNamed:@"btn_annot_ink"];
            break;
        }
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Line", nil);
            cell.imageView.image = (_rowImage) ? _rowImage : [UIImage imageNamed:@"btn_annot_line"];
            break;
        }
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"Rect", nil);
            cell.imageView.image = (_rectImage) ? _rectImage : [UIImage imageNamed:@"btn_annot_rect"];
            break;
        }
        case 3:
        {
            cell.textLabel.text = NSLocalizedString(@"Ellipse", nil);
            cell.imageView.image = (_ellipseImage) ? _ellipseImage : [UIImage imageNamed:@"btn_annot_ellipse"];
            break;
        }
        case 4:
        {
            cell.textLabel.text = NSLocalizedString(@"Stamp", nil);
            cell.imageView.image = (_bitmapImage) ? _bitmapImage : [UIImage imageNamed:@"pdf_custom_stamp"];
            break;
        }
        case 5:
        {
            cell.textLabel.text = NSLocalizedString(@"Note", nil);
            cell.imageView.image = (_noteImage) ? _noteImage : [UIImage imageNamed:@"btn_annot_note"];
            break;
        }
        case 6:
        {
            cell.textLabel.text = NSLocalizedString(@"Signature", nil);
            cell.imageView.image = (_signatureImage) ? _signatureImage : [UIImage imageNamed:@"btn_annot_ink"];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate didSelectDrawMode:(int)indexPath.row];
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
