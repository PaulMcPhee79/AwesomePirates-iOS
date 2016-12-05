//
//  ChallengeViewController.m
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChallengeViewController.h"
#import "MultiPurposeEvent.h"
#import "CCOFChallengeManager.h"

const NSInteger BUTTON_CELL_TAG_FLOOR = 2000;

@interface ChallengeViewController ()

- (void)onCreateButtonPressed:(UIButton *)button;

@end


@implementation ChallengeViewController

@synthesize eventProxy = mEventProxy;

- (id)initWithEventProxy:(SPEventDispatcher *)eventProxy {
	if (self = [super init]) {
        mCellHeight *= 1.5f;
        mEventProxy = [eventProxy retain];
        mLockBitmap = 0;
        mData = [[NSArray alloc] initWithObjects:
                 // Only Blue Crosses
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeOnlyBlueCrosses], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeOnlyBlueCrosses], @"DescKey",
                  @"cc-of-challenge-only-blue-crosses", @"IconKey",
                  nil],
                 
                 // Only Ricochets
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeOnlyRicochets], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeOnlyRicochets], @"DescKey",
                  @"cc-of-challenge-only-ricochets", @"IconKey",
                  nil],
                 
                 // No Ricochets
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoRicochets], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoRicochets], @"DescKey",
                  @"cc-of-challenge-no-ricochets", @"IconKey",
                  nil],
                 
                 // No Misses
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoMisses], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoMisses], @"DescKey",
                  @"cc-of-challenge-no-misses", @"IconKey",
                  nil],
                 
                 // No Hits Taken
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoHitsTaken], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoHitsTaken], @"DescKey",
                  @"cc-of-challenge-no-hits-taken", @"IconKey",
                  nil],
                 
                 // No Voodoo Spells or Munitions
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoVoodooSpellsOrMunitions], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoVoodooSpellsOrMunitions], @"DescKey",
                  @"cc-of-challenge-no-spells-munitions", @"IconKey",
                  nil],
                 
                 // No Navy Ships Sunk
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoNavyShipsSunk], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoNavyShipsSunk], @"DescKey",
                  @"cc-of-challenge-no-navy", @"IconKey",
                  nil],
                 
                 // No Rival Pirate Ships Sunk
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeNoPirateShipsSunk], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeNoPirateShipsSunk], @"DescKey",
                  @"cc-of-challenge-no-pirates", @"IconKey",
                 nil],
#ifndef CHEEKY_LITE_VERSION                 
                 // Fastest
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [CCOFChallengeManager challengeTitleForType:CCOFChallengeAverageSpeed], @"TitleKey",
                  [CCOFChallengeManager createChallengeTextForChallengeType:CCOFChallengeAverageSpeed], @"DescKey",
                  @"cc-of-challenge-avg-speed", @"IconKey",
                  @"Unlock by completing the secret achievement.", @"LockDescKey",
                  @"locked-icon", @"LockIconKey",
                  nil],
#endif                 
                 nil];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    self.view.center = CGPointMake(RUISCALE(240 + offset.x), RUISCALE(167.5f + offset.y));
    
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (void)enableLock:(BOOL)enable atIndex:(NSInteger)index {
    if (index < 0 || index > 31)
        return;
    
    if (enable)
        mLockBitmap |= (1<<index);
    else
        mLockBitmap &=~ (1<<index);
    
    // Refresh cell
    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger TITLE_LABEL_TAG = 1001;
	const NSInteger DESC_LABEL_TAG = 1002;
	const NSInteger DIVIDER_IMAGE_TAG = 1003;

    UILabel *titleLabel = nil;
	UILabel *descLabel = nil;
    UIButton *createButton = nil;
	UIImageView *dividerView = nil;
	UIImageView *backgroundView = nil;
	NSString *cellIdentifier = [NSString stringWithFormat:@"CellId%d", indexPath.row]; // Unique rows
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	CGRect tvRect = self.tableView.frame;
    
    [self flashTableViewScrollIndicators];
    
    if (indexPath.row < 0 || indexPath.row >= mData.count)
        return cell;
	
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
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.1f * tvRect.size.width,
																4,
																0.8f * tvRect.size.width,
																RUISCALE(22.0f))] autorelease];
		titleLabel.numberOfLines = 1;
		titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(18.0f)];
		titleLabel.tag = TITLE_LABEL_TAG;
		titleLabel.textAlignment = NSTextAlignmentCenter; // UITextAlignmentCenter;
		titleLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:titleLabel];
		
		// Description
		descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.2f * tvRect.size.width,
															   titleLabel.frame.origin.y + titleLabel.frame.size.height + 6,
															   0.6f * tvRect.size.width,
															   3 * RUISCALE(17.0f))] autorelease];
		descLabel.lineBreakMode = NSLineBreakByWordWrapping; // UILineBreakModeWordWrap;
		descLabel.numberOfLines = 0;
		descLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:RUISCALE(14.0f)];
		descLabel.tag = DESC_LABEL_TAG;
		descLabel.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter;
		descLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:descLabel];
        
        // Create Button
		CGSize createSize = CGSizeMake(56, 24);
		createButton = [UIButton buttonWithType:UIButtonTypeCustom];
		createButton.tag = BUTTON_CELL_TAG_FLOOR + (int)indexPath.row;
		createButton.frame = CGRectMake(tvRect.size.width - RUISCALE(createSize.width + 4),
                                        mCellHeight - RUISCALE(createSize.height + 4),
                                        RUISCALE(createSize.width),
                                        RUISCALE(createSize.height));
		createButton.backgroundColor = [UIColor clearColor];
		UIImage *buttonImage = [UIImage imageNamed:EXPUIIMG(@"create-button")];
		[createButton setImage:buttonImage forState:UIControlStateNormal];
		[createButton setImage:[UIImage imageNamed:EXPUIIMG(@"create-button-highlighted")] forState:UIControlStateHighlighted];
		[createButton addTarget:self action:@selector(onCreateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:createButton];
	}  else {
        titleLabel = (UILabel *)[cell viewWithTag:TITLE_LABEL_TAG];
		descLabel = (UILabel *)[cell viewWithTag:DESC_LABEL_TAG];
		dividerView = (UIImageView *)[cell viewWithTag:DIVIDER_IMAGE_TAG];
        createButton = (UIButton *)[cell viewWithTag:BUTTON_CELL_TAG_FLOOR + indexPath.row];
		backgroundView = (UIImageView *)cell.backgroundView;
	}
    
    // Data Cell
    NSDictionary *dataDict = (NSDictionary *)[mData objectAtIndex:indexPath.row];
    
	// Complete Icon
    NSString *iconKey = (mLockBitmap & (1<<indexPath.row)) ? (NSString *)[dataDict objectForKey:@"LockIconKey"] : (NSString *)[dataDict objectForKey:@"IconKey"];
	UIImage *icon = [UIImage imageNamed:EXPUIIMG(iconKey)];
	cell.imageView.image = icon;
	
    NSString *bgImageName = (indexPath.row & 1) ? @"tableview-cell-dark" : @"tableview-cell-light";
    
	// Background
	if (backgroundView == nil) {
		backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:EXPUIIMG(bgImageName)]] autorelease];
		cell.backgroundView = backgroundView;
	} else {
		backgroundView.image = [UIImage imageNamed:EXPUIIMG(bgImageName)];
	}
	
    dividerView.hidden = (indexPath.row == 0);
    
    if (mLockBitmap & (1<<indexPath.row)) {
        createButton.hidden = YES;
        titleLabel.hidden = YES;
        descLabel.text = (NSString *)[dataDict objectForKey:@"LockDescKey"];
    } else {
        createButton.hidden = NO;
        titleLabel.hidden = NO;
        titleLabel.text = (NSString *)[dataDict objectForKey:@"TitleKey"];
        descLabel.text = (NSString *)[dataDict objectForKey:@"DescKey"];
    }
	
	// Description frame
	CGSize maximumSize = CGSizeMake(0.6f * tvRect.size.width, 3 * RUISCALE(17.0f));
	CGSize descSize = [descLabel.text sizeWithFont:descLabel.font constrainedToSize:maximumSize lineBreakMode:descLabel.lineBreakMode];
	CGRect descFrame = CGRectMake(0.2f * tvRect.size.width,
                                  titleLabel.frame.origin.y + titleLabel.frame.size.height + 6,
                                  0.6f * tvRect.size.width,
                                  MAX(2 * RUISCALE(17.0f), descSize.height));
	descLabel.frame = descFrame;
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (NSInteger)mData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return mCellHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)onCreateButtonPressed:(UIButton *)button {
	NSInteger row = (NSInteger)button.tag - BUTTON_CELL_TAG_FLOOR;
    MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_CREATE_REQUEST bubbles:NO];
    [event.data setObject:[NSNumber numberWithInt:row] forKey:CUST_EVENT_TYPE_OF_CHALLENGE_CREATE_REQUEST];
    [mEventProxy dispatchEvent:event];
}

- (void)dealloc {
    [mData release]; mData = nil;
    [mEventProxy release]; mEventProxy = nil;
	[super dealloc];
}

@end
