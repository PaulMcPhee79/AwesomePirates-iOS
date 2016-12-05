//
//  Destination.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

@interface Destination : NSObject {
	BOOL mIsExclusive;		// YES: Prevents checking in of sea lanes that we don't own.
	BOOL mFinishIsDest;
	int mSpawnPlaneIndex;	// Superfluous - same as mStart. TODO: remove and let accessor point to mStart?
	b2Vec2 mLoc;
	b2Vec2 mDest;

	SPPoint *mSeaLaneA;	// Weak reference
	SPPoint *mSeaLaneB;	// Weak reference
	SPPoint *mSeaLaneC; // Weak reference
	SPPoint *mAdjustedSeaLaneC;
	int mStart;			// Index into mVacantSpawnPlanes/mOccupiedSpawnPlanes in ActorAi
	int mFinish;		// Index into mVacantSpawnPlanes/mOccupiedSpawnPlanes in ActorAi
}

@property (nonatomic,assign) BOOL isExclusive;
@property (nonatomic,assign) BOOL finishIsDest;
@property (nonatomic,assign) int spawnPlaneIndex;
@property (nonatomic,assign) b2Vec2 loc; // Cached location of departure
@property (nonatomic,assign) b2Vec2 dest; // Current destination
@property (nonatomic,assign) SPPoint *seaLaneA;	// Point of departure
@property (nonatomic,assign) SPPoint *seaLaneB;	// Point of final destination
@property (nonatomic,assign) SPPoint *seaLaneC;	// Midpoint: typically the town exit/entry point
@property (nonatomic,retain) SPPoint *adjustedSeaLaneC; // When we want a pointer to seaLaneC, but we want its location adjusted (eg Escort Ships)
@property (nonatomic,assign) int start;
@property (nonatomic,assign) int finish;

- (void)setFinishAsDest; // Head for seaLaneB: the final destination
- (void)setDestX:(float)x;
- (void)setDestY:(float)y;
- (void)setLocX:(float)x;
- (void)setLocY:(float)y;
+ (Destination *)destinationWithDestination:(Destination *)destination;

@end
