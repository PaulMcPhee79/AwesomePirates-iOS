//
//  MagmaPoolActor.m
//  CutlassCove
//
//  Created by Paul McPhee on 6/05/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "MagmaPoolActor.h"
#import "ActorFactory.h"
#import "DeathBitmaps.h"
#import "Globals.h"

@implementation MagmaPoolActor

+ (MagmaPoolActor *)magmaPoolActorAtX:(float)x y:(float)y duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createPoolDefinitionAtX:x y:y];
	MagmaPoolActor *magmaPool = [[[MagmaPoolActor alloc] initWithActorDef:actorDef duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return magmaPool;
}

- (double)fullDuration {
	return ASH_DURATION_MAGMA_POOL;
}

- (uint)bitmapID {
	return ASH_SPELL_MAGMA_POOL;
}

- (uint)deathBitmap {
	return DEATH_BITMAP_MAGMA_POOL;
}

- (NSString *)poolTextureName {
	return @"pool-of-magma";
}

- (NSString *)resourcesKey {
	return @"MagmaPool";
}

@end

