//
//  ThisTurn.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 3/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ThisTurn.h"
#import "Countdown.h"
#import "NumericValueChangedEvent.h"
#import "GameSettings.h"
#import "PlayerShip.h"
#import "Potion.h"
#import "GameStats.h"
#import "GameController.h"

#define THIS_TURN_ASSISTED_AIMING 0x1UL
#define THIS_TURN_TUTORIAL_MODE 0x2UL
#define THIS_TURN_IS_GAME_OVER 0x4UL

@interface ThisTurn ()

@property (nonatomic,assign) BOOL statsCommitted;

- (void)resetStats;
- (void)onMutinyCountdownChanged:(NumericRatioChangedEvent *)event;

@end


@implementation ThisTurn

@synthesize wasGameProgressMade,turnID,settings,mutiny,mutinyCountdown,infamyMultiplier,potionMultiplier,infamy,speed,gameMode,adventureState;
@synthesize statsCommitted,cannonballsShot,cannonballsHit,shipsSunk,daysAtSea;
@dynamic isGameOver,assistedAiming,tutorialMode,difficultyMultiplier,mutinyThreshold,playerShouldDie,cannonAccuracy;

- (id)init {
	if (self = [super init]) {
        wasGameProgressMade = NO;
        turnID = 0;
		settings = 0;
        mutiny = 0;
        self.mutinyCountdown = [[[Countdown alloc] initWithCounter:10 counterMax:10] autorelease];
        potionMultiplier = 1.0f;
        infamyMultiplier = 10;
        infamy = 0;
        speed = 0;
        
        statsCommitted = NO;
        cannonballsShot = 0;
        cannonballsHit = 0;
        shipsSunk = 0;
        daysAtSea = 0;
        
        self.adventureState = AdvStateNormal;
        self.gameMode = CC_GAME_MODE_DEFAULT;
	}
	return self;
}

- (void)dealloc {
    [mutinyCountdown removeEventListener:@selector(onMutinyCountdownChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED];
    [mutinyCountdown release]; mutinyCountdown = nil;
    [gameMode release]; gameMode = nil;
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
	ThisTurn *copy = [[[self class] allocWithZone:zone] init];
    copy.wasGameProgressMade = self.wasGameProgressMade;
    copy.turnID = self.turnID;
	copy.settings = self.settings;
    copy.mutiny = self.mutiny;
    copy.mutinyCountdown = self.mutinyCountdown;
    copy.potionMultiplier = self.potionMultiplier;
    copy.infamyMultiplier = self.infamyMultiplier;
    copy.infamy = self.infamy;
    copy.speed = self.speed;
    copy.statsCommitted = self.statsCommitted;
    copy.cannonballsShot = self.cannonballsShot;
    copy.cannonballsHit = self.cannonballsHit;
    copy.shipsSunk = self.shipsSunk;
    copy.daysAtSea = self.daysAtSea;
    copy.gameMode = self.gameMode;
    copy.adventureState = self.adventureState;
	return copy;
}

- (float)cannonAccuracy {
    float accuracy = 0;
    
    if (cannonballsShot != 0)
        accuracy = cannonballsHit / (float)cannonballsShot;
    
    return accuracy;
}

- (void)commitStats {
    if (statsCommitted)
        return;
    
    GameController *gc = GCTRL;
    gc.gameStats.cannonballsShot += cannonballsShot;
    gc.gameStats.cannonballsHit += cannonballsHit;
    gc.gameStats.daysAtSea += daysAtSea;
    statsCommitted = YES;
}

- (void)resetStats {
    cannonballsShot = 0;
    cannonballsHit = 0;
    shipsSunk = 0;
    daysAtSea = 0;
    statsCommitted = NO;
}

- (void)prepareForNewTurn {
    self.isGameOver = NO;
    wasGameProgressMade = NO;
    ++turnID;
    mutiny = 0;
    [mutinyCountdown softReset];
    potionMultiplier = [Potion notorietyFactorForPotion:[GCTRL.gameStats potionForKey:POTION_NOTORIETY]];
    infamy = 0;
    speed = 0;
    adventureState = AdvStateNormal;
    
    [self resetStats];
}

- (BOOL)isGameOver {
	return ((settings & THIS_TURN_IS_GAME_OVER) == THIS_TURN_IS_GAME_OVER);
}

- (void)setIsGameOver:(BOOL)value {
	if (value) settings |= THIS_TURN_IS_GAME_OVER;
	else settings &=~ THIS_TURN_IS_GAME_OVER;
}

- (BOOL)assistedAiming {
	return ((settings & THIS_TURN_ASSISTED_AIMING) == THIS_TURN_ASSISTED_AIMING);
}

- (void)setAssistedAiming:(BOOL)value {
	if (value) settings |= THIS_TURN_ASSISTED_AIMING;
	else settings &=~ THIS_TURN_ASSISTED_AIMING;
}

- (BOOL)tutorialMode {
	return ((settings & THIS_TURN_TUTORIAL_MODE) == THIS_TURN_TUTORIAL_MODE);
}

- (void)setTutorialMode:(BOOL)value {
	if (value) settings |= THIS_TURN_TUTORIAL_MODE;
	else settings &=~ THIS_TURN_TUTORIAL_MODE;
}

- (uint)difficultyMultiplier {
    return MAX(1,GCTRL.timeKeeper.day);
}

- (int)mutinyThreshold {
	return kMutinyThreshold;
}

- (BOOL)playerShouldDie {
    return (mutiny == kMutinyThreshold && mutinyCountdown.counter == mutinyCountdown.counterMax);
}

- (void)setMutiny:(int)value {
    if (value > kMutinyThreshold)
        [mutinyCountdown reset];
    
	int adjustedValue = MAX(0,MIN(kMutinyThreshold, value));
    
	int delta = adjustedValue - mutiny;
	mutiny = adjustedValue;
	
    NSNumber *valueNumber = [[NSNumber alloc] initWithInt:adjustedValue];
    NSNumber *minNumber = [[NSNumber alloc] initWithInt:0];
    NSNumber *maxNumber = [[NSNumber alloc] initWithInt:kMutinyThreshold];
    NSNumber *deltaNumber = [[NSNumber alloc] initWithInt:delta];
    NumericRatioChangedEvent *mutinyChangedEvent = [[NumericRatioChangedEvent alloc] initWithType:CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED
                                                                                            value:valueNumber
                                                                                         minValue:minNumber
                                                                                         maxValue:maxNumber
                                                                                            delta:deltaNumber
                                                                                          bubbles:NO];
    [self dispatchEvent:mutinyChangedEvent];
    [mutinyChangedEvent release];
    [valueNumber release]; [minNumber release]; [maxNumber release]; [deltaNumber release];
    
    if (mutiny == 0)
        [self resetMutinyCountdown];
}

- (void)addMutiny:(int)value {
    if (self.isGameOver || (value > 0 && GCTRL.playerShip.isFlyingDutchman))
        return;
    self.mutiny += value;
}

- (void)setMutinyCountdown:(Countdown *)countdown {
    if (mutinyCountdown != countdown) {
        [mutinyCountdown removeEventListener:@selector(onMutinyCountdownChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED];
        [mutinyCountdown autorelease];
        mutinyCountdown = [countdown retain];
        [mutinyCountdown addEventListener:@selector(onMutinyCountdownChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED];
    }
}

- (void)reduceMutinyCountdown:(float)amount {
    int reduction = (int)amount;
    
    for (int i = 0; i < reduction; ++i) {
        if (mutiny == 0)
            break;
        [mutinyCountdown decrement];
    }
    
    if (mutiny > 0)
        [mutinyCountdown reduceBy:amount - reduction];
}

- (void)resetMutinyCountdown {
    [mutinyCountdown reset];
}

- (void)onMutinyCountdownChanged:(NumericRatioChangedEvent *)event {
    [self dispatchEvent:event];
    
    if ([event.value intValue] == 0)
        [self addMutiny:-1];
}

- (void)setInfamy:(int64_t)value {
    NSNumber *valueNumber = [[NSNumber alloc] initWithLongLong:value];
    NSNumber *oldNumber = [[NSNumber alloc] initWithLongLong:infamy];
    
    NumericValueChangedEvent *infamyChangedEvent = [[NumericValueChangedEvent alloc] initWithType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED
                                                                                            value:valueNumber
                                                                                         oldValue:oldNumber
                                                                                          bubbles:NO];
    infamy = value;
    [self dispatchEvent:infamyChangedEvent];
    [infamyChangedEvent release];
    [valueNumber release]; [oldNumber release];
}

- (int64_t)addInfamy:(int64_t)value {
    if (self.isGameOver)
        return 0;
    int64_t adjustedValue = (int64_t)(value * infamyMultiplier * potionMultiplier);
    return [self addInfamyUnfiltered:adjustedValue];
}

- (int64_t)addInfamyUnfiltered:(int64_t)value {
    self.infamy += value;
    return value;
}

- (double)timeForLap:(int)lap {
    double lapTime = 0;
    
    if (lap >= 1 && lap <= 3)
        lapTime = lapTimes[lap-1];
    return lapTime;
}

- (void)setTime:(double)lapTime forLap:(int)lap {
    if (lap >= 1 && lap <= 3)
        lapTimes[lap-1] = lapTime;
}

- (double)totalRaceTime {
    double raceTime = 0;
    
    for (int i = 0; i < 3; ++i)
        raceTime += lapTimes[i];
    return raceTime;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		settings = [(NSNumber *)[decoder decodeObjectForKey:@"settings"] unsignedIntValue];
        mutiny = [(NSNumber *)[decoder decodeObjectForKey:@"mutiny"] intValue];
        self.mutinyCountdown = (Countdown *)[decoder decodeObjectForKey:@"mutinyCountdown"];
        infamyMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"infamyMultiplier"] unsignedIntValue];
		infamy = [(NSNumber *)[decoder decodeObjectForKey:@"infamy"] longLongValue];
        speed = [(NSNumber *)[decoder decodeObjectForKey:@"speed"] doubleValue];
        cannonballsShot = [(NSNumber *)[decoder decodeObjectForKey:@"cannonballsShot"] unsignedIntValue];
        cannonballsHit = [(NSNumber *)[decoder decodeObjectForKey:@"cannonballsHit"] unsignedIntValue];
        shipsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"shipsSunk"] unsignedIntValue];
        daysAtSea = [(NSNumber *)[decoder decodeObjectForKey:@"daysAtSea"] floatValue];
        self.gameMode = (NSString *)[decoder decodeObjectForKey:@"gameMode"];
        adventureState = (AdventureState)[(NSNumber *)[decoder decodeObjectForKey:@"adventureState"] intValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:settings] forKey:@"settings"];
    [coder encodeObject:[NSNumber numberWithInt:mutiny] forKey:@"mutiny"];
    [coder encodeObject:self.mutinyCountdown forKey:@"mutinyCountdown"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:infamyMultiplier] forKey:@"infamyMultiplier"];
    [coder encodeObject:[NSNumber numberWithLongLong:infamy] forKey:@"infamy"];
    [coder encodeObject:[NSNumber numberWithDouble:speed] forKey:@"speed"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:cannonballsShot] forKey:@"cannonballsShot"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:cannonballsHit] forKey:@"cannonballsHit"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:shipsSunk] forKey:@"shipsSunk"];
    [coder encodeObject:[NSNumber numberWithFloat:daysAtSea] forKey:@"daysAtSea"];
    [coder encodeObject:self.gameMode forKey:@"gameMode"];
    [coder encodeObject:[NSNumber numberWithInt:(AdventureState)adventureState] forKey:@"adventureState"];
}

@end
