//
//  AchievementsDescription.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AchievementsDescription : NSObject {
	BOOL mCompleted;
    uint mAchievementIndex;
	double mPercentComplete;
	
	NSDictionary *mAchDef;
}

@property (nonatomic,readonly) BOOL isBinary;
@property (nonatomic,assign) BOOL completed;
@property (nonatomic,assign) uint achievementIndex;
@property (nonatomic,assign) double percentComplete;
@property (nonatomic,retain) NSDictionary *achievementDef;

@end
