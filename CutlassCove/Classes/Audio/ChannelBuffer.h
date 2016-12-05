//
//  ChannelBuffer.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AUDIO_CATEGORY_SFX 1
#define AUDIO_CATEGORY_MUSIC 2


@interface ChannelBuffer : NSObject {
	BOOL mPaused;
    BOOL mOnDemand;
    BOOL mLoop;
	int mCategory;
    uint mCapacity;
    float mEaseOutDuration;
    SPSound *mSound;
    
	NSMutableArray *mBusy;
	NSMutableArray *mIdle;
	NSMutableArray *mStopping;
	SPJuggler *mJuggler;
}

@property (nonatomic,readonly) int category;
@property (nonatomic,readonly) float easeOutDuration;
@property (nonatomic,readonly) uint numActiveChannels;
@property (nonatomic,retain) SPJuggler *juggler;

+ (ChannelBuffer *)channelBufferWithCapacity:(uint)capacity soundName:(NSString *)soundName category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand;
- (id)initWithCapacity:(uint)capacity soundName:(NSString *)soundName category:(int)category easeOutDuration:(float)duration loop:(BOOL)loop onDemand:(BOOL)onDemand;

- (void)play;
- (void)playWithVolume:(float)volume;
- (void)playWithVolume:(float)volume pitch:(float)pitch;
- (void)playWithVolume:(float)volume easeInDuration:(float)duration;
- (void)playWithVolume:(float)volume pitch:(float)pitch easeInDuration:(float)duration;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)stopEaseOut;
- (void)stopWithEaseOutDuration:(float)duration;
- (void)setVolume:(float)volume;
- (void)setVolume:(float)volume easeDuration:(float)duration;
- (void)fadeAllSounds;

@end
