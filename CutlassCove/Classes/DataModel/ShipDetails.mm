//
//  ShipDetails.m
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ShipDetails.h"
#import "ShipFactory.h"
#import "Prisoner.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "PrisonerOverboardEvent.h"
#import "GameController.h"
#import "Globals.h"


@interface ShipDetails ()


@end

@implementation ShipDetails

@synthesize type = mType;
@synthesize bitmap = mBitmap;
@synthesize speedRating = mSpeedRating;
@synthesize controlRating = mControlRating;
@synthesize rudderOffset = mRudderOffset;
@synthesize reloadInterval = mReloadInterval;
@synthesize infamyBonus = mInfamyBonus;
@synthesize mutinyPenalty = mMutinyPenalty;
@synthesize prisoners = mPrisoners;
@synthesize textureName = mTextureName;
@synthesize textureFutureName = mTextureFutureName;
@dynamic plankVictim;

- (id)initWithType:(NSString *)type {
	if (self = [super init]) {
		mTransferingCargo = NO;
		mType = [type copy];
		mBitmap = 0;
		mPrisoners = [[NSMutableDictionary alloc] init];
		mSpeedRating = 0;
		mControlRating = 0;
		mReloadInterval = 1.0f;
		mInfamyBonus = 0;
        mMutinyPenalty = 0;
		mTextureName = nil;
		mTextureFutureName = nil;
	}
	return self;
}

- (id)init {
	return [self initWithType:@"Default"];
}

- (Prisoner *)plankVictim {
	Prisoner *victim = nil;
    
	for (NSString *key in mPrisoners) {
		victim = [mPrisoners objectForKey:key];
        break;
    }

	return victim;
}

- (BOOL)isFullOnPrisoners {
	NSArray *prisonerNames = [ShipFactory shipYard].allPrisonerNames;
	return (mPrisoners.count >= prisonerNames.count);
}

- (Prisoner *)addRandomPrisoner {
	NSArray *prisonerNames = [ShipFactory shipYard].allPrisonerNames;
	
	if (mPrisoners.count == prisonerNames.count)
		return nil;
	Prisoner *p = nil;
	
	for (int i = RANDOM_INT(0,prisonerNames.count - 1), count = 0; count < prisonerNames.count; ++i, ++count) {
		if (i >= prisonerNames.count)
			i  = 0;
		NSString *name = (NSString *)[prisonerNames objectAtIndex:i];
		p = [mPrisoners objectForKey:name];
		
		if (p == nil) {
			[self addPrisoner:name];
			p = [mPrisoners objectForKey:name];
			break;
		}
	}
	return p;
}

- (void)addPrisoner:(NSString *)prisonerName {
	Prisoner *prisoner = [mPrisoners objectForKey:prisonerName];
	
	// No prisoner duplicates
	if (prisoner == nil) {
		//NSLog(@"Prisoner Name: %@\n", prisonerName);
		prisoner = [[ShipFactory shipYard] createPrisonerForName:prisonerName];
		[mPrisoners setObject:prisoner forKey:prisonerName];
		[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED value:[NSNumber numberWithUnsignedInt:mPrisoners.count] bubbles:NO];
        //[self dispatchEvent:[SPEvent eventWithType:@"PlankedVictimsIncreased"]];
	}
}

- (void)addPrisonersFromDictionary:(NSDictionary *)dict {
	for (NSString *key in dict)
		[self addPrisoner:key];
}

- (void)removePrisoner:(NSString *)prisonerName {
	Prisoner *prisoner = [mPrisoners objectForKey:prisonerName];
	
	if (prisoner != nil) {
		[mPrisoners removeObjectForKey:prisonerName];
		[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED value:[NSNumber numberWithUnsignedInt:mPrisoners.count] bubbles:NO];
	}
}

- (void)removeAllPrisoners {
	[mPrisoners removeAllObjects];
}

- (void)prisonerPushedOverboard:(Prisoner *)prisoner {
	//NSLog(@"Removing prisoner with name: %@", event.prisoner.name);
	[self removePrisoner:prisoner.name];
}

- (void)reset {
	[self removeAllPrisoners];
}

- (void)dealloc {
	[mType release]; mType = nil;
	[mPrisoners release]; mPrisoners = nil;
	[mTextureName release]; mTextureName = nil;
	[mTextureFutureName release]; mTextureFutureName = nil;
    [super dealloc];
}

@end
