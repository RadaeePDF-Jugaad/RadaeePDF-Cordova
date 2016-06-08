//
//  CustomSignatureView.h
//  UviGLSignature
//
//  Created by Vignesh on 2/10/16.
//  Copyright © 2016 vigneshuvi. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol definition starts here
@protocol UviSignatureViewDelegate <NSObject>
@required
- (void)shakeCompleted;
@end

@interface UviSignatureView : UIView {
    CGPoint previousPoint;
    UIBezierPath *signPath;
    UIImage *resultImage;
    NSArray *backgroundLines;
}

@property (nonatomic, strong, nonnull) NSMutableArray *pathArray;
@property (nonatomic, strong, nullable) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, readonly) BOOL signatureExists;
- (void)captureSignature;
- (void)signatureImage:(CGPoint)position text:(NSString*_Nullable)text fitSignature:(BOOL)fitSignature;

- (void)erase;

@end
