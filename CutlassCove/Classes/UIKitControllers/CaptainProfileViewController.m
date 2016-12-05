//
//  CaptainProfileViewController.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CaptainProfileViewController.h"


@implementation CaptainProfileViewController

- (id)initWithDataModel:(AchievementManager *)model {
	if (self = [super init]) {
		mCellHeight = RUISCALE(32);
		mData = [model retain];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
	CGRect viewRect = self.view.frame;
	[self.view removeFromSuperview];
	self.view = nil;
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewRect.size.width, viewRect.size.height)];
    
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    view.center = CGPointMake(RUISCALE(240 + offset.x), RUISCALE(167.5f + offset.y));
	view.opaque = NO;
	self.view = view;
	[view release];
	
	// Tableview
	CGSize viewSize = self.view.frame.size;
	[self.tableView removeFromSuperview];
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                    2 * mTableViewTransformOffset,
                                                                    viewSize.width,
                                                                    viewSize.height - 2 * mTableViewTransformOffset)
                                                   style:UITableViewStylePlain] autorelease];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.separatorColor = [UIColor clearColor];
	[self.view addSubview:self.tableView];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (void)onModelDataWillChange:(SPEvent *)event {
	[self.view addSubview:mLoadingView];
	[mActivityIndicator startAnimating];
}

- (void)onModelDataChanged:(StringValueEvent *)event {
	[mTableView reloadData];
	
	if ([mData rowCount] > 0)
		[mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	[mActivityIndicator stopAnimating];
	[mLoadingView removeFromSuperview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	const NSInteger DESC_LABEL_TAG = 1001;
	const NSInteger VALUE_LABEL_TAG = 1002;
	const NSInteger DIVIDER_IMAGE_TAG = 1003;
	
	UILabel *descLabel = nil;
	UILabel *valueLabel = nil;
	UIImageView *dividerView = nil;
	UIImageView *backgroundView = nil;
	NSString *cellIdentifier = @"Stats";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    [self flashTableViewScrollIndicators];
    
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundView = nil;
		
		CGRect tvRect = self.tableView.frame;
		
		// Divider Image
		UIImage *dividerImage = [UIImage imageNamed:EXPUIIMG(@"tableview-cell-divider")];
		dividerView = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
		dividerView.tag = DIVIDER_IMAGE_TAG;
		[cell.contentView addSubview:dividerView];
		
		// Description
		descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0f,
															   0,
															   0.55f * tvRect.size.width,
															   mCellHeight)]
					 autorelease];
		descLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		descLabel.tag = DESC_LABEL_TAG;
		descLabel.textAlignment = NSTextAlignmentLeft; // UITextAlignmentLeft;
		descLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:descLabel];
		
		// Value
		valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(tvRect.size.width - 0.4f * tvRect.size.width,
																0,
																0.4f * tvRect.size.width - 10,
																mCellHeight)]
					  autorelease];
		valueLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		valueLabel.tag = VALUE_LABEL_TAG;
		valueLabel.textAlignment = NSTextAlignmentRight; // UITextAlignmentRight;
		valueLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:valueLabel];
	} else {
		descLabel = (UILabel *)[cell viewWithTag:DESC_LABEL_TAG];
		valueLabel = (UILabel *)[cell viewWithTag:VALUE_LABEL_TAG];
		dividerView = (UIImageView *)[cell viewWithTag:DIVIDER_IMAGE_TAG];
		backgroundView = (UIImageView *)cell.backgroundView;
	}
	
	// Background
	NSString *bgImageName = nil;
	
	if (indexPath.row & 1)
		bgImageName = @"tableview-cell-dark";
	else
		bgImageName = @"tableview-cell-light";
	
	bgImageName = EXPUIIMG(bgImageName);
	
	if (backgroundView == nil) {
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:bgImageName]] autorelease];
		cell.backgroundView = backgroundView;
	} else {
		backgroundView.image = [UIImage imageNamed:bgImageName];
	}
	
	dividerView.hidden = (indexPath.row == 0);
	
	descLabel.text = [mData descForIndex:indexPath];
	valueLabel.text = [mData valueForIndex:indexPath];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [mData rowCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return mCellHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)dealloc {
	[mData release]; mData = nil;
	[super dealloc];
}

@end
