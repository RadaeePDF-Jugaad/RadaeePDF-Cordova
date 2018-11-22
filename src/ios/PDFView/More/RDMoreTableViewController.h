//
//  RDMoreTableViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 10/01/18.
//

#import <UIKit/UIKit.h>

@protocol RDMoreTableViewControllerDelegate <NSObject>
-(void) selectAction: (int) type;
@end

@interface RDMoreTableViewController : UITableViewController
@property (nonatomic, weak) id <RDMoreTableViewControllerDelegate> delegate;
@property (strong, nonatomic) UIImage *viewModeImage;
@property (strong, nonatomic) UIImage *bookmarkImage;
@property (strong, nonatomic) UIImage *addBookmarkImage;
@property (strong, nonatomic) UIImage *outlineImage;
@property (strong, nonatomic) UIImage *saveImage;
@property (strong, nonatomic) UIImage *printImage;
@property (strong, nonatomic) UIImage *shareImage;
@end
