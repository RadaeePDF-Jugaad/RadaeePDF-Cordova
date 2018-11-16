#import "PopupMenuOverlayView.h"

#import "PopupMenu.h"

@implementation PopupMenuOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
   /* if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    */
    return self;
}
/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView *view = touch.view;
    
    if([view isMemberOfClass:[PopupMenuOverlayView class]]) {
        [self.popupMenu dismiss];
    }
}
 */
@end
