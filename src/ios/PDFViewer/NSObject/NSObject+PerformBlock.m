//
//  NSObject+PerformBlock.m
//  Answhere
//
//  Created by Radaee on 5/28/11.
//  Copyright 2011 Radaee. All rights reserved.
//

#import "NSObject+PerformBlock.h"

@implementation NSObject(PerformBlock_private)
- (void)performBlock:(dispatch_block_t)block afterDelay :(NSTimeInterval)delay
{
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(dispatchTime, dispatch_get_main_queue(), block);
}

- (void)performBlockOnMainThread :(dispatch_block_t)block
{
	dispatch_async(dispatch_get_main_queue(), block);
}

- (void)performBlockInBackground :(dispatch_block_t)block
{
	dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
	dispatch_async(globalQueue, block);
}

@end