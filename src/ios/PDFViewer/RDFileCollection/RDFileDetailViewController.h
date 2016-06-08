//
//  RDFileDetailViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 26/06/2020.
//

#import <UIKit/UIKit.h>

@protocol RDFileDetailViewControllerDelegate <NSObject>

- (void)showSelectedFileMeta:(NSString *)pdfPath;
- (void)refreshCollectionOnEdit;

@end

@interface RDFileDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *cover;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastModifiedLabel;
@property (strong, nonatomic) IBOutlet UIButton *metaButton;
@property (strong, nonatomic) IBOutlet UIButton *renameButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) NSString *pdfPath;

@property (weak, nonatomic) id <RDFileDetailViewControllerDelegate>delegate;

- (IBAction)dismissView:(id)sender;
- (IBAction)metaButtonTapped:(id)sender;
- (IBAction)renameButtonTapped:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;

@end
