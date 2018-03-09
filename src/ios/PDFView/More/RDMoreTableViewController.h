//
//  RDMoreTableViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 10/01/18.
//

#import <UIKit/UIKit.h>
#import "RDPDFViewController.h"

@protocol RDMoreTableViewControllerDelegate <NSObject>
-(void) selectAction: (int) type;
@end

@interface RDMoreTableViewController : UITableViewController
@property (nonatomic, weak) id <RDMoreTableViewControllerDelegate> delegate;
@end
