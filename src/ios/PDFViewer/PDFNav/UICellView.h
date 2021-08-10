//
//  UICellView.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import "PDFObjc.h"

typedef void(^func_delete)(id);
@interface UICellView : UIView

-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
- (IBAction)OnDelete:(id)sender;
-(void)UILoad : (NSString *)fname :(NSString *)path :(CGRect)frame :(UIImage *)def;
-(void)UISetDelete:(func_delete)callback;
-(void)UIUpdate;
-(void)BKRender;
-(PDFDoc *)UIGetDoc : (NSString *)pswd :(int *)err;
-(void)UIDelete;
@end
