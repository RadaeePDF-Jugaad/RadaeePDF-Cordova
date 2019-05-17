//
//  NSObject+PerformBlock.h
//  Answhere
//
//  Created by Radaee on 5/28/11.
//  Copyright 2011 Radaee. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject(PerformBlock)

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;
- (void)performBlockOnMainThread:(dispatch_block_t)block;
- (void)performBlockInBackground:(dispatch_block_t)block;

@end