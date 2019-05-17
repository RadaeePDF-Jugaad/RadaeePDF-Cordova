//
//  UIColor+Hex.h
//  PDFViewer
//
//  Created by strong on 2019/4/30.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)
+ (UIColor *)colorWithHexString:(NSString *)color;
@end

@interface BasicFactoryColor : NSObject
@end

NS_ASSUME_NONNULL_END
