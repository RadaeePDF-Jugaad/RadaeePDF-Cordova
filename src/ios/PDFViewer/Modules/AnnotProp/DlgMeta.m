//
//  DlgMeta.m
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/6.
//  Copyright © 2020 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DlgMeta.h"

@implementation DlgMeta
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        
    }
    return self;
}

-(NSString *)title
{
    return mTitle.text;
}
-(NSString *)author
{
    return mAuthor.text;
}
-(NSString *)subject
{
    return mSubject.text;
}
-(NSString *)keywords
{
    return mKeyWords.text;
}
-(void)setTitle:(NSString *)val
{
    mTitle.text = val;
}
-(void)setAuthor:(NSString *)val
{
    mAuthor.text = val;
}
-(void)setSubject:(NSString *)val
{
    mSubject.text = val;
}
-(void)setKeywords:(NSString *)val
{
    mKeyWords.text = val;
}

@end
