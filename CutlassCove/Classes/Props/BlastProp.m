//
//  BlastProp.m
//  CutlassCove
//
//  Created by Paul McPhee on 25/04/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "BlastProp.h"

@interface BlastProp ()

- (void)playBlastSound;
- (void)onBlasted:(SPEvent *)event;
- (void)onAftermathCompleted:(SPEvent *)event;

@end


@implementation BlastProp

@synthesize blastSound = mBlastSound;

+ (float)blastAnimationDuration {
    return 0.15f;
}

+ (float)aftermathAnimationDuration {
    return 0.9f;
}

- (id)initWithCategory:(int)category resourceKey:(NSString *)resourceKey {
#ifdef DEBUG    
    if ([self isMemberOfClass:[BlastProp class]]) 
    {
        [self release];
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to initialize abstract class BlastProp."];        
        return nil;
    }    
#endif
    
    if ((self = [super initWithCategory:category]))
    {
        mHasBlasted = NO;
        mBlastScale = 1.75f;
        mBlastDuration = [BlastProp blastAnimationDuration];
        mAftermathDuration = [BlastProp aftermathAnimationDuration];
        mBlastSound = nil;
        mBlastTexture = nil;
        mCostume = nil;
        
        mResourceKey = [resourceKey copy];
		mResources = nil;
		[self checkoutPooledResources];
    }
    return self;
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mCostume];
    [self checkinPooledResources];
    [mBlastSound release];
    [mBlastTexture release];
    [mCostume release];
    [mResourceKey release]; mResourceKey = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mCostume == nil) {
        mCostume = [[SPSprite alloc] init];
        
        SPImage *blastImage = [SPImage imageWithTexture:mBlastTexture];
        blastImage.x = -blastImage.width / 2;
        blastImage.y = -blastImage.height / 2;
        [mCostume addChild:blastImage];
    }
    
    mCostume.alpha = 0;
    mCostume.scaleX = mCostume.scaleY = mBlastScale;
    [self addChild:mCostume];
}

- (void)blast {
    if (mHasBlasted)
        return;
    mHasBlasted = YES;
    
    if (([mResources startTweenForKey:RESOURCE_KEY_BP_BLAST_TWEEN] && [mResources startTweenForKey:RESOURCE_KEY_BP_AFTERMATH_TWEEN]) == NO) {
        [mScene.juggler removeTweensWithTarget:mCostume];
        
        SPTween *blastTween = [SPTween tweenWithTarget:mCostume time:mBlastDuration];
        [blastTween animateProperty:@"alpha" targetValue:1];
        [mScene.juggler addObject:blastTween];
        
        SPTween *aftermathTween = [SPTween tweenWithTarget:mCostume time:mAftermathDuration];
        [aftermathTween animateProperty:@"alpha" targetValue:0];
        aftermathTween.delay = blastTween.delay + blastTween.time;
        [mScene.juggler addObject:aftermathTween];
        
        [blastTween addEventListener:@selector(onBlasted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [aftermathTween addEventListener:@selector(onAftermathCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    }
    
    [self playBlastSound];
}

- (void)playBlastSound {
    if (self.blastSound)
        [mScene.audioPlayer playSoundWithKey:mBlastSound];
}

- (void)blastDamage { }

- (void)aftermath {
    [mScene removeProp:self];
}

- (void)onBlasted:(SPEvent *)event {
    [self blastDamage];
}

- (void)onAftermathCompleted:(SPEvent *)event {
    [self aftermath];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_BP_BLAST_TWEEN:
            [self blastDamage];
            break;
        case RESOURCE_KEY_BP_AFTERMATH_TWEEN:
            [self aftermath];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_BLAST_PROP] checkoutPoolResourcesForKey:mResourceKey] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED BLAST CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mCostume == nil)
            mCostume = [(SPSprite *)[mResources displayObjectForKey:RESOURCE_KEY_BP_COSTUME] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_BLAST_PROP] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

@end
