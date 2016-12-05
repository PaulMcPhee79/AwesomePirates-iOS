//
//  BookletSubview.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "BookletSubview.h"

@interface BookletSubview ()

- (void)showPageNo:(BOOL)value;
- (void)playPageTurnSound;
- (void)logSwipe:(SPPoint *)point;
- (void)clearSwipeLog;
- (int)processSwipeDirection:(NSArray *)swipeLog threshold:(float)threshold;
- (void)onTouch:(SPTouchEvent *)event;

@end


@implementation BookletSubview

@synthesize loop = mLoop;
@synthesize bookKey = mBookKey;
@synthesize pageIndex = mPageIndex;
@synthesize numPages = mNumPages;
@synthesize pageTurns = mPageTurns;
@synthesize cover = mCover;
@synthesize currentPage = mCurrentPage;

+ (BookletSubview *)bookletSubviewWithCategory:(int)category key:(NSString *)key {
	return [[[BookletSubview alloc] initWithCategory:category key:key] autorelease];
}

- (id)initWithCategory:(int)category key:(NSString *)key {
	if (self = [super initWithCategory:category]) {
		self.touchable = YES;
		mLoop = YES;
		mBookKey = [key copy];
		mPageSwipeEnabled = NO;
		mPageTurns = 0;
		mPageIndex = 0;
		
		mCover = nil;
		mCurrentPage = nil;
		
		mSwipeTimestamp = 0;
		mSwipeLog = nil;
	}
	return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category key:@"BookKeyDefault"];
}

- (void)showPageNo:(BOOL)value {
	SPTextField *pageNo = [mCover.mutableLabels objectForKey:@"pageNo"];
	pageNo.visible = value;
	
	SPButton *button = [mCover.buttons objectForKey:@"prevPage"];
	button.visible = value;
	
	button = [mCover.buttons objectForKey:@"nextPage"];
	button.visible = value;
}

- (void)setNumPages:(uint)value {
	mNumPages = value;
	[self showPageNo:(mNumPages > 1)];
}

- (void)setCover:(TitleSubview *)view {
	if (mCover != nil) {
		if (mPageSwipeEnabled)
			[mCover removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
		[self removeChild:mCover];
		[mCover autorelease];
	}
	mCover = [view retain];
	view.touchable = YES;
	self.closeSelectorName = view.closeSelectorName;
	[self addChild:view atIndex:0];
	
	if (mPageSwipeEnabled)
		[self enablePageSwipe];
}

- (void)setCurrentPage:(MenuDetailView *)view {
    [view retain];
    
	if (mCurrentPage != nil) {
		[self removeChild:mCurrentPage];
		[mCurrentPage autorelease];
	}
	
	mCurrentPage = view;
	view.touchable = NO;
	[self addChild:view atIndex:MIN(self.numChildren,((mCover) ? 1 : 0))];
}

- (void)flip:(BOOL)enable {
    if (enable) {
        self.scaleX = -1;
        self.x = mScene.viewWidth;
    } else {
        self.scaleX = 1;
        self.x = 0;
    }
}

- (void)enablePageSwipe {
	if (mCover == nil)
		return;
	[mCover removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	mCover.touchable = YES;
	mCurrentPage.touchable = NO;
	
	for (int i = 0; i < mCover.numChildren; ++i) {
		SPDisplayObject *child = [mCover childAtIndex:i];
		child.touchable = YES;
	}
	
	[mCover addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	mPageSwipeEnabled = YES;
}

- (void)refreshPageNo {
	SPTextField *pageNo = [mCover.mutableLabels objectForKey:@"pageNo"];
	pageNo.text = [NSString stringWithFormat:@"%u/%u", mPageIndex + 1, mNumPages];
}

- (void)turnToPage:(uint)page {
	if (page < mNumPages) {
		mPageIndex = page;
		[self refreshPageNo];
		[self playPageTurnSound];
		[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED]];
	}
}

- (void)nextPage {
	uint index = mPageIndex + 1;
	
	if (mNumPages > 0 && ((index < mNumPages) || mLoop)) {
		++mPageTurns;
		[self turnToPage:index % mNumPages];
	}
}

- (void)prevPage {
	int index = mPageIndex - 1;
	
	if (index < 0 && mLoop)
		index += mNumPages;
	
	if (mNumPages > 0 && index >= 0) {
		--mPageTurns;
		[self turnToPage:(uint)index];
	}
}

- (void)playPageTurnSound {
	[mScene.audioPlayer playSoundWithKey:@"PageTurn"];
}

// Move this junk to a swipeHandler class
- (void)logSwipe:(SPPoint *)point {
	if (mSwipeLog == nil)
		mSwipeLog = [[NSMutableArray alloc] initWithCapacity:3];
	[mSwipeLog insertObject:point atIndex:0];
	
	if (mSwipeLog.count > 3)
		[mSwipeLog removeLastObject];
}

- (void)clearSwipeLog {
	[mSwipeLog removeAllObjects];
}

- (int)processSwipeDirection:(NSArray *)swipeLog threshold:(float)threshold {
	int dir = 0;
	float distX = 0, distY = 0;
	
	for (int i = 0; i < ((int)swipeLog.count-1); i++) {
		SPPoint *a = [swipeLog objectAtIndex:i];
		SPPoint *b = [swipeLog objectAtIndex:i+1];
		SPPoint *diff = [b subtractPoint:a];
		
		if ((dir == 0) || (dir == 1 && diff.x >= 0) || (dir == -1 && diff.x < 0))
			distX += diff.x;
		else
			distX = diff.x;
		dir = (distX >= 0) ? 1 : -1;
		distY += fabsf(diff.y);
	}
	
	if (fabsf(distX) < threshold || fabsf(distX) < (distY / 2))
		dir = 0;
	//NSLog(@"SWIPE DISTANCE: %f", distX);
	return dir;
}

- (void)onTouch:(SPTouchEvent *)event {
	if (mNumPages < 2)
		return;
    
    // Protect buttons from swipe
    SPTouch *touch = [[event touchesWithTarget:mCover andPhase:SPTouchPhaseBegan] anyObject];
    
    if (touch) {
        SPPoint *touchPoint = [touch locationInSpace:mCover];
        SPButton *prevButton = (SPButton *)[mCover controlForKey:@"prevPage"];
        SPButton *nextButton = (SPButton *)[mCover controlForKey:@"nextPage"];
        
        if ((prevButton && [[prevButton boundsInSpace:mCover] containsPoint:touchPoint])
            || (nextButton && [[nextButton boundsInSpace:mCover] containsPoint:touchPoint]))
            mPageSwipeIgnored = YES;
    }
    
    // Record swipe
	touch = [[event touchesWithTarget:mCover] anyObject];
	
    if (touch) {
        if (mSwipeLog == nil)
            mSwipeTimestamp = touch.timestamp;
        if (fabsf(touch.timestamp - mSwipeTimestamp) < 0.05f)
            [self logSwipe:[touch locationInSpace:mCover]];
        else
            [self clearSwipeLog];
        
        mSwipeTimestamp = touch.timestamp;
    }
	
	touch = [[event touchesWithTarget:mCover andPhase:SPTouchPhaseEnded] anyObject];
	
    // Process swipe
	if (touch) {
        if (mPageSwipeIgnored) {
            mPageSwipeIgnored = NO;
            return;
        }
        
		int dir = [self processSwipeDirection:mSwipeLog threshold:3];
		
		if (dir == 1)
			[self nextPage];
		else if (dir == -1)
			[self prevPage];
		[self clearSwipeLog];
	}
    
    touch = [[event touchesWithTarget:mCover andPhase:SPTouchPhaseCancelled] anyObject];
    
    if (touch)
        mPageSwipeIgnored = NO;
}

- (void)dealloc {
	[mCover removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[mCover release]; mCover = nil;
	[mCurrentPage release]; mCurrentPage = nil;
	[mSwipeLog release]; mSwipeLog = nil;
	[mBookKey release]; mBookKey = nil;
	[super dealloc];
}

@end
