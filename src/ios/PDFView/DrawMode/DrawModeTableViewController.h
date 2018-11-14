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

@property (strong, nonatomic) UIImage *lineImage;
@property (strong, nonatomic) UIImage *rowImage;
@property (strong, nonatomic) UIImage *rectImage;
@property (strong, nonatomic) UIImage *ellipseImage;
@property (strong, nonatomic) UIImage *bitmapImage;
@property (strong, nonatomic) UIImage *noteImage;
@property (strong, nonatomic) UIImage *signatureImage;

@end
