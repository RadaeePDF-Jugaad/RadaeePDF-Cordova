#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "PopupMenuItem.h"

typedef enum {
    PopupMenuStateNormal,
    PopupMenuStateHighlighted
} PopupMenuState;

@class PopupMenu;

@protocol PopupMenuDelegate <NSObject>

@optional
- (void)popupMenuWillAppear:(PopupMenu *)popupMenu;
- (void)popupMenuDidAppear:(PopupMenu *)popupMenu;
- (void)popupMenuWillDisappear:(PopupMenu *)popupMenu;
- (void)popupMenuDidDisappear:(PopupMenu *)popupMenu;

@end

@interface PopupMenu : UIView

@property (nonatomic, assign) id<PopupMenuDelegate> delegate;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat arrowSize;
@property (nonatomic, assign, getter = isAnimationEnabled) BOOL animationEnabled;

- (id)initWithItems:(NSArray *)items;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;
- (void)dismiss;

@end
