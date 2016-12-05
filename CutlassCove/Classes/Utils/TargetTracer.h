//
//  TargetTracer.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

@class ShipActor;

const int kTargetVelBufferSize = 30;

@interface TargetTracer : NSObject {
	int mTargetVelocityIter;
	b2Vec2 mTargetVelocity[kTargetVelBufferSize];
	ShipActor *mTarget;
}

@property (nonatomic,retain) ShipActor *target;
@property (nonatomic,readonly) b2Vec2 targetVel;

- (void)advanceTime:(double)time;

@end
