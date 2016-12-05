//
//  AchievementEarnedEvent.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 14/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_ACHIEVEMENT_EARNED @"achievementEarnedEvent"

@interface AchievementEarnedEvent : SPEvent {
	uint mAchievementBit;
	uint mAchievementIndex;
}

@property (nonatomic,readonly) uint bit;
@property (nonatomic,readonly) uint index;

+ (AchievementEarnedEvent *)achievementEarnedEventWithBit:(uint)achBit index:(uint)index bubbles:(BOOL)bubbles;
- (id)initWithBit:(uint)bit index:(uint)index bubbles:(BOOL)bubbles;

@end
