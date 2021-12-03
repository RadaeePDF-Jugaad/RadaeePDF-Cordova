//
//  RDCollectionViewCell.m
//  PDFViewer
//
//  Created by Federico Vellani on 19/06/2020.
//

#import "RDFileCollectionViewCell.h"

@implementation RDFileCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setShadow
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.layer.cornerRadius = 15.0f;
        self.contentView.layer.masksToBounds = YES;

        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0.0f);
        self.layer.shadowRadius = 15.0f;
        self.layer.shadowOpacity = 0.25f;
        self.layer.masksToBounds = NO;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.layer.cornerRadius = 10.0f;
        self.contentView.layer.masksToBounds = YES;

        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0.0f);
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.25f;
        self.layer.masksToBounds = NO;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
    }
}

- (IBAction)moreButtonTapped:(id)sender
{
    [_delegate showInfosAtIndexPath:_indexPath];
}

@end
