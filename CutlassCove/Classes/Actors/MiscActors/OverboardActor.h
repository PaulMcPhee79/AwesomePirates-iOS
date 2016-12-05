//
//  OverboardActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 17/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "PathFollower.h"
#import "ResourceClient.h"
#import "Prisoner.h"


@class Shark;

@interface OverboardActor : Actor <PathFollower,ResourceClient> {
	BOOL mIsCollidable;
    BOOL mHasRepellent;
    BOOL mIsPlayer;
	int mState;
    uint mDeathBitmap;
	
	Prisoner *mPrisoner;
	
	SPMovieClip *mPersonClip;
	SPSprite *mBlood;
	
	Destination *mDestination;
	Shark *mPredator;
	ResourceServer *mResources;
}

@property (nonatomic,assign) BOOL isCollidable;
@property (nonatomic,readonly) BOOL edible;
@property (nonatomic,assign) BOOL hasRepellent;
@property (nonatomic,assign) BOOL isPlayer;
@property (nonatomic,readonly) BOOL dying;
@property (nonatomic,retain) Prisoner *prisoner;
@property (nonatomic,readonly) int gender;
@property (nonatomic,readonly) int infamyBonus;
@property (nonatomic,assign) uint deathBitmap;
@property (nonatomic,retain) Destination *destination;
@property (nonatomic,retain) Shark *predator;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key;
- (void)getEatenByShark;
- (void)environmentalDeath;
- (void)playEatenAliveSound;
- (void)dock;
- (void)dropLoot;
+ (float)fps;

@end
