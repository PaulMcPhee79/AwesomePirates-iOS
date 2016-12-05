//
//  TableViewController.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 18/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "TableViewController.h"
#import "CCMacros.h"

@implementation TableViewController

@synthesize tableView = mTableView;

- (id)init {
	if (self = [super init]) {
		mHasScrollIndicatorFlashed = NO;
		mCellHeight = RUISCALEY(64.0f);
		mTableViewTransformOffset = RUISCALEX(7.5f);
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		mTranslateTo = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height / 2);
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RUISCALEX(280), RUISCALEY(207))];
	view.opaque = NO;
	self.view = view;
	[view release];
	
	CGSize viewSize = self.view.frame.size;
	mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
															   2 * mTableViewTransformOffset,
															   viewSize.width,
															   viewSize.height - 2 * mTableViewTransformOffset)
											  style:UITableViewStylePlain];
	mTableView.backgroundColor = [UIColor clearColor];
	mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	mTableView.separatorColor = [UIColor clearColor];
	[self.view addSubview:mTableView];
	
	// Loading Scores Subview
	mLoadingView = [[UIView alloc] initWithFrame:CGRectMake((viewSize.width - RUISCALEX(128)) / 2, (viewSize.height - RUISCALEY(32)) / 2, RUISCALEX(128), RUISCALEY(32))];
	mLoadingView.center = mTableView.center;
	
	mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	mActivityIndicator.frame = CGRectMake(0.0f, 0.0f, RUISCALE(32.0f), RUISCALE(32.0f));
	[mLoadingView addSubview:mActivityIndicator];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(RUISCALE(40.0f), RUISCALE(8.0f), RUISCALE(96.0f), RUISCALE(16.0f))];
	label.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
	label.text = @"Loading...";
	label.textColor = RGB(0,114,255);
	label.textAlignment = NSTextAlignmentLeft; // UITextAlignmentLeft;
	label.backgroundColor = [UIColor clearColor];
	[mLoadingView addSubview:label];
	[label release];
	label = nil;
}

- (void)updateOrientation:(UIDeviceOrientation)orientation {
    return;
#if 0
	if (orientation != UIDeviceOrientationLandscapeRight && orientation != UIDeviceOrientationLandscapeLeft)
		return;
	UIView *view = self.view;
	view.transform = CGAffineTransformIdentity;
	
	float angle = 0, xTransformAdjust = 0;
	
	if (orientation == UIDeviceOrientationLandscapeRight) {
		angle = -PI_HALF;
		xTransformAdjust = mTableViewTransformOffset;
	} else {
		angle = PI_HALF;
		xTransformAdjust = -mTableViewTransformOffset;
	}
	CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(angle);
	CGAffineTransform originTransform = CGAffineTransformMakeTranslation(-view.frame.size.width / 2, -view.frame.size.height / 2);
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(mTranslateTo.x + xTransformAdjust, mTranslateTo.y);
	
	CGAffineTransform combinedTransform = CGAffineTransformConcat(CGAffineTransformConcat(rotateTransform,originTransform), translateTransform);
	view.transform = combinedTransform;
#endif
}

- (void)flashTableViewScrollIndicators {
	if (mHasScrollIndicatorFlashed == NO) {
		mHasScrollIndicatorFlashed = YES;
		[self.tableView flashScrollIndicators];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)dealloc {
	[mActivityIndicator release]; mActivityIndicator = nil;
	[mLoadingView release]; mLoadingView = nil;
	[mTableView release]; mTableView = nil;
	[super dealloc];
}

@end
