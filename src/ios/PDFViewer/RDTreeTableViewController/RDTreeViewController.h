//
//  RDTreeViewController.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 31/05/2019.
//

#import <UIKit/UIKit.h>
#import "RDTreeTableViewCell.h"

@class PDFDoc;

NS_ASSUME_NONNULL_BEGIN

// define the protocol for the delegate
@protocol RDTreeViewControllerDelegate
// define protocol functions that can be used in any class using this delegate
- (void)didSelectDest:(OUTLINE_ITEM *)item;
@end;

@interface RDTreeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PDFDoc *doc;
@property (nonatomic, weak) id<RDTreeViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)dismissView:(id)sender;

@end

NS_ASSUME_NONNULL_END
