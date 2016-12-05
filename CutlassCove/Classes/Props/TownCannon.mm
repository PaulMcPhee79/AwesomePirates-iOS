//
//  TownCannon.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TownCannon.h"
#import "CannonFactory.h"
#import "Cannonball.h"
#import "CannonFire.h"
#import "Globals.h"
#import <math.h>

const float kNozzleOffset = -15.0f;
const float kDefaultRange = 600.0f;
const float kDefaultAccuracy = 40.0f;
const float kRecoilTime = 0.1f;
const float kTurnIncrement = SP_D2R(3);


@interface TownCannon ()

- (void)recalculateAttributes;
- (void)playFireCannonSound;

@end


@implementation TownCannon

@synthesize shotType = mShotType;
@synthesize targetX = mTargetX;
@synthesize targetY = mTargetY;
@synthesize aiModifier = mAiModifier;
@synthesize range = mRange;
@synthesize accuracy = mAccuracy;
@synthesize shotQueue = mShotQueue;
@dynamic nozzle,rangeSquared;

- (id)initWithShotType:(NSString *)shotType {
	if (self = [super initWithCategory:-1]) {
		mShotType = [shotType copy];
		mAiModifier = 1.0f;
		mShotQueue = 0;
		[self recalculateAttributes];
	}
	return self;
}

- (id)init {
	return [self initWithShotType:@"single-shot_"];
}

- (void)recalculateAttributes {
	if (mAiModifier == 0.0f)
		mAiModifier = 1.0f;
	mRange = kDefaultRange * mAiModifier;
	mAccuracy = kDefaultAccuracy / mAiModifier;
}

- (float)accuracy {
	int randInt = RANDOM_INT(0,2);
	float accuracy = mAccuracy;
	
	if (randInt == 0)
		accuracy = mAccuracy;
	else if (randInt == 1)
		accuracy = -mAccuracy;
	return accuracy;
}

- (void)setAiModifier:(float)modifier {
	mAiModifier = modifier;
	[self recalculateAttributes];
}

- (SPPoint *)nozzle {
	SPPoint *pos = [SPPoint pointWithX:0 y:kNozzleOffset];
	[Globals rotatePoint:pos throughAngle:self.rotation];
	pos.x += self.x;
	pos.y += self.y;
	return pos;
}

- (float)rangeSquared {
	return mRange * mRange;
}

- (BOOL)aimAtX:(float)x y:(float)y {
	BOOL withinRange = NO;
	mTargetX = x;
	mTargetY = y;
	float aimAt = PI - atan2f(x-self.x, y-self.y);
	
	if (aimAt > SP_D2R(90) && aimAt < SP_D2R(180)) {
		self.rotation = aimAt;
		withinRange = YES;
	}
	return withinRange;
}

- (void)playFireCannonSound {
	[mScene.audioPlayer playSoundWithKey:@"TownCannon" volume:1.0f];
}

- (BOOL)fire:(b2Vec2)targetVel {
	[self playFireCannonSound];
	
	// Fire Cannonball
	//float accuracy = self.accuracy;
	float x = mTargetX, y = mTargetY; // MAX(15.0f, mTargetX + accuracy), y = MAX(15.0f, mTargetY + accuracy);
	Cannonball *cannonball = [[CannonFactory munitions] createCannonballForTownCannon:self bore:0.75f];
	[mScene addActor:cannonball];
	[cannonball calculateTrajectoryFromTargetX:x targetY:y];
    cannonball.body->SetLinearVelocity(cannonball.body->GetLinearVelocity() + targetVel);
	[cannonball setupCannonball];
	
	// Smoke
    if (RESM.isLowPerformance == NO) {
        CannonFire *smoke = (CannonFire *)[PointMovie pointMovieWithType:MovieTypeCannonFire x:cannonball.px y:cannonball.py];
        smoke.scaleX = smoke.scaleY = 1.25f;
        smoke.cannonRotation = self.rotation;
	
        SPPoint *smokeVel = [SPPoint pointWithX:0.0f y:-0.5f];
        [Globals rotatePoint:smokeVel throughAngle:smoke.cannonRotation];
        [smoke setLinearVelocityX:smokeVel.x y:smokeVel.y];
    }
	
	// Recoil
    /*
	SPTween *tween = [SPTween tweenWithTarget:self time:kRecoilTime];
	[tween animateProperty:@"x" targetValue:self.x-2*smokeVel.x];
	[tween animateProperty:@"y" targetValue:self.y-2*smokeVel.y];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:self time:kRecoilTime];
	[tween animateProperty:@"x" targetValue:self.x];
	[tween animateProperty:@"y" targetValue:self.y];
	tween.delay = tween.time;
	[mScene.juggler addObject:tween];
     */
    
	return YES;
}

- (void)idle {
	self.rotation = SP_D2R(135);
}

- (NSComparisonResult)shotQueueCompare:(TownCannon *)aCannon {
	NSComparisonResult result;

	if (mShotQueue < aCannon.shotQueue) // This should be in reverse as array is walked backwards
		result = NSOrderedDescending;
	else if (mShotQueue > aCannon.shotQueue)
		result = NSOrderedAscending;
	else
		result = NSOrderedSame;
	return result;
}

- (void)dealloc {
	[mShotType release]; mShotType = nil;
	[super dealloc];
}

@end
