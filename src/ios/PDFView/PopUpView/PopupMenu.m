#import "PopupMenu.h"

#import "PopupMenuOverlayView.h"

@interface PopupMenu ()

@property (nonatomic, retain) PopupMenuOverlayView *overlayView;

@property (nonatomic, retain) UIImage *popupImage;
@property (nonatomic, retain) UIImage *highlightedPopupImage;

- (void)performAction:(id)sender;
- (CGSize)actualSize;
- (UIImage *)croppedImageFromImage:(UIImage *)image rect:(CGRect)rect;
- (UIImage *)popupImageForState:(PopupMenuState)state;
- (void)drawRightSeparatorInContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint state:(PopupMenuState)state;
- (void)drawLeftSeparatorInContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint state:(PopupMenuState)state;

@end

@implementation PopupMenu

- (id)init
{
    return [self initWithItems:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithItems:nil];
}

- (id)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectZero];
    
    if(self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.items = items;
        self.cornerRadius = 8;
        self.arrowSize = 12;
        self.animationEnabled = YES;
        
        self.popupImage = nil;
        self.highlightedPopupImage = nil;
    }
    
    return self;
}

- (void)setItems:(NSArray *)items
{
    _items = [items copy];
    
    if(items) {
        CGSize actualSize = [self actualSize];
        actualSize.height = actualSize.height + self.arrowSize;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, actualSize.width, actualSize.height);
        
        self.popupImage = [self popupImageForState:PopupMenuStateNormal];
        self.highlightedPopupImage = [self popupImageForState:PopupMenuStateHighlighted];
        
        for(UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
        
        CGSize frameSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - self.arrowSize);
        CGFloat middle = round(frameSize.height / 2);
        
        CGFloat itemOffset = 0;
        
        for(NSUInteger i = 0; i < self.items.count; i++) {
            PopupMenuItem *item = [self.items objectAtIndex:i];
            CGSize itemSize = [item actualSize];
            CGRect itemFrame = CGRectMake(itemOffset, 0, itemSize.width, actualSize.height);
            
            UIImage *image = [self croppedImageFromImage:self.popupImage rect:itemFrame];
            UIImage *highlightedImage = [self croppedImageFromImage:self.highlightedPopupImage rect:itemFrame];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = itemFrame;
            button.autoresizingMask = UIViewAutoresizingNone;
            button.enabled = item.enabled;
            
            [button setImage:image forState:UIControlStateNormal];
            [button setImage:highlightedImage forState:UIControlStateHighlighted];
            [button setImage:image forState:UIControlStateDisabled];
            
            [button addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            
            if(item.customView) {
                item.customView.frame = CGRectMake(itemOffset, 0, itemSize.width, frameSize.height);
                
                [self addSubview:item.customView];
            } else {
                if(item.title && item.image) {
                    // Image
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemOffset, 4, itemSize.width, middle - 4)];
                    imageView.image = item.image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:imageView];
                //    [imageView release];
                    
                    // Title
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemOffset, middle, itemSize.width, middle)];
                    titleLabel.text = item.title;
                    titleLabel.font = [item actualFont];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:titleLabel];
                //    [titleLabel release];
                } else if(item.title) {
                    // Title
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemOffset, 0, itemSize.width, frameSize.height)];
                    titleLabel.text = item.title;
                    titleLabel.font = [item actualFont];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = [UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:titleLabel];
                 //   [titleLabel release];
                } else if(item.image) {
                    // Image
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemOffset, 4, itemSize.width, frameSize.height - 4)];
                    imageView.image = item.image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeCenter;
                    imageView.autoresizingMask = UIViewAutoresizingNone;
                    
                    [self addSubview:imageView];
                 //   [imageView release];
                }
            }
            
            itemOffset = itemOffset + itemSize.width;
        }
    }
}

- (void)dealloc
{
   // [_items release];
    
   // [super dealloc];
}


#pragma mark -

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;
{
    if([self.delegate respondsToSelector:@selector(popupMenuWillAppear:)]) {
        [self.delegate popupMenuWillAppear:self];
    }
    
    CGRect frame = self.frame;
    frame.origin.x = round(point.x - frame.size.width / 2);
    frame.origin.y = round(point.y - frame.size.height);
    self.frame = frame;
    
    PopupMenuOverlayView *overlayView = [[PopupMenuOverlayView alloc] initWithFrame:view.bounds];
    overlayView.popupMenu = self;
    
    self.overlayView = overlayView;
   // [overlayView release];
    
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 1.6);
    self.layer.shadowRadius = 1.5;
    
    if(self.animationEnabled) {
        self.layer.opacity = 0;
    }
    
    [self.overlayView addSubview:self];
    [view addSubview:self.overlayView];
    
    if(self.animationEnabled) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            self.layer.opacity = 1.0;
        } completion:^(BOOL finished) {
            if([self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
                [self.delegate popupMenuDidAppear:self];
            }
        }];
    } else {
        if([self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
            [self.delegate popupMenuDidAppear:self];
        }
    }
}

- (void)dismiss
{
    if([self.delegate respondsToSelector:@selector(popupMenuWillDisappear:)]) {
        [self.delegate popupMenuWillDisappear:self];
    }
    
    if(self.animationEnabled) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            self.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.overlayView removeFromSuperview];
            
            if([self.delegate respondsToSelector:@selector(popupMenuDidDisappear:)]) {
                [self.delegate popupMenuDidDisappear:self];
            }
        }];
    } else {
        [self removeFromSuperview];
        [self.overlayView removeFromSuperview];
        
        if([self.delegate respondsToSelector:@selector(popupMenuDidDisappear:)]) {
            [self.delegate popupMenuDidDisappear:self];
        }
    }
}

- (void)performAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PopupMenuItem *item = [self.items objectAtIndex:button.tag];
    
    [item performAction];
    
    [self dismiss];
}

- (CGSize)actualSize
{
    CGFloat width = 0, height = 0;
    
    for(NSUInteger i = 0; i < self.items.count; i++) {
        PopupMenuItem *item = [self.items objectAtIndex:i];
        CGSize actualItemSize = [item actualSize];
        
        width = width + actualItemSize.width;
        
        if(actualItemSize.height > height) {
            height = actualItemSize.height;
        }
    }
    
    return CGSizeMake(width, height);
}

- (UIImage *)croppedImageFromImage:(UIImage *)image rect:(CGRect)rect
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect scaledRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * 2);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], scaledRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)popupImageForState:(PopupMenuState)state
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cornerRadius = self.cornerRadius;
    CGFloat arrowSize = self.arrowSize;
    CGSize frameSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - arrowSize);
    CGPoint point = CGPointMake(round(self.bounds.size.width / 2 - 1), self.bounds.size.height - 1);
    CGFloat middle = round(frameSize.height / 2);
    CGFloat inset = 1;
    CGFloat cornerInset = 1;
    
    CGMutablePathRef basePath = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath, NULL, 0, cornerRadius);
    CGPathAddArcToPoint(basePath, NULL, 0, 0, cornerRadius, 0, cornerRadius);
    
    CGPathAddLineToPoint(basePath, NULL, frameSize.width - cornerRadius, 0);
    CGPathAddArcToPoint(basePath, NULL, frameSize.width, 0, frameSize.width, cornerRadius, cornerRadius);
    
    CGPathAddLineToPoint(basePath, NULL, frameSize.width, frameSize.height - cornerRadius);
    CGPathAddArcToPoint(basePath, NULL, frameSize.width, frameSize.height, frameSize.width - cornerRadius, frameSize.height, cornerRadius);
    
    CGPathAddLineToPoint(basePath, NULL, point.x + arrowSize, frameSize.height);
    CGPathAddLineToPoint(basePath, NULL, point.x, point.y);
    CGPathAddLineToPoint(basePath, NULL, point.x - arrowSize, frameSize.height);
    
    CGPathAddLineToPoint(basePath, NULL, cornerRadius, frameSize.height);
    CGPathAddArcToPoint(basePath, NULL, 0, frameSize.height, 0, frameSize.height - cornerRadius, cornerRadius);
    
    CGPathCloseSubpath(basePath);
    
    CGContextAddPath(context, basePath);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    CGContextFillPath(context);
    
    CGPathRelease(basePath);
    
    if(state == PopupMenuStateHighlighted) {
        CGMutablePathRef arrowPath = CGPathCreateMutable();
        
        CGPathMoveToPoint(arrowPath, NULL, point.x + arrowSize, frameSize.height - inset);
        CGPathAddLineToPoint(arrowPath, NULL, point.x, point.y - inset);
        CGPathAddLineToPoint(arrowPath, NULL, point.x - arrowSize, frameSize.height - inset);
        CGPathCloseSubpath(arrowPath);
        
        CGContextSaveGState(context);
        CGContextAddPath(context, arrowPath);
        CGContextClip(context);
        
        CGColorSpaceRef arrowColorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGFloat arrowComponents[8] = {
            0.027, 0.169, 0.733, 1,
            0.02, 0.114, 0.675, 1
        };
        size_t arrowCount = sizeof(arrowComponents) / (sizeof(CGFloat) * 4);
        
        CGGradientRef arrowGradientRef = CGGradientCreateWithColorComponents(arrowColorSpaceRef, arrowComponents, NULL, arrowCount);
        
        CGPoint arrowStartPoint = CGPointMake(0, frameSize.height - inset);
        CGPoint arrowEndPoint = CGPointMake(0, point.y - inset);
        
        CGContextDrawLinearGradient(context, arrowGradientRef, arrowStartPoint, arrowEndPoint, kCGGradientDrawsAfterEndLocation);
        
        CGGradientRelease(arrowGradientRef);
        CGColorSpaceRelease(arrowColorSpaceRef);
        
        CGContextRestoreGState(context);
        
        CGPathRelease(arrowPath);
    }
    
    CGMutablePathRef basePath2 = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath2, NULL, inset, cornerRadius);
    CGPathAddArcToPoint(basePath2, NULL, inset, inset, cornerRadius, inset, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath2, NULL, frameSize.width - cornerRadius, inset);
    CGPathAddArcToPoint(basePath2, NULL, frameSize.width - inset, inset, frameSize.width - inset, cornerRadius, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath2, NULL, frameSize.width - inset, middle);
    CGPathAddLineToPoint(basePath2, NULL, inset, middle);
    
    CGPathCloseSubpath(basePath2);
    
    CGContextAddPath(context, basePath2);
    switch(state) {
        case PopupMenuStateNormal:
            CGContextSetRGBFillColor(context, 0.471, 0.471, 0.471, 1.0);
            break;
        case PopupMenuStateHighlighted:
            CGContextSetRGBFillColor(context, 0.384, 0.608, 0.906, 1.0);
            break;
    }
    CGContextFillPath(context);
    
    CGPathRelease(basePath2);
    
    CGMutablePathRef basePath3 = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath3, NULL, inset, cornerRadius);
    CGPathAddArcToPoint(basePath3, NULL, inset, inset + 1, cornerRadius, inset + 1, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath3, NULL, frameSize.width - cornerRadius, inset + 1);
    CGPathAddArcToPoint(basePath3, NULL, frameSize.width - inset, inset + 1, frameSize.width - inset, cornerRadius, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath3, NULL, frameSize.width - inset, middle);
    CGPathAddLineToPoint(basePath3, NULL, inset, middle);
    
    CGPathCloseSubpath(basePath3);
    
    CGContextAddPath(context, basePath3);
    switch(state) {
        case PopupMenuStateNormal:
            CGContextSetRGBFillColor(context, 0.314, 0.314, 0.314, 1.0);
            break;
        case PopupMenuStateHighlighted:
            CGContextSetRGBFillColor(context, 0.216, 0.471, 0.871, 1.0);
            break;
    }
    CGContextFillPath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, basePath3);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef3 = CGColorSpaceCreateDeviceRGB();
    CGFloat components3[8];
    switch(state) {
        case PopupMenuStateNormal:
            components3[0] = 0.314; components3[1] = 0.314; components3[2] = 0.314; components3[3] = 1;
            components3[4] = 0.165; components3[5] = 0.165; components3[6] = 0.165; components3[7] = 1;
            break;
        case PopupMenuStateHighlighted:
            components3[0] = 0.216; components3[1] = 0.471; components3[2] = 0.871; components3[3] = 1;
            components3[4] = 0.059; components3[5] = 0.353; components3[6] = 0.839; components3[7] = 1;
            break;
    }
    size_t count3 = sizeof(components3) / (sizeof(CGFloat) * 4);
    
    CGGradientRef gradientRef3 = CGGradientCreateWithColorComponents(colorSpaceRef3, components3, NULL, count3);
    
    CGPoint startPoint3 = CGPointMake(0, inset);
    CGPoint endPoint3 = CGPointMake(0, middle);
    
    CGContextDrawLinearGradient(context, gradientRef3, startPoint3, endPoint3, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef3);
    CGColorSpaceRelease(colorSpaceRef3);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(basePath3);
    
    CGMutablePathRef basePath4 = CGPathCreateMutable();
    
    CGPathMoveToPoint(basePath4, NULL, inset, middle);
    CGPathAddLineToPoint(basePath4, NULL, frameSize.width - inset, middle);
    
    CGPathAddLineToPoint(basePath4, NULL, frameSize.width - inset, frameSize.height - cornerRadius);
    CGPathAddArcToPoint(basePath4, NULL, frameSize.width - inset, frameSize.height - inset, frameSize.width - cornerRadius, frameSize.height - inset, cornerRadius - cornerInset);
    
    CGPathAddLineToPoint(basePath4, NULL, cornerRadius, frameSize.height - inset);
    CGPathAddArcToPoint(basePath4, NULL, inset, frameSize.height - inset, inset, frameSize.height - cornerRadius, cornerRadius - cornerInset);
    
    CGPathCloseSubpath(basePath4);
    
    CGContextAddPath(context, basePath4);
    switch(state) {
        case PopupMenuStateNormal:
            CGContextSetRGBFillColor(context, 0.102, 0.102, 0.102, 1.0);
            break;
        case PopupMenuStateHighlighted:
            CGContextSetRGBFillColor(context, 0.047, 0.306, 0.827, 1.0);
            break;
    }
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    CGContextFillPath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, basePath4);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef4 = CGColorSpaceCreateDeviceRGB();
    CGFloat components4[8];
    switch(state) {
        case PopupMenuStateNormal:
            components4[0] = 0.102; components4[1] = 0.102; components4[2] = 0.102; components4[3] = 1;
            components4[4] = 0; components4[5] = 0; components4[6] = 0; components4[7] = 1;
            break;
        case PopupMenuStateHighlighted:
            components4[0] = 0.047; components4[1] = 0.306; components4[2] = 0.827; components4[3] = 1;
            components4[4] = 0.027; components4[5] = 0.176; components4[6] = 0.737; components4[7] = 1;
            break;
    }
    size_t count4 = sizeof(components4) / (sizeof(CGFloat) * 4);
    
    CGGradientRef gradientRef4 = CGGradientCreateWithColorComponents(colorSpaceRef4, components4, NULL, count4);
    
    CGPoint startPoint4 = CGPointMake(0, middle);
    CGPoint endPoint4 = CGPointMake(0, frameSize.height - inset);
    
    CGContextDrawLinearGradient(context, gradientRef4, startPoint4, endPoint4, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef4);
    CGColorSpaceRelease(colorSpaceRef4);
    
    CGContextRestoreGState(context);
    
    CGPathRelease(basePath4);
    
    CGFloat separatorOffset = 0;
    
    if(self.items.count > 1) {
        for(NSUInteger i = 0; i < self.items.count; i++) {
            PopupMenuItem *item = [self.items objectAtIndex:i];
            CGSize actualSize = [item actualSize];
            
            if(i == 0) {
                separatorOffset = separatorOffset + actualSize.width;
                
                [self drawRightSeparatorInContext:context startPoint:CGPointMake(separatorOffset - 1, inset * 2) endPoint:CGPointMake(separatorOffset - 1, frameSize.height - inset * 2) state:state];
            } else if(i == self.items.count - 1) {
                [self drawLeftSeparatorInContext:context startPoint:CGPointMake(separatorOffset, inset * 2) endPoint:CGPointMake(separatorOffset, frameSize.height - inset * 2) state:state];
                
                separatorOffset = separatorOffset + actualSize.width;
            } else {
                [self drawLeftSeparatorInContext:context startPoint:CGPointMake(separatorOffset, inset * 2) endPoint:CGPointMake(separatorOffset, frameSize.height - inset * 2) state:state];
                
                separatorOffset = separatorOffset + actualSize.width;
                
                [self drawRightSeparatorInContext:context startPoint:CGPointMake(separatorOffset - 1, inset * 2) endPoint:CGPointMake(separatorOffset - 1, frameSize.height - inset * 2) state:state];
            }
        }
    }
    UIImage *popupImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return popupImage;
}

- (void)drawRightSeparatorInContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint state:(PopupMenuState)state
{
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(startPoint.x, startPoint.y, 1, endPoint.y - startPoint.y));
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[16];
    switch(state) {
        case PopupMenuStateNormal:
            components[0] = 0.31; components[1] = 0.31; components[2] = 0.31; components[3] = 1;
            components[4] = 0.06; components[5] = 0.06; components[6] = 0.06; components[7] = 1;
            
            components[8] = 0.04; components[9] = 0.04; components[10] = 0.04; components[11] = 1;
            components[12] = 0; components[13] = 0; components[14] = 0; components[15] = 1;
            break;
        case PopupMenuStateHighlighted:
            components[0] = 0.22; components[1] = 0.47; components[2] = 0.87; components[3] = 1;
            components[4] = 0.03; components[5] = 0.18; components[6] = 0.72; components[7] = 1;
            
            components[8] = 0.02; components[9] = 0.15; components[10] = 0.73; components[11] = 1;
            components[12] = 0.03; components[13] = 0.17; components[14] = 0.72; components[15] = 1;
            break;
    }
    size_t count = sizeof(components) / (sizeof(CGFloat) * 4);
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient (context, gradientRef, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
}

- (void)drawLeftSeparatorInContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint state:(PopupMenuState)state
{
    CGContextSaveGState(context);
    CGContextAddRect(context, CGRectMake(startPoint.x, startPoint.y, 1, endPoint.y - startPoint.y));
    CGContextClip(context);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[16];
    switch(state) {
        case PopupMenuStateNormal:
            components[0] = 0.31; components[1] = 0.31; components[2] = 0.31; components[3] = 1;
            components[4] = 0.31; components[5] = 0.31; components[6] = 0.31; components[7] = 1;
            
            components[8] = 0.24; components[9] = 0.24; components[10] = 0.24; components[11] = 1;
            components[12] = 0.05; components[13] = 0.05; components[14] = 0.05; components[15] = 1;
            break;
        case PopupMenuStateHighlighted:
            components[0] = 0.22; components[1] = 0.47; components[2] = 0.87; components[3] = 1;
            components[4] = 0.12; components[5] = 0.50; components[6] = 0.89; components[7] = 1;
            
            components[8] = 0.09; components[9] = 0.47; components[10] = 0.88; components[11] = 1;
            components[12] = 0.03; components[13] = 0.18; components[14] = 0.74; components[15] = 1;
            break;
    }
    size_t count = sizeof(components) / (sizeof(CGFloat) * 4);
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient (context, gradientRef, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
}

@end
