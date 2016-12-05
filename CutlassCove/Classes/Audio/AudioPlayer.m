//
//  AudioPlayer.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "AudioPlayer.h"
#import "NSDictionary_Extension.h"
#import "Globals.h"

const int kDefaultAudioBufferCapacity = 10;

@interface AudioPlayer ()

- (void)loadAudioSettingdsWithArgs:(NSDictionary *)args;
- (void)settingsDidLoadWithArgs:(NSDictionary *)args;
- (BOOL)soundShouldPlay:(NSString *)key;
- (void)stopSilencedSounds;
- (float)fadeOutDuration;
- (void)addChannelBuffer:(ChannelBuffer *)channelBuffer withKey:(NSString *)key;
- (ChannelBuffer *)playableChannelBufferForKey:(NSString *)key;
- (ChannelBuffer *)channelBufferForKey:(NSString *)key;
- (void)moveChannelBuffersFromSrc:(NSMutableDictionary *)src toDest:(NSMutableDictionary *)dest withCategory:(int)category;
- (void)markForDestruction;

@end


@implementation AudioPlayer

@synthesize juggler = mJuggler;
@dynamic musicOn,sfxOn,markedForDestruction;

- (id)initWithCapacity:(uint)capacity {
	if (self = [super init]) {
		mMarkedForDestruction = 0;
		mAudioSettings = AUDIO_CATEGORY_MUSIC | AUDIO_CATEGORY_SFX;
		mJuggler = [[SPJuggler alloc] init];
		mPlayableChannelBuffers = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		mSilencedChannelBuffers = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		mAmbientAudio = [[NSMutableArray alloc] initWithCapacity:5];
	}
	return self;
}

- (id)init {
	return [self initWithCapacity:kDefaultAudioBufferCapacity];
}

- (BOOL)musicOn {
	return (mAudioSettings & AUDIO_CATEGORY_MUSIC) == AUDIO_CATEGORY_MUSIC;
}

- (void)setMusicOn:(BOOL)value {
	if (value == self.musicOn)
		return;
	NSMutableDictionary *src = nil;
	NSMutableDictionary *dest = nil;
	
	if (value == YES) {
		src = mSilencedChannelBuffers;
		dest = mPlayableChannelBuffers;
		mAudioSettings |= AUDIO_CATEGORY_MUSIC;
	} else {
		src = mPlayableChannelBuffers;
		dest = mSilencedChannelBuffers;
		mAudioSettings &= ~AUDIO_CATEGORY_MUSIC;
	}
	
	[self moveChannelBuffersFromSrc:src toDest:dest withCategory:AUDIO_CATEGORY_MUSIC];

    if (value == NO)
        [self stopSilencedSounds];
/*    
	if (value == YES) {
		for (NSString *key in mAmbientAudio)
			[self playSoundWithKey:key];
	} else {
		[self stopSilencedSounds];
	}
*/
}

- (BOOL)sfxOn {
	return (mAudioSettings & AUDIO_CATEGORY_SFX) == AUDIO_CATEGORY_SFX;
}

- (void)setSfxOn:(BOOL)value {
	if (value == self.sfxOn)
		return;
	NSMutableDictionary *src = nil;
	NSMutableDictionary *dest = nil;
	
	if (value == YES) {
		src = mSilencedChannelBuffers;
		dest = mPlayableChannelBuffers;
		mAudioSettings |= AUDIO_CATEGORY_SFX;
	} else {
		src = mPlayableChannelBuffers;
		dest = mSilencedChannelBuffers;
		mAudioSettings &= ~AUDIO_CATEGORY_SFX;
	}
	
	[self moveChannelBuffersFromSrc:src toDest:dest withCategory:AUDIO_CATEGORY_SFX];
	
	if (value == NO)
		[self stopSilencedSounds];
}

- (void)moveChannelBuffersFromSrc:(NSMutableDictionary *)src toDest:(NSMutableDictionary *)dest withCategory:(int)category {
	NSMutableArray *removedKeys = [NSMutableArray arrayWithCapacity:kDefaultAudioBufferCapacity];
	
	for (NSString *key in src) {
		ChannelBuffer *channelBuffer = (ChannelBuffer *)[src objectForKey:key];
		
		if (channelBuffer.category == category) {
			[removedKeys addObject:key];
			[dest setObject:channelBuffer forKey:key];
		}
	}
	
	for (NSString *key in removedKeys)
		[src removeObjectForKey:key];
}

- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)audioKey extras:(NSDictionary *)extras {
    [self loadAudioSettingsFromPlist:plistPath audioKey:audioKey extras:extras caller:nil callback:nil];
}

- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)audioKey caller:(id)caller callback:(NSString *)callback {
	[self loadAudioSettingsFromPlist:plistPath audioKey:audioKey extras:nil caller:caller callback:callback];
}

- (void)loadAudioSettingsFromPlist:(NSString *)plistPath audioKey:(NSString *)audioKey extras:(NSDictionary *)extras caller:(id)caller callback:(NSString *)callback {
	assert(plistPath && audioKey);
	
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 plistPath, @"plistPath",
								 audioKey, @"audioKey",
								 nil];
    if (caller && callback) {
        [args setObject:callback forKey:@"callback"];
        [args setObject:caller forKey:@"caller"];
    }
    
	if (extras)
		[args setObject:extras forKey:@"extras"];
    
    if (caller && callback)
        [NSThread detachNewThreadSelector:@selector(loadAudioSettingdsWithArgs:) toTarget:self withObject:args];
    else
        [self loadAudioSettingdsWithArgs:args];
}

- (void)loadAudioSettingdsWithArgs:(NSDictionary *)args {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Unpack args
	NSString *plistPath = [args objectForKey:@"plistPath"];
	NSString *audioKey = [args objectForKey:@"audioKey"];
	NSDictionary *extras = [args objectForKey:@"extras"];
	NSObject *caller = [args objectForKey:@"caller"];
	NSString *callback = [args objectForKey:@"callback"];
	
	// Load sounds
	NSDictionary *audioSettings = [Globals loadPlist:plistPath];
	audioSettings = (NSDictionary *)[audioSettings objectForKey:audioKey];
	
	NSDictionary *playlist = (NSDictionary *)[audioSettings objectForKey:@"Playlist"];
	playlist = [playlist dictionaryByMerging_CHEEKY:playlist with:extras];
	ChannelBuffer *channelBuffer = nil;
	NSMutableDictionary *queuedChannels = [NSMutableDictionary dictionaryWithCapacity:playlist.count];
	
	for (NSString *soundKey in playlist) {
        NSString *filename = nil;
        uint count = 0;
        BOOL loop = NO, onDemand = NO;
        float easeOutDuration = 0;
        int category = AUDIO_CATEGORY_SFX;
		NSDictionary *soundSetting = [playlist objectForKey:soundKey];
        
        for (NSString *key in soundSetting) {
            if ([key isEqualToString:@"Filename"])
                filename = [soundSetting objectForKey:key];
            else if ([key isEqualToString:@"Count"])
                count = [(NSNumber *)[soundSetting objectForKey:key] unsignedIntValue];
            else if ([key isEqualToString:@"Loop"])
                loop = [(NSNumber *)[soundSetting objectForKey:key] boolValue];
            else if ([key isEqualToString:@"EaseOutDuration"])
                easeOutDuration = [(NSNumber *)[soundSetting objectForKey:key] floatValue];
            else if ([key isEqualToString:@"Category"])
                category = [(NSNumber *)[soundSetting objectForKey:key] intValue];
            else if ([key isEqualToString:@"OnDemand"])
                onDemand = [(NSNumber *)[soundSetting objectForKey:key] boolValue];
        }
        
        if (filename) {
            channelBuffer = [ChannelBuffer channelBufferWithCapacity:count soundName:filename category:category easeOutDuration:easeOutDuration loop:loop onDemand:onDemand];
            [queuedChannels setValue:channelBuffer forKey:soundKey];
        }
	}
	
	// Add sounds on main thread
	NSArray *ambientAudio = (NSArray *)[audioSettings objectForKey:@"AmbientAudio"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 queuedChannels, @"queuedChannels",
								 audioKey, @"audioKey",
								 caller, @"caller",
								 callback, @"callback",
								 nil];
	if (ambientAudio != nil)
		[dict setObject:ambientAudio forKey:@"ambientAudio"];
	
    if (caller && callback)
        [self performSelectorOnMainThread:@selector(settingsDidLoadWithArgs:)
                               withObject:dict
                            waitUntilDone:YES];
    else
        [self settingsDidLoadWithArgs:dict];

	[pool release];
}

- (void)settingsDidLoadWithArgs:(NSDictionary *)args {
	NSDictionary *queuedChannels = (NSDictionary *)[args objectForKey:@"queuedChannels"];
	NSArray *ambientAudio = (NSArray *)[args objectForKey:@"ambientAudio"];
	
	for (NSString *key in queuedChannels)
		[self addChannelBuffer:[queuedChannels objectForKey:key] withKey:key];
	for (NSString *key in ambientAudio)
		[self addAmbientAudioKey:key];
	
	NSString *key = (NSString *)[args objectForKey:@"audioKey"];
	//NSString *errorMsg = (audioSettings) ? nil : [NSString stringWithFormat:
	//											  @"AudioPlayer could not find plist named %@.", plistPath];
	NSObject *caller = (NSObject *)[args objectForKey:@"caller"];
    NSString *callbackString = (NSString *)[args objectForKey:@"callback"];
    
    if (caller && callbackString) {
        SEL callback = NSSelectorFromString(callbackString);
        NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:[caller methodSignatureForSelector:callback]];
        [invoc setTarget:caller];
        [invoc setSelector:callback];
        [invoc setArgument:&key atIndex:2];
        //[invoc setArgument:&errorMsg atIndex:3];
        [invoc invoke];
    }
}

- (void)advanceTime:(double)time {
	[mJuggler advanceTime:time];
}

- (void)pause {
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = [mPlayableChannelBuffers objectForKey:key];
		[channelBuffer pause];
	}
}

- (void)resume {
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = [mPlayableChannelBuffers objectForKey:key];
		[channelBuffer resume];
	}
}

- (void)stop {
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = [mPlayableChannelBuffers objectForKey:key];
		[channelBuffer stop];
	}
}

- (void)stopEaseOutSounds {
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = [mPlayableChannelBuffers objectForKey:key];
		[channelBuffer stopEaseOut];
	}
}

- (void)stopSilencedSounds {
	for (NSString *key in mSilencedChannelBuffers) {
		ChannelBuffer *channelBuffer = [mSilencedChannelBuffers objectForKey:key];
		[channelBuffer stop];
	}
}

- (BOOL)soundShouldPlay:(NSString *)key {
	return [mSilencedChannelBuffers objectForKey:key] == nil;
}

- (void)playSoundWithKey:(NSString *)key {
	[self playSoundWithKey:key volume:1.0f];
}

- (void)playSoundWithKey:(NSString *)key volume:(float)volume {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer playWithVolume:volume];
	//NSLog(@"SOUND: %@", key);
}

- (void)playSoundWithKey:(NSString *)key volume:(float)volume pitch:(float)pitch {
    ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer playWithVolume:volume pitch:pitch];
}

- (void)playSoundWithKey:(NSString *)key volume:(float)volume easeInDuration:(float)duration {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer playWithVolume:volume easeInDuration:duration];
}

- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range {
	[self playRandomSoundWithKeyPrefix:key range:range volume:1.0f];
}

- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range volume:(float)volume {
	int index = RANDOM_INT(1, MAX(1,range));
	[self playSoundWithKey:[NSString stringWithFormat:@"%@%d", key, index] volume:volume];
}

- (void)playRandomSoundWithKeyPrefix:(NSString *)key range:(int)range volume:(float)volume pitch:(float)pitch {
    int index = RANDOM_INT(1, MAX(1,range));
	[self playSoundWithKey:[NSString stringWithFormat:@"%@%d", key, index] volume:volume pitch:pitch];
}

- (void)pauseSoundWithKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer pause];
}

- (void)resumeSoundWithKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer resume];
}

- (void)stopSoundWithKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer stop];
}

- (void)stopEaseOutSoundWithKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer stopEaseOut];
}

- (void)stopSoundWithKey:(NSString *)key easeOutDuration:(float)duration {
	ChannelBuffer *channelBuffer = [self playableChannelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer stopWithEaseOutDuration:duration];
}

- (void)setVolume:(float)volume forSoundWithKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [self channelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer setVolume:volume];
}

- (void)setVolume:(float)volume forSoundWithKey:(NSString *)key easeDuration:(float)duration {
	ChannelBuffer *channelBuffer = [self channelBufferForKey:key];
	
	if (channelBuffer != nil)
		[channelBuffer setVolume:volume easeDuration:duration];
}

- (void)addChannelBuffer:(ChannelBuffer *)channelBuffer withKey:(NSString *)key {
	if (mAudioSettings & channelBuffer.category)
		[mPlayableChannelBuffers setObject:channelBuffer forKey:key];
	else
		[mSilencedChannelBuffers setObject:channelBuffer forKey:key];
	channelBuffer.juggler = mJuggler;
}

- (ChannelBuffer *)channelBufferForKey:(NSString *)key {
	ChannelBuffer *channelBuffer = [mPlayableChannelBuffers objectForKey:key];
	
	if (channelBuffer == nil)
		channelBuffer = [mSilencedChannelBuffers objectForKey:key];
	return channelBuffer;
}

- (ChannelBuffer *)playableChannelBufferForKey:(NSString *)key {
	return [mPlayableChannelBuffers objectForKey:key];
}

- (void)addSoundWithKey:(NSString *)key count:(uint)count filename:(NSString *)filename category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand {
	ChannelBuffer *channelBuffer = [ChannelBuffer channelBufferWithCapacity:count soundName:filename category:category easeOutDuration:duration loop:loop onDemand:onDemand];
	[self addChannelBuffer:channelBuffer withKey:key];
}

- (void)removeSoundWithKey:(NSString *)key {
	[mPlayableChannelBuffers removeObjectForKey:key];
	[mSilencedChannelBuffers removeObjectForKey:key];
}

- (void)removeAllSounds {	
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = (ChannelBuffer *)[mPlayableChannelBuffers objectForKey:key];
		[channelBuffer stop];
	}
	[mPlayableChannelBuffers removeAllObjects];
	[mSilencedChannelBuffers removeAllObjects];
	[mAmbientAudio removeAllObjects];
}

- (float)fadeOutDuration {
	float duration = 0;
	
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = (ChannelBuffer *)[mPlayableChannelBuffers objectForKey:key];
		
		if (channelBuffer.easeOutDuration > duration)
			duration = channelBuffer.easeOutDuration;
	}
	return duration;
}

- (void)fadeAllSounds {
	if (mMarkedForDestruction)
		return;
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = (ChannelBuffer *)[mPlayableChannelBuffers objectForKey:key];
		[channelBuffer fadeAllSounds];
	}
}

- (void)fadeAndMarkForDestruction {
	if (mMarkedForDestruction)
		return;
	mMarkedForDestruction = 1;
	
	for (NSString *key in mPlayableChannelBuffers) {
		ChannelBuffer *channelBuffer = (ChannelBuffer *)[mPlayableChannelBuffers objectForKey:key];
		[channelBuffer fadeAllSounds];
	}
	[[mJuggler delayInvocationAtTarget:self byTime:[self fadeOutDuration]] markForDestruction];
}

- (BOOL)markedForDestruction {
	return (mMarkedForDestruction == 2);
}

- (void)markForDestruction {
	if (mMarkedForDestruction == 1)
		mMarkedForDestruction = 2;
}

- (void)addAmbientAudioKey:(NSString *)key {
	[mAmbientAudio addObject:key];
}

- (void)destroyAudioPlayer {
	[mJuggler removeAllObjects];
}

- (void)dealloc {
	[mAmbientAudio release]; mAmbientAudio = nil;
	[mPlayableChannelBuffers release]; mPlayableChannelBuffers = nil;
	[mSilencedChannelBuffers release]; mSilencedChannelBuffers = nil;
	[mJuggler release]; mJuggler = nil;
	[super dealloc];
	
	NSLog(@"=========== AudioPlayer Dealloc'ed ===========");
}

@end
