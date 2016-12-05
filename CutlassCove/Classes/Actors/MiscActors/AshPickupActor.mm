//
//  AshPickupActor.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AshPickupActor.h"
#import "Ash.h"
#import "Cannonball.h"
#import "NumericValueChangedEvent.h"
#import "GameSettings.h"
#import "GameController.h"
#import "Globals.h"

@implementation AshPickupActor

- (id)initWithActorDef:(ActorDef *)def ashKey:(uint)ashKey duration:(float)duration {
    if (self = [super initWithActorDef:def category:CAT_PF_PICKUPS duration:duration]) {
        mAshKey = ashKey;
		[self setupActorCostume];
    }
    return self;
}

- (void)setupActorCostume {
    if (mPickupBase)
        return;
    mFlipCostume = [[SPSprite alloc] init];
    [self addChild:mFlipCostume];
    
    mCostume = [[SPSprite alloc] init];
    [mFlipCostume addChild:mCostume];
    
    mPickup = [[SPSprite alloc] init];
    [mCostume addChild:mPickup];
    
    SPTexture *pickupTexture = [mScene textureByName:@"pickup-wheel"];
    
    // Base
    mPickupBase = [[SPSprite alloc] init];
    [mPickup addChild:mPickupBase];
    
    SPImage *baseImage = [SPImage imageWithTexture:pickupTexture];
    baseImage.x = -baseImage.width / 2;
    baseImage.y = -baseImage.height / 2;
    baseImage.color = 0xaaaaaa;
    [mPickupBase addChild:baseImage];
    
    baseImage = [SPImage imageWithTexture:pickupTexture];
    baseImage.x = -baseImage.width / 2;
    baseImage.y = -baseImage.height / 2;
    baseImage.color = 0xaaaaaa;
    
    SPSprite *sprite = [SPSprite sprite];
    sprite.rotation = PI / 4;
    [sprite addChild:baseImage];
    [mPickupBase addChild:sprite];
    
    // Highlight
    mPickupHighlight = [[SPSprite alloc] init];
    [mPickup addChild:mPickupHighlight];
    
    SPImage *highlightImage = [SPImage imageWithTexture:pickupTexture];
    highlightImage.x = -highlightImage.width / 2;
    highlightImage.y = -highlightImage.height / 2;
    [mPickupHighlight addChild:highlightImage];
    
    /*
    highlightImage = [SPImage imageWithTexture:pickupTexture];
    highlightImage.x = -highlightImage.width / 2;
    highlightImage.y = -highlightImage.height / 2;
    
    sprite = [SPSprite sprite];
    sprite.rotation = PI / 4;
    [sprite addChild:highlightImage];
    [mPickupHighlight addChild:sprite];
    */
    
    // Ash
    mAshSprite = [[SPSprite alloc] init];
    [mCostume addChild:mAshSprite];
    
    NSString *texturePrefix = [Ash texturePrefixForKey:mAshKey];
    mAshClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:texturePrefix] fps:[Cannonball fps]];
    mAshClip.x = -mAshClip.width / 2;
    mAshClip.y = -mAshClip.height / 2;
    [mScene.juggler addObject:mAshClip];
    
    mAshSprite.scaleX = mAshSprite.scaleY = 12.5f / mAshClip.width;
    [mAshSprite addChild:mAshClip];
    
    SPTween *tween = [SPTween tweenWithTarget:mPickup time:3.0f];
    [tween animateProperty:@"rotation" targetValue:2 * PI];
    tween.loop = SPLoopTypeRepeat;
    [mScene.juggler addObject:tween];
    
    tween = [SPTween tweenWithTarget:mPickup time:tween.time];
    [tween animateProperty:@"scaleX" targetValue:0.5f];
    [tween animateProperty:@"scaleY" targetValue:0.5f];
    tween.loop = SPLoopTypeReverse;
    [mScene.juggler addObject:tween];
    
    tween = [SPTween tweenWithTarget:mPickupHighlight time:1.5f];
    [tween animateProperty:@"rotation" targetValue:-2 * PI];
    tween.loop = SPLoopTypeRepeat;
    [mScene.juggler addObject:tween];
    
    // Hint
    if ([GCTRL.gameSettings settingForKey:[Ash gameSettingForKey:mAshKey]] == NO) {
        mHint = [[SPTextField textFieldWithWidth:100
                                          height:24
                                            text:[Ash hintForKey:mAshKey]
                                        fontName:mScene.fontKey
                                        fontSize:20
                                           color:0xfcc30e] retain];
        mHint.x = (mPickupBase.x - mPickupBase.width / 2) + (mPickupBase.width - mHint.width) / 2;
        mHint.y = mPickupBase.y + mPickupBase.height / 4;
        mHint.hAlign = SPHAlignCenter;
        mHint.vAlign = SPVAlignTop;
        mHint.compiled = NO;
        [mCostume addChild:mHint];
    }
}

- (void)flip:(BOOL)enable {
    mFlipCostume.scaleX = (enable) ? -1 : 1;
}

- (void)playLootSound {
	[mScene.audioPlayer playSoundWithKey:[Ash soundNameForKey:mAshKey]];
}

- (void)loot:(PlayerShip *)ship {
	if (mLooted == YES)
		return;
	mLooted = YES;
	[mScene.juggler removeTweensWithTarget:self]; // Remove delayed invocation
	[self playLootSound];
	
    [[self retain] autorelease];
	[mScene.spriteLayerManager removeChild:self withCategory:mCategory];
	mCategory = CAT_PF_DECK;
	[mScene.spriteLayerManager addChild:self withCategory:mCategory];
	self.alpha = 1.0f;
	
	SPTween *tween = [SPTween tweenWithTarget:mCostume time:1.0f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween animateProperty:@"scaleX" targetValue:3.0f];
	[tween animateProperty:@"scaleY" targetValue:3.0f];
	[tween addEventListener:@selector(onLooted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
    
    [NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_ASH_PICKUP_LOOTED value:[NSNumber numberWithUnsignedInt:mAshKey] bubbles:NO];
}

- (void)onExpired:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_ASH_PICKUP_EXPIRED]];
    [super onExpired:event];
}

- (void)dealloc {
    if (mHint && mLooted) {
        GameController *gc = GCTRL;
        NSString *settingKey = [Ash gameSettingForKey:mAshKey];
        
        if (settingKey && [gc.gameSettings settingForKey:settingKey] == NO)
            [gc.gameSettings setSettingForKey:settingKey value:YES];
    }
    
    [mScene.juggler removeTweensWithTarget:mPickupHighlight];
    [mScene.juggler removeTweensWithTarget:mPickup];
    [mScene.juggler removeTweensWithTarget:mCostume];
    [mScene.juggler removeObject:mAshClip];
    [mAshClip release]; mAshClip = nil;
    [mAshSprite release]; mAshSprite = nil;
    [mPickupBase release]; mPickupBase = nil;
    [mPickupHighlight release]; mPickupHighlight = nil;
    [mPickup release]; mPickup = nil;
    [mHint release]; mHint = nil;
    [mCostume release]; mCostume = nil;
    [mFlipCostume release]; mFlipCostume = nil;
    [super dealloc];
}

@end
