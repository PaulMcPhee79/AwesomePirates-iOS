//
//  SceneView.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SceneView.h"
#import "GameController.h"

@implementation SceneView

@synthesize hud = mHud;
@synthesize achievementPanel = mAchievementPanel;

- (id)init {
	if (self = [super init]) {
		//mName = [NSStringFromClass([self class]) copy];
		mHud = nil;
		mAchievementPanel = nil;
	}
	return self;
}

- (void)setupView { }

- (void)loadViewState:(GameCoder *)coder { }
- (void)saveViewState:(GameCoder *)coder { }

- (void)attachEventListeners { }

- (void)detachEventListeners { }

- (void)moveAchievementPanelToCategory:(int)category {
    [mAchievementPanel moveToCategory:category];
}

- (void)flip:(BOOL)enable { }

- (void)advanceTime:(double)time {
	[GCTRL.achievementManager advanceTime:time];
}

- (void)dealloc {
	//[mName release];
	[mAchievementPanel release]; mAchievementPanel = nil;
	[mHud release]; mHud = nil;
	[super dealloc];
}

@end

