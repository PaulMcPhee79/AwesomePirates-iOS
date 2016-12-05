//
//  TownAi.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TownAi.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "CannonFactory.h"
#import "Cannonball.h"
#import "TownCannon.h"
#import "TargetTracer.h"
#import "NumericValueChangedEvent.h"
#import "PlayfieldController.h"
#import "GameCoder.h"
#import "Globals.h"

const double kTownAiThinkInterval = 0.2;
const double kTownShotInterval = 20.0;

@interface TownAi ()

- (void)think:(double)time;
- (void)thinkCannons;

@end


@implementation TownAi

@synthesize aiModifier = mAiModifier;
@synthesize timeSinceLastShot = mTimeSinceLastShot;

- (id)initWithController:(PlayfieldController *)scene {
	if (self = [super init]) {
		mScene = scene;
        mSuspendedMode = NO;
		//mName = [NSStringFromClass([self class]) copy];
		mAiModifier = 1.0f;
		mTimeSinceLastShot = kTownShotInterval;
		mShotQueue = 0;
		mCannons = [[NSMutableArray alloc] init];
		mTargets = [[NSMutableArray alloc] init];
		mTracers = [[NSMutableArray alloc] init];
        
        mThinkTimer = kTownAiThinkInterval;
        mThinking = NO;
	}
	return self;
}

- (void)setAiModifier:(float)modifier {
	mAiModifier = modifier;
	
	for (TownCannon *cannon in mCannons)
		cannon.aiModifier = modifier;
}

- (void)onAiModifierChanged:(NumericValueChangedEvent *)event {
	self.aiModifier = [event.value floatValue];
}

- (void)addCannon:(TownCannon *)cannon {
	if ([mCannons containsObject:cannon] == NO) {
		[mCannons addObject:cannon];
		cannon.aiModifier = mAiModifier;
	}
}

- (void)addTarget:(ShipActor *)target {
	if ([mTargets containsObject:target] == NO) {
		[mTargets addObject:target];
		TargetTracer *tracer = [[TargetTracer alloc] init];
		tracer.target = target;
		[mTracers addObject:tracer];
		[tracer release];
	}
}

- (void)removeTarget:(ShipActor *)target {
	NSUInteger index = [mTargets indexOfObject:target];
	
	if (index != NSNotFound) {
		assert(index < mTracers.count);
		[mTargets removeObject:target];
		[mTracers removeObjectAtIndex:index];
	}
}

- (void)enableSuspendedMode:(BOOL)enable {
    [self stopThinking];
    
    if (enable == NO)
        [self think];
    mSuspendedMode = enable;
}

- (void)think {
	mThinking = YES;
}

- (void)think:(double)time {
    if (mThinking == NO)
        return;
    
    mThinkTimer -= time;
    
    if (mThinkTimer <= 0) {
        mThinkTimer = kTownAiThinkInterval;
        [self thinkCannons];
    
        if (mTimeSinceLastShot >= kTownAiThinkInterval)
            mTimeSinceLastShot -= kTownAiThinkInterval;
    }
}

- (void)stopThinking {
	mThinking = NO;
}

- (void)prepareForNewGame {
    mTimeSinceLastShot = kTownShotInterval;
    [self think];
}

- (void)prepareForGameOver {
    [mTargets removeAllObjects];
    [mTracers removeAllObjects];
    [self stopThinking];
}

- (void)thinkCannons {
	BOOL done = (mTimeSinceLastShot > kTownAiThinkInterval);
	float x,y,dist;
	NSMutableArray *cannons = [[NSMutableArray alloc] initWithArray:mCannons];
	[cannons sortUsingSelector:@selector(shotQueueCompare:)];
	
	int shipIndex = 0;
	
	for (int i = mTargets.count - 1; i >= 0; --i) {
		ShipActor *ship = (ShipActor *)[mTargets objectAtIndex:i];
		if ([ship isKindOfClass:[PlayerShip class]]) {
			PlayerShip *playerShip = (PlayerShip *)ship;
			
			if (playerShip.isCamouflaged)
				continue;
		}
		
		if (cannons.count == 0 || done == YES)
			break;
		if ([ship isKindOfClass:[PlayerShip class]]) {
			PlayerShip *playerShip = (PlayerShip *)ship;
			
			if (playerShip.isCamouflaged)
				continue;
		}
		
		for (int j = cannons.count - 1; j >= 0; --j) {
			TownCannon *cannon = (TownCannon *)[cannons objectAtIndex:j];
	
			x = ship.px - cannon.x;
			y = ship.py - cannon.y;
			dist = [Globals vecLengthSquaredX:x y:y];
			
			if (dist < cannon.rangeSquared) {
				if ([cannon aimAtX:ship.px y:ship.py]) {
					if (shipIndex < mTracers.count) { // Could be false if removeTarget occurred between loop start and here
						TargetTracer *tracer = [mTracers objectAtIndex:shipIndex];

						if ([cannon fire:tracer.targetVel]) {
							cannon.shotQueue = ++mShotQueue;
							mTimeSinceLastShot = kTownShotInterval;
						}
					}
					[cannons removeObjectAtIndex:j];
					done = YES;
					break;
				}
			}
		}
		++shipIndex;
	}
	
	for (TownCannon *cannon in cannons)
		[cannon idle];
	
	[cannons release];
}

- (void)advanceTime:(double)time {
	for (TargetTracer *tracer in mTracers)
		[tracer advanceTime:time];
    [self think:time];
}

- (void)loadGameState:(GameCoder *)coder {
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	GCTownAi *gcTownAi = misc.townAi;
	mTimeSinceLastShot = gcTownAi.timeSinceLastShot;
	
	if (mCannons.count > 0) {
		// Doesn't matter from which cannon it was shot, just give it a valid owner.
		TownCannon *townCannon = (TownCannon *)[mCannons objectAtIndex:0];
		CannonballInfamyBonus *infamyBonus = [CannonballInfamyBonus cannonballInfamyBonus];
		
		for (GCCannonball *gcCannonball in gcTownAi.cannonballs) {
			Cannonball *cannonball = [[CannonFactory munitions] createCannonballForShooter:townCannon shotType:gcCannonball.shotType
																					  bore:1
																			 ricochetCount:0
																			   infamyBonus:infamyBonus
																					   loc:b2Vec2(gcCannonball.x,gcCannonball.y)
																					   vel:b2Vec2(gcCannonball.velX, gcCannonball.velY)
																				trajectory:gcCannonball.trajectory
																			 distRemaining:gcCannonball.distanceRemaining];
			[mScene addActor:cannonball];
			[cannonball setupCannonball];
		}
	}
}

- (void)saveGameState:(GameCoder *)coder {
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	GCTownAi *gcTownAi = [[GCTownAi alloc] init];
	gcTownAi.timeSinceLastShot = mTimeSinceLastShot;
	
	NSMutableArray *cannonballs = [mScene liveCannonballs];
	
	for (Cannonball *cannonball in cannonballs) {
		for (TownCannon *townCannon in mCannons) {
			if (cannonball.shooter == townCannon) {
				GCCannonball *gcCannonball = [[GCCannonball alloc] init];
				gcCannonball.shotType = townCannon.shotType;
				
				b2Vec2 loc = cannonball.body->GetPosition();
				gcCannonball.x = loc.x;
				gcCannonball.y = loc.y;
				
				b2Vec2 vel = cannonball.body->GetLinearVelocity();
				gcCannonball.velX = vel.x;
				gcCannonball.velY = vel.y;
				
				gcCannonball.trajectory = cannonball.trajectory;
				gcCannonball.distanceRemaining = cannonball.distanceRemaining;
				
				[gcTownAi addCannonball:gcCannonball];
				[gcCannonball release];
				break;
			}
		}
	}
	
	misc.townAi = gcTownAi;
	[gcTownAi release];
}

- (void)dealloc {
	//[mName release];
	[mCannons release]; mCannons = nil;
	[mTargets release]; mTargets = nil;
	[mTracers release]; mTracers = nil;
	mScene = nil;
	[super dealloc];
}

@end
