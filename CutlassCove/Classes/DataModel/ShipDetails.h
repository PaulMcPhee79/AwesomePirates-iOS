//
//  ShipDetails.h
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_SHIP_MENU_TEXTURE_CHANGED @"shipMenuTextureChangedEvent"
#define NUM_NPC_COSTUME_IMAGES 7

@class Booty,Prisoner,Ransom;

@interface ShipDetails : SPEventDispatcher {
	BOOL mTransferingCargo;
	NSString *mType;
	uint mBitmap; // Ship Type ID
	int mSpeedRating;
	int mControlRating;
	float mRudderOffset;
	float mReloadInterval;
	int mInfamyBonus;
    int mMutinyPenalty;
	NSString *mTextureName;
	NSString *mTextureFutureName;
	NSMutableDictionary *mPrisoners;
}

@property (nonatomic,readonly) NSString *type;
@property (nonatomic,assign) uint bitmap;
@property (nonatomic,assign) int speedRating;
@property (nonatomic,assign) int controlRating;
@property (nonatomic,assign) float rudderOffset;
@property (nonatomic,assign) float reloadInterval;
@property (nonatomic,assign) int infamyBonus;
@property (nonatomic,assign) int mutinyPenalty;
@property (nonatomic,retain) NSString *textureName;
@property (nonatomic,retain) NSString *textureFutureName;
@property (nonatomic,readonly) NSMutableDictionary *prisoners;
@property (nonatomic,readonly) Prisoner *plankVictim;


- (id)initWithType:(NSString *)type;
- (BOOL)isFullOnPrisoners;
- (void)addPrisoner:(NSString *)prisonerName;
- (Prisoner *)addRandomPrisoner;
- (void)addPrisonersFromDictionary:(NSDictionary *)dict;
- (void)removePrisoner:(NSString *)prisonerName;
- (void)removeAllPrisoners;
- (void)prisonerPushedOverboard:(Prisoner *)prisoner;
- (void)reset;

@end
