//
//  PlayerDetails.h
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStats.h"

#define CUST_EVENT_TYPE_PURCHASE_MADE @"purchaseMadeEvent"
#define CUST_EVENT_TYPE_INSUFFICIENT_FUNDS @"insufficientFundsEvent"

@class ShipDetails,CannonDetails,NumericValueChangedEvent,Countdown;

@interface PlayerDetails : SPEventDispatcher {
	GameStats *mGameStats;
	ShipDetails *mShipDetails;
	CannonDetails *mCannonDetails;
}

@property (nonatomic,copy) NSString *name;			// Convenience interface to GameStats
@property (nonatomic,readonly) uint abilities;
@property (nonatomic,readonly) GameStats *gameStats;

@property (nonatomic,readonly) float playerRating;
@property (nonatomic,readonly) uint scoreMultiplier;
@property (nonatomic,retain) ShipDetails *shipDetails;
@property (nonatomic,retain) CannonDetails *cannonDetails;

- (id)initWithGameStats:(GameStats *)gameStats;

- (Score *)hiScore;
- (void)setHiScore:(int64_t)value;

- (void)reset;
- (void)onPlayerChanged:(SPEvent *)event;
- (void)cleanup;

@end
