//
//  RDCollectionViewCell.h
//  PDFViewer
//
//  Created by Federico Vellani on 19/06/2020.
//

#import <UIKit/UIKit.h>

@protocol RDFileCollectionViewCellDelegate <NSObject>
- (void)showInfosAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface RDFileCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPreview;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) id<RDFileCollectionViewCellDelegate> delegate;

- (IBAction)moreButtonTapped:(id)sender;

- (void)setShadow;

@end
