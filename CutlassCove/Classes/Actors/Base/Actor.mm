//
//  Actor.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Actor.h"
#import "Prop.h"

@interface Actor ()

- (ActorContact *)actorContactForActor:(Actor *)actor;
- (void)onPreparedForNewGame:(SPEvent *)event;

@end


@implementation Actor

@synthesize key = mKey;
@synthesize actorId = mActorId;
@synthesize turnID = mTurnID;
@synthesize advanceable = mAdvanceable;
@synthesize markedForRemoval = mRemoveMe;
@synthesize isPreparingForNewGame = mPreparingForNewGame;
@synthesize body = mBody;
@synthesize category = mCategory;
@dynamic px,py,b2x,b2y;

static int _actorId = 0;
static NSMutableArray *_actors = nil;
static PlayfieldController *_scene = nil;

+ (int)actorCount {
	return _actors.count;
}

+ (void)printActors {
	for (NSValue *value in _actors) {
		Actor *actor = [value nonretainedObjectValue];
		NSLog(@"Alive Actor: %@",NSStringFromClass([actor class]));
	}
}

+ (SceneController *)actorsScene {
	return _scene;
}

+ (void)setActorsScene:(PlayfieldController *)scene {
	_scene = scene;
}

+ (void)seedActorId:(int)seed {
	_actorId = seed;
}

+ (int)nextActorId {
	return ++_actorId;
}

- (id)initWithActorDef:(ActorDef *)def actorId:(int)actorId {
	if (self = [super init]) {
		if (_actors == nil)
			_actors = [[NSMutableArray alloc] init];
		
		[_actors addObject:[NSValue valueWithNonretainedObject:self]];
		mScene = [_scene retain];
		mKey = nil;
		mActorId = actorId;
        mTurnID = GCTRL.thisTurn.turnID;
		mCategory = 0;
		mAdvanceable = NO;
        mRemoveMe = NO;
        mRemovedContact = NO;
        mPreparingForNewGame = NO;
        mNewGamePreparationDuration = 1.0f;
		mBody = 0;
		mZombieProp = nil;
		mContacts = [[NSMutableSet alloc] init];
		mContactCounts = [[NSMutableSet alloc] init];
		mBody = mScene.world->CreateBody(&def->bd);
		def->fixtures = new b2Fixture*[def->fixtureDefCount];
		
		for (int i = 0; i < def->fixtureDefCount; ++i)
			def->fixtures[i] = mBody->CreateFixture(&def->fds[i]);
		mBody->SetUserData(self);
		self.touchable = mScene.touchableDefault;
    }
    return self;
}

- (id)initWithActorDef:(ActorDef *)def {
    return [self initWithActorDef:def actorId:0];
}

- (id)init {
	ActorDef actorDef;
	return [self initWithActorDef:&actorDef];
}

- (float)px {
	return M2PX(self.b2x);
}

- (float)py {
	return M2PY(self.b2y);
}

- (float)b2x {
	return ((mBody) ? mBody->GetPosition().x : 0);
}

- (float)b2y {
	return ((mBody) ? mBody->GetPosition().y : 0);
}

- (float)b2rotation {
	return ((mBody) ? mBody->GetAngle() : 0);
}

// Only true if all fixtures are sensors
- (bool)isSensor {
	if (mBody == 0)
		return NO;
	bool result = NO;
	
	b2Fixture *fixtures = mBody->GetFixtureList();
	
	if (fixtures)
		result = YES;
	
	while (fixtures) {
		result = result && fixtures->IsSensor();
		fixtures = fixtures->GetNext();
	}
	return result;
}

- (void)flip:(BOOL)enable { }

- (int)tagForContactWithActor:(Actor *)actor {
	int tag = 0;
	ActorContact *actorContact = [self actorContactForActor:actor];
	
	if (actorContact)
		tag = actorContact.tag;
	return tag;
}

- (void)setTag:(int)tag forContactWithActor:(Actor *)actor {
	ActorContact *actorContact = [self actorContactForActor:actor];
	
	if (actorContact)
		actorContact.tag = tag;
}

- (ActorContact *)actorContactForActor:(Actor *)actor {
	ActorContact *foundIt = nil;
	
	for (ActorContact *actorContact in mContactCounts) {
		if (actorContact.actor == actor) {
			foundIt = actorContact;
			break;
		}
	}
	return foundIt;
}

- (void)fpsFactorChanged:(float)value { }

- (void)advanceTime:(double)time { }

- (void)respondToPhysicalInputs { }

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([mContacts containsObject:other] == NO) {
		[mContacts addObject:other];
		
		ActorContact *actorContact = [ActorContact actorContactWithActor:other];
		++actorContact.count;
		[mContactCounts addObject:actorContact];
	} else {
		ActorContact *actorContact = [self actorContactForActor:other];
		++actorContact.count;
	}
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact { 
	return true;
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    mRemovedContact = NO;
    
	if ([mContacts containsObject:other]) {
		ActorContact *actorContact = [self actorContactForActor:other];
		assert(actorContact && actorContact.count > 0);
		--actorContact.count;
		
		if (actorContact.count == 0) {
			[mContactCounts removeObject:actorContact];
			actorContact = nil;
            mRemovedContact = YES;
			[mContacts removeObject:other];
			//NSLog(@"%@ ending contact with %@.", other.key, self.key);
		}
	}
}

- (void)prepareForNewGame {
    if (self.markedForRemoval || mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    
    SPTween *tween = [SPTween tweenWithTarget:self time:mNewGamePreparationDuration];
    [tween animateProperty:@"alpha" targetValue:0];
    [tween addEventListener:@selector(onPreparedForNewGame:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.juggler addObject:tween];
}

- (void)onPreparedForNewGame:(SPEvent *)event {
    if (self.markedForRemoval == NO)
        [mScene removeActor:self];
}

- (void)checkoutPooledResources { }
- (void)checkinPooledResources { }

- (void)safeRemove {
#if 0	
	if (mRemoveMe == NO && mZombieProp == nil) {
		mZombieProp = [[Prop alloc] initWithCategory:mScene.topCategory];
		mZombieProp.x = self.x;
		mZombieProp.y = self.y;
		
		SPQuad *quad = [SPQuad quadWithWidth:16 height:16];
		quad.x = -quad.width / 2;
		quad.y = -quad.height / 2;
		quad.color = 0xff0000;
		[mZombieProp addChild:quad];
		[mScene addProp:mZombieProp];
	}
#endif
		
	mRemoveMe = YES;
}

// Do not destroy in dealloc because dealloc may be called during a world step.
- (void)destroyActorBody {
	if (mBody) {
		b2Body *b = mBody;
		mBody = 0; // TOOO: So that if the destroy fails, then it only fails once - it is not tried on the next frame.
		mScene.world->DestroyBody(b); 
		//mBody = 0;
		[self zeroOutFixtures];
	}
}

- (void)zeroOutFixtures { }

- (void)cleanup { }

- (void)dealloc {
	//[mScene.juggler removeTweensWithTarget:self]; // We wouldn't be in here if we were targets of any tweens.
	[_actors removeObject:[NSValue valueWithNonretainedObject:self]];
	//NSLog(@"Actor Count: %d",[Actor actorCount]);
	
	if (mZombieProp != nil) {
		[mScene removeProp:mZombieProp];
		[mZombieProp release]; mZombieProp = nil;
	}
    
	if ([Actor actorCount] < 3)
		[Actor printActors];
	[mKey release]; mKey = nil;
	[mContacts release]; mContacts = nil;
	[mContactCounts release]; mContactCounts = nil;
	[mScene release]; mScene = nil;
    [super dealloc];
}

@end

@implementation ActorContact

@synthesize tag = mTag;
@synthesize count = mCount;
@synthesize actor = mActor;

+ (ActorContact *)actorContactWithActor:(Actor *)actor {
	ActorContact *actorContact = [[[ActorContact alloc] init] autorelease];
	actorContact.actor = actor;
	return actorContact;
}

- (id)init {
	if (self = [super init]) {
		mTag = 0;
		mCount = 0;
		mActor = nil;
	}
	return self;
}

@end


