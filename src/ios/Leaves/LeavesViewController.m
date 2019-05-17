//
//  LeavesViewController.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright Tom Brow 2010. All rights reserved.
//

#import "LeavesViewController.h"
#import "LeavesView.h"

@interface LeavesViewController () <LeavesViewDataSource, LeavesViewDelegate>

@end

@implementation LeavesViewController

//manu
//init also LeavesView and set Delegate and DataSource
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        _leavesView = [[LeavesView alloc] initWithFrame:CGRectZero];
        _leavesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _leavesView.dataSource = self;
        _leavesView.delegate = self;
    }
    return self;
}

//manu
//dealloc and release the LeaveView
- (void)dealloc {
	[_leavesView release];
    [super dealloc];
}

#pragma mark LeavesViewDataSource
//manu
//for the generic class, always return 0
- (NSUInteger)numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return 0;
}

//manu
//for the generic class, don't render anything
- (void)renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	
}

- (CGImageRef)vGetImageForPage:(int)pg
{
    return nil;
}

#pragma mark UIViewController
//manu
//when load, set the LeaveView frame and shows it
- (void)viewDidLoad {
	[super viewDidLoad];
    
    _leavesView.frame = self.view.bounds;
	[self.view addSubview:_leavesView];
	[_leavesView reloadData];
}

@end
