//
//  GCAchievementManager.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCAchievementManager : NSObject <NSCoding> {
	uint consecutiveCannonballsHit;
	uint friendlyFires;
	uint kabooms;
    uint slimerCount;
	int comboMultiplierMax;
	int comboMultiplier;
	uint comboBonusCharges;
	
	NSArray *displayQueue;
}

@property (nonatomic,assign) uint consecutiveCannonballsHit;
@property (nonatomic,assign) uint friendlyFires;
@property (nonatomic,assign) uint kabooms;
@property (nonatomic,assign) uint slimerCount;
@property (nonatomic,assign) int comboMultiplierMax;
@property (nonatomic,assign) int comboMultiplier;
@property (nonatomic,assign) uint comboBonusCharges;
@property (nonatomic,copy) NSArray *displayQueue;

+ (GCAchievementManager *)gcAchievementManager;

@end
