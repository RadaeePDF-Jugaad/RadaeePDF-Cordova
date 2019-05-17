//
//  OvalColorViewController.h
//  PDFViewer
//
//  Created by strong on 13-7-14.
//
//

#import <UIKit/UIKit.h>

@interface OvalColorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(strong,retain)UITableView *partitationTableView;
@property(strong,retain)UITableViewCell *partitationTableViewCell;
@property(strong,retain)NSDictionary *dicData;
@property(strong,retain)NSArray *arrayData;
@property(strong,retain)NSDictionary *checkStatus;

@end
