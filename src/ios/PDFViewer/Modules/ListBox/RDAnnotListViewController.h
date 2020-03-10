//
//  RDAnnotListTableViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 17/01/18.
//

#import <UIKit/UIKit.h>

@protocol RDAnnotListViewControllerDelegate <NSObject>
-(void)listCheckedAt:(NSArray *)indexes;
@end

@interface RDAnnotListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <RDAnnotListViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *annotList;
@property (strong, nonatomic) NSMutableArray *annotSelected;
@property (nonatomic) BOOL multiSel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
