//
//  Shark.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "PathFollower.h"
#import "ResourceClient.h"

@class OverboardActor;

@interface Shark : Actor <PathFollower,ResourceClient> {
	BOOL mIsCollidable;
    double mTimeToKill;
    
	b2Fixture *mNose;
	b2Fixture *mHead;
	
	SPMovieClip *mSwimClip;
	SPMovieClip *mAttackClip;
	
	int mState;
	float mSpeed;
	
	Destination *mDestination;
	OverboardActor *mPrey;
	ResourceServer *mResources;
}

@property (nonatomic,assign) BOOL isCollidable;
@property (nonatomic,retain) Destination *destination;
@property (nonatomic,retain) OverboardActor *prey;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key;
- (float)navigate;
- (void)playEatVictimSound;
- (void)dock;

+ (float)swimFps;
+ (float)attackFps;

@end
