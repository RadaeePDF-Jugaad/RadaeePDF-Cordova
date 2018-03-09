//
//  DrawModeTableViewController.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 29/12/17.
//

#import <UIKit/UIKit.h>

@protocol DrawModeDelegate <NSObject>

-(void)didSelectDrawMode:(int)mode;

@end

@interface DrawModeTableViewController : UITableViewController

@property (nonatomic, weak) id<DrawModeDelegate> delegate;

@end
