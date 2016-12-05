//
//  SpeedboatSummary.m
//  CutlassCove
//
//  Created by Paul McPhee on 9/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeedboatSummary.h"
#import "GuiHelper.h"
#import "GameController.h"

@interface SpeedboatSummary ()

- (void)destroySpeedboatSummary;

@end


@implementation SpeedboatSummary

- (void)setupProp {
    GameController *gc = GCTRL;
    
[RESM pushItemOffsetWithAlignment:RACenter];
    mCanvasSprite = [[SPSprite alloc] init];
    [self addChild:mCanvasSprite];
    
    // Background Scroll
    SPTexture *scrollTexture = [GuiHelper cachedScrollTextureByName:@"scroll-quarter-large" scene:mScene];
    SPImage *scrollImage = [SPImage imageWithTexture:scrollTexture];
    SPSprite *scrollSprite = [SPSprite sprite];
    [scrollSprite addChild:scrollImage];
    
    scrollSprite.scaleX = scrollSprite.scaleY = 300.0f / scrollSprite.width;
    scrollSprite.rx = 90;
    scrollSprite.ry = 32;
    [mCanvasSprite addChild:scrollSprite];
    
    // Speedboat Sprite
    mSpeedboatSprite = [[SPSprite alloc] init];
    [self addChild:mSpeedboatSprite];
    
    SPImage *bannerImage = [SPImage imageWithTexture:[mScene textureByName:@"race-banner"]];
    bannerImage.x = -(bannerImage.width - 13);
    bannerImage.y = 10;
    [mSpeedboatSprite addChild:bannerImage];
    
    SPImage *speedboatImage = [SPImage imageWithTexture:[mScene textureByName:@"shady-speedboat"]];
    [mSpeedboatSprite addChild:speedboatImage];
    
    mSpeedText = [[SPTextField textFieldWithWidth:92
                                           height:22
                                             text:[NSString stringWithFormat:@"%.3f Mph", gc.thisTurn.speed]
                                         fontName:mScene.fontKey
                                         fontSize:18
                                            color:0] retain];
    mSpeedText.x = bannerImage.x + 16;
    mSpeedText.y = bannerImage.y + 1;
    mSpeedText.hAlign = SPHAlignRight;
    mSpeedText.vAlign = SPVAlignTop;
    [mSpeedboatSprite addChild:mSpeedText];
    
    mSpeedboatSprite.x = -speedboatImage.width;
    mSpeedboatSprite.ry = 57;
    
    // Laps Sprite
    mLapsSprite = [[SPSprite alloc] init];
    [mCanvasSprite addChild:mLapsSprite];
    
    NSMutableArray *laps = [NSMutableArray arrayWithCapacity:4];
    
    for (int i = 0; i < 4; ++i) {
        SPSprite *sprite = [SPSprite sprite];
        
        // Left-hand column: Lap label
        NSString *lapLabelText = (i < 3) ? [NSString stringWithFormat:@"Lap %d", i+1] : @"Total";
        SPTextField *lapLabel = [SPTextField textFieldWithWidth:40
                                                         height:22
                                                           text:lapLabelText
                                                       fontName:mScene.fontKey
                                                       fontSize:18
                                                          color:0];
        lapLabel.y = i * lapLabel.height;
        lapLabel.hAlign = SPHAlignRight;
        lapLabel.vAlign = SPVAlignTop;
        lapLabel.compiled = NO;
        [sprite addChild:lapLabel];
        
        // Right-hand column: Lap times
        NSString *lapTimeText = [NSString stringWithFormat:@"%.2f sec", ((i < 3) ? [gc.thisTurn timeForLap:i+1] : [gc.thisTurn totalRaceTime])];
        SPTextField *lapTime = [SPTextField textFieldWithWidth:100
                                                        height:22
                                                          text:lapTimeText
                                                      fontName:mScene.fontKey
                                                      fontSize:18
                                                         color:0];
        lapTime.x = lapLabel.x + lapLabel.width + 16;
        lapTime.y = i * lapTime.height;
        lapTime.hAlign = SPHAlignLeft;
        lapTime.vAlign = SPVAlignTop;
        lapTime.compiled = NO;
        [sprite addChild:lapTime];
        
        sprite.x = -(lapLabel.width + 12);
        sprite.y = -sprite.height / 2;
        sprite.alpha = 0;
        [laps addObject:sprite];
        [mLapsSprite addChild:sprite];
    }
    
    mLaps = [[NSArray alloc] initWithArray:laps];
    mLapsSprite.x = mScene.viewWidth / 2;
    mLapsSprite.ry = 80 + mLapsSprite.height / 2;

    // Buttons
    [self addMenuButtons];
    
[RESM popOffset];
}

- (float)displayGameOverSequence {
    [mScene.juggler removeTweensWithTarget:mSpeedboatSprite];
    
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    SPTween *translationTween = [SPTween tweenWithTarget:mSpeedboatSprite time:2.0f transition:SP_TRANSITION_EASE_OUT];
	[translationTween animateProperty:@"x" targetValue:270 + offset.x];
	[mScene.juggler addObject:translationTween];
	return translationTween.time;
}

- (float)stampsDelay {
    return 1.0f;
}

- (float)displayStamps {
    float delay = 0, tweenDuration = 0.25f;
    
    [mScene.audioPlayer playSoundWithKey:@"CrewCelebrate"];
    
    for (SPSprite *sprite in mLaps) {
        SPTween *alphaTween = [SPTween tweenWithTarget:sprite time:tweenDuration transition:SP_TRANSITION_LINEAR];
        [alphaTween animateProperty:@"alpha" targetValue:1];
        alphaTween.delay = delay;
        [mScene.juggler addObject:alphaTween];
        delay += tweenDuration / 2;
    }
    
    return mLaps.count * tweenDuration;
}

- (void)destroy {
    [self destroySpeedboatSummary];
}

- (void)destroySpeedboatSummary {
    [mScene.juggler removeTweensWithTarget:mSpeedboatSprite];
    [mScene.juggler removeTweensWithTarget:mLapsSprite];
    
    for (SPSprite *sprite in mLaps)
        [mScene.juggler removeTweensWithTarget:sprite];
}

- (void)dealloc {
    [self destroySpeedboatSummary];
    [mSpeedText release]; mSpeedText = nil;
    [mLaps release]; mLaps = nil;
    [mSpeedboatSprite release]; mSpeedboatSprite = nil;
    [mLapsSprite release]; mLapsSprite = nil;
    [super dealloc];
}

@end
