//
//  AchievementPanel.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_ACHIEVEMENT_HIDDEN @"achievementHiddenEvent"

#define ACHIEVEMENT_TIER_SWABBY 0
#define ACHIEVEMENT_TIER_PIRATE 1
#define ACHIEVEMENT_TIER_CAPTAIN 2

@interface AchievementPanel : Prop {
	BOOL mHiding;
	uint mTier;
	double mDuration;
    double mHideTimer;
	float mOriginY;
	SPSprite *mIcon;
    SPSprite *mContainer;
    SPSprite *mFlipCanvas;
	SPTextField *mTitle;
	SPTextField *mText;
}

@property (nonatomic,readonly) BOOL busy;
@property (nonatomic,assign) uint tier;
@property (nonatomic,assign) double duration;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *text;

- (void)display;

@end
