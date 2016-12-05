//
//  GCMisc.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCMisc.h"


@implementation GCMisc

@synthesize alias,gameState,queuedState,thisTurn,infamy,mutiny,day,timeOfDay,timePassed,actorIdSeed,beachState,kegsRemaining;
@synthesize activeVoodoos,activeAshes,actors,townAi,coveVenueKeys,numShotsMissed,bottlesState,infamyAwarded,ashProc;


+ (GCMisc *)gcMisc {
	return [[[GCMisc alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		// Init to safest options (those that punish exploit attempts in case of semantic error resulting in properties not being set)
		alias = nil;
		gameState = StateNull;
		queuedState = StateNull;
		thisTurn = nil;
		infamy = 0;
		mutiny = 0;
		day = 1;
		timeOfDay = 0;
		timePassed = 0;
		actorIdSeed = 0;
		beachState = 0;
		kegsRemaining = 0;
		activeAshes = nil;
		activeVoodoos = nil;
		actors = nil;
		townAi = nil;
		ashProc = nil;
		coveVenueKeys = nil;
		numShotsMissed = 3;
		bottlesState = 0;
		infamyAwarded = YES;
	}
	return self;
}

- (void)addActiveAsh:(GCAsh *)ash {
	if (activeAshes == nil)
		activeAshes = [[NSMutableArray alloc] init];
	[activeAshes addObject:ash];
}

- (void)addActiveVoodoo:(GCVoodoo *)voodoo {
	if (activeVoodoos == nil)
		activeVoodoos = [[NSMutableArray alloc] init];
	[activeVoodoos addObject:voodoo];
}

- (void)addActor:(GCActor *)actor {
	if (actors == nil)
		actors = [[NSMutableArray alloc] init];
	[actors addObject:actor];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		alias = [(NSString *)[decoder decodeObjectForKey:@"alias"] copy];
		gameState = (GameState)[(NSNumber *)[decoder decodeObjectForKey:@"gameState"] unsignedIntValue];
		queuedState = (GameState)[(NSNumber *)[decoder decodeObjectForKey:@"queuedState"] unsignedIntValue];
		thisTurn = [(ThisTurn *)[decoder decodeObjectForKey:@"thisTurn"] retain];
		infamy = [(NSNumber *)[decoder decodeObjectForKey:@"infamy"] longLongValue];
		mutiny = [(NSNumber *)[decoder decodeObjectForKey:@"mutiny"] intValue];
		day = [(NSNumber *)[decoder decodeObjectForKey:@"day"] unsignedIntValue];
		timeOfDay = [(NSNumber *)[decoder decodeObjectForKey:@"timeOfDay"] unsignedIntValue];
		timePassed = [(NSNumber *)[decoder decodeObjectForKey:@"timePassed"] floatValue];
		actorIdSeed = [(NSNumber *)[decoder decodeObjectForKey:@"actorIdSeed"] intValue];
		beachState = [(NSNumber *)[decoder decodeObjectForKey:@"beachState"] unsignedIntValue];
		kegsRemaining = [(NSNumber *)[decoder decodeObjectForKey:@"kegsRemaining"] unsignedIntValue];
		activeAshes = [(NSArray *)[decoder decodeObjectForKey:@"activeAshes"] mutableCopy];
		activeVoodoos = [(NSArray *)[decoder decodeObjectForKey:@"activeVoodoos"] mutableCopy];
		actors = [(NSArray *)[decoder decodeObjectForKey:@"actors"] mutableCopy];
		townAi = [(GCTownAi *)[decoder decodeObjectForKey:@"townAi"] retain];
		ashProc = [(AshProc *)[decoder decodeObjectForKey:@"ashProc"] retain];
		coveVenueKeys = [(NSArray *)[decoder decodeObjectForKey:@"coveVenueKeys"] retain];
		numShotsMissed = [(NSNumber *)[decoder decodeObjectForKey:@"numShotsMissed"] unsignedIntValue];
		bottlesState = [(NSNumber *)[decoder decodeObjectForKey:@"bottlesState"] unsignedIntValue];
		infamyAwarded = [(NSNumber *)[decoder decodeObjectForKey:@"infamyAwarded"] boolValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:alias forKey:@"alias"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:(uint)gameState] forKey:@"gameState"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:(uint)queuedState] forKey:@"queuedState"];
	[coder encodeObject:thisTurn forKey:@"thisTurn"];
	[coder encodeObject:[NSNumber numberWithLongLong:infamy] forKey:@"infamy"];
	[coder encodeObject:[NSNumber numberWithInt:mutiny] forKey:@"mutiny"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:day] forKey:@"day"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:timeOfDay] forKey:@"timeOfDay"];
	[coder encodeObject:[NSNumber numberWithFloat:timePassed] forKey:@"timePassed"];
	[coder encodeObject:[NSNumber numberWithInt:actorIdSeed] forKey:@"actorIdSeed"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:beachState] forKey:@"beachState"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:kegsRemaining] forKey:@"kegsRemaining"];
	[coder encodeObject:activeAshes forKey:@"activeAshes"];
	[coder encodeObject:activeVoodoos forKey:@"activeVoodoos"];
	[coder encodeObject:actors forKey:@"actors"];
	[coder encodeObject:townAi forKey:@"townAi"];
	[coder encodeObject:ashProc forKey:@"ashProc"];
	[coder encodeObject:coveVenueKeys forKey:@"coveVenueKeys"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:numShotsMissed] forKey:@"numShotsMissed"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:bottlesState] forKey:@"bottlesState"];
	[coder encodeObject:[NSNumber numberWithBool:infamyAwarded] forKey:@"infamyAwarded"];
}

- (void)dealloc {
	[activeAshes release]; activeAshes = nil;
	[activeVoodoos release]; activeVoodoos = nil;
	[actors release]; actors = nil;
	[townAi release]; townAi = nil;
	[ashProc release]; ashProc = nil;
	[coveVenueKeys release]; coveVenueKeys = nil;
	[super dealloc];
}

@end
