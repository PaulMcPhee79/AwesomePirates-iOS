//
//  GameCoder.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GameCoder.h"
#import "NSMutableData_Extension.h"
#import "FileManager.h"

@interface GameCoder ()

- (void)validateState;
- (id)createObjectForKey:(NSString *)key;

@end


@implementation GameCoder

- (id)init {
	if (self = [super init]) {
		mFilename = [[NSString stringWithFormat:@"_gs_10004_err_log"] retain];
		mKey = [[NSString stringWithFormat:@"th4#H16K!^*gK(CV{868}$!zZaAs)(.,"] retain];
		mGameData = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)createObjectForKey:(NSString *)key {
	id object = nil;
	
	if ([key isEqualToString:GAME_CODER_KEY_MISC])
		object = [GCMisc gcMisc];
	else if ([key isEqualToString:GAME_CODER_KEY_SHIP_DETAILS])
		object = [GCShipDetails gcShipDetails];
	else if ([key isEqualToString:GAME_CODER_KEY_ACHIEVEMENT_MANAGER])
		object = [GCAchievementManager gcAchievementManager];
	else if ([key isEqualToString:GAME_CODER_KEY_AI_KNOB])
		object = [GCAiKnob gcAiKnob];
	
	return object;
}

- (void)beginNewStateCache {
	if (mGameData == nil)
		mGameData = [[NSMutableDictionary alloc] init];
	else
		[mGameData removeAllObjects];
}

- (void)addObject:(id)object forKey:(NSString *)key {
	[mGameData setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
	id object = [mGameData objectForKey:key];
	
	if (object == nil) {
		object = [self createObjectForKey:key];
		[self addObject:object forKey:key];
	}
	
	return object;
}

- (void)validateState {
	// ...TODO: further validation as necessary
}

- (BOOL)loadGameState {
	BOOL result = NO;
	
	@try {
		NSMutableData *data = [NSMutableData mutableDataWithData:[FileManager loadNSDataWithFilename:mFilename]];
		
		if (data != nil) {
			[FileManager deleteNSDataFile:mFilename];
			[data unmaskWithOffset:0xa1];
			[mGameData release];
			mGameData = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
			result = (mGameData != nil);
		}
	} @catch (NSException *e) {
		// Don't bother with possible small memory leak from mGameData. Most important is to return NO so that
		// the player doesn't end up in an endless loop of trying to load a corrupt file on each startup.
		result = NO;
		NSLog(@"Error loading saved game state. Load aborted.");
	}
	return result;
}

- (void)saveGameState {
	if (mGameData != nil) {
		[self validateState];
		NSMutableData *data = [NSMutableData mutableDataWithData:[NSKeyedArchiver archivedDataWithRootObject:mGameData]];
		[data maskWithOffset:0xa1];
		BOOL stateSaved = [FileManager saveNSData:data withFilename:mFilename];
		NSLog(@"Game serialized: %@", ((stateSaved) ? @"YES" : @"NO"));
	}
}

- (void)dealloc {
	[mFilename release]; mFilename = nil;
	[mKey release]; mKey = nil;
	[mGameData release]; mGameData = nil;
	[super dealloc];
}

@end
