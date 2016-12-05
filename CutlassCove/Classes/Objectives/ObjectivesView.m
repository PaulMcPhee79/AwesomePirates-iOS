//
//  ObjectivesView.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesView.h"
#import "ObjectivesCurrentPanel.h"
#import "ObjectivesCompletedPanel.h"
#import "ObjectivesRankupPanel.h"
#import "ObjectivesRank.h"
#import "Globals.h"

@interface ObjectivesView ()

- (void)pumpCompletedQueue;
- (void)pumpNoticeQueue;
- (void)purgeCompletedQueue;
- (void)purgeNoticesQueue;
- (void)onCurrentPanelDismissed:(SPEvent *)event;
- (void)onRankupPanelDismissed:(SPEvent *)event;

@end


@implementation ObjectivesView

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mAdvanceable = YES;
        mTouchBarrierEnabled = NO;
        mRankupPanel = nil;
        mCompletedQueue = [[NSMutableArray alloc] init];
        mNoticeQueue = [[NSMutableArray alloc] init];
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mCompletedPanel];
    [mScene.juggler removeTweensWithTarget:mCurrentPanel];
    [mScene.juggler removeTweensWithTarget:mRankupPanel];
    [mScene removeProp:mCompletedPanel];
    [mScene removeProp:mCurrentPanel];
    [mScene removeProp:mNoticesPanel];
    
    [mCurrentPanel removeEventListener:@selector(onCurrentPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_CONTINUED];
    [mRankupPanel removeEventListener:@selector(onRankupPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_CONTINUED];
    
    [mCompletedPanel release]; mCompletedPanel = nil;
    [mCurrentPanel release]; mCurrentPanel = nil;
    [mRankupPanel release]; mRankupPanel = nil;
    [mNoticesPanel release]; mNoticesPanel = nil;
    [mCompletedQueue release]; mCompletedQueue = nil;
    [mNoticeQueue release]; mNoticeQueue = nil;
    [super dealloc];
}

- (void)setupProp {
[RESM pushItemOffsetWithAlignment:RACenter];
    // Objectives Completed Panel
    mCompletedPanel = [[ObjectivesCompletedPanel alloc] initWithCategory:[mScene objectivesCategoryForViewType:ObjViewTypeCompleted]];
    mCompletedPanel.rx = 0;
    [mScene addProp:mCompletedPanel];
    
    // Objectives Current Panel
    mCurrentPanel = [[ObjectivesCurrentPanel alloc] initWithCategory:[mScene objectivesCategoryForViewType:ObjViewTypeCurrent]];
    mCurrentPanel.rx = 0; mCurrentPanel.ry = 0;
    mCurrentPanel.visible = NO;
    [mCurrentPanel addEventListener:@selector(onCurrentPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_CONTINUED];
    [mScene addProp:mCurrentPanel];
    
    // Notices Panel
    mNoticesPanel = [[ObjectivesCompletedPanel alloc] initWithCategory:[mScene objectivesCategoryForViewType:ObjViewTypeNotices]];
    mNoticesPanel.rx = 0;
    mNoticesPanel.showTargetY = 0;
    mNoticesPanel.isSilent = YES;
    [mNoticesPanel shrinkToSingleLine];
    [mScene addProp:mNoticesPanel];
[RESM popOffset];
}

- (void)enableTouchBarrier:(BOOL)enable {
    mTouchBarrierEnabled = enable;
}

- (void)flip:(BOOL)enable {
    [mCompletedPanel flip:enable];
    [mNoticesPanel flip:enable];
}

- (SPSprite *)maxRankSprite {
    return [mCurrentPanel maxRankSprite];
}

- (void)prepareForNewGame {
    [self purgeCompletedQueue];
    [self hideCurrentPanel];
    [self hideRankupPanel];
    [self purgeNoticesQueue];
}

- (void)beginChallenge {
    [mCurrentPanel setState:ObjCurrentStateChallenge];
}

- (void)finishChallenge {
    [mCurrentPanel setState:ObjCurrentStateObjectives];
}

// Current Panel
- (void)populateWithObjectivesRank:(ObjectivesRank *)objRank {
    [mCurrentPanel populateWithObjectivesRank:objRank];
}

- (void)showCurrentPanel {
    mCurrentPanel.visible = YES;
}

- (void)hideCurrentPanel {
    mCurrentPanel.visible = NO;
}

- (void)enableCurrentPanelButtons:(BOOL)enable {
    [mCurrentPanel enableButtons:enable];
}

- (void)onCurrentPanelDismissed:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_DISMISSED]];
}

// Completed Panel
- (void)fillCompletedCacheWithRank:(ObjectivesRank *)objRank {
    [mCompletedPanel fillCacheWithRank:objRank];
}

- (void)enqueueCompletedObjectivesDescription:(ObjectivesDescription *)objDesc {
    if (objDesc)
        [mCompletedQueue addObject:objDesc];
}

- (void)purgeCompletedQueue {
    [mCompletedQueue removeAllObjects];
    [mCompletedPanel hide];
}

- (void)purgeNoticesQueue {
    [mNoticeQueue removeAllObjects];
    [mNoticesPanel hide];
}

- (void)pumpCompletedQueue {
    if (mCompletedQueue.count > 0 && mCompletedPanel.isBusy == NO && mNoticesPanel.isBusy == NO) {
        ObjectivesDescription *objDesc = [[(ObjectivesDescription *)[mCompletedQueue objectAtIndex:0] retain] autorelease];
        [mCompletedPanel setText:objDesc.description];
        [mCompletedPanel displayForDuration:5.0f];
        [mCompletedQueue removeObjectAtIndex:0];
    }
}

// Rankup Panel
- (void)showRankupPanelWithRank:(uint)rank {
    [self hideRankupPanel];
    
[RESM pushItemOffsetWithAlignment:RACenter];
    mRankupPanel = [[ObjectivesRankupPanel alloc] initWithCategory:self.category rank:rank];
    mRankupPanel.rx = 0; mRankupPanel.ry = 0;
    [mRankupPanel addEventListener:@selector(onRankupPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_CONTINUED];
    [mRankupPanel enableTouchBarrier:mTouchBarrierEnabled];
    [self addChild:mRankupPanel];
[RESM popOffset];
}

- (void)hideRankupPanel {
    if (mRankupPanel) {
        [mRankupPanel removeEventListener:@selector(onRankupPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_CONTINUED];
        [self removeChild:mRankupPanel];
        [mRankupPanel autorelease];
        mRankupPanel = nil;
    }
}

- (void)onRankupPanelDismissed:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_DISMISSED]];
}

// Misc messages
- (void)enqueueNotice:(NSString *)msg {
    if (msg)
        [mNoticeQueue addObject:msg];
}

- (void)hideNoticesPanel {
    [self purgeNoticesQueue];
}

- (void)pumpNoticeQueue {
    if (mNoticeQueue.count > 0 && mNoticesPanel.isBusy == NO && mCompletedQueue.count == 0 && mCompletedPanel.isBusy == NO) {
        NSString *msg = [[(NSString *)[mNoticeQueue objectAtIndex:0] retain] autorelease];
        [mNoticesPanel setText:msg];
        [mNoticesPanel displayForDuration:10.0f];
        [mNoticeQueue removeObjectAtIndex:0];
    }
}

- (void)advanceTime:(double)time {
    [self pumpCompletedQueue];
    [self pumpNoticeQueue];
}

@end
