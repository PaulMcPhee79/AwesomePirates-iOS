//
//  LootActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"

class ActorDef;

@class PlayerShip;

@interface LootActor : Actor {
	BOOL mLooted;
	uint mDoubloons;
	uint mInfamyBonus;
    double mDuration;
}

@property (nonatomic,assign) uint doubloons;
@property (nonatomic,assign) uint infamyBonus;

- (id)initWithActorDef:(ActorDef *)def category:(int)category duration:(float)duration;
- (void)setupActorCostume;
- (void)playLootSound;
- (void)loot:(PlayerShip *)ship;
- (void)onLooted:(SPEvent *)event;
- (void)onExpired:(SPEvent *)event;

@end
