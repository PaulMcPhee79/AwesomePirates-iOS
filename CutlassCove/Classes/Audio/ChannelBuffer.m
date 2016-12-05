//
//  ChannelBuffer.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ChannelBuffer.h"
#import "AudioPlayer.h"
#import "GameController.h"

@interface ChannelBuffer ()

- (void)processCompletedChannel:(SPSoundChannel *)channel srcCache:(NSMutableArray *)src destCache:(NSMutableArray *)dest;
- (void)addSoundChannel:(SPSoundChannel *)channel;
- (void)setVolume:(float)volume forChannel:(SPSoundChannel *)channel easeDuration:(float)duration;
- (void)setPitch:(float)pitch forChannel:(SPSoundChannel *)channel;
- (void)fadeVolumeForChannel:(SPSoundChannel *)channel easeDuration:(float)duration;
- (void)playWithVolume:(float)volume pitch:(float)pitch easeInDuration:(float)duration channel:(SPSoundChannel *)channel;
- (void)onChannelVolumeFaded:(SPEvent *)event;
- (void)onSoundCompleted:(SPEvent *)event;

@end


@implementation ChannelBuffer

@synthesize category = mCategory;
@synthesize easeOutDuration = mEaseOutDuration;
@synthesize juggler = mJuggler;
@dynamic numActiveChannels;

+ (ChannelBuffer *)channelBufferWithCapacity:(uint)capacity soundName:(NSString *)soundName category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand {
	return [[[ChannelBuffer alloc] initWithCapacity:capacity soundName:soundName category:category easeOutDuration:duration loop:loop onDemand:onDemand] autorelease];
}

- (id)initWithCapacity:(uint)capacity soundName:(NSString *)soundName category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand {
	if (self = [super init]) {
		mPaused = NO;
        mCapacity = capacity;
		mCategory = category;
        mEaseOutDuration = duration;
        mLoop = loop;
        mOnDemand = onDemand;
		mBusy = [[NSMutableArray arrayWithCapacity:capacity] retain];
		mIdle = [[NSMutableArray arrayWithCapacity:capacity] retain];
		mStopping = [[NSMutableArray arrayWithCapacity:capacity] retain];
		
		if (soundName != nil) {
            @try {
                mSound = [[SPSound soundWithContentsOfFile:soundName] retain];
                
                if (onDemand == NO) {
                    for (int i = 0; i < capacity; ++i) {
                        SPSoundChannel *channel = [mSound createChannel];
                        channel.loop = loop;
                        [self addSoundChannel:channel];
                    }
                }
            } @catch (NSException *e) {
                [mSound release]; mSound = nil;
                NSLog(@"%@", e.description);
            }
		}
		mJuggler = nil;
	}
	return self;
}

- (id)init {
	assert(0);
    return nil;
}

- (uint)numActiveChannels {
    return mBusy.count + mStopping.count;
}

- (void)processCompletedChannel:(SPSoundChannel *)channel srcCache:(NSMutableArray *)src destCache:(NSMutableArray *)dest {
    if (mOnDemand == NO)
        [dest addObject:channel];
    else
        [channel removeEventListener:@selector(onSoundCompleted:) atObject:self forType:SP_EVENT_TYPE_SOUND_COMPLETED];
    [src removeObject:channel];
}

- (void)addSoundChannel:(SPSoundChannel *)channel {
    if (channel == nil)
        return;
    
	[channel stop];
    [channel removeEventListener:@selector(onSoundCompleted:) atObject:self forType:SP_EVENT_TYPE_SOUND_COMPLETED];
	[channel addEventListener:@selector(onSoundCompleted:) atObject:self forType:SP_EVENT_TYPE_SOUND_COMPLETED];
	[mIdle addObject:channel];
}

- (void)setVolume:(float)volume forChannel:(SPSoundChannel *)channel easeDuration:(float)duration {
	[mJuggler removeTweensWithTarget:channel];
	duration = MAX(0, duration);
	
	if (mJuggler && SP_IS_FLOAT_EQUAL(duration, 0) == NO) {
		SPTween *tween = [SPTween tweenWithTarget:channel time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"volume" targetValue:volume];
		[mJuggler addObject:tween];
	} else {
		channel.volume = volume;
	}
}

- (void)setPitch:(float)pitch forChannel:(SPSoundChannel *)channel {
    channel.pitch = pitch;
}

- (void)fadeVolumeForChannel:(SPSoundChannel *)channel easeDuration:(float)duration {
	assert(mJuggler);
	[mJuggler removeTweensWithTarget:channel];
	
	SPTween *tween = [SPTween tweenWithTarget:channel time:duration transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"volume" targetValue:0];
	[tween addEventListener:@selector(onChannelVolumeFaded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mJuggler addObject:tween];
}

- (void)onChannelVolumeFaded:(SPEvent *)event {
	SPTween *tween = (SPTween *)event.currentTarget;
	SPSoundChannel *channel = (SPSoundChannel *)tween.target;
	[channel stop];
	
	if (channel && [mStopping containsObject:channel])
        [self processCompletedChannel:channel srcCache:mStopping destCache:mIdle];
}

- (void)setVolume:(float)volume {
	for (SPSoundChannel *channel in mBusy)
		channel.volume = volume;
}

- (void)setVolume:(float)volume easeDuration:(float)duration {
	for (SPSoundChannel *channel in mBusy)
		[self setVolume:volume forChannel:channel easeDuration:duration];
}

- (void)play {
	[self playWithVolume:1.0f];
}

- (void)playWithVolume:(float)volume {
	[self playWithVolume:volume easeInDuration:0];
}

- (void)playWithVolume:(float)volume pitch:(float)pitch {
    [self playWithVolume:volume pitch:pitch easeInDuration:0];
}

- (void)playWithVolume:(float)volume easeInDuration:(float)duration {
    [self playWithVolume:volume pitch:1.0f easeInDuration:duration];
}

- (void)playWithVolume:(float)volume pitch:(float)pitch easeInDuration:(float)duration {
    SPSoundChannel *channel = nil;
	
	if (mIdle.count > 0) {
		channel = [[mIdle lastObject] retain];
		[mIdle removeObject:channel];
    } else if (mOnDemand && self.numActiveChannels < mCapacity) {
        channel = [mSound createChannel];
        channel.loop = mLoop;
        [self addSoundChannel:channel];
        [self playWithVolume:volume easeInDuration:duration];
        return;
	} else if (mStopping.count > 0) {
		channel = [[mStopping objectAtIndex:0] retain];
		[mStopping removeObject:channel];
	} else if (mBusy.count > 0) {
		channel = [[mBusy objectAtIndex:0] retain];
		[mBusy removeObject:channel];
	}
    
	[self playWithVolume:volume pitch:pitch easeInDuration:duration channel:channel];
	[channel release];
}

- (void)playWithVolume:(float)volume pitch:(float)pitch easeInDuration:(float)duration channel:(SPSoundChannel *)channel {
    if (channel == nil)
        return;
	[mJuggler removeTweensWithTarget:channel];
	channel.volume = 0;
	[channel stop];
	[self setVolume:volume forChannel:channel easeDuration:duration];
    [self setPitch:pitch forChannel:channel];
	[channel play];
	[mBusy addObject:channel];
}

- (void)pause {
	if (mPaused == YES)
		return;
	for (SPSoundChannel *channel in mBusy)
		[channel pause];
	mPaused = YES;
}

- (void)resume {
	if (mPaused == NO)
		return;
	for (SPSoundChannel *channel in mBusy)
		[channel play];
	mPaused = NO;
}

- (void)stop {	
	if (mBusy.count > 0) {
		for (int i = mBusy.count - 1; i >= 0; --i) {
			SPSoundChannel *channel = (SPSoundChannel *)[mBusy objectAtIndex:i];
			[mJuggler removeTweensWithTarget:channel];
			[channel stop];
            [self processCompletedChannel:channel srcCache:mBusy destCache:mIdle];
		}
	}
	
	if (mStopping.count > 0) {
		for (int i = mStopping.count - 1; i >= 0; --i) {
			SPSoundChannel *channel = (SPSoundChannel *)[mStopping objectAtIndex:i];
			[mJuggler removeTweensWithTarget:channel];
			[channel stop];
            [self processCompletedChannel:channel srcCache:mStopping destCache:mIdle];
		}
	}
}

- (void)stopEaseOut {
	if (SP_IS_FLOAT_EQUAL(mEaseOutDuration,0) == NO)
		[self stopWithEaseOutDuration:mEaseOutDuration];
	else
		[self stop];
}

- (void)stopWithEaseOutDuration:(float)duration {
	if (mBusy.count > 0) {
		for (int i = mBusy.count - 1; i >= 0; --i) {
			SPSoundChannel *channel = (SPSoundChannel *)[mBusy objectAtIndex:i];
			[mStopping addObject:channel];
			[mBusy removeObjectAtIndex:i];
			//[mJuggler removeTweensWithTarget:channel]; // Done in fadeVolumeForChannel:
			[self fadeVolumeForChannel:channel easeDuration:duration];
		}
	} else {
		[self stop];
	}
}

- (void)onSoundCompleted:(SPEvent *)event {
	SPSoundChannel *channel = (SPSoundChannel *)event.currentTarget;
    [self processCompletedChannel:channel srcCache:mBusy destCache:mIdle];
}

- (void)fadeAllSounds {
	[self stopEaseOut];
}

- (void)dealloc {
	[self stop];
	
	for (SPSoundChannel *channel in mIdle)
		[channel removeEventListener:@selector(onSoundCompleted:) atObject:self forType:SP_EVENT_TYPE_SOUND_COMPLETED];
	[mBusy release]; mBusy = nil;
	[mIdle release]; mIdle = nil;
	[mStopping release]; mStopping = nil;
	[mJuggler release]; mJuggler = nil;
    [mSound release]; mSound = nil;
	[super dealloc];
}

@end
