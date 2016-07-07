//
//  ViewModeTableViewController.h
//  Radaee-Cordova
//
//  Created by Emanuele Bortolami on 24/06/16.
//
//

#import <UIKit/UIKit.h>

@protocol ViewModeDelegate <NSObject>

-(void)setReaderViewMode:(int)mode;

@end

@interface ViewModeTableViewController : UITableViewController

@property (nonatomic, weak) id<ViewModeDelegate> delegate;

@end
