//
//  PlayerDetails.m
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayerDetails.h"
#import "PlayerShip.h"
#import "ShipDetails.h"
#import "CannonDetails.h"
#import "ShipFactory.h"
#import "CannonFactory.h"
#import "Countdown.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "ObjectivesManager.h"
#import "GameSettings.h"
#import "GameController.h"

@interface PlayerDetails ()

- (void)acquireNewShip;
- (void)acquireNewCannon;
- (void)onShipTypeChanged:(SPEvent *)event;
- (void)onCannonTypeChanged:(SPEvent *)event;

@end


@implementation PlayerDetails

@synthesize gameStats = mGameStats;
@synthesize shipDetails = mShipDetails;
@synthesize cannonDetails = mCannonDetails;
@dynamic name,playerRating,scoreMultiplier,abilities;

- (id)initWithGameStats:(GameStats *)gameStats {
	if (self = [super init]) {
		mGameStats = [gameStats retain];
		self.shipDetails = [[ShipFactory shipYard] createShipDetailsForType:mGameStats.shipName];
		self.cannonDetails = [[CannonFactory munitions] createCannonDetailsForType:mGameStats.cannonName];
		[mGameStats addEventListener:@selector(onShipTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED];
		[mGameStats addEventListener:@selector(onCannonTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED];
	}
	return self;
}

- (id)init {
	return [self initWithGameStats:[[[GameStats alloc] initWithAlias:@"Player"] autorelease]];
}

- (ShipDetails *)shipDetails {
	return mShipDetails;
}

- (NSString *)name {
	return mGameStats.alias;
}

- (void)setName:(NSString *)name {
	mGameStats.alias = name;
}

- (uint)scoreMultiplier {
    return GCTRL.objectivesManager.scoreMultiplier;
}

- (void)setHiScore:(int64_t)score forGameMode:(NSString *)mode {
    [mGameStats setHiScore:score forGameMode:mode];
}

- (Score *)hiScore {
    return mGameStats.hiScore;
}

- (void)setHiScore:(int64_t)value {
    [mGameStats setHiScore:value];
}

- (float)playerRating {
	// Best Ship and Cannon ratings are 7. So best rating gives a unity scaling factor.
	return (12.0f + mShipDetails.speedRating + mShipDetails.controlRating + mCannonDetails.rangeRating + mCannonDetails.damageRating) / 40.0f;
}

- (uint)abilities {
	return mGameStats.abilities;
}

- (void)reset {
	[mShipDetails reset];
}

- (void)acquireNewShip {
	ShipDetails *details = [[ShipFactory shipYard] createShipDetailsForType:mGameStats.shipName];
	
	if (mShipDetails != nil)
		[details reset];
	self.shipDetails = details;
}

- (void)acquireNewCannon {
	CannonDetails *details = [[CannonFactory munitions] createCannonDetailsForType:mGameStats.cannonName];
	self.cannonDetails = details;
}

- (void)onShipTypeChanged:(SPEvent *)event {
	[self acquireNewShip];
}

- (void)onCannonTypeChanged:(SPEvent *)event {
	[self acquireNewCannon];
}

- (void)onPlayerChanged:(SPEvent *)event {
	[mGameStats removeEventListener:@selector(onShipTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED];
	[mGameStats removeEventListener:@selector(onCannonTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED];
	[mGameStats release];
	mGameStats = nil;
	
	mGameStats = [GCTRL.gameStats retain];
	[self acquireNewShip];
	[self acquireNewCannon];
	[mGameStats addEventListener:@selector(onShipTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED];
	[mGameStats addEventListener:@selector(onCannonTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED];
}

- (void)cleanup {
	[mGameStats removeEventListener:@selector(onShipTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED];
	[mGameStats removeEventListener:@selector(onCannonTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED];
	[mGameStats release];
	mGameStats = nil;
}

- (void)dealloc {
	[mGameStats removeEventListener:@selector(onShipTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED];
	[mGameStats removeEventListener:@selector(onCannonTypeChanged:) atObject:self forType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED];
	[mGameStats release]; mGameStats = nil;
	[mShipDetails release]; mShipDetails = nil;
	[mCannonDetails release]; mCannonDetails = nil;
	[super dealloc];
}

@end
