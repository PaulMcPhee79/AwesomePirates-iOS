//
//  AchievementEarnedEvent.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 14/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "AchievementEarnedEvent.h"


@implementation AchievementEarnedEvent

@synthesize bit = mAchievementBit;
@synthesize index = mAchievementIndex;

+ (AchievementEarnedEvent *)achievementEarnedEventWithBit:(uint)achBit index:(uint)index bubbles:(BOOL)bubbles {
	return [[[AchievementEarnedEvent alloc] initWithBit:achBit index:index bubbles:NO] autorelease];
}

- (id)initWithBit:(uint)bit index:(uint)index bubbles:(BOOL)bubbles {
	if (self = [super initWithType:CUST_EVENT_TYPE_ACHIEVEMENT_EARNED]) {
		mAchievementBit = bit;
		mAchievementIndex = index;
	}
	return self;
}

@end
