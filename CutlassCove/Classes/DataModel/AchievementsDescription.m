//
//  AchievementsDescription.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "AchievementsDescription.h"


@implementation AchievementsDescription

@synthesize completed = mCompleted;
@synthesize achievementIndex = mAchievementIndex;
@synthesize percentComplete = mPercentComplete;
@synthesize achievementDef = mAchDef;
@dynamic isBinary;

- (void)dealloc {
	[mAchDef release];
	[super dealloc];
}

- (BOOL)isBinary {
    BOOL result = YES;
    
    if (mAchDef) {
        NSNumber *number = (NSNumber *)[mAchDef objectForKey:@"binary"];
        
        if (number)
            result = [number boolValue];
    }
    
    return result;
}

@end
