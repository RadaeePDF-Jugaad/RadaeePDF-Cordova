#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PopupMenu;

@interface PopupMenuItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIView *customView;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, retain) UIFont *font;

+ (id)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (id)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (id)itemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;
+ (id)itemWithCustomView:(UIView *)customView target:(id)target action:(SEL)action;

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;
- (id)initWithCustomView:(UIView *)customView target:(id)target action:(SEL)action;

- (CGSize)actualSize;
- (UIFont *)actualFont;
- (void)performAction;

@end
