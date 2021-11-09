//
//  RDToolbar.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 23/06/2020.
//

#import "RDToolbar.h"

@implementation RDToolbar


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}


- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    _toolbar.hidden = hidden;
}

@end
