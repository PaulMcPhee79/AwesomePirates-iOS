//
//  TempestActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Pursuer.h"
#import "ResourceClient.h"

@class ShipActor,RingBuffer;

@interface TempestActor : Actor <Pursuer,ResourceClient> {
	int mState;
	double mDuration;
	
	ShipActor *mTarget;
	SPSprite *mCostume;
	SPSprite *mClouds;
	SPSprite *mSwirl;
	SPSprite *mDebris;
	SPImage *mStem;
	SPMovieClip *mSplash;
	NSArray *mDebrisCache; // Convenience accessor
	RingBuffer *mDebrisBuffer;
    ResourceServer *mResources;
}

@property (nonatomic,retain) ShipActor *target;

+ (int)debrisBufferSize;
+ (TempestActor *)tempestActorAtX:(float)x y:(float)y rotation:(float)rotation duration:(float)duration;
- (id)initWithActorDef:(ActorDef *)def duration:(float)duration;
- (void)despawnOverTime:(float)duration;

@end
