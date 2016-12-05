//
//  GameCoder.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCMisc.h"
#import "GCAiKnob.h"
#import "GCActor.h"
#import "GCShipDetails.h"
#import "GCAchievementManager.h"

#define GAME_CODER_KEY_MISC @"Misc"
#define GAME_CODER_KEY_AI_KNOB @"AiKnob"
#define GAME_CODER_KEY_SHIP_DETAILS @"ShipDetails"
#define GAME_CODER_KEY_ACHIEVEMENT_MANAGER @"AchievementManager"
#define GAME_CODER_KEY_ENHANCEMENTS @"Enhancements"


@interface GameCoder : NSObject {
	NSString *mFilename;
	NSString *mKey;
	NSMutableDictionary *mGameData; // All elements must conform to NSCoding protocol
}

- (void)beginNewStateCache;
- (void)addObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (BOOL)loadGameState;
- (void)saveGameState;

@end
