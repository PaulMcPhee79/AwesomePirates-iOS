//
//  CombatText.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 22/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

// NSValue

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface CTAnimation : NSObject {
    float mScaleX;
    float mScaleY;
    float mScaleFactor;
    
    SPSprite *mContainerSprite;
    SPSprite *mAnimatedSprite;
    NSMutableArray *mNonCritUpTweens;
    NSMutableArray *mNonCritDownTweens;
    NSMutableArray *mCritTweens;
}

@property (nonatomic,assign) float scaleX;
@property (nonatomic,assign) float scaleY;
@property (nonatomic,assign) float scaleFactor;
@property (nonatomic,readonly) SPSprite *containerSprite;
@property (nonatomic,readonly) SPSprite *animatedSprite;
@property (nonatomic,readonly) double nonCritUpDelay;
@property (nonatomic,readonly) double nonCritDownDelay;
@property (nonatomic,readonly) double critDelay;

+ (CTAnimation *)animation;
- (void)addTween:(SPTween *)tween crit:(BOOL)crit dir:(int)dir;
- (void)removeTween:(SPTween *)tween;
- (void)reset;

- (void)animateAsNonCritUp:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler;
- (void)animateAsNonCritDown:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler;
- (void)animateAsCrit:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler;
- (void)cleanupWithJuggler:(SPJuggler *)juggler;

@end


@interface CombatText : Prop {
    BOOL mCacheFull;
    
	uint mAnimationIndex;
	uint mColor;
	uint mBufferSize;
	NSMutableArray *mBusy;
	NSMutableArray *mIdle;
	
	NSArray *mCritAnimations;
	NSDictionary *mCombatSpriteCache;
    NSDictionary *mCombatCountCache;
}

@property (nonatomic,assign) uint color;

+ (uint)redCombatTextColor;
+ (uint)yellowCombatTextColor;
+ (uint)greenCombatTextColor;

- (id)initWithCategory:(int)category bufferSize:(uint)bufferSize;
- (void)fillCombatSpriteCache;
- (void)resetCombatSpriteCache;
- (void)prepareForNewGame;
- (void)combatText:(NSString *)text x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops;
- (void)combatText:(NSString *)text x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops color:(uint)color;
- (void)hideAllText;
- (void)cleanUp;

@end
