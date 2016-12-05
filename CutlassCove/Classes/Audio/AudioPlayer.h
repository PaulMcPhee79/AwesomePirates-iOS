//
//  AudioPlayer.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ChannelBuffer.h"

// AVAudioPlayerDelegate: not currently implementing any of this optional protocol
@interface AudioPlayer : NSObject <AVAudioPlayerDelegate> {
	int mMarkedForDestruction;
	int mAudioSettings; // Music/Sfx On/Off
	
	NSMutableDictionary *mPlayableChannelBuffers;
	NSMutableDictionary *mSilencedChannelBuffers;
	NSMutableArray *mAmbientAudio; // List of sounds that should always be playing (to be played when music/sfx is toggled on)
	
	SPJuggler *mJuggler;
}

@property (nonatomic,assign) BOOL musicOn;
@property (nonatomic,assign) BOOL sfxOn;
@property (nonatomic,readonly) BOOL markedForDestruction;
@property (nonatomic,readonly) SPJuggler *juggler;

- (id)initWithCapacity:(uint)capacity;
- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)audioKey extras:(NSDictionary *)extras;
// Example callback selector form: (void)onAudioLoaded:(NSString *)audioKey errorMsg:(NSString *)errorMsg;
- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)key caller:(id)caller callback:(NSString *)callback;
- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)audioKey extras:(NSDictionary *)extras caller:(id)caller callback:(NSString *)callback;
- (void)advanceTime:(double)time;

- (void)pause;
- (void)resume;
- (void)stop;
- (void)stopEaseOutSounds;
- (void)fadeAllSounds;
- (void)fadeAndMarkForDestruction;

- (void)playSoundWithKey:(NSString *)key;
- (void)playSoundWithKey:(NSString *)key volume:(float)volume;
- (void)playSoundWithKey:(NSString *)key volume:(float)volume pitch:(float)pitch;
- (void)playSoundWithKey:(NSString *)key volume:(float)volume easeInDuration:(float)duration;
- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range;
- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range volume:(float)volume;
- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range volume:(float)volume pitch:(float)pitch;
- (void)pauseSoundWithKey:(NSString *)key;
- (void)resumeSoundWithKey:(NSString *)key;
- (void)stopSoundWithKey:(NSString *)key;
- (void)stopEaseOutSoundWithKey:(NSString *)key;
- (void)stopSoundWithKey:(NSString *)key easeOutDuration:(float)duration;
- (void)setVolume:(float)volume forSoundWithKey:(NSString *)key;
- (void)setVolume:(float)volume forSoundWithKey:(NSString *)key easeDuration:(float)duration;

- (void)addSoundWithKey:(NSString *)key count:(uint)count filename:(NSString *)filename category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand;
- (void)removeSoundWithKey:(NSString *)key;
- (void)removeAllSounds;

- (void)addAmbientAudioKey:(NSString *)key;

- (void)destroyAudioPlayer;

@end
