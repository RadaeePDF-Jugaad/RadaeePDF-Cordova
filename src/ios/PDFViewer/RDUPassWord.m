//
//  RDUPassWord.m
//  PDFViewer
//
//  Created by radaee on 13-2-1.
//  Copyright (c) 2013年 Radaee. All rights reserved.
//

#import "RDUPassWord.h"

@implementation RDUPassWord
@synthesize uPwd;
NSString *text;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
   
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self != nil) {
        // 初始化自定义控件，注意摆放的位置，可以多试几次位置参数直到满意为止
        // createTextField函数用来初始化UITextField控件，在文件末尾附上
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            self.alertViewStyle = UIAlertViewStyleSecureTextInput;
        }
        NSString *password =[[NSString alloc]initWithFormat:NSLocalizedString(@"PassWord", @"Localizable")];
        self.uPwd = [self createTextField:password
                                   withFrame:CGRectMake(22, 45, 240, 36)];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
            
        }
        [self addSubview:self.uPwd];
        

    }
    
    return self;
}

// Override父类的layoutSubviews方法
- (void)layoutSubviews {
    [super layoutSubviews];     // 当override父类的方法时，要注意一下是否需要调用父类的该方法
    
    for (UIView* view in self.subviews) {
        // 搜索AlertView底部的按钮，然后将其位置下移
        // IOS5以前按钮类是UIButton, IOS5里该按钮类是UIThreePartButton
        if ([view isKindOfClass:[UIButton class]] ||
            [view isKindOfClass:NSClassFromString(@"UIThreePartButton")]) {
            CGRect btnBounds = view.frame;
            btnBounds.origin.y = self.uPwd.frame.origin.y + self.uPwd.frame.size.height + 7;
            view.frame = btnBounds;
        }
    }
    
    // 定义AlertView的大小
    CGRect bounds = self.frame;
    bounds.size.height = 160;
    self.frame = bounds;
}

- (UITextField*)createTextField:(NSString*)placeholder withFrame:(CGRect)frame {
    UITextField* field = [[UITextField alloc] initWithFrame:frame];
    field.placeholder = placeholder;
    field.delegate = (id)self;
    field.secureTextEntry = YES;
    field.backgroundColor = [UIColor whiteColor]; 
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged]; 
    return field;
}
- (void) textFieldDidChange:(id) sender 
{    
     UITextField *_field = (UITextField *)sender;    
     text = [_field text];
}



@end
