//
//  TownCannon.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

class b2Vec2;

@interface TownCannon : Prop {
	float mTargetX;
	float mTargetY;
	float mRange;
	float mAccuracy;
	float mAiModifier;
	uint mShotQueue;
	NSString *mShotType;
}

@property (nonatomic,readonly) NSString *shotType;
@property (nonatomic,readonly) float targetX;
@property (nonatomic,readonly) float targetY;
@property (nonatomic,readonly) SPPoint *nozzle;
@property (nonatomic,readonly) float range;
@property (nonatomic,readonly) float rangeSquared;
@property (nonatomic,readonly) float accuracy;
@property (nonatomic,assign) float aiModifier;
@property (nonatomic,assign) uint shotQueue;

- (id)initWithShotType:(NSString *)shotType;
- (BOOL)aimAtX:(float)x y:(float)y;
- (BOOL)fire:(b2Vec2)targetVel;
- (void)idle;
- (NSComparisonResult)shotQueueCompare:(TownCannon *)aCannon;

@end
