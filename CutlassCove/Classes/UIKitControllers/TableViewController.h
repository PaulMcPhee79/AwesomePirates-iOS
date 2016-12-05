//
//  TableViewController.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 18/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UIViewController {
	BOOL mHasScrollIndicatorFlashed;
	int mCellHeight;
	float mTableViewTransformOffset;
	CGPoint mTranslateTo;
	
	UIView *mLoadingView;
	UIActivityIndicatorView *mActivityIndicator;
	
	UITableView *mTableView;
}

@property (nonatomic,retain) UITableView *tableView;

- (void)updateOrientation:(UIDeviceOrientation)orientation;
- (void)flashTableViewScrollIndicators;

@end
