//
//  UILElement.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 09/07/2020.
//

#import "UILElement.h"
#import "RDUtils.h"

@implementation UILElement

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initLayout];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initLayout];
    }
    return self;
}

- (void)initLayout {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [RDUtils radaeeBlackColor].CGColor;
    self.layer.borderWidth = 2.0;
}

@end
