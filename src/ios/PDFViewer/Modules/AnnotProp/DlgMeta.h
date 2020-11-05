//
//  DlgMeta.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
@interface DlgMeta : UIView
{
    __weak IBOutlet UITextField *mTitle;
    __weak IBOutlet UITextField *mAuthor;
    __weak IBOutlet UITextField *mSubject;
    __weak IBOutlet UITextView *mKeyWords;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(NSString *)title;
-(NSString *)author;
-(NSString *)subject;
-(NSString *)keywords;
-(void)setTitle:(NSString *)val;
-(void)setAuthor:(NSString *)val;
-(void)setSubject:(NSString *)val;
-(void)setKeywords:(NSString *)val;
@end
