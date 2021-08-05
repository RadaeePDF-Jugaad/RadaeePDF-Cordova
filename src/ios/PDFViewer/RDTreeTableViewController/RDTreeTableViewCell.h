//
//  RDTreeTableViewCell.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 31/05/2019.
//

#import <UIKit/UIKit.h>
#import "OUTLINE_ITEM.h"

NS_ASSUME_NONNULL_BEGIN

@interface RDTreeTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *arrowImage;
@property (strong, nonatomic) UILabel *outlineLabel;
@property (strong, nonatomic) OUTLINE_ITEM *item;

- (void)setupWithItem:(OUTLINE_ITEM *)outline;
- (void)rotateArrow;
- (void)resetArrow;

@end

NS_ASSUME_NONNULL_END
