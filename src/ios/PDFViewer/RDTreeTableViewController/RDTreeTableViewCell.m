//
//  RDTreeTableViewCell.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 31/05/2019.
//

#import "RDTreeTableViewCell.h"
#import "RDUtils.h"

@implementation RDTreeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithItem:(OUTLINE_ITEM *)outline {
    _item = outline;
    int x = 20 * _item.level;
    
    CGRect rect = _outlineLabel.frame;
    rect.size.width = self.frame.size.width - rect.origin.x - x - 20;
    _outlineLabel.frame = rect;
    
    _outlineLabel.transform = CGAffineTransformMakeTranslation(x, 0);
    _arrowImage.transform = CGAffineTransformMakeTranslation(x, 0);
    _outlineLabel.text = [self cleanString:_item.label];
    _arrowImage.hidden = ([outline child] == nil);
    
    if (_item.childIndexes != nil) {
        [self rotateArrow];
    }
}

- (void)rotateArrow {
    CGAffineTransform transform = _arrowImage.transform;
    _arrowImage.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2), CGAffineTransformMakeTranslation(transform.tx, 0));
}

- (void)resetArrow {
    CGAffineTransform transform = _arrowImage.transform;
    _arrowImage.transform = CGAffineTransformMakeTranslation(transform.tx, 0);
}

- (NSString *)cleanString:(NSString *)string {
    return [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    // Then Reset here back to default values that you want.
    
    _item = nil;
    _outlineLabel.transform = CGAffineTransformIdentity;
    self.textLabel.text = @"";
}

@end
