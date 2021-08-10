//
//  RDPageViewController.h
//  RDPageViewController
//
//  Created by Federico Vellani on 06/02/2020.
//  Copyright © 2020 Federico Vellani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFObjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface RDPageViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (int)PDFOpenAtPath:(NSString *)path withPwd:(NSString *)pwd;
- (void)closeView;

#pragma mark - lib methods

- (id)getDoc;
- (int)getCurrentPage;
- (CGImageRef)imageForPage:(int)pg;
- (void)setReaderBGColor:(int)color;
- (void)setToolbarColor:(int)color;
- (void)setToolbarTintColor:(int)color;
- (void)setImmersive:(BOOL)immersive;
- (BOOL)saveImageFromAnnotAtIndex:(int)index atPage:(int)pageno savePath:(NSString *)path size:(CGSize )size;
- (BOOL)addAttachmentFromPath:(NSString *)path;
- (bool)flatAnnotAtPage:(int)page doc:(PDFDoc *)doc;
- (bool)flatAnnots;
- (bool)saveDocumentToPath:(NSString *)path;

// Form Manager
- (NSString *)getJSONFormFields;
- (NSString *)getJSONFormFieldsAtPage:(int)page;
- (NSString *)setFormFieldWithJSON:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
