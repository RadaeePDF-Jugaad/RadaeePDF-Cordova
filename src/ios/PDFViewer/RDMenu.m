//
//  RDMenu.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 11/06/2020.
//

#import "RDMenu.h"
#import "RDUtils.h"

@implementation RDMenu

//createItemWithIcon e createItemWithSwitch
+ (UIView *)createItemWithIcon:(UIImage *)img :(int)tag :(CGFloat)y :(CGFloat)w  :(NSString *)val
{
    int margin = 10;
    int size = rd_menu_height;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, w, size)];
    UIImageView *vimg = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 0, size, size)];
    vimg.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [view addSubview:vimg];
    UILabel *vlab = [[UILabel alloc] initWithFrame:CGRectMake(size + margin, 0, w - size - margin, size)];
    vlab.text = val;
    [vlab setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:vlab];
    view.tag = tag;
    return view;
}

+ (UIView *)createItemWithSwitch:(UISwitch *)swtch :(int)tag :(CGFloat)y :(CGFloat)w  :(NSString *)val
{
    int margin = 8;
    int h = rd_menu_height;
    int sw = swtch.frame.size.width;
    int sh = swtch.frame.size.height;
    if (y == 0) {
        y = 2;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y, w, sw)];
    UILabel *vlab = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, w - sw - (margin * 2), h)];
    vlab.text = val;
    [vlab setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:vlab];
    CGRect frame = swtch.frame;
    frame.origin = CGPointMake(w - sw - margin, (h - sh) / 2);
    [swtch setFrame:frame];
    [view addSubview:swtch];
    view.tag = tag;
    return view;
}

- (instancetype)init:(CGPoint)point :(RDBlock)callback :(NSMutableArray *)items
{
    CGRect frame = CGRectMake(point.x, point.y, 0, 0);
    self = [super initWithFrame:frame];
    if(self)
    {
        m_callback = callback;
        int w = rd_menu_width;
        int h = rd_menu_height;
        UIView *view;
        UITapGestureRecognizer *tap;
        CGFloat radius = 10.0f;
        for (int i = 0; i < items.count; i++) {
            if (self.isSearchMenu) {
                h = 50;
                view = [RDMenu createItemWithSwitch:[[[items objectAtIndex:i] allValues] objectAtIndex:0] :i :(5 + (i * h)) :w :[[[items objectAtIndex:i] allKeys] objectAtIndex:0]];
                radius = 18.0f;
            } else {
                view = [RDMenu createItemWithIcon:[[[items objectAtIndex:i] allValues] objectAtIndex:0] :i :(i * h) :w :[[[items objectAtIndex:i] allKeys] objectAtIndex:0]];
            }
            tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [view addGestureRecognizer:tap];
            [self addSubview:view];
        }
        
        [self setBackgroundColor:[RDUtils radaeeWhiteColor]];//[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f]];
        
        frame.size.width = w;
        frame.size.height = h * items.count;
        frame.origin.y = frame.origin.y - frame.size.height - 10;
        self.frame = frame;
        
        self.layer.cornerRadius = radius;
        self.layer.shadowRadius = radius;
        
        //[self insertSubview:shadow atIndex:0];
    }
    return self;
}

- (instancetype)initWithSwitch:(CGPoint)point :(RDBlock)callback :(NSMutableArray *)items
{
    _isSearchMenu = YES;
    self = [self init:point :callback :items];
    return self;
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if(m_callback) m_callback((int)tap.view.tag);
}

@end
