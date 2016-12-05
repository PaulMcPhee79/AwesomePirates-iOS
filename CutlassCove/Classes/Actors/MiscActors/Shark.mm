//
//  Shark.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Shark.h"
#import "SharkCache.h"
#import "ActorFactory.h"
#import "OverboardActor.h"
#import "SharkWater.h"
#import "DeathBitmaps.h"
#import "ActorAi.h"
#import "Globals.h"
#import "Box2DUtils.h"

const int kStateNull = 0x0;
const int kStateSwimming = 0x1;
const int kStatePursuing = 0x2;
const int kStateAttacking = 0x3;

const float kSharkSwimSpeed = 20.0f;

@interface Shark ()

- (void)setupActorCostume;
- (void)setSharkState:(int)state;
- (float)navigate;
- (void)attackCompleted;
- (void)onAttackMovieComplete:(SPEvent *)event;
- (void)swimWithForce:(float32)force;
- (void)turnWithForce:(float32)force;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end

@implementation Shark

@synthesize isCollidable = mIsCollidable;
@synthesize destination = mDestination;
@synthesize prey = mPrey;

+ (float)swimFps {
	return 10.0f;
}

+ (float)attackFps {
	return 12.0f;
}

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
	if (self = [super initWithActorDef:def]) {
		mKey = [key copy];
		mIsCollidable = YES;
        mTimeToKill = 0;
		mCategory = CAT_PF_SEA;
		mAdvanceable = YES;
		mDestination = 0;
		mPrey = nil;
		mResources = nil;
		mState = kStateNull;
		
		// Save fixtures
		b2Fixture **fixtures = def->fixtures;
		assert(def->fixtureDefCount == 2);
		mHead = *fixtures;
		++fixtures;
		mNose =  *fixtures;
		
		[self checkoutPooledResources];
		[self setupActorCostume];
    }
    return self;
}

- (void)setupActorCostume {
	if (mSwimClip == nil) {
		mSwimClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"shark_" cacheGroup:TM_CACHE_SHARK] fps:[Shark swimFps]];
		mSwimClip.loop = YES;
		mSwimClip.x = -mSwimClip.width / 2;
		mSwimClip.y = -mSwimClip.height / 2;
	}
    
    mSwimClip.visible = YES;
	
	if (mAttackClip == nil) {
		mAttackClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"shark-attack_" cacheGroup:TM_CACHE_SHARK] fps:[Shark attackFps]];
		mAttackClip.loop = NO;
		mAttackClip.x = -mAttackClip.width / 2;
		mAttackClip.y = -mAttackClip.height / 2;
        [mAttackClip addEventListener:@selector(onAttackMovieComplete:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	}
    
    mAttackClip.currentFrame = 0;
    mAttackClip.visible = NO;
	
	[self addChild:mSwimClip];
	[self addChild:mAttackClip];
	
	self.alpha = 0.5f;
	self.x = self.px;
	self.y = self.py;
	self.rotation = -self.b2rotation;
	
	[mScene.juggler addObject:mSwimClip];
	[mScene.juggler addObject:mAttackClip];
	[self setSharkState:kStateSwimming];
}

- (void)setPrey:(OverboardActor *)prey {
    if (mPrey == prey)
        return;
    
    // Prevent stack overflow when OverboardActor tries to unset us.
    OverboardActor *currentPrey = mPrey;
    mPrey = nil;
    
    if (currentPrey) {
        if (currentPrey.predator == self)
            currentPrey.predator = nil;
        [currentPrey autorelease]; currentPrey = nil;
    }
    
	mPrey = [prey retain];
    
    if (self.markedForRemoval == NO) {
        if (mPrey)
            [self setSharkState:kStatePursuing];
        else
            [self setSharkState:kStateSwimming];
    }
}

- (void)setSharkState:(int)state {
	if (state == mState)
		return;
	
	switch (state) {
		case kStateSwimming:
		{
			mSpeed = kSharkSwimSpeed;
			mSwimClip.currentFrame = 0;
			mSwimClip.visible = YES;
			[mSwimClip play];
			mAttackClip.visible = NO;
			[mAttackClip pause];
		}
            break;
		case kStatePursuing:
            mTimeToKill = 0;
			break;
		case kStateAttacking:
		{
			[self playEatVictimSound];
			mSpeed = kSharkSwimSpeed / 2;
			mSwimClip.visible = NO;
			[mSwimClip pause];
			mAttackClip.currentFrame = 0;
			mAttackClip.visible = YES;
			[mAttackClip play];
			
            b2Vec2 waterPos = mNose->GetAABB(0).GetCenter();
            SharkWater *water = [[SharkWater alloc] initWithX:M2PX(waterPos.x) y:M2PY(waterPos.y)];
            [mScene addProp:water];
            [water playEffect];
            [water release];
		}
            break;
		default:
			NSLog(@"Invalid state in Shark.setSharkState");
			return;
	}
	
	mState = state;
}

- (void)playEatVictimSound {
	[mScene.audioPlayer playSoundWithKey:@"SharkAttack" volume:1.0f];
}

- (float)navigate {
	if (mRemoveMe || mBody == 0) {
        if (mBody == 0)
            [self dock];
		return 0;
    }
    
	float swimForce = mSpeed * mBody->GetMass();
	[self swimWithForce:swimForce];
	
	if (mState != kStateAttacking) {
		b2Vec2 bodyPos = mBody->GetPosition(), destPos;
		
		if (mPrey != nil) {
			assert(mPrey.body);
			b2Vec2 preyPos = mPrey.body->GetPosition();
			destPos = bodyPos - preyPos;
		} else {
			assert(mDestination);
			destPos = bodyPos - mDestination.dest;
		}
		
		if (fabsf(destPos.x) < 2.5f && fabsf(destPos.y) < 2.5f) {
			if (mState == kStateSwimming)
				[self dock];
		} else {
			// Turn towards destination
			b2Vec2 linearVel = mBody->GetLinearVelocity();
			float angleToTarget = Box2DUtils::signedAngle(destPos, linearVel);
			
			if (angleToTarget != 0.0f) {
				float turnForce = ((angleToTarget > 0.0f) ? -1.0f : 1.0f) * mBody->GetMass() * 5;
				[self turnWithForce: turnForce];
			}
		}
	}

	return swimForce;
}

- (void)advanceTime:(double)time {
	// Ship position/orientation
	self.x = self.px;
	self.y = self.py;
	self.rotation = -self.b2rotation;
	[self navigate];
    
    if (mState == kStatePursuing) {
        mTimeToKill += time;
        
        if (mTimeToKill > 30.0) {
            mTimeToKill = 0;
            [self dock];
        }
    }
}

- (void)attackCompleted {
    self.prey = nil;
}

- (void)onAttackMovieComplete:(SPEvent *)event {
	[self attackCompleted];
}

- (void)swimWithForce:(float32)force {
	if (mBody == 0)
		return;
	b2Vec2 noseCenter = mNose->GetAABB(0).GetCenter();
	b2Vec2 bodyCenter = mBody->GetWorldCenter();
	b2Vec2 delta = noseCenter - bodyCenter;
	delta.Normalize();
	mBody->ApplyForce(force * delta, bodyCenter);
}

- (void)turnWithForce:(float32)force {
	if (mBody == 0)
		return;
	float32 dir = (force < 0.0f) ? 1 : -1;
	b2Vec2 turnVec = b2Vec2(0.0f,fabsf(force));
	Box2DUtils::rotateVector(turnVec, mBody->GetAngle()+dir*PI_HALF);
	mBody->ApplyForce(turnVec,mNose->GetAABB(0).GetCenter());
}

- (void)dock {
	[mScene removeActor:self]; // Calls safeRemove for us
}

- (void)respondToPhysicalInputs {
	if (mState == kStateAttacking)
		return;
	
	for (Actor *actor in mContacts) {
		if (actor == mPrey) {
			[self setSharkState:kStateAttacking];
            mPrey.deathBitmap = DEATH_BITMAP_SHARK;
			[mPrey getEatenByShark];
			break;
		}
	}
}

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    return (fixtureSelf != mNose || [other isKindOfClass:[OverboardActor class]] == NO);
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    [super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)prepareForNewGame {
    // Do nothing
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_SHARK_SWIM:
            break;
        case RESOURCE_KEY_SHARK_ATTACK:
            [self attackCompleted];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_SHARK] checkoutPoolResourcesForKey:@"Shark"] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED SHARK CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mSwimClip == nil)
            mSwimClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_SHARK_SWIM] retain];
        if (mAttackClip == nil)
            mAttackClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_SHARK_ATTACK] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_SHARK] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)cleanup {
	[super cleanup];
    
    if (mPrey)
        self.prey = nil;  // Will already be nil if called from our dealloc
}

- (void)dealloc {
    [self cleanup];
	[self checkinPooledResources];
	[mAttackClip removeEventListener:@selector(onAttackMovieComplete:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mScene.juggler removeObject:mSwimClip];
	[mScene.juggler removeObject:mAttackClip];
	[mSwimClip release]; mSwimClip = nil;
	[mAttackClip release]; mAttackClip = nil;
	[mDestination release]; mDestination = nil;
	[super dealloc];
}

@end
