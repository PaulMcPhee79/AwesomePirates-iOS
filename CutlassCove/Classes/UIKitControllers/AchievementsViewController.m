//
//  AchievementsViewController.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AchievementsViewController.h"
#import "UIImage_Extension.h"
#import "CCMacros.h"
//#import "TransparentView.h"


@interface AchievementsViewController ()

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView speedboatCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView achievementCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)onLaunchSpeedboatButtonPressed:(UIButton *)button;

@end


@implementation AchievementsViewController

- (id)initWithDataModel:(AchievementManager *)model eventProxy:(SPEventDispatcher *)eventProxy {
	if (self = [super init]) {
		mData = [model retain];
        mEventProxy = [eventProxy retain];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    self.view.center = CGPointMake(RUISCALEX(240) + RUISCALE(offset.x), RUISCALEY(167.5f + offset.y));
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger TITLE_LABEL_TAG = 1001;
    const NSInteger DIVIDER_IMAGE_TAG = 1002;
    
    UILabel *titleLabel = nil;
    UIImageView *dividerView = nil;
	UIImageView *backgroundView = nil;
	NSString *cellIdentifier = @"HeaderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CGRect tvRect = self.tableView.frame;
    
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundView = nil;
        
        // Divider Image
		UIImage *dividerImage = [UIImage imageNamed:EXPUIIMG(@"tableview-cell-divider")];
		dividerView = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
		dividerView.tag = DIVIDER_IMAGE_TAG;
		[cell.contentView addSubview:dividerView];
        
        // Title
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.2f * tvRect.size.width,
																(mCellHeight - RUISCALEY(32.0f)) / 2,
																0.7f * tvRect.size.width,
																RUISCALEY(32.0f))] autorelease];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping; // UILineBreakModeWordWrap;
		titleLabel.numberOfLines = 0;
		titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(16.0f)];
		titleLabel.tag = TITLE_LABEL_TAG;
		titleLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:titleLabel];
    } else {
        titleLabel = (UILabel *)[cell viewWithTag:TITLE_LABEL_TAG];
		dividerView = (UIImageView *)[cell viewWithTag:DIVIDER_IMAGE_TAG];
		backgroundView = (UIImageView *)cell.backgroundView;
    }
    
    // Icon
	UIImage *icon = [UIImage imageNamed:EXPUIIMG([mData imageNameForIndex:indexPath])];
	cell.imageView.image = icon;
	
	// Background
	if (backgroundView == nil) {
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])]] autorelease];
		cell.backgroundView = backgroundView;
	} else {
		backgroundView.image = [UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])];
	}
	
	dividerView.hidden = (indexPath.row == 0);
    titleLabel.text = [mData titleForIndex:indexPath];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView speedboatCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Upper section
    const NSInteger TITLE_LABEL_TAG = 1001;
	const NSInteger DESC_LABEL_TAG = 1002;
	const NSInteger POINTS_LABEL_TAG = 1003;
    const NSInteger ICON_IMAGE_TAG = 1004;
	const NSInteger DIVIDER_IMAGE_TAG = 1005;
    const NSInteger PRIZE_GREY_IMAGE_TAG = 1006;
    const NSInteger PRIZE_IMAGE_TAG = 1007;
    
    // Lower section
    const NSInteger SHIP_LABEL_TAG = 1008;
    const NSInteger SHIP_IMAGE_TAG = 1009;
	const NSInteger HELM_BUTTON_TAG = 1010;
	
    // Upper section
	UILabel *titleLabel = nil;
	UILabel *descLabel = nil;
	UILabel *pointsLabel = nil;
    UIImageView *iconView = nil;
	UIImageView *dividerView = nil;
    UIImageView *prizeGreyView = nil;
    UIImageView *prizeView = nil;
	UIImageView *backgroundView = nil;
    
    // Lower section
    UIImageView *shipView = nil;
    UILabel *shipLabel = nil;
    UIButton *helmButton = nil;
    
	NSString *cellIdentifier = @"SpeedboatCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	CGRect tvRect = self.tableView.frame;
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundView = nil;
		
        // Upper section
        
		// Divider Image
		UIImage *dividerImage = [UIImage imageNamed:EXPUIIMG(@"tableview-cell-divider")];
		dividerView = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
		dividerView.tag = DIVIDER_IMAGE_TAG;
		[cell.contentView addSubview:dividerView];
        
        // Icon Image
		iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5 + (mCellHeight - RUISCALEY(32.0f)) / 2, RUISCALE(32.0f), RUISCALE(32.0f))] autorelease];
		iconView.tag = ICON_IMAGE_TAG;
		[cell.contentView addSubview:iconView];
		
		// Title
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.2f * tvRect.size.width,
																4.0f,
																0.6f * tvRect.size.width,
																RUISCALEY(14.0f))] autorelease];
		titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		titleLabel.textColor = RGB(0,114,255);
		titleLabel.tag = TITLE_LABEL_TAG;
		titleLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:titleLabel];
		
		// Description
		descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.175f * tvRect.size.width,
															   titleLabel.frame.origin.y + titleLabel.frame.size.height,
															   0.6f * tvRect.size.width,
															   3 * RUISCALEY(13.0f))] autorelease];
		descLabel.lineBreakMode = NSLineBreakByWordWrapping; // UILineBreakModeWordWrap;
		descLabel.numberOfLines = 0;
		descLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(12.0f)];
		descLabel.tag = DESC_LABEL_TAG;
		descLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentLeft;
		descLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:descLabel];
		
		// Points
		pointsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.79125f * tvRect.size.width,
                                                                 mCellHeight - RUISCALEY(18.0f),
                                                                 0.2f * tvRect.size.width,
                                                                 RUISCALEY(16.0f))] autorelease];
		pointsLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(16.0f)];
		pointsLabel.textColor = RGB(0,0,0);
		pointsLabel.tag = POINTS_LABEL_TAG;
		pointsLabel.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter;
		pointsLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:pointsLabel];
        
        // Prize Grey Image
		UIImage *prizeGreyImage = [UIImage imageNamed:EXPUIIMG(@"ach-prize-grey-0")];
		prizeGreyView = [[[UIImageView alloc] initWithImage:prizeGreyImage] autorelease];
		prizeGreyView.tag = PRIZE_GREY_IMAGE_TAG;
        prizeGreyView.frame = CGRectMake(tvRect.size.width - 1.125f * prizeGreyImage.size.width, RUISCALEY(2), prizeGreyImage.size.width, prizeGreyImage.size.height);
		[cell.contentView addSubview:prizeGreyView];
        
        // Prize Image
		UIImage *prizeImage = [UIImage imageNamed:EXPUIIMG(@"ach-prize-0")];
		prizeView = [[[UIImageView alloc] initWithImage:prizeImage] autorelease];
		prizeView.tag = PRIZE_IMAGE_TAG;
        prizeView.frame = CGRectMake(tvRect.size.width - 1.125f * prizeImage.size.width, RUISCALEY(2), prizeImage.size.width, prizeImage.size.height);
		[cell.contentView addSubview:prizeView];
        
        
        
        // Lower section
        
        // Ship Image
		UIImage *shipImage = [UIImage imageNamed:EXPUIIMG(@"speedboat-icon")];
		shipView = [[[UIImageView alloc] initWithImage:shipImage] autorelease];
        
        CGRect tempFrame = shipView.frame;
        shipView.frame = CGRectMake(8, mCellHeight + (mCellHeight - tempFrame.size.height) / 2, tempFrame.size.width, tempFrame.size.height);
		shipView.tag = SHIP_IMAGE_TAG;
		[cell.contentView addSubview:shipView];
        
        // Ship Label
        shipLabel = [[[UILabel alloc] initWithFrame:CGRectMake(tempFrame.origin.x + tempFrame.size.width + 16,
                                                               mCellHeight + (mCellHeight - 2 * RUISCALEY(14.0f)) / 2,
                                                               0.35f * tvRect.size.width,
                                                               2 * RUISCALEY(15.0f))] autorelease];
        shipLabel.lineBreakMode = NSLineBreakByWordWrapping; // UILineBreakModeWordWrap;
		shipLabel.numberOfLines = 0;
		shipLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		shipLabel.tag = SHIP_LABEL_TAG;
		shipLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		shipLabel.backgroundColor = [UIColor clearColor];
        shipLabel.text = @"Touch the wheel to launch.";
		[cell.contentView addSubview:shipLabel];
        
        // Helm Button
        UIImage *helmImage = [UIImage imageNamed:EXPUIIMG(@"speedboat-helm-icon")];
        UIImage *helmImageHighlighted = [UIImage imageNamed:EXPUIIMG(@"speedboat-helm-icon-highlighted")];
        //helmImageHighlighted = [UIImage scale_CHEEKY:helmImageHighlighted toSize:CGSizeMake(0.9f * helmImageHighlighted.size.width, 0.9f * helmImageHighlighted.size.height)];
        
		helmButton = [UIButton buttonWithType:UIButtonTypeCustom];
		helmButton.tag = HELM_BUTTON_TAG;
        helmButton.frame = CGRectMake(tvRect.size.width - (helmImage.size.width + 10),
                                      mCellHeight + (mCellHeight - helmImage.size.height) / 2,
                                      helmImage.size.width,
                                      helmImage.size.height);
		helmButton.backgroundColor = [UIColor clearColor];
		[helmButton setImage:helmImage forState:UIControlStateNormal];
		[helmButton setImage:helmImageHighlighted forState:UIControlStateHighlighted];
		[helmButton addTarget:self action:@selector(onLaunchSpeedboatButtonPressed:) forControlEvents:UIControlEventTouchDown];
		[cell.contentView addSubview:helmButton];
	}  else {
        // Upper section
		titleLabel = (UILabel *)[cell viewWithTag:TITLE_LABEL_TAG];
		descLabel = (UILabel *)[cell viewWithTag:DESC_LABEL_TAG];
		pointsLabel = (UILabel *)[cell viewWithTag:POINTS_LABEL_TAG];
        iconView = (UIImageView *)[cell viewWithTag:ICON_IMAGE_TAG];
		dividerView = (UIImageView *)[cell viewWithTag:DIVIDER_IMAGE_TAG];
        prizeGreyView = (UIImageView *)[cell viewWithTag:PRIZE_GREY_IMAGE_TAG];
        prizeView = (UIImageView *)[cell viewWithTag:PRIZE_IMAGE_TAG];
		backgroundView = (UIImageView *)cell.backgroundView;
        
        // Lower section
        //shipView = (UIImageView *)[cell viewWithTag:SHIP_IMAGE_TAG];
        //shipLabel = (UILabel *)[cell viewWithTag:SHIP_LABEL_TAG];
        //helmButton (UIButton *)[cell viewWithTag:HELM_BUTTON_TAG];
	}
    
    // Icon
    UIImage *icon = [UIImage imageNamed:EXPUIIMG([mData imageNameForIndex:indexPath])];
	iconView.image = icon;
	
	// Background
	if (backgroundView == nil) {
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])]] autorelease];
		cell.backgroundView = backgroundView;
	} else {
		backgroundView.image = [UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])];
	}
	
	// Achievement completion status
	BOOL completed = [mData completedForIndex:indexPath];
	
	if (completed == YES) {
		titleLabel.textColor = RGB(0,114,255);
		pointsLabel.textColor = RGB(0,120,0);
        prizeGreyView.hidden = YES;
        prizeView.hidden = NO;
	} else {
		titleLabel.textColor = RGB(0,0,0);
		pointsLabel.textColor = RGB(0,0,0);
        prizeGreyView.hidden = NO;
        prizeView.hidden = YES;
	}
	
	titleLabel.text = [mData titleForIndex:indexPath];
	descLabel.text = [mData descForIndex:indexPath];
	pointsLabel.text = [mData valueForIndex:indexPath];
	
	// Description frame
	CGSize maximumSize = CGSizeMake(0.6f * tvRect.size.width, 3 * RUISCALEY(13.0f));
	CGSize descSize = [descLabel.text sizeWithFont:descLabel.font constrainedToSize:maximumSize lineBreakMode:descLabel.lineBreakMode];
	CGRect descFrame = CGRectMake(0.175f * tvRect.size.width,
                                  titleLabel.frame.origin.y + titleLabel.frame.size.height,
                                  0.6f * tvRect.size.width,
                                  MAX(2 * RUISCALEY(13.0f), descSize.height));
	descLabel.frame = descFrame;
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView achievementCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger TITLE_LABEL_TAG = 1001;
	const NSInteger DESC_LABEL_TAG = 1002;
	const NSInteger POINTS_LABEL_TAG = 1003;
	const NSInteger PERCENT_LABEL_TAG = 1004;
	const NSInteger DIVIDER_IMAGE_TAG = 1005;
    const NSInteger PROGRESS_GREY_IMAGE_TAG = 1006;
    const NSInteger PROGRESS_IMAGE_TAG = 1007;
    const NSInteger COMPLETED_GREY_IMAGE_TAG = 1008;
    const NSInteger COMPLETED_IMAGE_TAG = 1009;
    const NSInteger PRIZE_GREY_IMAGE_TAG = 1010;
    const NSInteger PRIZE_IMAGE_TAG = 1011;
    
	
	UILabel *titleLabel = nil;
	UILabel *descLabel = nil;
	UILabel *pointsLabel = nil;
	UILabel *percentLabel = nil;
	UIImageView *dividerView = nil;
    UIImageView *progressGreyView = nil;
    UIImageView *progressView = nil;
    UIImageView *completedGreyView = nil;
    UIImageView *completedView = nil;
    UIImageView *prizeGreyView = nil;
    UIImageView *prizeView = nil;
	UIImageView *backgroundView = nil;
	NSString *cellIdentifier = @"AchievementCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	CGRect tvRect = self.tableView.frame;
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundView = nil;
		
		// Divider Image
		UIImage *dividerImage = [UIImage imageNamed:EXPUIIMG(@"tableview-cell-divider")];
		dividerView = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
		dividerView.tag = DIVIDER_IMAGE_TAG;
		[cell.contentView addSubview:dividerView];
		
		// Title
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.2f * tvRect.size.width,
																4.0f,
																0.6f * tvRect.size.width,
																RUISCALEY(14.0f))] autorelease];
		titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		titleLabel.textColor = RGB(0,114,255);
		titleLabel.tag = TITLE_LABEL_TAG;
		titleLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:titleLabel];
		
		// Description
		descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.175f * tvRect.size.width,
															   titleLabel.frame.origin.y + titleLabel.frame.size.height,
															   0.6f * tvRect.size.width,
															   3 * RUISCALEY(13.0f))] autorelease];
		descLabel.lineBreakMode = NSLineBreakByWordWrapping; // UILineBreakModeWordWrap;
		descLabel.numberOfLines = 0;
		descLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(12.0f)];
		descLabel.tag = DESC_LABEL_TAG;
		descLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentLeft;
		descLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:descLabel];
		
		// Points
		pointsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.79125f * tvRect.size.width,
                                                                 mCellHeight - RUISCALEY(18.0f),
                                                                 0.2f * tvRect.size.width,
                                                                 RUISCALEY(16.0f))] autorelease];
		pointsLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(16.0f)];
		pointsLabel.textColor = RGB(0,0,0);
		pointsLabel.tag = POINTS_LABEL_TAG;
		pointsLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		pointsLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:pointsLabel];
        
        // Prize Grey Image
		UIImage *prizeGreyImage = [UIImage imageNamed:EXPUIIMG(@"ach-prize-grey-0")];
		prizeGreyView = [[[UIImageView alloc] initWithImage:prizeGreyImage] autorelease];
		prizeGreyView.tag = PRIZE_GREY_IMAGE_TAG;
        prizeGreyView.frame = CGRectMake(tvRect.size.width - 1.125f * prizeGreyImage.size.width, RUISCALEY(2), prizeGreyImage.size.width, prizeGreyImage.size.height);
		[cell.contentView addSubview:prizeGreyView];
        
        // Prize Image
		UIImage *prizeImage = [UIImage imageNamed:EXPUIIMG(@"ach-prize-0")];
		prizeView = [[[UIImageView alloc] initWithImage:prizeImage] autorelease];
		prizeView.tag = PRIZE_IMAGE_TAG;
        prizeView.frame = CGRectMake(tvRect.size.width - 1.125f * prizeImage.size.width, RUISCALEY(2), prizeImage.size.width, prizeImage.size.height);
		[cell.contentView addSubview:prizeView];
		
		// Percent
		percentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.03f * tvRect.size.width,
																  mCellHeight - RUISCALEY(13.0f),
																  0.1125f * tvRect.size.width,
																  RUISCALEY(12.0f))] autorelease];
		percentLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(12.0f)];
		percentLabel.textColor = RGB(196,17,30);
		percentLabel.tag = PERCENT_LABEL_TAG;
		percentLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentRight;
		percentLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:percentLabel];
        
        // Progress Grey Trail
        UIImage *progressGreyTrailImage = [UIImage imageNamed:EXPUIIMG(@"treasure-trail-grey")];
		progressGreyView = [[[UIImageView alloc] initWithImage:progressGreyTrailImage] autorelease];
		progressGreyView.tag = PROGRESS_GREY_IMAGE_TAG;
        progressGreyView.frame = CGRectMake(percentLabel.frame.origin.x + percentLabel.frame.size.width + 2,
                                        mCellHeight - 1.25f * progressGreyTrailImage.size.height,
                                        progressGreyTrailImage.size.width,
                                        progressGreyTrailImage.size.height);
        progressGreyView.contentMode = UIViewContentModeBottomLeft;
        progressGreyView.clipsToBounds = YES;
		[cell.contentView addSubview:progressGreyView];
        
        // Progress Trail
        UIImage *progressTrailImage = [UIImage imageNamed:EXPUIIMG(@"treasure-trail")];
		progressView = [[[UIImageView alloc] initWithImage:progressTrailImage] autorelease];
		progressView.tag = PROGRESS_IMAGE_TAG;
        progressView.frame = CGRectMake(percentLabel.frame.origin.x + percentLabel.frame.size.width + 2,
                                        mCellHeight - 1.25f * progressTrailImage.size.height,
                                        progressTrailImage.size.width,
                                        progressTrailImage.size.height);
        progressView.contentMode = UIViewContentModeBottomLeft;
        progressView.clipsToBounds = YES;
		[cell.contentView addSubview:progressView];
        
        // Completed Grey: X Marks the Spot
        UIImage *completedGreyImage = [UIImage imageNamed:EXPUIIMG(@"x-marks-the-spot-grey")];
		completedGreyView = [[[UIImageView alloc] initWithImage:completedGreyImage] autorelease];
		completedGreyView.tag = COMPLETED_GREY_IMAGE_TAG;
        completedGreyView.frame = CGRectMake(progressView.frame.origin.x + 0.985f * progressView.frame.size.width,
                                         progressView.frame.origin.y - 0.275f * completedGreyImage.size.height,
                                         completedGreyImage.size.width,
                                         completedGreyImage.size.height);
		[cell.contentView addSubview:completedGreyView];
        
        // Completed: X Marks the Spot
        UIImage *completedImage = [UIImage imageNamed:EXPUIIMG(@"x-marks-the-spot")];
		completedView = [[[UIImageView alloc] initWithImage:completedImage] autorelease];
		completedView.tag = COMPLETED_IMAGE_TAG;
        completedView.frame = CGRectMake(progressView.frame.origin.x + 0.985f * progressView.frame.size.width,
                                        progressView.frame.origin.y - 0.275f * completedImage.size.height,
                                        completedImage.size.width,
                                        completedImage.size.height);
		[cell.contentView addSubview:completedView];
	}  else {
		titleLabel = (UILabel *)[cell viewWithTag:TITLE_LABEL_TAG];
		descLabel = (UILabel *)[cell viewWithTag:DESC_LABEL_TAG];
		pointsLabel = (UILabel *)[cell viewWithTag:POINTS_LABEL_TAG];
		percentLabel = (UILabel *)[cell viewWithTag:PERCENT_LABEL_TAG];
		dividerView = (UIImageView *)[cell viewWithTag:DIVIDER_IMAGE_TAG];
        progressGreyView = (UIImageView *)[cell viewWithTag:PROGRESS_GREY_IMAGE_TAG];
        progressView = (UIImageView *)[cell viewWithTag:PROGRESS_IMAGE_TAG];
        completedGreyView = (UIImageView *)[cell viewWithTag:COMPLETED_GREY_IMAGE_TAG];
        completedView = (UIImageView *)[cell viewWithTag:COMPLETED_IMAGE_TAG];
        prizeGreyView = (UIImageView *)[cell viewWithTag:PRIZE_GREY_IMAGE_TAG];
        prizeView = (UIImageView *)[cell viewWithTag:PRIZE_IMAGE_TAG];
		backgroundView = (UIImageView *)cell.backgroundView;
	}
	
	// Cell Icon
	UIImage *icon = [UIImage imageNamed:EXPUIIMG([mData imageNameForIndex:indexPath])];
	//icon = [UIImage scale:icon toSize:CGSizeMake(24.0f, 24.0f)];
	cell.imageView.image = icon;
	
	// Background
	if (backgroundView == nil) {
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])]] autorelease];
		cell.backgroundView = backgroundView;
	} else {
		backgroundView.image = [UIImage imageNamed:EXPUIIMG([mData backgroundImageNameForIndex:indexPath])];
	}
	
	// Achievement completion status
	BOOL completed = [mData completedForIndex:indexPath];
	
	if (completed == YES) {
		titleLabel.textColor = RGB(0,114,255);
		pointsLabel.textColor = RGB(0,120,0);
        prizeGreyView.hidden = YES;
        prizeView.hidden = NO;
        completedGreyView.hidden = YES;
        completedView.hidden = NO;
        
        // Prize Icon
        UIImage *prizeIcon = [UIImage imageNamed:EXPUIIMG([mData prizeImageNameForIndex:indexPath completed:YES])];
        prizeView.image = prizeIcon;
	} else {
		titleLabel.textColor = RGB(0,0,0);
		pointsLabel.textColor = RGB(0,0,0);
        prizeGreyView.hidden = NO;
        prizeView.hidden = YES;
        completedGreyView.hidden = NO;
        completedView.hidden = YES;
        
        // Prize Grey Icon
        UIImage *prizeGreyIcon = [UIImage imageNamed:EXPUIIMG([mData prizeImageNameForIndex:indexPath completed:NO])];
        prizeGreyView.image = prizeGreyIcon;
	}
    
    double percent = [mData percentForIndex:indexPath];
    percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)percent];
    percentLabel.textColor = ((int)percent == 0) ? RGB(196,17,30) : RGB(0,120,0);
    
    if ([mData isBinaryForIndex:indexPath]) {
        percentLabel.hidden = YES;
        completedGreyView.hidden = YES;
        completedView.hidden = YES;
        progressView.hidden = YES;
        progressGreyView.hidden = YES;
    } else {
        percentLabel.hidden = NO;
        progressView.hidden = NO;
        progressGreyView.hidden = NO;
        progressView.frame = CGRectMake(progressView.frame.origin.x,
                                        progressView.frame.origin.y,
                                        MIN(progressView.image.size.width, (percent / 100.0) * progressView.image.size.width),
                                        progressView.image.size.height);
    }
	
	titleLabel.text = [mData titleForIndex:indexPath];
	descLabel.text = [mData descForIndex:indexPath];
	pointsLabel.text = [mData valueForIndex:indexPath];
    
	// Description frame
	CGSize maximumSize = CGSizeMake(0.6f * tvRect.size.width, 3 * RUISCALEY(13.0f));
	CGSize descSize = [descLabel.text sizeWithFont:descLabel.font constrainedToSize:maximumSize lineBreakMode:descLabel.lineBreakMode];
	CGRect descFrame = CGRectMake(0.175f * tvRect.size.width,
                                  titleLabel.frame.origin.y + titleLabel.frame.size.height,
                                  0.6f * tvRect.size.width,
                                  MAX(2 * RUISCALEY(13.0f), descSize.height));
	descLabel.frame = descFrame;
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    [self flashTableViewScrollIndicators];
    
	switch (indexPath.row) {
        case 0:
        {
            cell = [self tableView:tableView headerCellForRowAtIndexPath:indexPath];
        }
            break;
        default:
        {
#ifdef CHEEKY_LITE_VERSION
            cell = [self tableView:tableView achievementCellForRowAtIndexPath:indexPath];
#else
            if (indexPath.row == ACHIEVEMENT_INDEX_88_MPH+1 || indexPath.row == ACHIEVEMENT_INDEX_SPEED_DEMON+1) {
                if ([mData unlockedForIndex:indexPath])
                    cell = [self tableView:tableView speedboatCellForRowAtIndexPath:indexPath];
                else
                    cell = [self tableView:tableView headerCellForRowAtIndexPath:indexPath];
            } else {
                cell = [self tableView:tableView achievementCellForRowAtIndexPath:indexPath];
            }
#endif
        }
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [mData rowCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef CHEEKY_LITE_VERSION
    return mCellHeight;
#else
	return ((indexPath.row == ACHIEVEMENT_INDEX_88_MPH+1 || indexPath.row == ACHIEVEMENT_INDEX_SPEED_DEMON+1) && [mData unlockedForIndex:indexPath]) ? 2 * mCellHeight : mCellHeight;
#endif
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)onLaunchSpeedboatButtonPressed:(UIButton *)button {
    [mEventProxy dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SPEEDBOAT_LAUNCH_REQUESTED]];
}

- (void)dealloc {
	[mData release]; mData = nil;
    [mEventProxy release]; mEventProxy = nil;
	[super dealloc];
}

@end
