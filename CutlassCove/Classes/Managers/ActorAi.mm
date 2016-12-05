//
//  ActorAi.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ActorAi.h"
#import "Actor.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "PlayerDetails.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "PursuitShip.h"
#import "NavyShip.h"
#import "PirateShip.h"
#import "PrimeShip.h"
#import "SilverTrain.h"
#import "TreasureFleet.h"
#import "EscortShip.h"
#import "ShipDetails.h"
#import "Shark.h"
#import "OverboardActor.h"
#import "AshPickupActor.h"
#import "ShipFactory.h"
#import "CannonFactory.h"
#import "Cannonball.h"
#import "TempestActor.h"
#import "DeathFromDeep.h"
#import "ActorFactory.h"
#import "PathFollower.h"
#import "NumericValueChangedEvent.h"
#import "PlayfieldController.h"
#import "GameController.h"
#import "GameCoder.h"
#import "Globals.h"

// Game AI settings
const double kActorAiThinkInterval = 2.0;

// Game AI sub-state attribute defaults
const int kDefaultChanceMax = 1000;

const int kDefaultMerchantShipsMin = 2;
const int kDefaultMerchantShipsMax = 4;
const int kDefaultMerchantShipsChance = 0.6f * kDefaultChanceMax;

const int kDefaultPirateShipsMax = 0;
const int kDefaultPirateShipsChance = 0.15f * kDefaultChanceMax;

const int kDefaultNavyShipsMax = 0;
const int kDefaultNavyShipsChance = 0;

const int kDefaultSpecialShipsChance = 0;

// Misc
const int kMaxSharks = 2;
const float kFleetTimeoutDuration = DAY_CYCLE_IN_SEC / 2.0f;

// Playfield data
const float kSpawnAngles[6] = { PI / 2, 0, -PI / 2, PI, -0.75f * PI, PI / 4 };

const int kSeaLaneNorth[3] = { 1, 2, 4 };	// 0
const int kSeaLaneEast[3] = { 0, 3, 4 };	// 1
const int kSeaLaneSouth[2] = { 0, 3 };		// 2
const int kSeaLaneWest[2] = { 1, 2 };		// 3
const int kSeaLaneTown[2] = { 0, 1 };		// 4
const int kSeaLaneCove[1] = { 4 };			// 5
const int kSeaLaneCounts[kSpawnPlanesCount] = { 3, 3, 2, 2, 2, 1 };
const int *kSeaLanes[kSpawnPlanesCount] = { kSeaLaneNorth, kSeaLaneEast, kSeaLaneSouth, kSeaLaneWest, kSeaLaneTown, kSeaLaneCove };

@interface ActorAi ()

// How fast do damage/mutiny penalties scale as the game progress.
@property (nonatomic,readonly) float damageMutinyScaleFactor;

- (void)think:(double)time;
- (void)resetThinkTank;
- (void)resetFleetTimer;
- (void)resetAshPickupTimer;
- (void)advanceFleetTimer:(double)time;
- (void)advanceAshPickupTimer:(double)time;
- (uint)randomAshKey;

- (void)createPlayingField;
- (void)updateAiKnobState;
- (void)setRandomPursuitLocation:(PursuitShip *)ship;
- (void)setRandomPursuitSpawnLocation:(PursuitShip *)ship;
- (PrimeShip *)spawnSilverTrain;
- (PrimeShip *)spawnTreasureFleet;
- (void)spawnSilverTrainEscortShips;
- (void)spawnTreasureFleetEscortShips;
- (EscortShip *)spawnEscortShip:(Destination *)dest;
- (MerchantShip *)spawnMerchantShip:(int)type;
- (NavyShip *)spawnNavyShip;
- (PirateShip *)spawnPirateShip;
- (Shark *)spawnShark;
- (AshPickupActor *)spawnAshPickupActor;

- (PrimeShip *)spawnSilverTrainAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest escorts:(BOOL)escorts;
- (PrimeShip *)spawnTreasureFleetAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest escorts:(BOOL)escorts;
- (EscortShip *)spawnEscortShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest;
- (MerchantShip *)spawnMerchantShip:(NSString *)shipKey x:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest;
- (PirateShip *)spawnPirateShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest;
- (NavyShip *)spawnNavyShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest;
- (Shark *)spawnSharkAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest;
- (OverboardActor *)spawnPersonOverboardAtX:(float32)x y:(float32)y prisoner:(Prisoner *)prisoner;
- (AshPickupActor *)spawnAshPickupActorAtX:(float)x y:(float)y ashKey:(uint)ashKey duration:(float)duration;

- (void)checkinSpawn:(id<PathFollower>)ship;
- (void)checkinShip:(id<PathFollower>)ship;
- (void)checkoutShip:(id<PathFollower>)ship;
- (int)getSpawnPlaneCount:(int)index;
- (Destination *)createRandomDestinationFromPlanes:(NSMutableArray *)planes startIndex:(int)startIndex finishIndex:(int)finishIndex ;
- (void)fillDestination:(Destination *)dest from:(SPPoint *)from to:(SPPoint *)to;
- (BOOL)isTownVacant;
- (BOOL)isTreasureFleetSpawnVacant;
- (BOOL)isSilverTrainDestVacant;
- (BOOL)isSeaLaneAvailableAtIndex:(int)index;
- (int)findAvailableSeaLaneIndex:(int)index maxIndex:(int)maxIndex;
- (Destination *)fetchRandomVacantDestination:(int)spawnPlaneIndexMax destPlaneIndexMax:(int)destPlaneIndexMax;
- (Destination *)fetchRandomDestination:(int)spawnPlaneIndexMax;
- (Destination *)fetchTownSpawnDestination;
- (Destination *)fetchTreasureFleetDestination;
- (Destination *)fetchSilverTrainDestination;

- (void)thinkSpecialShips;
- (void)thinkMerchantShips;
- (void)thinkNavyShips;
- (void)thinkPirateShips;
- (void)thinkSharks;
- (Shark *)findPredatorForPrey:(OverboardActor *)prey;
- (void)onDeathFromDeepDismissed:(SPEvent *)event;
- (ShipActor *)onScreenTarget:(NSMutableSet *)targets;
- (NSMutableSet *)onScreenTargets:(NSMutableSet *)targets;
- (ShipActor *)closestTargetToX:(float)x y:(float)y targets:(NSMutableSet *)targets;
- (BOOL)isVoodooTargetTaken:(ShipActor *)target;
- (void)dockNpcShips:(NSArray *)ships;

// Convenience
- (OverboardActor *)overboardPlayer;
- (NSArray *)allShips;
- (NSArray *)allNpcShips;
- (NSArray *)allPursuitShips;

// Save Game State
- (GCDestination *)gcDestFromDest:(Destination *)dest;
- (Destination *)destFromGcDest:(GCDestination *)gcDest;
- (void)spawnGCActor:(GCActor *)gcActor;
- (void)saveActors:(NSSet *)actors asGCActors:(GCMisc *)misc cannonballs:(NSMutableArray *)cannonballs;

@end


@implementation ActorAi

@synthesize aiKnob = mAiKnob;
@synthesize difficultyFactor = mDifficultyFactor;
@synthesize shipsPaused = mShipsPaused;
@synthesize inFuture = mInFuture;
@synthesize tempests = mTempests;
@synthesize deathFromDeeps = mDeathFromDeeps;
@synthesize fleet = mFleet;
@dynamic isPlayfieldClear,isPlayfieldClearOfNpcShips;

+ (void)setupAiKnob:(AiKnob *)aiKnob {
	aiKnob->merchantShipsMin = kDefaultMerchantShipsMin;
	aiKnob->merchantShipsMax = kDefaultMerchantShipsMax;
	aiKnob->pirateShipsMax = kDefaultPirateShipsMax;
	aiKnob->navyShipsMax = kDefaultNavyShipsMax;
	
	aiKnob->merchantShipsChance = kDefaultMerchantShipsChance;
	aiKnob->pirateShipsChance = kDefaultPirateShipsChance;
	aiKnob->navyShipsChance = kDefaultNavyShipsChance;
	aiKnob->specialShipsChance = kDefaultSpecialShipsChance;
	
	aiKnob->fleetShouldSpawn = NO;
	aiKnob->fleetTimer = kFleetTimeoutDuration;
	
	aiKnob->difficulty = 0;
	aiKnob->difficultyIncrement = 1;
	aiKnob->difficultyFactor = 1.01f; // To ensure (int) casts don't go to zero.
	aiKnob->aiModifier = 1.0f;
	aiKnob->stateCeiling = 5;
	aiKnob->state = 0;
}

- (id)initWithController:(PlayfieldController *)scene {
	if (self = [super init]) {
		mLocked = NO;
        mSuspendedMode = NO;
		mShipsPaused = NO;
		mInFuture = NO;
		//mName = [NSStringFromClass([self class]) copy];
		mScene = scene;
		mDifficultyFactor = 1.0f;
		mPirateSpawnTimer = 0;
		mNavySpawnTimer = 0;
        mCamouflageTimer = 0.0;
        mAshPickupSpawnTimer = RANDOM_INT(0.33f * DAY_CYCLE_IN_SEC, 0.95f * DAY_CYCLE_IN_SEC);
        mAshPickupQueue = nil;
		mAiKnob = 0;
		mRandomInt = 0;
        mFleetID = 1;
		mSpawnPlanes = nil;	
		mVacantSpawnPlanes = nil;
		mOccupiedSpawnPlanes = nil;
		[self createPlayingField];
		mFleet = nil;
		mTempests = [[NSMutableSet alloc] init];
		mDeathFromDeeps = [[NSMutableSet alloc] init];
		mMerchantShips = [[NSMutableSet alloc] init];
		mNavyShips = [[NSMutableSet alloc] init];
		mPirateShips = [[NSMutableSet alloc] init];
		mPlayerShips = [[NSMutableSet alloc] init];
		mEscortShips = [[NSMutableSet alloc] init];
		mSharks = [[NSMutableSet alloc] init];
		mPeople = [[NSMutableSet alloc] init];
        mAshPickups = [[NSMutableSet alloc] init];
		mShipTypes = [[ShipFactory shipYard].allNpcShipTypes retain];
        
        [self resetThinkTank];
        mThinking = NO;
	}
	return self;
}

- (id)init {
	return [self initWithController:nil];
}

- (float)damageMutinyScaleFactor {
	// Slowly ramps up so that other difficulty factors play the major role until they're maxed out, then this factor takes over.
	return 1.0f; //MAX(1.0f, 1.0f + mAiKnob->state / (300.0f - MIN(200.0f, 2 * mAiKnob->state)));
}

- (void)setDifficultyFactor:(float)value {
	mDifficultyFactor = MAX(1.0f,value);
}

- (void)setAiKnob:(AiKnob *)knob {
	mAiKnob = knob;
	
	if (mAiKnob)
		[self updateAiKnobState];
}

- (BOOL)isPlayfieldClearOfNpcShips {
    NSArray *npcShips = [self allNpcShips];
    return (npcShips.count == 0);
}

- (BOOL)isPlayfieldClear {
    return (self.isPlayfieldClearOfNpcShips && mPeople.count == 0);
}

- (void)updateAiKnobState {
	if (mAiKnob == 0 || mAiKnob->difficulty < mAiKnob->stateCeiling)
		return;
	float oldAiModifier = mAiKnob->aiModifier;
	
	mAiKnob->difficulty -= mAiKnob->stateCeiling;
	++mAiKnob->state;
	
	switch (mAiKnob->state) {
		case 0:
			break;
		case 1:
			mAiKnob->pirateShipsChance += 0.025f * kDefaultChanceMax; // 0.15->0.175
			mAiKnob->stateCeiling = 25;
			break;
		case 2:
			mAiKnob->pirateShipsChance += 0.025f * kDefaultChanceMax; // 0.175->0.2
			++mAiKnob->navyShipsMax; // 0->1
			mAiKnob->navyShipsChance += 0.15f * kDefaultChanceMax; // 0->0.15
			mAiKnob->stateCeiling = 20;
			break;
		case 3:
			mAiKnob->navyShipsChance += 0.1f * kDefaultChanceMax; // 0.15->0.25
			mAiKnob->specialShipsChance = kDefaultChanceMax; // 0->1.0
			mAiKnob->stateCeiling = 20;
			break;
		case 4:
			++mAiKnob->merchantShipsMin; // 2->3
			++mAiKnob->merchantShipsMax; // 4->5
			mAiKnob->stateCeiling = 20;
			break;
		case 5:
		case 6:
		case 7:
		case 8:
			mAiKnob->aiModifier += 0.05f; // 1.00->1.20
			mAiKnob->stateCeiling = 20;
			break;
        case 9:
            ++mAiKnob->merchantShipsMin; // 3->4
			++mAiKnob->merchantShipsMax; // 5->6
            ++mAiKnob->pirateShipsMax; // 0->1
            mAiKnob->aiModifier += 0.05f; // 1.20->1.25
			mAiKnob->stateCeiling = 20;
            break;
		case 10:
			mAiKnob->pirateShipsChance += 0.05f * kDefaultChanceMax; // 0.2->0.25
			mAiKnob->stateCeiling = 25;
			break;
		case 11:
            mAiKnob->aiModifier += 0.05f; // 1.25->1.3
			mAiKnob->stateCeiling = 25;
            break;
		case 12:
            mAiKnob->aiModifier += 0.05f; // 1.3->1.35
            mAiKnob->stateCeiling = 25;
            break;
		case 13:
			++mAiKnob->merchantShipsMax; // 6->7
            ++mAiKnob->navyShipsMax; // 1->2
            mAiKnob->aiModifier += 0.05f; // 1.35->1.40
			mAiKnob->stateCeiling = 25;
            break;
		case 14:
			mAiKnob->aiModifier += 0.05f; // 1.4->1.45
			mAiKnob->stateCeiling = 25;
			break;
		case 15:
			mAiKnob->stateCeiling = 25;
			break;
		case 16:
			mAiKnob->pirateShipsChance += 0.05f * kDefaultChanceMax; // 0.25->0.3
			mAiKnob->navyShipsChance += 0.1f * kDefaultChanceMax; // 0.25->0.35
			mAiKnob->stateCeiling = 25;
			break;
		case 17:
            ++mAiKnob->merchantShipsMin; // 4->5
            ++mAiKnob->merchantShipsMax; // 7->8
            mAiKnob->aiModifier += 0.05f; // 1.45->1.50
			mAiKnob->stateCeiling = 25;
            break;
		case 18:
            ++mAiKnob->pirateShipsMax; // 1->2
            ++mAiKnob->navyShipsMax; // 2->3
            mAiKnob->aiModifier += 0.05f; // 1.50->1.55
			mAiKnob->stateCeiling = 25;
            break;
		case 19:
			mAiKnob->aiModifier += 0.05f; // 1.55->1.60
			mAiKnob->stateCeiling = 25;
			break;
		case 20:
			mAiKnob->pirateShipsChance += 0.05f * kDefaultChanceMax; // 0.3->0.35
			mAiKnob->navyShipsChance += 0.05f * kDefaultChanceMax; // 0.35->0.4
			mAiKnob->stateCeiling = 15;
			break;
        case 21:
            ++mAiKnob->merchantShipsMin; // 5->6
            ++mAiKnob->merchantShipsMax; // 8->9
            // Allow fall-through
        case 22:
        case 23:
        case 24:
        case 25:
            mAiKnob->aiModifier += 0.05f; // 1.60->1.85
			mAiKnob->stateCeiling = 25;
            break;
        case 26:
            ++mAiKnob->merchantShipsMin; // 6->7
            ++mAiKnob->merchantShipsMax; // 9->10
            ++mAiKnob->pirateShipsMax; // 2->3
            mAiKnob->stateCeiling = 15;
            break;
		default:
			mAiKnob->aiModifier += 0.07f; // 1.85->...
			mAiKnob->stateCeiling = 25;
			break;
	}
    
    // Increase aiModifier to counter potential lag on older devices making it too easy
    if ([RESM isHighPerformance] == NO) {
        if (mAiKnob->state > 5)
            mAiKnob->aiModifier += 0.015f;
        if (mAiKnob->state > 20 && mAiKnob->state < 24) {
            mAiKnob->pirateShipsChance += 0.05f * kDefaultChanceMax; // 0.35->0.5
            mAiKnob->navyShipsChance += 0.05f * kDefaultChanceMax; // 0.4->0.55
        }
    }

	mAiKnob->stateCeiling *= 1.0f / mDifficultyFactor;
	
	//NSLog(@"AiState: %d Ceiling: %d", mAiKnob->state, mAiKnob->stateCeiling);
	
	[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_AI_STATE_VALUE_CHANGED value:[NSNumber numberWithInt:mAiKnob->state] bubbles:NO];
	
	// Prevent inifnite loops and absurd values
	if (mAiKnob->stateCeiling <= 0)
		mAiKnob->stateCeiling = 15;
	else if (mAiKnob->stateCeiling > 50)
		mAiKnob->stateCeiling = 50;
	if (mAiKnob->difficulty < 0)
		mAiKnob->difficulty = 0;
	else if (mAiKnob->difficulty > 50)
		mAiKnob->difficulty = 50;
	
	if (mAiKnob->difficulty >= mAiKnob->stateCeiling)
		[self updateAiKnobState];
	else if (oldAiModifier != mAiKnob->aiModifier)
		[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_AI_KNOB_VALUE_CHANGED value:[NSNumber numberWithFloat:mAiKnob->aiModifier] bubbles:NO];
    
    /*
    //For testing
    if (mAiKnob->state < 35) {
        mAiKnob->difficulty = mAiKnob->stateCeiling;
        [self updateAiKnobState];
    }
     */
}

- (void)enableSuspendedMode:(BOOL)enable {
    [self stopThinking];
    
    if (enable == NO)
        [self think];
    mSuspendedMode = enable;
}

- (void)turnAiKnob {
	if (mAiKnob && mInFuture == NO && GCTRL.thisTurn.isGameOver == NO) {
		mAiKnob->difficulty += (int)(mAiKnob->difficultyIncrement * mAiKnob->difficultyFactor);
		[self updateAiKnobState];
	}
}

- (void)resetThinkTank {
    for (int i = 0; i < THINK_TANK_COUNT-1; ++i)
        mThinkTank[i] = 0.3f + i*0.3f;
    mThinkTank[THINK_CYCLE] = kActorAiThinkInterval;
}

- (void)think {
    mThinking = YES;
}

- (void)think:(double)time {
    if (mThinking == NO)
        return;
    
    GameController *gc = GCTRL;
    
    for (int i = 0; i < THINK_TANK_COUNT; ++i) {
        mThinkTank[i] -= time;
        
        if (mThinkTank[i] <= 0) {
            mThinkTank[i] += kActorAiThinkInterval;
            
            if (gc.thisTurn.adventureState != AdvStateNormal && i != THINK_SHARK)
                continue;
            
            switch (i) {
                case THINK_SPECIAL:
                    [self thinkSpecialShips];
                    break;
                case THINK_NAVY:
                    [self thinkNavyShips];
                    break;
                case THINK_PIRATE:
                    [self thinkPirateShips];
                    break;
                case THINK_MERCHANT:
                    [self thinkMerchantShips];
                    break;
                case THINK_SHARK:
                    [self thinkSharks];
                    break;
                case THINK_CYCLE:
                    [self turnAiKnob];
                    mPirateSpawnTimer += kActorAiThinkInterval;
                    mNavySpawnTimer += kActorAiThinkInterval;
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)stopThinking {
    mThinking = NO;
	//[mScene.juggler removeTweensWithTarget:self];
}

- (void)resetFleetTimer {
	if (mAiKnob) {
		mAiKnob->fleetShouldSpawn = NO;
		mAiKnob->fleetTimer = kFleetTimeoutDuration;
	}
}

- (void)resetAshPickupTimer {
    mAshPickupSpawnTimer = RANDOM_INT(0.33f * DAY_CYCLE_IN_SEC, 0.95f * DAY_CYCLE_IN_SEC);
}

- (void)advanceFleetTimer:(double)time {
	if (mAiKnob && mAiKnob->fleetShouldSpawn == NO) {
		mAiKnob->fleetTimer -= time;
		
		if (mAiKnob->fleetTimer <= 0)
			mAiKnob->fleetShouldSpawn = YES;
	}
}

- (void)advanceAshPickupTimer:(double)time {
    mAshPickupSpawnTimer -= time;
    
    if (mAshPickupSpawnTimer <= 0) {
        mAshPickupSpawnTimer = MAX(0.5f * DAY_CYCLE_IN_SEC,GCTRL.timeKeeper.timeRemainingToday + RANDOM_INT(0.05f * DAY_CYCLE_IN_SEC, 0.95f * DAY_CYCLE_IN_SEC));
        
        if (GCTRL.thisTurn.isGameOver == NO && mScene.raceEnabled == NO)
            [self spawnAshPickupActor];
    }
}

- (void)advanceTime:(double)time {
    if (mSuspendedMode)
        return;
    mRandomInt = RANDOM_INT(0,kDefaultChanceMax);
	[self advanceFleetTimer:time];
    [self advanceAshPickupTimer:time];
    [self think:time];
    
    if (mCamouflageTimer > 0.0) {
        mCamouflageTimer -= time;
        
        if (mCamouflageTimer <= 0.0)
            [self deactivateCamouflage];
    }
}

- (uint)randomAshKey {
#if 1
    if (mAshPickupQueue == nil) {
        mAshPickupQueue = [[NSMutableArray alloc] initWithArray:[Ash procableAshKeys]];
        
        // Randomize
        int count = mAshPickupQueue.count;
        
        for (int i = 0; i < count; ++i) {
            int randIndex = RANDOM_INT(0, count-1);
            NSNumber *key = (NSNumber *)[[[mAshPickupQueue objectAtIndex:randIndex] retain] autorelease];
            [mAshPickupQueue removeObjectAtIndex:randIndex];
            [mAshPickupQueue insertObject:key atIndex:0];
        }
        
        // Move objectives ash to the front of the queue
        uint requiredAshType = mScene.objectivesManager.requiredAshType;
        
        if (requiredAshType != 0) {
            int index = 0;
            
            for (NSNumber *key in mAshPickupQueue) {
                if ([key unsignedIntValue] == requiredAshType)
                    break;
                ++index;
            }
            
            if (index > 0 && index < mAshPickupQueue.count) {
                NSNumber *key = (NSNumber *)[[[mAshPickupQueue objectAtIndex:index] retain] autorelease];
                [mAshPickupQueue removeObjectAtIndex:index];
                [mAshPickupQueue insertObject:key atIndex:0];
            }
        }
    }
    
    uint ashKey = ASH_DEFAULT;
    
    if (mAshPickupQueue && mAshPickupQueue.count > 0) {
        NSNumber *key = (NSNumber *)[[[mAshPickupQueue objectAtIndex:0] retain] autorelease];
        
        if (mAshPickupQueue.count > 1) {
            [mAshPickupQueue removeObjectAtIndex:0];
            [mAshPickupQueue insertObject:key atIndex:RANDOM_INT(1, mAshPickupQueue.count)];
        }
            
        ashKey = [key unsignedIntValue];
    }
    
    return ashKey;
#else
    if (mAshPickupQueue == nil) {
        mAshPickupQueue = [[NSMutableArray alloc] initWithObjects:
                           [NSNumber numberWithUnsignedInt:ASH_NOXIOUS],
                           [NSNumber numberWithUnsignedInt:ASH_SAVAGE],
                           [NSNumber numberWithUnsignedInt:ASH_MOLTEN],
                           [NSNumber numberWithUnsignedInt:ASH_ABYSSAL],
                           nil];
    }
    
    uint ashKey = [(NSNumber *)[mAshPickupQueue objectAtIndex:ashIndex] unsignedIntValue];
    ++ashIndex;
    
    if (ashIndex >= mAshPickupQueue.count)
        ashIndex = 0;
    
    return ashKey;
#endif
}

- (b2Vec2)randomPickupLocation {
    PlayerShip *playerShip = [mPlayerShips anyObject];
    b2Vec2 pickupLoc;
    
    if (playerShip == nil)
        return pickupLoc;
	b2Vec2 playerLoc = b2Vec2(playerShip.b2x,playerShip.b2y);
	
	
	// Give up after 10 attempts and just spawn the treasure wherever
	for (int i = 0; i < 10; ++i) {
		pickupLoc = b2Vec2(RANDOM_INT(8, RITMFX(40)), RANDOM_INT(12, RITMFY(30)));
		
		b2Vec2 dist = (playerLoc - pickupLoc);
		
		if (dist.LengthSquared() > (P2M(40) * P2M(40))) {
			//NSLog(@"Valid random pickup spawn location found.");
			break;
		}
	}
	
	return pickupLoc;
}

- (void)thinkSpecialShips {
	if (mShipsPaused  == YES || mInFuture == YES || mAiKnob == 0)
		return;
	
	if (mFleet == nil) {
		if (mAiKnob->fleetShouldSpawn && mRandomInt < mAiKnob->specialShipsChance) {
            float shipChance = 0.5f;
            ShipActor *ship = nil;
            
            if (mScene.objectivesManager.requiredNpcShipType == SHIP_TYPE_SILVER_TRAIN)
                ship = [self spawnSilverTrain];
            else if (mScene.objectivesManager.requiredNpcShipType == SHIP_TYPE_TREASURE_FLEET)
                ship = [self spawnTreasureFleet];
            else if (mRandomInt < shipChance * mAiKnob->specialShipsChance)
                ship = [self spawnSilverTrain];
            else
                ship = [self spawnTreasureFleet];
            
            if (ship) {
                if ([ship isKindOfClass:[SilverTrain class]])
                    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SILVER_TRAIN_SPAWNED]];
                else
                    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_TREASURE_FLEET_SPAWNED]];
            }
			
			if (mFleet)
				[self resetFleetTimer];
		}
	}
}

- (void)thinkMerchantShips {
	if (mShipsPaused == YES || mAiKnob == 0)
		return;
	
	if (mMerchantShips.count >= mAiKnob->merchantShipsMax)
		return;
	if (mRandomInt < mAiKnob->merchantShipsChance || [mMerchantShips count] < mAiKnob->merchantShipsMin) {
		// Chance to spawn different types of merchant ships
		int merchantType = mRandomInt, breakEarly = MIN(2,mAiKnob->merchantShipsMax - mMerchantShips.count);
		int typeIncrement = mAiKnob->merchantShipsChance / 3;
		
		[self spawnMerchantShip:merchantType];
		
		while (breakEarly > 0 || [mMerchantShips count] < mAiKnob->merchantShipsMin) {
			merchantType += typeIncrement;
			
			if (merchantType > mAiKnob->merchantShipsChance)
				merchantType -= mAiKnob->merchantShipsChance;
			if ([self spawnMerchantShip:merchantType] == nil)
				break; // No free spawn places
			--breakEarly;
		}
	}
}

- (void)thinkNavyShips {
	PlayerShip *ship = [mPlayerShips anyObject];
	
	if (GCTRL.thisTurn.isGameOver || mAiKnob == 0 || ship == nil || ship.motorBoating || mShipsPaused  || mInFuture || mNavyShips.count >= mAiKnob->navyShipsMax)
		return;
	if (mRandomInt < mAiKnob->navyShipsChance || mNavySpawnTimer > 45) {
		if ([self spawnNavyShip])
			mNavySpawnTimer = 0;
	}
}

- (void)thinkPirateShips {
	if (GCTRL.thisTurn.isGameOver || mAiKnob == 0 || mShipsPaused == YES || mInFuture == YES || mPirateShips.count >= mAiKnob->pirateShipsMax)
		return;
	if (mRandomInt < mAiKnob->pirateShipsChance || mPirateSpawnTimer > 45) {
		if ([self spawnPirateShip])
			mPirateSpawnTimer = 0;
	}
}

- (void)thinkSharks {
	for (OverboardActor *person in mPeople) {
		if (person.predator == nil && person.isPreparingForNewGame == NO) {
			Shark *shark = [self findPredatorForPrey:person];
			
			if (shark == nil) {
				if (mPeople.count >= 3*mSharks.count)
					[self spawnShark];
				break;
			}
		}
	}
	
	if ([mSharks count] < kMaxSharks && mRandomInt < kDefaultChanceMax)
		[self spawnShark];
}

- (Shark *)findPredatorForPrey:(OverboardActor *)prey {
	Shark *shark = nil;
	
	if (prey.edible == YES) {
		for (Shark *shark in mSharks) {
			if (shark.prey == nil && shark.markedForRemoval == NO) {
				shark.prey = prey;
				prey.predator = shark;
				break;
			}
		}
	}
	return shark;
}

- (void)dockNpcShips:(NSArray *)ships {
	for (int i = ships.count - 1; i >= 0; --i) {
		NpcShip *ship = (NpcShip *)[ships objectAtIndex:i];
		[ship dock];
	}
}

// FIXME: Does not dock escort ships when mFleet is null. No major side-effects, so leave as is for now.
- (void)dockAllShips {
	[mFleet.leftEscort dock];
	[mFleet.rightEscort dock];
	[mFleet dock];
	
	NSArray *array = [mMerchantShips allObjects];
	[self dockNpcShips:array];
	
	array = [mNavyShips allObjects];
	[self dockNpcShips:array];
	
	array = [mPirateShips allObjects];
	[self dockNpcShips:array];
}

- (void)prepareForNewGame {
    NSSet *dfdCopy = [NSSet setWithSet:mDeathFromDeeps];
    
    for (DeathFromDeep *dfd in dfdCopy)
        [dfd despawn];
    
    // Force reset of ash queue
    [mAshPickupQueue release]; mAshPickupQueue = nil;
    
    // Reset State
    self.inFuture = NO;
    self.shipsPaused = NO;
    
    // Reset Timers
    mPirateSpawnTimer = 0.0;
    mNavySpawnTimer = 0.0;
    mCamouflageTimer = 0.0;
    [self resetFleetTimer];
    [self resetAshPickupTimer];
    [self resetThinkTank];
    [self think];
}

- (void)prepareForGameOver {
    NSArray *pursuitShips = [self allPursuitShips];
    
    for (PursuitShip *pursuitShip in pursuitShips)
        [pursuitShip endPursuit];
}

- (void)prepareForMontyMutiny {
    NSArray *pursuitShips = [self allPursuitShips];
    
    for (PursuitShip *pursuitShip in pursuitShips)
        [pursuitShip endPursuit];
}

- (void)sinkAllShipsWithDeathBitmap:(uint)deathBitmap {
	if (mFleet.docking == NO) {
		mFleet.deathBitmap = deathBitmap;
		[mFleet sink];
	}
	
	NSArray *array = [mEscortShips allObjects];
	
	for (int i = array.count - 1; i >= 0; --i) {
		NpcShip *ship = (NpcShip *)[array objectAtIndex:i];
		
		if (ship.docking == NO) {
			ship.deathBitmap = deathBitmap;
			[ship sink];
		}
	}
	
	array = [mMerchantShips allObjects];
	
	for (int i = array.count - 1; i >= 0; --i) {
		NpcShip *ship = (NpcShip *)[array objectAtIndex:i];
		
		if (ship.docking == NO) {
			ship.deathBitmap = deathBitmap;
			[ship sink];
		}
	}

	array = [mNavyShips allObjects];
	
	for (int i = array.count - 1; i >= 0; --i) {
		NpcShip *ship = (NpcShip *)[array objectAtIndex:i];
		
		if (ship.docking == NO) {
			ship.deathBitmap = deathBitmap;
			[ship sink];
		}
	}
		
	array = [mPirateShips allObjects];
	
	for (int i = array.count - 1; i >= 0; --i) {
		NpcShip *ship = (NpcShip *)[array objectAtIndex:i];
		
		if (ship.docking == NO) {
			ship.deathBitmap = deathBitmap;
			[ship sink];
		}
	}
	
	array = [mPeople allObjects];
	
	for (int i = array.count - 1; i >= 0; --i) {
		OverboardActor *person = (OverboardActor *)[array objectAtIndex:i];
        person.deathBitmap = deathBitmap;
		[person environmentalDeath];
	}
}

- (ShipActor*)requestNewMerchantEnemy:(ShipActor *)ship {
	NSMutableSet *enemies = [NSMutableSet setWithSet:mMerchantShips];
	return [self closestTargetToX:ship.x y:ship.y targets:enemies];
}

- (ShipActor *)onScreenTarget:(NSMutableSet *)targets {
	ShipActor *target = nil;
	SPRectangle *rect = [[SPRectangle alloc] initWithX:15 y:15 width:RESW-30 height:RESH-45]; // 45 to give 15 clearance above ship deck
	
	for (ShipActor *ship in targets) {
		if (ship.markedForRemoval == NO && [rect containsX:ship.x y:ship.y]) {
			if ([ship isKindOfClass:[NpcShip class]]) {
				NpcShip *npcShip = (NpcShip *)ship;
				
				if (npcShip.docking == YES)
					continue;
			}
			target = ship;
			break;
		}
	}
	[rect release];
	return target;
}

- (NSMutableSet *)onScreenTargets:(NSMutableSet *)targets {
	NSMutableSet *ships = [NSMutableSet setWithCapacity:targets.count];
	SPRectangle *rect = [[SPRectangle alloc] initWithX:15 y:15 width:RESW-30 height:RESH-45]; // 45 to give 15 clearance above ship deck
	
	for (ShipActor *ship in targets) {
		if (ship.markedForRemoval == NO && [rect containsX:ship.x y:ship.y]) {
			if ([ship isKindOfClass:[NpcShip class]]) {
				NpcShip *npcShip = (NpcShip *)ship;
				
				if (npcShip.docking == YES)
					continue;
			}
			[ships addObject:ship];
		}
	}
	[rect release];
	return ships;
}

- (ShipActor *)closestTargetToX:(float)x y:(float)y targets:(NSMutableSet *)targets {
	float xDist, yDist, closest = 99999999.9, distSq;
	ShipActor *target = nil;
	
	for (ShipActor *ship in targets) {
		if (ship.markedForRemoval)
			continue;
		xDist = x - ship.x;
		yDist = y - ship.y;
		distSq = [Globals vecLengthSquaredX:xDist y:yDist];
		
		if (closest > distSq) {
			closest = distSq;
			target = ship;
		}
	}
	return target;
}

- (BOOL)isVoodooTargetTaken:(ShipActor *)target {
    if (target.isPreparingForNewGame)
        return YES;
    
	BOOL result = NO;
	
	if ([target isKindOfClass:[NpcShip class]]) {
		NpcShip *npcShip = (NpcShip *)target;
		result = npcShip.inWhirlpoolVortex || npcShip.inDeathsHands;
	}
	
	if (result == NO) {
		for (DeathFromDeep *dfd in mDeathFromDeeps) {
			if (dfd.target == target) {
				result = YES;
				break;
			}
		}
	}
	
	if (result == NO) {
		for (TempestActor *tempest in mTempests) {
			if (tempest.target == target) {
				result = YES;
				break;
			}
		}
	}
	return result;
}

- (ShipActor *)requestNewVoodooTarget {
    ShipActor *target = nil;
    
    if (target == nil || [self isVoodooTargetTaken:target])
        target = [self onScreenTarget:mPirateShips];
	if (target == nil || [self isVoodooTargetTaken:target])
		target = [self onScreenTarget:mNavyShips];
	if ((target == nil || [self isVoodooTargetTaken:target]) && mFleet != nil)
		target = [self onScreenTarget:[NSMutableSet setWithObject:mFleet]];
	if (target == nil || [self isVoodooTargetTaken:target])
		target = [self onScreenTarget:mEscortShips];
	if (target == nil || [self isVoodooTargetTaken:target])
		target = [self onScreenTarget:mMerchantShips];
	if (target && [self isVoodooTargetTaken:target])
		target = nil;
	return target;
}

- (ShipActor *)requestClosestTarget:(Actor *)actor {
	ShipActor *target = nil;
	NSMutableSet *closestTargets = nil, *availableTargets = [NSMutableSet set];
	NSMutableSet *targets = [NSMutableSet set], *fleetSet = [NSMutableSet set];
	
	if (mFleet)
		[fleetSet addObject:mFleet];
	
	NSSet *allTargets = [NSSet setWithObjects:mMerchantShips,mPirateShips,mNavyShips,mEscortShips,fleetSet,nil];
	
	for (NSMutableSet *set in allTargets) {
		[availableTargets removeAllObjects];
		closestTargets = [self onScreenTargets:set];
		
		for (ShipActor *ship in closestTargets) {
			if ([self isVoodooTargetTaken:ship] == NO)
				[availableTargets addObject:ship];
		}
		
		target = [self closestTargetToX:actor.x y:actor.y targets:availableTargets];
		
		if (target)
			[targets addObject:target];
	}
	
	target = [self closestTargetToX:actor.x y:actor.y targets:targets];
	return target;
}

- (void)setRandomPursuitLocation:(PursuitShip *)ship {
	[ship.destination setDestX:P2MX(RANDOM_INT(104.0f, RITMFX(400.0f)))];
	[ship.destination setDestY:P2MY(RANDOM_INT(72.0f, RITMFY(224.0f)))];
	
	//NSLog(@"Pursuit Ship Random DestX: %f DestY: %f", M2PX(ship.destination.dest.x), M2PY(ship.destination.dest.y));
}

- (void)setRandomPursuitSpawnLocation:(PursuitShip *)ship {
    [ship.destination setDestX:P2MX(RANDOM_INT(128.0f, RITMFX(352.0f)))];
	[ship.destination setDestY:P2MY(RANDOM_INT(90.0f, RITMFY(200.0f)))];
}

- (int)getSpawnPlaneCount:(int)index {
	int count = 0;
	
	switch (index) {
		case kPlaneIdNorth: count = 4; break;
		case kPlaneIdEast: count = 4; break;
		case kPlaneIdSouth: count = 5; break;
		case kPlaneIdWest: count = 5; break;
		default: NSLog(@"Invalid spawn plane Id in ActorAi.getSpawnPlaneCount:"); break;
	}
	return count;
}

- (void)checkinSpawn:(id<PathFollower>)ship {
	if (!ship.destination.isExclusive)
		return;
	NSMutableArray *startVacant = nil, *startOccupied = nil;
	
	if (ship.destination.seaLaneA != nil) {
		startVacant = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:ship.destination.start];
		startOccupied = (NSMutableArray *)[mOccupiedSpawnPlanes objectAtIndex:ship.destination.start];
		[startVacant addObject:ship.destination.seaLaneA];
		[startOccupied removeObject:ship.destination.seaLaneA];
		ship.destination.seaLaneA = nil;
	}
}

- (void)checkinShip:(id<PathFollower>)ship {
	if (!ship.destination.isExclusive)
		return;
	NSMutableArray *startVacant = nil, *finishVacant = nil, *startOccupied = nil, *finishOccupied = nil;
	
	if (ship.destination.seaLaneA) {
		startVacant = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:ship.destination.start];
		startOccupied = (NSMutableArray *)[mOccupiedSpawnPlanes objectAtIndex:ship.destination.start];
		[startVacant addObject:ship.destination.seaLaneA];
		[startOccupied removeObject:ship.destination.seaLaneA];
	}
	
	if (ship.destination.seaLaneB) {
		finishVacant = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:ship.destination.finish];
		finishOccupied = (NSMutableArray *)[mOccupiedSpawnPlanes objectAtIndex:ship.destination.finish];
		[finishVacant addObject:ship.destination.seaLaneB];
		[finishOccupied removeObject:ship.destination.seaLaneB];
	}
}

// Note: It's possible for Escort Ships to be heading to town but not have town checked out. They will not collide with
// other ships coming from town, however, so we ignore it out of convenience.
- (void)checkoutShip:(id<PathFollower>)ship {
	// Town has an intermediate point through which ships must travel. This edge case is hacked in here.
	if ((ship.destination.seaLaneA == mTownDock || ship.destination.seaLaneB == mTownDock) && ship.destination.finishIsDest == NO)
		ship.destination.seaLaneC = mTownEntrance; // Mark as edge case. This also sets the current destination.dest to seaLaneC!

	if (!ship.destination.isExclusive)
		return;
	NSMutableArray *startVacant = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:ship.destination.start];
	NSMutableArray *finishVacant = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:ship.destination.finish];
	NSMutableArray *startOccupied = (NSMutableArray *)[mOccupiedSpawnPlanes objectAtIndex:ship.destination.start];
	NSMutableArray *finishOccupied = (NSMutableArray *)[mOccupiedSpawnPlanes objectAtIndex:ship.destination.finish];

	if (ship.destination.seaLaneA) {
		[startOccupied addObject:ship.destination.seaLaneA];
		[startVacant removeObject:ship.destination.seaLaneA];
	}
	
	if (ship.destination.seaLaneB) {
		[finishOccupied addObject:ship.destination.seaLaneB];
		[finishVacant removeObject:ship.destination.seaLaneB];
	}
	
	for (NSMutableArray	*spawnPlane in mSpawnPlanes)
		assert(spawnPlane.count > 0);
}

- (BOOL)isSeaLaneAvailableAtIndex:(int)index {
	BOOL result = NO;
	
	if (index < mVacantSpawnPlanes.count) {
		NSMutableArray *spawnPlane = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:index];
		result = (spawnPlane.count > 0);
	}
	return result;
}

// Based on kSeaLanes[index], this method returns the index of an available sealane destination.
- (int)findAvailableSeaLaneIndex:(int)index maxIndex:(int)maxIndex {
	int availableIndex = -1, count = kSeaLaneCounts[index], seaLaneIndex;
	const int *seaLane  = kSeaLanes[index];
	int rnd = RANDOM_INT(0, count - 1);
	
	for (int i = 0; i < count; ++i) {
		seaLaneIndex = seaLane[rnd];
		
		if (seaLaneIndex <= maxIndex) {
			if ([self isSeaLaneAvailableAtIndex:seaLaneIndex]) {
				availableIndex = seaLaneIndex;
				break;
			}
		}
		
		if (++rnd == count)
			rnd = 0;
	}
	return availableIndex;
}

- (Destination *)createRandomDestinationFromPlanes:(NSMutableArray *)planes startIndex:(int)startIndex finishIndex:(int)finishIndex {
	NSMutableArray *startPlane = (NSMutableArray *)[planes objectAtIndex:startIndex];
	NSMutableArray *finishPlane = (NSMutableArray *)[planes objectAtIndex:finishIndex];
	SPPoint *fromPoint = [startPlane objectAtIndex:RANDOM_INT(0, startPlane.count - 1)];
	SPPoint *toPoint = [finishPlane objectAtIndex:RANDOM_INT(0, finishPlane.count - 1)];
	Destination *dest = [[Destination alloc] init];
	dest.seaLaneA = fromPoint;
	dest.seaLaneB = toPoint;
	dest.start = startIndex;
	dest.finish = finishIndex;
	dest.spawnPlaneIndex = dest.start;
	return [dest autorelease];
}

- (void)fillDestination:(Destination *)dest from:(SPPoint *)from to:(SPPoint *)to {
	dest.seaLaneA = from;
	dest.seaLaneB = to;
}

- (Destination *)fetchRandomVacantDestination:(int)spawnPlaneIndexMax destPlaneIndexMax:(int)destPlaneIndexMax {
	int limit = MIN(spawnPlaneIndexMax,mVacantSpawnPlanes.count-1);
	int i = 0, count = 0, spawnPlaneIndexes[limit+1];
	NSMutableArray *spawnPlane = nil;
	Destination *dest = nil;
	
	// Collect spawn plane indexes from spawn planes with vacant locations into spawnPlaneIndexes
	for (i = 0; i <= limit; ++i) {
		spawnPlane = (NSMutableArray *)[mVacantSpawnPlanes objectAtIndex:i];
		
		if (spawnPlane.count > 0)
			spawnPlaneIndexes[count++] = i;
	}
	
	if (count > 0) {
		int seaLaneIndex = -1;
		int rnd = RANDOM_INT(0, count - 1);
		
		for (i = 0; i < count - 1; ++i) { // "< count - 1" because sealanes go both ways. Therefore an available route MUST be found before the final iteration.
			seaLaneIndex = [self findAvailableSeaLaneIndex:spawnPlaneIndexes[rnd] maxIndex:destPlaneIndexMax];
			
			if (seaLaneIndex != -1)
				break;
			if (++rnd == count)
				rnd = 0;
		}
		
		if (seaLaneIndex != -1) // Travelling from startIndex to finishIndex (finish index found from an valid and available destination in kSeaLanes.
			dest = [self createRandomDestinationFromPlanes:mVacantSpawnPlanes startIndex:spawnPlaneIndexes[rnd] finishIndex:seaLaneIndex];
	}
	return dest;
}

- (Destination *)fetchRandomDestination:(int)spawnPlaneIndexMax {
	int rndStartPlane, rndFinishPlane, limit = MIN(spawnPlaneIndexMax, mSpawnPlanes.count - 1);
	rndStartPlane = RANDOM_INT(0, limit);
	assert(limit > 0); // Prevent possible infinite loop
	
	do {
		rndFinishPlane = RANDOM_INT(0, limit);
	} while (rndFinishPlane == rndStartPlane);
	
	return [self createRandomDestinationFromPlanes:mSpawnPlanes startIndex:rndStartPlane finishIndex:rndFinishPlane];
}

- (BOOL)isTownVacant {
	NSMutableArray *spawnPlane = [mVacantSpawnPlanes objectAtIndex:kPlaneIdTown];
	return (spawnPlane.count > 0);
}

- (BOOL)isTreasureFleetSpawnVacant {
	NSMutableArray *spawnPlane = [mVacantSpawnPlanes objectAtIndex:kPlaneIdNorth];
	return ([spawnPlane containsObject:mTreasureFleetSpawn]);
}

- (BOOL)isSilverTrainDestVacant {
	NSMutableArray *spawnPlane = [mVacantSpawnPlanes objectAtIndex:kPlaneIdNorth];
	return ([spawnPlane containsObject:mSilverTrainDest]);
}

- (Destination *)fetchTownSpawnDestination {
	Destination *dest = nil;
	
	if ([self isTownVacant]) {
		int seaLaneIndex = [self findAvailableSeaLaneIndex:kPlaneIdTown maxIndex:kPlaneIdEast];
		
		if (seaLaneIndex != -1)
			dest = [self createRandomDestinationFromPlanes:mVacantSpawnPlanes startIndex:kPlaneIdTown finishIndex:seaLaneIndex];
	}
	return dest;
}

- (Destination *)fetchTreasureFleetDestination {
	Destination *dest = nil;
	
	if ([self isTownVacant] && [self isTreasureFleetSpawnVacant]) {
		dest = [[Destination alloc] init];
		dest.start = kPlaneIdNorth;
		dest.finish = kPlaneIdTown;
		dest.spawnPlaneIndex = dest.start;
		[self fillDestination:dest from:mTreasureFleetSpawn to:mTownDock];
	}
	return [dest autorelease];
}

- (Destination *)fetchSilverTrainDestination {
	Destination *dest = nil;
	
	if ([self isTownVacant] && [self isSilverTrainDestVacant]) {
		dest = [[Destination alloc] init];
		dest.start = kPlaneIdTown;
		dest.finish = kPlaneIdNorth;
		dest.spawnPlaneIndex = dest.start;
		[self fillDestination:dest from:mTownDock to:mSilverTrainDest];
	}
	return [dest autorelease];
}

- (void)requestTargetForPursuer:(NSObject *)pursuer {
    if (mLocked == YES)
        return;
    
    if ([pursuer isKindOfClass:[PirateShip class]]) {
        PirateShip *pirateShip = (PirateShip *)pursuer;
		pirateShip.enemy = [self requestNewMerchantEnemy:pirateShip];
    } else if ([pursuer isKindOfClass:[NavyShip class]]) {
        NavyShip *navyShip = (NavyShip *)pursuer;
		
		if (navyShip.destination.seaLaneC == mTownEntrance)
			[navyShip.destination setFinishAsDest];
		
		PlayerShip *playerShip = [mPlayerShips anyObject];
		
		if (playerShip.isCamouflaged == NO && playerShip.markedForRemoval == NO)
			navyShip.enemy = playerShip;
		else
			navyShip.duelState = PursuitStateSailingToDock;
    } else if ([pursuer isKindOfClass:[EscortShip class]]) {
        EscortShip *escortShip = (EscortShip *)pursuer;
        escortShip.duelState = PursuitStateEscorting;
    } else if ([pursuer isKindOfClass:[TempestActor class]]) {
        TempestActor *tempest = (TempestActor *)pursuer;
        tempest.target = [self requestClosestTarget:tempest];
    } else if ([pursuer isKindOfClass:[DeathFromDeep class]]) {
        DeathFromDeep *dfd = (DeathFromDeep *)pursuer;
        dfd.target = (NpcShip *)[self requestNewVoodooTarget];
    }
}

- (void)actorDepartedPort:(Actor *)actor {
	if (mLocked == YES || ![actor conformsToProtocol:@protocol(PathFollower)])
		return;
	id<PathFollower> ship = (id<PathFollower>)actor;
	
	// Release spawn point to keep traffic moving
	if (ship.destination.seaLaneA != nil)
		[self checkinSpawn:ship];
}

- (void)actorArrivedAtDestination:(Actor *)actor {
	if (mLocked == YES || ![actor conformsToProtocol:@protocol(PathFollower)])
		return;
	id<PathFollower> ship = (id<PathFollower>)actor;
	
	if (ship.destination.seaLaneC == mTownEntrance) {
		if ([actor isKindOfClass:[EscortShip class]]) {
			EscortShip *escortShip = (EscortShip *)actor;
			
			if (escortShip.enemy != nil && escortShip.duelState != PursuitStateSailingToDock) {
				[self setRandomPursuitLocation:escortShip];
				return;
			}
		}
		
		[ship.destination setFinishAsDest];
		
		// PrimeShip Escorts (they will handle this themselves if their escortee is dead)
		if (ship == mFleet) {
			[mFleet.leftEscort.destination setFinishAsDest];
			[mFleet.rightEscort.destination setFinishAsDest];
		}
		
		if (ship.destination.seaLaneB == mTownDock) {
			// Mark as non-collidable to prevent town harbour from clogging up
			ship.isCollidable = NO;
			
			if (ship == mFleet) {
				mFleet.leftEscort.isCollidable = NO;
				mFleet.rightEscort.isCollidable = NO;
			}
		}
		return;
	}
	
	if ([actor isKindOfClass:[PursuitShip class]]) {
		PursuitShip *pursuitShip = (PursuitShip *)actor;
		
		if (pursuitShip.duelState != PursuitStateSailingToDock)
			[self setRandomPursuitLocation:pursuitShip];
		else
			[pursuitShip dock];
	} else {
		[ship dock];
	}
}

- (void)prisonerOverboard:(Prisoner *)prisoner ship:(ShipActor *)ship {
    if (mLocked == YES)
		return;
	
    if (ship == nil)
		ship = [mPlayerShips anyObject];
	
	b2Vec2 shipLoc = ship.overboardLocation;
	
	if (prisoner == nil) {
        prisoner = [Prisoner prisonerWithName:@"Prisoner0"];
        prisoner.gender = (mRandomInt < 0.67f * kDefaultChanceMax) ? kGenderMale : kGenderFemale;
        prisoner.textureName = @"prisoner0";
	}
	
	OverboardActor *person = [self spawnPersonOverboardAtX:shipLoc.x y:shipLoc.y prisoner:prisoner];
	[self findPredatorForPrey:person];
}

- (PrimeShip *)spawnSilverTrainAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest escorts:(BOOL)escorts {
	assert(mFleet == nil);
	
	if (mLocked == YES || dest == nil)
		return nil;
	
	NSString *shipKey = @"SilverTrain";
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	ActorDef *actorDef = [shipYard createShipDefForShipType:shipKey x:x y:y angle:angle];
	mFleet = [[SilverTrain alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	mFleet.shipDetails = shipDetails;
	mFleet.aiModifier = mAiKnob->aiModifier;
	[mFleet setupShip];
	mFleet.destination = dest;
	
	[mScene addActor:mFleet];
	[self checkoutShip:(id<PathFollower>)mFleet];
	
	if (escorts == YES)
		[self spawnSilverTrainEscortShips];
	return mFleet;
}

- (PrimeShip *)spawnSilverTrain {	
	if (mLocked == YES)
		return nil;
	PrimeShip *ship = nil;
	Destination *dest = [self fetchSilverTrainDestination];
	
	if (dest != nil) {
        dest.adjustedSeaLaneC = [SPPoint pointWithX:P2MX(120.0f) y:P2MY(100.0f)];
		ship = [self spawnSilverTrainAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest escorts:YES];
        ship.fleetID = mFleetID++;
    }
    
	return ship;
}

- (PrimeShip *)spawnTreasureFleetAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest escorts:(BOOL)escorts {
	assert(mFleet == nil);
	
	if (mLocked == YES || dest == nil)
		return nil;
	
	NSString *shipKey = @"TreasureFleet";
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	ActorDef *actorDef = [shipYard createShipDefForShipType:shipKey x:x y:y angle:angle];
	mFleet = [[TreasureFleet alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	mFleet.shipDetails = shipDetails;
	mFleet.aiModifier = mAiKnob->aiModifier;
	[mFleet setupShip];
	mFleet.destination = dest;
	
	[mScene addActor:mFleet];
	[self checkoutShip:(id<PathFollower>)mFleet];
	
	if (escorts == YES)
		[self spawnTreasureFleetEscortShips];
	return mFleet;
}

- (PrimeShip *)spawnTreasureFleet {
	if (mLocked == YES)
		return nil;
	PrimeShip *ship = nil;
	Destination *dest = [self fetchTreasureFleetDestination];
	
	if (dest != nil) {
        dest.adjustedSeaLaneC = [SPPoint pointWithX:P2MX(70.0f) y:P2MY(70.0f)];
		ship = [self spawnTreasureFleetAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest escorts:YES];
        ship.fleetID = mFleetID++;
    }
    
	return ship;
}

- (void)spawnSilverTrainEscortShips {
	if (mFleet == nil || mLocked == YES)
		return;
	Destination *dest = [Destination destinationWithDestination:mFleet.destination];
	[dest setLocX:P2MX(-55.0f)];
	[dest setLocY:P2MY(-69.0f)];
	dest.isExclusive = NO; // Prevents checking in of destination points we don't own.
	mFleet.leftEscort = [self spawnEscortShip:dest];
	mFleet.leftEscort.escortee = mFleet;
	
	dest = [Destination destinationWithDestination:mFleet.destination];
	[dest setLocX:P2MX(-68.0f)];
	[dest setLocY:P2MY(-54.0f)];
	dest.isExclusive = NO;
	mFleet.rightEscort = [self spawnEscortShip:dest];
	mFleet.rightEscort.escortee = mFleet;
	
	[mScene addActor:mFleet.leftEscort];
	[mScene addActor:mFleet.rightEscort];
	[self addActor:mFleet.leftEscort];
	[self addActor:mFleet.rightEscort];
}

- (void)spawnTreasureFleetEscortShips {
	if (mFleet == nil || mLocked == YES)
		return;
	Destination *dest = [Destination destinationWithDestination:mFleet.destination];
	[dest setLocX:dest.loc.x + 6.0f];
	[dest setLocY:dest.loc.y - 1.5f];
	dest.isExclusive = NO;
	mFleet.leftEscort = [self spawnEscortShip:dest];
	mFleet.leftEscort.escortee = mFleet;
	mFleet.leftEscort.willEnterTown = YES;
	
	dest = [Destination destinationWithDestination:mFleet.destination];
	[dest setLocX:dest.loc.x + 6.0f];
	[dest setLocY:dest.loc.y + 1.5f];
	dest.isExclusive = NO;
	mFleet.rightEscort = [self spawnEscortShip:dest];
	mFleet.rightEscort.escortee = mFleet;
	mFleet.rightEscort.willEnterTown = YES;
	
	[mScene addActor:mFleet.leftEscort];
	[mScene addActor:mFleet.rightEscort];
	[self addActor:mFleet.leftEscort];
	[self addActor:mFleet.rightEscort];
}

- (EscortShip *)spawnEscortShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;
	
	NSString *shipKey = @"Escort";
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	
	// Ensure turn-fights have a clear victor
	if (mFleet && mFleet.leftEscort)
		shipDetails.controlRating += 2;
	
	ActorDef *actorDef = [shipYard createShipDefForShipType:shipKey x:x y:y angle:angle];
	EscortShip *ship = [[EscortShip alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	ship.shipDetails = shipDetails;
	ship.cannonDetails = [[CannonFactory munitions] createCannonDetailsForType:@"Perisher"];
	ship.aiModifier = mAiKnob->aiModifier;
	[ship setupShip];
	ship.destination = dest;
	return [ship autorelease];
}

- (EscortShip *)spawnEscortShip:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;
	
	return [self spawnEscortShipAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest];
}

- (MerchantShip *)spawnMerchantShip:(NSString *)shipKey x:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;
	
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	ActorDef *actorDef = [shipYard createShipDefForShipType:@"Merchant" x:x y:y angle:angle];
	MerchantShip *ship = [[MerchantShip alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	
	ship.shipDetails = shipDetails;
	ship.cannonDetails = [[CannonFactory munitions] createCannonDetailsForType:@"Perisher"];
	ship.aiModifier = mAiKnob->aiModifier;
	ship.inFuture = mInFuture;
	[ship setupShip];
	ship.destination = dest;
	[mScene addActor:ship];
	[self addActor:ship];
	return [ship autorelease];
}


- (MerchantShip *)spawnMerchantShip:(int)type {
	if (mLocked == YES)
		return nil;
	MerchantShip *ship = nil;
	Destination *dest = [self fetchRandomVacantDestination:kPlaneIdTown destPlaneIndexMax:kPlaneIdTown];
	NSString *shipKey = nil;
	
	if (type < mAiKnob->merchantShipsChance * 0.4f)
		shipKey = @"MerchantCaravel";
	else if (type < mAiKnob->merchantShipsChance * 0.75f)
		shipKey = @"MerchantGalleon";
	else
		shipKey = @"MerchantFrigate";
	
	if (dest != nil)
		ship = [self spawnMerchantShip:shipKey x:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest];
	return ship;
}

- (NavyShip *)spawnNavyShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;

	NSString *shipKey = @"Navy";
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	ActorDef *actorDef = [shipYard createShipDefForShipType:shipKey x:x y:y angle:angle];
	
	NavyShip *ship = [[NavyShip alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	ship.shipDetails = shipDetails;
	ship.cannonDetails = [[CannonFactory munitions] createCannonDetailsForType:@"Perisher"];
	ship.aiModifier = mAiKnob->aiModifier;
	[ship setupShip];
	ship.destination = dest;
	
	[mScene addActor:ship];
	[self addActor:ship];
	return [ship autorelease];
}

- (NavyShip *)spawnNavyShip {
	if (mLocked == YES)
		return nil;
	NavyShip *ship = nil;
	Destination *dest = [self fetchTownSpawnDestination];
	
	if (dest != nil)
		ship = [self spawnNavyShipAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest];
	return ship;
}

- (PirateShip *)spawnPirateShipAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;
	
	NSString *shipKey = @"Pirate";
	ShipFactory *shipYard = [ShipFactory shipYard];
	ShipDetails *shipDetails = [shipYard createNpcShipDetailsForType:shipKey];
	ActorDef *actorDef = [shipYard createShipDefForShipType:shipKey x:x y:y angle:angle];
	
	PirateShip *ship = [[PirateShip alloc] initWithActorDef:actorDef key:shipKey];
	delete actorDef;
	actorDef = 0;
	ship.shipDetails = shipDetails;
	ship.cannonDetails = [[CannonFactory munitions] createCannonDetailsForType:@"Perisher"];
	ship.aiModifier = mAiKnob->aiModifier;
	[ship setupShip];
	ship.destination = dest;
	//ship.enemy = [self requestNewMerchantEnemy:ship];
	[self setRandomPursuitSpawnLocation:ship];
	
	[mScene addActor:ship];
	[self addActor:ship];
	return [ship autorelease];
}

- (PirateShip *)spawnPirateShip {
	if (mLocked == YES)
		return nil;
	PirateShip *ship = nil;
	Destination *dest = [self fetchRandomVacantDestination:kPlaneIdWest destPlaneIndexMax:kPlaneIdWest];
	
	if (dest != nil)
		ship = [self spawnPirateShipAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest];
	return ship;
}

- (void)enactMontysMutiny {
    ShipActor *ship = [mPlayerShips anyObject];
    assert(ship);
	
	b2Vec2 shipLoc = ship.overboardLocation;
	Prisoner *prisoner = [Prisoner prisonerWithName:nil];
    prisoner.gender = 1;
    prisoner.infamyBonus = 500000;
	
	OverboardActor *person = [self spawnPersonOverboardAtX:shipLoc.x y:shipLoc.y prisoner:prisoner];
    person.hasRepellent = YES;
    person.isPlayer = YES;
	[self findPredatorForPrey:person];
}

- (void)markPlayerAsEdible {
    OverboardActor *actor = [self overboardPlayer];
    assert(actor);
    actor.hasRepellent = NO;
}

- (TempestActor *)summonTempest {
	Idol *tempestIdol = [mScene idolForKey:VOODOO_SPELL_TEMPEST];
	assert(tempestIdol);
	
	if (mLocked == YES)
		return nil;
	NSMutableArray *spawnPlane = [mSpawnPlanes objectAtIndex:kPlaneIdWest];
	SPPoint *loc = [spawnPlane objectAtIndex:0];
	return [self summonTempestAtX:loc.x y:loc.y duration:[Idol durationForIdol:tempestIdol]];
}

- (TempestActor *)summonTempestAtX:(float)x y:(float)y duration:(float)duration {
	Idol *tempestIdol = [mScene idolForKey:VOODOO_SPELL_TEMPEST];
	assert(tempestIdol);
	
	if (mLocked == YES)
		return nil;
	TempestActor *tempest = [TempestActor tempestActorAtX:x y:y rotation:0.0f duration:duration];
	[mTempests addObject:tempest];
	[mScene addActor:tempest];
	return tempest;
}

- (void)onDeathFromDeepDismissed:(SPEvent *)event {
	DeathFromDeep *dfd = (DeathFromDeep *)event.currentTarget;
	[mScene removeProp:dfd];
    dfd.target = nil;
	[mDeathFromDeeps removeObject:dfd];
}

- (DeathFromDeep *)summonDeathFromDeepWithDuration:(float)duration {
	Idol *dfdIdol = [mScene idolForKey:VOODOO_SPELL_DEATH_FROM_DEEP];
	assert(dfdIdol);
	
	int maxDfdAllowed = [Idol countForIdol:dfdIdol];
	
	if (mLocked == YES || mDeathFromDeeps.count >= maxDfdAllowed)
		return nil;
	DeathFromDeep *dfd = [[[DeathFromDeep alloc] initWithCategory:CAT_PF_EXPLOSIONS duration:duration] autorelease];
	[mDeathFromDeeps addObject:dfd];
	[mScene addProp:dfd];
	[dfd addEventListener:@selector(onDeathFromDeepDismissed:) atObject:self forType:CUST_EVENT_TYPE_DEATH_FROM_DEEP_DISMISSED];
	return dfd;
}

- (Shark *)spawnSharkAtX:(float)x y:(float)y angle:(float)angle dest:(Destination *)dest {
	if (mLocked == YES || dest == nil)
		return nil;
	ActorDef *actorDef = [[ActorFactory juilliard] createSharkDefAtX:x y:y angle:angle];
	Shark *shark = [[Shark alloc] initWithActorDef:actorDef key:@"Shark"];
	delete actorDef;
	actorDef = 0;
	dest.isExclusive = NO;
	shark.destination = dest;
	
	[mScene addActor:shark];
	[self addActor:shark];
	return [shark autorelease];
}

- (Shark *)spawnShark {
	if (mLocked == YES)
		return nil;
	Shark *shark = nil;
	Destination *dest = [self fetchRandomDestination:kPlaneIdWest];

	if (dest != nil)
		shark = [self spawnSharkAtX:dest.loc.x y:dest.loc.y angle:kSpawnAngles[dest.spawnPlaneIndex] dest:dest];
	return shark;
}

- (OverboardActor *)spawnPersonOverboardAtX:(float32)x y:(float32)y prisoner:(Prisoner *)prisoner {
	if (mLocked == YES)
		return nil;
	Destination *dest = [self fetchRandomDestination:kPlaneIdWest];
	[dest setLocX:x];
	[dest setLocY:y];
	[dest setDestX:x];
	[dest setDestY:y];
	dest.isExclusive = NO;
	ActorDef *actorDef = [[ActorFactory juilliard] createPersonOverboardDefAtX:dest.loc.x y:dest.loc.y angle:SP_D2R(mRandomInt)];
	OverboardActor *person = [[OverboardActor alloc] initWithActorDef:actorDef key:@"Prisoner"];
	person.prisoner = prisoner;
	person.destination = dest;
	delete actorDef;
	actorDef = 0;
	
	[mScene addActor:person];
	[self addActor:person];
	
	if (mPeople.count == 20)
		[mScene.achievementManager grantSmorgasbordAchievement];
	return [person autorelease];
}

- (AshPickupActor *)spawnAshPickupActorAtX:(float)x y:(float)y ashKey:(uint)ashKey duration:(float)duration {
    ActorDef *actorDef = [[ActorFactory juilliard] createLootDefinitionAtX:x y:y radius:P2M(20)];
    AshPickupActor *actor = [[AshPickupActor alloc] initWithActorDef:actorDef ashKey:ashKey duration:duration];
    delete actorDef;
	actorDef = 0;
    [mScene addActor:actor];
	[self addActor:actor];
    return [actor autorelease];
}

- (AshPickupActor *)spawnAshPickupActor {
    b2Vec2 loc = [self randomPickupLocation];
    uint ashKey = [self randomAshKey];
    return [self spawnAshPickupActorAtX:loc.x y:loc.y ashKey:ashKey duration:30];
}

- (void)activateCamouflageForDuration:(float)duration {
    mCamouflageTimer = (double)duration;
    
	PlayerShip *playerShip = [mPlayerShips anyObject];
	
	if (playerShip.isCamouflaged == YES)
		return;
	[playerShip activateCamouflage];
	
	for (NavyShip *ship in mNavyShips)
		[ship playerCamouflageActivated:YES];
	
	for (EscortShip *ship in mEscortShips)
		[ship playerCamouflageActivated:YES];
}

- (void)deactivateCamouflage {
	PlayerShip *playerShip = [mPlayerShips anyObject];
	
	if (playerShip.isCamouflaged == NO)
		return;
	[playerShip deactivateCamouflage];
	
	for (NavyShip *ship in mNavyShips)
		[ship playerCamouflageActivated:NO];
	
	for (EscortShip *ship in mEscortShips)
		[ship playerCamouflageActivated:NO];
}

- (void)addActor:(Actor *)actor {
	if ([actor conformsToProtocol:@protocol(PathFollower)])
		[self checkoutShip:(id<PathFollower>)actor];
	
	if ([actor isKindOfClass:[MerchantShip class]])
		[mMerchantShips addObject:actor];
	else if ([actor isKindOfClass:[PirateShip class]])
		[mPirateShips addObject:actor];
	else if ([actor isKindOfClass:[NavyShip class]])
		[mNavyShips addObject:actor];
	else if ([actor isKindOfClass:[PlayerShip class]])
		[mPlayerShips addObject:actor];
	else if ([actor isKindOfClass:[Shark class]])
		[mSharks addObject:actor];
	else if ([actor isKindOfClass:[OverboardActor class]])
		[mPeople addObject:actor];
	else if ([actor isKindOfClass:[EscortShip class]])
		[mEscortShips addObject:actor];
    else if ([actor isKindOfClass:[AshPickupActor class]]) {
		[mAshPickups addObject:actor];
        [actor addEventListener:@selector(onAshPickupLooted:) atObject:mScene forType:CUST_EVENT_TYPE_ASH_PICKUP_LOOTED];
        [actor dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_ASH_PICKUP_SPAWNED]];
    }
	//else
	//	NSLog(@"Unsupported actor class sent to ActorAi.addActor");
}

- (void)removeActor:(Actor *)actor {
	if (mLocked)
		return;
	
	if ([actor conformsToProtocol:@protocol(PathFollower)]) {
		[self checkinShip:(id<PathFollower>)actor];
	}
	
	if ([actor isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)actor;
		
		if (ship.deathBitmap == DEATH_BITMAP_PLAYER_CANNON && ship.isPreparingForNewGame == NO && ship.destination.finishIsDest == YES && ship.destination.seaLaneB == mTownDock)
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOSE_BUT_NO_CIGAR_STATE_REACHED]];
	}
	
	if ([actor isKindOfClass:[Cannonball class]]) // Short-circuit for most common case
		return;
	else if (actor == mFleet) {
        if (actor.isPreparingForNewGame == NO) {
            if (mAiKnob->fleetTimer < 10)
                mAiKnob->fleetTimer = 10; // Don't want them spawning over the top of each other if they've docked
        
            if ([actor isKindOfClass:[TreasureFleet class]])
                [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_TREASURE_FLEET_ATTACKED]];
            else if ([actor isKindOfClass:[SilverTrain class]])
                [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SILVER_TRAIN_ATTACKED]];
        }
        
		[mFleet cleanup];
		[mFleet release];
		mFleet = nil;
	} else if ([mTempests containsObject:actor]) {
		TempestActor *tempest = (TempestActor *)actor;
		[tempest cleanup];
		[mTempests removeObject:tempest];
	} else if ([actor isKindOfClass:[MerchantShip class]])
		[mMerchantShips removeObject:actor];
	else if ([actor isKindOfClass:[PirateShip class]])
		[mPirateShips removeObject:actor];
	else if ([actor isKindOfClass:[NavyShip class]])
		[mNavyShips removeObject:actor];
	else if ([actor isKindOfClass:[PlayerShip class]]) {
        [actor cleanup];
		[mPlayerShips removeObject:actor];
	} else if ([actor isKindOfClass:[Shark class]]) {
        [actor cleanup];
		[mSharks removeObject:actor];
	} else if ([actor isKindOfClass:[OverboardActor class]]) {
        [actor cleanup];
		[mPeople removeObject:actor];
	} else if ([actor isKindOfClass:[EscortShip class]]) {
        EscortShip *escortShip = (EscortShip *)actor;
        
        if (mFleet && mFleet.fleetID == escortShip.fleetID && escortShip.isPreparingForNewGame == NO) {
            if ([mFleet isKindOfClass:[TreasureFleet class]])
                [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_TREASURE_FLEET_ATTACKED]];
            else if ([mFleet isKindOfClass:[SilverTrain class]])
                [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SILVER_TRAIN_ATTACKED]];
        }

		[mEscortShips removeObject:actor];
    } else if ([actor isKindOfClass:[AshPickupActor class]]) {
		[mAshPickups removeObject:actor];
        [actor removeEventListener:@selector(onAshPickupLooted:) atObject:mScene forType:CUST_EVENT_TYPE_ASH_PICKUP_LOOTED];
    }
}

- (void)createPlayingField {
	if (mSpawnPlanes != nil)
		return;
	mSpawnPlanes = [[NSMutableArray alloc] initWithCapacity:kSpawnPlanesCount];
	mVacantSpawnPlanes = [[NSMutableArray alloc] initWithCapacity:kSpawnPlanesCount];
	mOccupiedSpawnPlanes = [[NSMutableArray alloc] initWithCapacity:kSpawnPlanesCount];
	
	ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerRight];
	
	// Spawn Planes - North
	int numPoints = 4;
	float xOrigin = 520.0f + offset.x;
	float yOrigin = 36.0f;
	float step = RITMFY(36.0f);
	SPPoint *point = nil;
	NSMutableArray *spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	
	for (int i = 0; i < numPoints; ++i) {
		point = [SPPoint pointWithX:P2MX(xOrigin) y:P2MY(yOrigin + i * step)];
		[spawnPlane addObject:point];
		
		if (i == 1) {
			mTreasureFleetSpawn = point;
			mSilverTrainDest = point;
		}
	}
	
	[mSpawnPlanes addObject:spawnPlane];
	
	// East
	numPoints = 4;
	xOrigin = 56.0f;
	yOrigin = 360.0f + offset.y;
	step = RITMFX(56.0f);
	spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	
	for (int i = 0; i < numPoints; ++i) {
		point = [SPPoint pointWithX:P2MX(xOrigin + i * step) y:P2MY(yOrigin)];
		[spawnPlane addObject:point];
	}
	
	[mSpawnPlanes addObject:spawnPlane];
	
	// South
	numPoints = 5;
	xOrigin = -40.0f;
	yOrigin = mScene.viewHeight;
	step = RITMFY(36.0f);
	spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	
	for (int i = 0; i < numPoints; ++i) {
		point = [SPPoint pointWithX:P2MX(xOrigin) y:P2MY(yOrigin - i * step)];
		[spawnPlane addObject:point];
	}
	
	[mSpawnPlanes addObject:spawnPlane];
	
	// West
	numPoints = 5;
	xOrigin = mScene.viewWidth;
	yOrigin = -40.0f;
	step = RITMFX(64.0f);
	spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	
	for (int i = 0; i < numPoints; ++i) {
		point = [SPPoint pointWithX:P2MX(xOrigin - i * step) y:P2MY(yOrigin)];
		[spawnPlane addObject:point];
	}
	
	[mSpawnPlanes addObject:spawnPlane];
	
	// Town Spawn
	numPoints = 1;
	spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	//mTownDock = [[SPPoint pointWithX:P2MX(-29.0f) y:P2MY(-32.0f)] retain];
    mTownDock = [[SPPoint pointWithX:P2MX(-29.9f) y:P2MY(-33.0f)] retain];
	[spawnPlane addObject:mTownDock];
	[mSpawnPlanes addObject:spawnPlane];
	
	// Town Entrance
	mTownEntrance = [[SPPoint pointWithX:P2MX(70.0f) y:P2MY(60.0f)] retain];
	
	// Cove Spawn
	numPoints = 1;
	spawnPlane = [NSMutableArray arrayWithCapacity:numPoints];
	mCoveDock = [[SPPoint pointWithX:P2MX(mScene.viewWidth) y:P2MY(190.0f + offset.y)] retain];
	[spawnPlane addObject:mCoveDock];
	[mSpawnPlanes addObject:spawnPlane];
	
	// Setup vacant/occupied collections
	for (spawnPlane in mSpawnPlanes) {
		[mVacantSpawnPlanes addObject:[NSMutableArray arrayWithArray:spawnPlane]];
		[mOccupiedSpawnPlanes addObject:[NSMutableArray arrayWithCapacity:spawnPlane.count]];
	}
}

// ---------- Save Game State section -------------
- (GCDestination *)gcDestFromDest:(Destination *)dest {
	assert(dest);
	NSArray *spawnPlaneStart = (NSArray *)[mSpawnPlanes objectAtIndex:dest.start];
	NSArray *spawnPlaneFinish = (NSArray *)[mSpawnPlanes objectAtIndex:dest.finish];
	
	GCDestination *gcDest = [[[GCDestination alloc] init] autorelease];
	gcDest.spawnPlaneStart = dest.start;
	gcDest.spawnPlaneFinish = dest.finish;
	
	if (dest.seaLaneA != nil)
		gcDest.seaLaneA = [spawnPlaneStart indexOfObject:dest.seaLaneA];
	if (dest.seaLaneB != nil)
		gcDest.seaLaneB = [spawnPlaneFinish indexOfObject:dest.seaLaneB];
	gcDest.adjustedSeaLaneC = dest.adjustedSeaLaneC;
	gcDest.finishIsDest = dest.finishIsDest;
	
	return gcDest;
}

- (Destination *)destFromGcDest:(GCDestination *)gcDest {
	if (gcDest == nil)
		return nil;
	//NSLog(@"Destination Start");
	//NSLog(@"SeaLaneA: %d SeaLaneB: %d Start: %d Finish: %d", gcDest.seaLaneA, gcDest.seaLaneB, gcDest.spawnPlaneStart, gcDest.spawnPlaneFinish);
	
	Destination *dest = [[[Destination alloc] init] autorelease];
	
	NSArray *spawnPlaneStart = (NSArray *)[mSpawnPlanes objectAtIndex:gcDest.spawnPlaneStart];
	NSArray *spawnPlaneFinish = (NSArray *)[mSpawnPlanes objectAtIndex:gcDest.spawnPlaneFinish];
	
	if (gcDest.seaLaneA != -1)
		dest.seaLaneA = (SPPoint *)[spawnPlaneStart objectAtIndex:gcDest.seaLaneA];
	if (gcDest.seaLaneB != -1)
		dest.seaLaneB = (SPPoint *)[spawnPlaneFinish objectAtIndex:gcDest.seaLaneB];
	dest.start = gcDest.spawnPlaneStart;
	dest.finish = gcDest.spawnPlaneFinish;
	dest.spawnPlaneIndex = dest.start;
	dest.finishIsDest = gcDest.finishIsDest;
	
	
	//NSLog(@"Destination Finish");
	
	return dest;
}

- (void)spawnGCActor:(GCActor *)gcActor {
	Destination *dest = [self destFromGcDest:gcActor.dest];
	Actor *actor = nil;
	
	if ([gcActor.key isEqualToString:@"Player"]) {
		PlayerShip *ship = (PlayerShip *)[mPlayerShips anyObject];
		ship.body->SetTransform(b2Vec2(gcActor.x, gcActor.y), gcActor.rotation);
		actor = ship;
	} else if ([gcActor.key rangeOfString:@"Merchant" options:NSCaseInsensitiveSearch].location != NSNotFound) {
		actor = [self spawnMerchantShip:gcActor.key x:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest];
	} else if ([gcActor.key isEqualToString:@"Pirate"]) {
		actor = [self spawnPirateShipAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest];
	} else if ([gcActor.key isEqualToString:@"Navy"]) {
		actor = [self spawnNavyShipAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest];
	} else if ([gcActor.key isEqualToString:@"Escort"]) {
		EscortShip *ship = [self spawnEscortShipAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest];
        ship.fleetID = gcActor.fleetID;
        
        if (mFleetID <= ship.fleetID)
            mFleetID = ship.fleetID + 1;
		
		if (mFleet != nil) {
			if (gcActor.fleetEscort == 1 && mFleet.leftEscort == nil) {
				mFleet.leftEscort = ship;
				ship.escortee = mFleet;
			} else if (gcActor.fleetEscort == 2 && mFleet.rightEscort == nil) {
				mFleet.rightEscort = ship;
				ship.escortee = mFleet;
			}
		}
		
		[mScene addActor:ship];
		[self addActor:ship];
		actor = ship;
	} else if ([gcActor.key isEqualToString:@"TreasureFleet"]) {
		PrimeShip *ship = [self spawnTreasureFleetAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest escorts:NO];
        ship.fleetID = gcActor.fleetID;
		actor = ship;
        
        if (mFleetID <= ship.fleetID)
            mFleetID = ship.fleetID + 1;
	} else if ([gcActor.key isEqualToString:@"SilverTrain"]) {
		PrimeShip *ship = [self spawnSilverTrainAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest escorts:NO];
        ship.fleetID = gcActor.fleetID;
		actor = ship;
        
        if (mFleetID <= ship.fleetID)
            mFleetID = ship.fleetID + 1;
	} else if ([gcActor.key isEqualToString:@"Shark"]) {
		actor = [self spawnSharkAtX:gcActor.x y:gcActor.y angle:gcActor.rotation dest:dest];
	} else if ([gcActor.key isEqualToString:@"Prisoner"]) {
		actor = [self spawnPersonOverboardAtX:gcActor.x y:gcActor.y prisoner:gcActor.prisoner];
	} else {
		assert(0);
	}
	
	if (actor != nil) {
		// Set actorId
		actor.actorId = gcActor.actorId;
		
		// Set PursuitShip's duel state
		if ([actor isKindOfClass:[PursuitShip class]]) {
			PursuitShip *pursuitShip = (PursuitShip *)actor;
			pursuitShip.duelState = (PursuitState)gcActor.duelState;
		}
		
		// Respawn cannonballs owned by actor
		for (GCCannonball *gcCannonball in gcActor.cannonballs) {
			CannonballInfamyBonus *bonus = gcCannonball.infamyBonus;
			Cannonball *cannonball = [[CannonFactory munitions] createCannonballForShooter:actor shotType:gcCannonball.shotType
																					  bore:gcCannonball.bore
																			 ricochetCount:gcCannonball.ricochetCount
																			   infamyBonus:bonus
																					   loc:b2Vec2(gcCannonball.x,gcCannonball.y)
																					   vel:b2Vec2(gcCannonball.velX, gcCannonball.velY)
																				trajectory:gcCannonball.trajectory
																			 distRemaining:gcCannonball.distanceRemaining];
			cannonball.cannonballGroupId = gcCannonball.groupId;
			[mScene addActor:cannonball];
			[cannonball setupCannonball];
		}
	}
}

- (void)saveActors:(NSSet *)actors asGCActors:(GCMisc *)misc cannonballs:(NSMutableArray *)cannonballs {
	for (Actor *actor in actors) {
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
			if (((NpcShip *)actor).docking == YES)
				continue;
		}
		
		GCActor *gcActor = [[GCActor alloc] initWithKey:actor.key];
		gcActor.actorId = actor.actorId;
		
		// Fleet
        if ([actor isKindOfClass:[PrimeShip class]]) {
            PrimeShip *primeShip = (PrimeShip *)actor;
            gcActor.fleetID = primeShip.fleetID;
        }
        
        if ([actor isKindOfClass:[EscortShip class]]) {
			EscortShip *escortShip = (EscortShip *)actor;
            gcActor.fleetID = escortShip.fleetID;
			
            if (mFleet != nil) {
                if (escortShip == mFleet.leftEscort)
                    gcActor.fleetEscort = 1;
                else if (escortShip == mFleet.rightEscort)
                    gcActor.fleetEscort = 2;
            }
		}
		
		// Enemies
		if ([actor isKindOfClass:[PursuitShip class]]) {
			PursuitShip *pursuitShip = (PursuitShip *)actor;
			gcActor.duelState = (int)pursuitShip.duelState;
			
			if (pursuitShip.enemy != nil)
				[gcActor addEnemyId:pursuitShip.enemy.actorId];
		}
		
		// Orientation
		b2Vec2 loc = actor.body->GetPosition();
		gcActor.x = loc.x;
		gcActor.y = loc.y;
		gcActor.rotation = actor.body->GetAngle();
		
		if ([actor conformsToProtocol:@protocol(PathFollower)])
			gcActor.dest = [self gcDestFromDest:((id<PathFollower>)actor).destination];
		else
			gcActor.dest = nil;
		
		if ([actor isKindOfClass:[OverboardActor class]])
			gcActor.prisoner = ((OverboardActor *)actor).prisoner;
		
		// Projectiles
		if ([actor isKindOfClass:[ShipActor class]]) {
			NSMutableArray *usedCannonballs = [[NSMutableArray alloc] init];
			
			for (Cannonball *cannonball in cannonballs) {
				if (cannonball.shooter == actor) {
					GCCannonball *gcCannonball = [[GCCannonball alloc] initWithCannonball:cannonball];
					[gcActor addCannonball:gcCannonball];
					[usedCannonballs addObject:cannonball];
					[gcCannonball release];
				}
			}
			
			for (Cannonball *cannonball in usedCannonballs)
				[cannonballs removeObject:cannonball];
			[usedCannonballs release];
		}
		[misc addActor:gcActor];
		[gcActor release];
	}
}

- (OverboardActor *)overboardPlayer {
    OverboardActor *actor = nil;
    
    for (OverboardActor *person in mPeople) {
        if (person.isPlayer) {
            actor = person;
            break;
        }
    }
    
    return actor;
}

- (NSArray *)allShips {
	NSMutableArray *allShips = [NSMutableArray arrayWithArray:[self allNpcShips]];
	[allShips addObjectsFromArray:[mPlayerShips allObjects]];
	return allShips;
}

- (NSArray *)allNpcShips {
	NSMutableArray *allNpcShips = [NSMutableArray arrayWithCapacity:25];
	[allNpcShips addObjectsFromArray:[mMerchantShips allObjects]];
	[allNpcShips addObjectsFromArray:[mNavyShips allObjects]];
	[allNpcShips addObjectsFromArray:[mPirateShips allObjects]];
	
	[allNpcShips addObjectsFromArray:[mEscortShips allObjects]];
	
	if (mFleet != nil)
		[allNpcShips addObject:mFleet];
	return allNpcShips;
}

- (NSArray *)allPursuitShips {
	NSMutableArray *pursuitShips = [NSMutableArray arrayWithCapacity:15];
	[pursuitShips addObjectsFromArray:[mNavyShips allObjects]];
	[pursuitShips addObjectsFromArray:[mPirateShips allObjects]];
	[pursuitShips addObjectsFromArray:[mEscortShips allObjects]];
	return pursuitShips;
}

- (void)loadGameState:(GameCoder *)coder {
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	NSArray *actors = misc.actors;
	
	// Spawn Actors
	for (GCActor *actor in actors)
		[self spawnGCActor:actor];
	
	// Assign enemies
	for (GCActor *actor in actors) {
		Actor *predator = [mScene actorById:actor.actorId];
		
		if (predator && [predator isKindOfClass:[PursuitShip class]]) {
			PursuitShip *pursuitShip = (PursuitShip *)predator;
			
			if (pursuitShip.enemy == nil) {
				Actor *prey = [mScene actorById:actor.firstEnemyId];
			
				if (prey && [prey isKindOfClass:[ShipActor class]])
					pursuitShip.enemy = (ShipActor *)prey;
			}
		}
	}
	
	// Re-group cannonballs
	NSMutableDictionary *cannonballGroups = [NSMutableDictionary dictionary];
	NSArray *cannonballs = [mScene liveCannonballs];
	
	for (Cannonball *cannonball in cannonballs) {
		if (cannonball.cannonballGroupId != 0) {
			NSString *key = [NSString stringWithFormat:@"%d", cannonball.cannonballGroupId];
			CannonballGroup *grp = (CannonballGroup *)[cannonballGroups objectForKey:key];
			
			if (grp == nil) {
				grp = [CannonballGroup cannonballGroupWithHitQuota:1];
				[cannonballGroups setObject:grp forKey:key];
				[mScene addProp:grp];
			}
			
			cannonball.cannonballGroupId = 0;
			[grp addCannonball:cannonball];
		}
	}
}

// TODO: Save TownCannon cannonballs
- (void)saveGameState:(GameCoder *)coder {
	NSMutableArray *cannonballs = [mScene liveCannonballs];
	
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	[self saveActors:mPlayerShips asGCActors:misc cannonballs:cannonballs];
	
	if (mFleet != nil) // Must save fleet before escort ships so we can be sure it is loaded first.
		[self saveActors:[NSSet setWithObject:mFleet] asGCActors:misc cannonballs:nil];
	[self saveActors:mEscortShips asGCActors:misc cannonballs:cannonballs];
	[self saveActors:mMerchantShips asGCActors:misc cannonballs:cannonballs];
	[self saveActors:mPirateShips asGCActors:misc cannonballs:cannonballs];
	[self saveActors:mNavyShips asGCActors:misc cannonballs:cannonballs];
	[self saveActors:mPeople asGCActors:misc cannonballs:nil]; // Save people first so that sharks have something to eat when loaded.
	[self saveActors:mSharks asGCActors:misc cannonballs:nil];
}
// ------------------------------------------------

- (void)dealloc {
	mLocked = YES;
	
	//[self stopThinking]; // It's not possible to be in dealloc if we haven't already stopped thinking
	
	if (mTempests.count > 0) {
		for (TempestActor *tempest in mTempests) {
			[tempest cleanup];
		}
	}
	
	if (mDeathFromDeeps.count > 0) {
		for (DeathFromDeep *dfd in mDeathFromDeeps) {
			dfd.target = nil;
			[dfd removeEventListener:@selector(onDeathFromDeepDismissed:) atObject:self forType:CUST_EVENT_TYPE_DEATH_FROM_DEEP_DISMISSED];
			[mScene removeProp:dfd];
		}
	}
	
	if (mFleet != nil) {
		[mFleet cleanup];
		[mScene removeActor:mFleet];
		[mFleet release];
		mFleet = nil;
	}
	
	for (Actor *actor in mNavyShips) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mMerchantShips) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mPirateShips) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mEscortShips) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mSharks) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mPeople) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
    
    for (Actor *actor in mAshPickups) {
		[actor cleanup];
        [actor removeEventListener:@selector(onAshPickupLooted:) atObject:mScene forType:CUST_EVENT_TYPE_ASH_PICKUP_LOOTED];
		[mScene removeActor:actor];
	}
	
	for (Actor *actor in mPlayerShips) {
		[actor cleanup];
		[mScene removeActor:actor];
	}
    
    [mAshPickupQueue release]; mAshPickupQueue = nil;
	
	//[mName release];
	[mNavyShips release]; mNavyShips = nil;
	[mMerchantShips release]; mMerchantShips = nil;
	[mPirateShips release]; mPirateShips = nil;
	[mEscortShips release]; mEscortShips = nil;
	[mSharks release]; mSharks = nil;
	[mPeople release]; mPeople = nil;
    [mAshPickups release]; mAshPickups = nil;
	[mTempests release]; mTempests = nil;
	[mDeathFromDeeps release]; mDeathFromDeeps = nil;
	
	[mPlayerShips release]; mPlayerShips = nil;
	[mShipTypes release]; mShipTypes = nil;
	
	mTreasureFleetSpawn = nil;
	mSilverTrainDest = nil;
	[mTownEntrance release]; mTownEntrance = nil;
	[mTownDock release]; mTownDock = nil;
	[mCoveDock release]; mCoveDock = nil;
	[mSpawnPlanes release]; mSpawnPlanes = nil;
	[mVacantSpawnPlanes release]; mVacantSpawnPlanes = nil;
	[mOccupiedSpawnPlanes release]; mOccupiedSpawnPlanes = nil;
    
    mScene = nil;
	[super dealloc];
}

@end
