//
//  MoreViewController.h
//  PDFViewer
//
//  Created by Radaee on 12-12-9.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property(strong,retain)UITableView *partitationTableView;
@property(strong,retain)UITableViewCell *partitationTableViewCell;
@property(strong,retain)NSDictionary *dicData;
@property(strong,retain)NSArray *arrayData;
- (BOOL)isPortrait;
-(void)performWillRotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end
