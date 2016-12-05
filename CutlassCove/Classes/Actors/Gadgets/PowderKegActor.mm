//
//  PowderKegActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PowderKegActor.h"
#import "ActorFactory.h"
#import "Prop.h"
#import "PointMovie.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "BrandySlickActor.h"
#import "OverboardActor.h"
#import "AchievementManager.h"
#import "Globals.h"

@interface PowderKegActor ()

- (void)setupActorCostume;
- (void)retireActorCostume;
- (void)displayHitEffect:(int)effectType;
- (void)playDetonationSound;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end


@implementation PowderKegActor

+ (PowderKegActor *)powderKegActorAtX:(float)x y:(float)y rotation:(float)rotation {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createPowderKegDefAtX:x y:y angle:rotation];
	PowderKegActor *keg = [[[PowderKegActor alloc] initWithActorDef:actorDef] autorelease];
	delete actorDef;
	actorDef = 0;
	return keg;
}

- (id)initWithActorDef:(ActorDef *)def {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_POINT_MOVIES;
		mAdvanceable = YES;
		mDetonated = NO;
		mCostume = nil;
		[self setupActorCostume];
    }
    return self;
}

- (void)setupActorCostume {
	if (mCostume != nil)
		return;
	mCostume = [[SPSprite alloc] init];
	SPImage *image = [SPImage imageWithTexture:[mScene textureByName:@"powder-keg"]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	[mCostume addChild:image];
	[self addChild:mCostume];
	
	self.x = self.px;
	self.y = self.py;
	self.rotation = -mBody->GetAngle();
	
	// Make the keg appear to bob up and down in the water
	SPTween *tween = [SPTween tweenWithTarget:mCostume time:0.75f];
	[tween animateProperty:@"scaleX" targetValue:0.8f];
	[tween animateProperty:@"scaleY" targetValue:0.8f];
	tween.loop = SPLoopTypeReverse;
	[mScene.juggler addObject:tween];
}

- (void)retireActorCostume {
	[mScene.juggler removeTweensWithTarget:mCostume];
	[self removeAllChildren];
}

- (void)advanceTime:(double)time {
	self.x = self.px;
	self.y = self.py;
}

- (BOOL)ignited {
	return mDetonated;
}

- (void)ignite {
	[self detonate];
}

- (BOOL)detonate {
	if (mDetonated || self.markedForRemoval)
		return NO;
	mDetonated = YES;
	
	for (Actor *actor in mContacts) {
		if ([actor isKindOfClass:[BrandySlickActor class]]) {
			BrandySlickActor *slick = (BrandySlickActor *)actor;
			[slick ignite];
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
			OverboardActor *person = (OverboardActor *)actor;
			
			if (person.dying == NO)
				[person environmentalDeath];
		} else if ([actor isKindOfClass:[PowderKegActor class]]) {
			PowderKegActor *powderKeg = (PowderKegActor *)actor;
			[powderKeg detonate];
		}
	}
	
	[self displayHitEffect:MovieTypeExplosion];
	[self displayHitEffect:MovieTypeSplash];
	[self playDetonationSound];
	[self retireActorCostume];
    
    if (self.turnID == GCTRL.thisTurn.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:GADGET_SPELL_TNT_BARRELS];
	[mScene removeActor:self];
	return YES;
}

- (void)displayHitEffect:(int)effectType {
	[PointMovie pointMovieWithType:effectType x:self.x y:self.y];
}

- (void)playDetonationSound {
	[mScene.audioPlayer playRandomSoundWithKeyPrefix:@"Explosion" range:3 volume:0.7f pitch:1.0f];
	[mScene.audioPlayer playSoundWithKey:@"Splash" volume:1.0f];
}

- (void)respondToPhysicalInputs {
	if (self.markedForRemoval)
		return;
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == NO && [actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.docking == NO) {
				ship.deathBitmap = DEATH_BITMAP_POWDER_KEG;
				[ship sink];
			}
			++mScene.achievementManager.kabooms; // Players may feel cheated if they see a keg explode but miss their achievement, so leave this outside conditional.
			[self detonate];
			break;
		}
	}
}

/*
- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;
		
		if (fixtureOther == ship.feeler)
			return false;
	}
	return [super preSolve:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}
*/

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    BOOL ignores = NO;
    
    if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;
		
		if (fixtureOther == ship.feeler)
			ignores = YES;
//		else if ([other isKindOfClass:[MerchantShip class]]) {
//			MerchantShip *merchantShip = (MerchantShip *)other;
//			
//			if (fixtureOther == merchantShip.defender)
//				ignores = YES;
//		}
	} else if ([other isKindOfClass:[BrandySlickActor class]] == NO && [other isKindOfClass:[OverboardActor class]] == NO && [other isKindOfClass:[PowderKegActor class]] == NO) {
		ignores = YES;
	}
    
    return ignores;
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

- (void)dealloc {
	[mScene.juggler removeTweensWithTarget:mCostume];
	[mCostume release]; mCostume = nil;
	[super dealloc];
}

@end
