//
//  CombatText.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 22/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CombatText.h"
#import "ShipFactory.h"
#import "SPPoint_Extension.h"
#import "PlayerDetails.h"
#import "CannonDetails.h"
#import "ThreadSafetyManager.h"
#import "GameController.h"
#import "CCMiscConstants.h"
#import "Globals.h"

//#define COMBAT_TEXT_DEBUG

//const int kCombatBufferCapacity = 20;
const int kRicochetBufferSize = 5;
const uint kCombatCacheNodeSize = 10;
const int kMaxChars = 6;
const float kRicochetFontSize = 32;
const int kOffsetMax = 32;
const int kOffsetMin = 16;
const uint kRicochetTextColor = 0x9c0000;
const uint kRedCombatTextColor = 0xa00000;
const uint kYellowCombatTextColor = 0xfcff1b; // Video color: 0xffdd1b;
const uint kGreenCombatTextColor = 0x037400;
const uint kWhiteCombatTextColor = 0xffffff;

@interface CombatText ()

- (SPSprite *)createCombatTextSpriteWithText:(NSString *)text;
- (SPSprite *)cachedCombatSpriteForKey:(NSString *)key;
- (BOOL)recacheCombatSprite:(SPSprite *)sprite;
- (CTAnimation *)nextAnimation;
- (void)onCombatTweenCompleted:(SPEvent *)event;
//- (void)onRicochetTweenCompleted:(SPEvent *)event;

@end


@implementation CombatText

@synthesize color = mColor;

+ (uint)redCombatTextColor {
	return kRedCombatTextColor;
}

+ (uint)yellowCombatTextColor {
	return kYellowCombatTextColor;
}

+ (uint)greenCombatTextColor {
	return kGreenCombatTextColor;
}

- (id)initWithCategory:(int)category bufferSize:(uint)bufferSize {
	if (self = [super initWithCategory:category]) {
        mCacheFull = NO;
		mBufferSize = MAX(1,bufferSize);
		mAnimationIndex = 0;
		mColor = kYellowCombatTextColor;
		mBusy = [[NSMutableArray alloc] initWithCapacity:mBufferSize];
		mIdle = [[NSMutableArray alloc] initWithCapacity:mBufferSize];
		mCombatSpriteCache = nil;
        mCombatCountCache = nil;
		
		// Init crit details
        double critFrameDuration = (SP_IS_FLOAT_EQUAL(GCTRL.fps, 30.0f) ? 0.05 : 0.0525);
		SPPoint *prevOffset = [SPPoint pointWithX:0 y:0];
		SPPoint *offset = [SPPoint pointWithX:0 y:0];
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:mBufferSize];
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Position offset animations
		for (int i = 0; i < mBufferSize; ++i) {
			float scale = 2.0f, scaleDelta = -0.35f, scaleInc = -0.35f, scaleDeltaReverse = 1.0f;

            // Commented out so that ricochet chain scalings are more distinct.
//			if (RANDOM_INT(0,1)) {
//				scale /= 2;
//				scaleDelta *= -1;
//				scaleInc *= -1;
//			}
			
			CTAnimation *animation = [CTAnimation animation];
            animation.scaleX = animation.scaleY = scale;
			
            // Crits
			for (int j = 0; j < 4; ++j) {
				offset.x = RANDOM_INT(kOffsetMin,kOffsetMax);
				offset.y = RANDOM_INT(kOffsetMin,kOffsetMax);
				
				if (RANDOM_INT(0,1))
					offset.x *= -1;
				if (RANDOM_INT(0,1))
					offset.y *= -1;
				
//                if (fabsf(prevOffset.x + offset.x) > kOffsetMax)
//                    offset.x = (offset.x > 0 ? 1 : -1) * kOffsetMax;
//                if (fabsf(prevOffset.y + offset.y) > kOffsetMax)
//                    offset.y = (offset.y > 0 ? 1 : -1) * kOffsetMax;
                
				// Make sure we're not too close to the previous offset (else the animation looks weak)
				if ([SPPoint distanceSqFromPoint:prevOffset toPoint:offset] < (0.75f * kOffsetMax)) {
					// Flip to diagonally adjacent quadrant
					offset.x *= -1;
					offset.y *= -1;
				}
                
                SPTween *tween = [SPTween tweenWithTarget:animation.animatedSprite time:critFrameDuration];
                [tween animateProperty:@"x" targetValue:offset.x];
                [tween animateProperty:@"y" targetValue:offset.y];
                [tween animateProperty:@"scaleX" targetValue:scale + scaleDelta];
                [tween animateProperty:@"scaleY" targetValue:scale + scaleDelta];
                tween.delay = animation.critDelay;
                [animation addTween:tween crit:YES dir:0];
                
				prevOffset.x = offset.x;
				prevOffset.y = offset.y;
                
//                if (i == 0)
//                    NSLog(@"CombatText Scale: %f", scale + scaleDelta);
				
				if (fabsf(scaleDelta) < scaleDeltaReverse)
					scaleDelta += scaleInc;
				else
					scaleDelta = 1.5f - scale;
			}
            
            SPTween *tween = [SPTween tweenWithTarget:animation.animatedSprite time:0.75f transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"alpha" targetValue:0.0f];
            tween.delay = animation.critDelay;
            [tween addEventListener:@selector(onCombatTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [animation addTween:tween crit:YES dir:0];
            
            // Non-crits
//            tween = [SPTween tweenWithTarget:animation.animatedSprite time:1.0f transition:SP_TRANSITION_LINEAR];
//            [tween animateProperty:@"y" targetValue:-12];
//            [animation addTween:tween crit:NO dir:-1];
//            
//            tween = [SPTween tweenWithTarget:animation.animatedSprite time:0.4f transition:SP_TRANSITION_LINEAR];
//            [tween animateProperty:@"alpha" targetValue:0.0f];
//            tween.delay = 0.5f;
//            [tween addEventListener:@selector(onCombatTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
//            [animation addTween:tween crit:NO dir:-1];
//            
//            tween = [SPTween tweenWithTarget:animation.animatedSprite time:1.0f transition:SP_TRANSITION_LINEAR];
//            [tween animateProperty:@"y" targetValue:12];
//            [animation addTween:tween crit:NO dir:1];
//            
//            tween = [SPTween tweenWithTarget:animation.animatedSprite time:0.4f transition:SP_TRANSITION_LINEAR];
//            [tween animateProperty:@"alpha" targetValue:0.0f];
//            tween.delay = 0.5f;
//            [tween addEventListener:@selector(onCombatTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
//            [animation addTween:tween crit:NO dir:1];
            
			[array addObject:animation];
		}
		
		[pool release];
		pool = nil;
		
		mCritAnimations = [[NSArray alloc] initWithArray:array];
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	// Crit/penalty text
	for (int i = 0; i < mBufferSize; ++i) {
		SPSprite *sprite = [self createCombatTextSpriteWithText:@" "];
        
        if (sprite)
            [mIdle addObject:sprite];
	}
    
    [self resetCombatSpriteCache];
	[mScene addProp:self];
}

- (void)flip:(BOOL)enable {
    float sceneWidth = mScene.viewWidth;
    
    for (CTAnimation *animation in mCritAnimations)
        animation.containerSprite.x = sceneWidth - animation.containerSprite.x;
}

- (void)resetCombatSpriteCache {
    GameController *gc = GCTRL;
    [self hideAllText];
    [gc cacheResource:nil forKey:RESOURCE_CACHE_COMBAT_TEXT];
    [mCombatSpriteCache release]; mCombatSpriteCache = nil;
    [mCombatCountCache release]; mCombatCountCache = nil;
    
    // Prep cache
    NSMutableArray *shipScores = [NSMutableArray arrayWithCapacity:7];
    
	NSArray *shipKeys = [NSArray arrayWithObjects:
						 @"MerchantCaravel",
						 @"MerchantGalleon",
						 @"MerchantFrigate",
                         @"Pirate",
						 @"Navy",
                         @"SilverTrain",
						 nil];
	NSDictionary *shipDetails = [[ShipFactory shipYard] allNpcShipDetails];
	
	for (NSString *key in shipKeys) {
		NSDictionary *shipDict = [shipDetails objectForKey:key];
		NSNumber *shipScore = (NSNumber *)[shipDict objectForKey:@"infamyBonus"];
		[shipScores addObject:shipScore];
	}
    
    // Add overboard score bonus
    [shipScores addObject:[NSNumber numberWithInt:CC_OVERBOARD_SCORE_BONUS]];
    
    uint scoreMultiplier = gc.playerDetails.scoreMultiplier;
    NSMutableDictionary *keyCache = [[NSMutableDictionary alloc] initWithCapacity:shipScores.count];
    NSMutableDictionary *countCache = [[NSMutableDictionary alloc] initWithCapacity:shipScores.count];
    
    float notorietyFactor = [Potion notorietyFactorForPotion:[mScene potionForKey:POTION_NOTORIETY]];
    
    int scoreIndex = 0;
    uint ricochetBonus = [Potion ricochetBonusForPotion:[mScene potionForKey:POTION_RICOCHET]];
    
    for (NSNumber *shipScore in shipScores) {
        for (int crit = 1; crit <= 2; ++crit) {
            float critBonus = crit == 1 ? 1.0f : 1.25f;
            
            {
                uint cacheSize = (scoreIndex < (shipScores.count-1)) ? kCombatCacheNodeSize / 2 : kCombatCacheNodeSize;
                uint infamyBonus = (uint)([shipScore intValue] * critBonus);
                infamyBonus = (uint)(infamyBonus * scoreMultiplier * notorietyFactor);
                
                NSString *text = [NSString stringWithFormat:@"%u", infamyBonus];
                [keyCache setObject:[NSMutableArray arrayWithCapacity:cacheSize] forKey:text];
                
                NSNumber *prevCacheSize = (NSNumber *)[countCache objectForKey:text];
                
                if (prevCacheSize == nil || [prevCacheSize unsignedIntValue] < cacheSize)
                    [countCache setObject:[NSNumber numberWithUnsignedInt:cacheSize] forKey:text];
            }
            
            {
                // Cache ricochet scores due to potion
                if (ricochetBonus > 0 && scoreIndex < (shipScores.count-1)) {
                    for (int i = 1; i < 6; ++i) {
                        uint cacheSize = (i < 3) ? 7 - 2 * i : 2; // 5,3,2,2,2
                        uint infamyBonus = (uint)(([shipScore intValue] + i * ricochetBonus) * critBonus);
                        infamyBonus = (uint)(infamyBonus * scoreMultiplier * notorietyFactor);
                        
                        NSString *text = [NSString stringWithFormat:@"%u", infamyBonus];
                        [keyCache setObject:[NSMutableArray arrayWithCapacity:cacheSize] forKey:text];
                        
                        NSNumber *prevCacheSize = (NSNumber *)[countCache objectForKey:text];
                        
                        if (prevCacheSize == nil || [prevCacheSize unsignedIntValue] < cacheSize)
                            [countCache setObject:[NSNumber numberWithUnsignedInt:cacheSize] forKey:text];
                    }
                }
            }
        }
        
        ++scoreIndex;
    }
    
#ifdef COMBAT_TEXT_DEBUG
    for (id key in keyCache)
        NSLog(@"Score: %@", key);
#endif
    
    mCacheFull = NO;
    mCombatSpriteCache = [[NSDictionary alloc] initWithDictionary:keyCache];
    mCombatCountCache = [[NSDictionary alloc] initWithDictionary:countCache];
    [gc cacheResource:mCombatSpriteCache forKey:RESOURCE_CACHE_COMBAT_TEXT];
    [keyCache release];
    [countCache release];
}

- (void)fillCombatSpriteCache {
    if (mCacheFull)
        return;
    
    for (NSString *key in mCombatSpriteCache) {
        mCacheFull = YES;
        
        NSNumber *cachedCount = (NSNumber *)[mCombatCountCache objectForKey:key];
        uint cacheSize = (cachedCount) ? [cachedCount unsignedIntValue] : kCombatCacheNodeSize;
        NSMutableArray *subCache = (NSMutableArray *)[mCombatSpriteCache objectForKey:key];
        
        if (subCache.count >= cacheSize)
            continue;
        
        mCacheFull = NO;
        
        // Increment cache size
        SPSprite *sprite = [self createCombatTextSpriteWithText:key];
        
        if (sprite) {
            [subCache addObject:sprite];
            break;
        }
    }
    
#ifdef COMBAT_TEXT_DEBUG
    if (mCacheFull) {
        uint cacheSize = 0;
        
        for (NSString *key in mCombatSpriteCache) {
            NSMutableArray *subCache = (NSMutableArray *)[mCombatSpriteCache objectForKey:key];
            cacheSize += subCache.count;
        }
        
        NSLog(@"CombatText Cache size: %u", cacheSize);
    }
#endif
}

- (SPSprite *)createCombatTextSpriteWithText:(NSString *)text {
    SPSprite *sprite = [[[SPSprite alloc] init] autorelease];
    sprite.touchable = NO;
    
    float width = ((RESM.isLowPerformance) ? 13.0f : 17.0f) * kMaxChars;
    float height = (RESM.isLowPerformance) ? 28.0f : 36.0f;
    float fontSize = (RESM.isLowPerformance) ? 24.0f : 32.0f;
    
    // Try to keep this under 256x64 to minimize texture memory
    SPTextField *textfield = [SPTextField textFieldWithWidth:width
                                                      height:height
                                                        text:text
                                                    fontName:mScene.fontKey
                                                    fontSize:fontSize
                                                       color:kWhiteCombatTextColor];
    textfield.touchable = NO;
    textfield.compiled = NO;
    textfield.hAlign = SPHAlignCenter;
    textfield.vAlign = SPVAlignCenter;
    textfield.x = -textfield.width / 2;
    textfield.y = -textfield.height / 2;
    [sprite addChild:textfield];
    [textfield preCache];
    return sprite;
}

- (void)prepareForNewGame {
    for (CTAnimation *animation in mCritAnimations)
        [animation cleanupWithJuggler:mScene.hudJuggler];
	[mScene removeProp:self];
	[mScene addProp:self];
}

- (void)setColor:(uint)value {
	mColor = value;
	
	for (SPSprite *sprite in mIdle) {
		SPTextField *textfield = (SPTextField *)[sprite childAtIndex:0];
		textfield.color = value;
	}
	
	for (SPSprite *sprite in mBusy) {
		SPTextField *textfield = (SPTextField *)[sprite childAtIndex:0];
		textfield.color = value;
	}
}

- (SPSprite *)cachedCombatSpriteForKey:(NSString *)key {
    SPSprite *sprite = nil;
    NSMutableArray *array = (NSMutableArray *)[mCombatSpriteCache objectForKey:key];
    
    if (array && array.count) {
        sprite = [[(SPSprite *)[array lastObject] retain] autorelease];
        [array removeLastObject];
    }
    
    return sprite;
}

- (BOOL)recacheCombatSprite:(SPSprite *)sprite {
    if (sprite == nil || sprite.numChildren == 0)
        return NO;
    
    BOOL recached = NO;
    SPTextField *textfield = (SPTextField *)[sprite childAtIndex:0];
    NSString *key = textfield.text;
    
    if (key) {
        NSMutableArray *array = (NSMutableArray *)[mCombatSpriteCache objectForKey:key];
        
        if (array && [array count] < kCombatCacheNodeSize) {
            [array addObject:sprite];
            recached = YES;
        }
    }
    
    return recached;
}

- (CTAnimation *)nextAnimation {
	if (++mAnimationIndex >= mCritAnimations.count)
		mAnimationIndex = 0;
	return [mCritAnimations objectAtIndex:mAnimationIndex];
}

- (void)combatText:(NSString *)text x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops {
	[self combatText:text x:x y:y twoBy:twoBy numHops:hops color:mColor];
}

- (void)combatText:(NSString *)text x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops color:(uint)color {
    BOOL cacheHit = NO, crit = YES;
	float scaleFactor = (twoBy) ? 1.2f : 0.9f;
    scaleFactor += 0.25f * hops;
	SPSprite *combatSprite = [self cachedCombatSpriteForKey:text];
    
    if (combatSprite == nil) {
        if (mIdle.count == 0)
            return;
        combatSprite = [mIdle lastObject];
#ifdef COMBAT_TEXT_DEBUG
        NSLog(@"XXXXX   UNCACHED %@   XXXXXXX", text);
#endif
    } else {
        cacheHit = YES;
#ifdef COMBAT_TEXT_DEBUG
        NSLog(@"$$$$$$   CACHED   $$$$$$$");
#endif
    }
    
    if (mScene.flipped)
        x = mScene.viewWidth - x;
    
    [mBusy addObject:combatSprite];
    
    if (cacheHit == NO)
        [mIdle removeObject:combatSprite];
    combatSprite.x = combatSprite.y = 0;
    
    if (combatSprite.numChildren == 0)
        return;
    
    SPTextField *textfield = (SPTextField *)[combatSprite childAtIndex:0];
    textfield.color = (crit) ? color : kWhiteCombatTextColor;
    
    CTAnimation *animation = [self nextAnimation];
    [animation reset];
    animation.scaleFactor = scaleFactor;
    
    if (cacheHit == NO)
        textfield.text = text;
    
//    if (crit == NO) {
//        animation.scaleFactor *= 0.75f;
//        animation.containerSprite.x = MIN(MAX(0.5f * combatSprite.width, x), mScene.viewWidth - 0.5f * combatSprite.width);
//        
//        float yOffset = 5.0f + combatSprite.height;
//		y -= yOffset;
//		
//		if (y < combatSprite.height) {
//			// Too close to top of screen - move down and tween downwards
//			y += 2 * yOffset;
//            animation.containerSprite.y = MIN(y, mScene.viewHeight - 35.0f - 0.5f * combatSprite.height);
//            [animation animateAsNonCritDown:combatSprite withJuggler:mScene.hudJuggler];
//		} else {
//            // Normal situtation - place above ship and tween upwards
//            animation.containerSprite.y = MIN(y, mScene.viewHeight - 35.0f - 0.5f * combatSprite.height);
//            [animation animateAsNonCritUp:combatSprite withJuggler:mScene.hudJuggler];
//		}
//    } else {
        // Use 0.75f rather than 0.5f because the underlying animation will end on a 1.5f internal scale.
        float yOffset = 0.75f * scaleFactor * textfield.height, xOffset = 0.75f * scaleFactor * textfield.width;
        // 5.0f for HUD, -10.0f to clear the ship, 35.0f for deck railing.
		animation.containerSprite.y = MIN(MAX(5.0f + kOffsetMax + yOffset, y - 10.0f), mScene.viewHeight - (35.0f + yOffset + kOffsetMax));
		animation.containerSprite.x = MIN(MAX(xOffset + kOffsetMax, x), mScene.viewWidth - (xOffset + kOffsetMax));
        [animation animateAsCrit:combatSprite withJuggler:mScene.hudJuggler];
//    }
    
    [self addChild:animation.containerSprite];
}

- (void)onCombatTweenCompleted:(SPEvent *)event {
    SPSprite *combatSprite = nil;
	SPTween *tween = (SPTween *)event.currentTarget;
    
    // Retrieve animated sprite
	SPSprite *animatedSprite = (SPSprite *)tween.target;
    
    // Retrieve combat sprite
    if (animatedSprite.numChildren > 0)
        combatSprite = (SPSprite *)[animatedSprite childAtIndex:0];
    
    // Retrieve container sprite
    SPSprite *containerSprite = (SPSprite *)[animatedSprite parent];
    [containerSprite removeFromParent];
    
    if (combatSprite) {
        if ([self recacheCombatSprite:combatSprite] == NO)
            [mIdle addObject:combatSprite];
#ifdef COMBAT_TEXT_DEBUG
        else
            NSLog(@"!!!!!!!  RECACHED  !!!!!!!!");
#endif
        [combatSprite removeFromParent];
        [mBusy removeObject:combatSprite];
    }
}

- (void)hideAllText {
	for (SPSprite *combatSprite in mBusy) {
        SPSprite *animatedSprite = (SPSprite *)[combatSprite parent];
        
        if (animatedSprite) {
            [mScene.hudJuggler removeTweensWithTarget:animatedSprite];
        
            SPSprite *containerSprite = (SPSprite *)[animatedSprite parent];
            [containerSprite removeFromParent];
            
            [combatSprite removeFromParent];
        }
        
        if ([self recacheCombatSprite:combatSprite] == NO)
            [mIdle addObject:combatSprite];
	}
    
	[self removeAllChildren];
	[mBusy removeAllObjects];
}

- (void)cleanUp {
    for (CTAnimation *animation in mCritAnimations)
        [animation cleanupWithJuggler:mScene.hudJuggler];
	[mScene removeProp:self];
}

- (void)dealloc {
	[mCritAnimations release]; mCritAnimations = nil;
	[mCombatSpriteCache release]; mCombatSpriteCache = nil;
    [mCombatCountCache release]; mCombatCountCache = nil;
	[mBusy release]; mBusy = nil;
	[mIdle release]; mIdle = nil;
	[super dealloc];
}

@end


@implementation CTAnimation

@synthesize scaleX = mScaleX;
@synthesize scaleY = mScaleY;
@synthesize scaleFactor = mScaleFactor;
@synthesize containerSprite = mContainerSprite;
@synthesize animatedSprite = mAnimatedSprite;
@dynamic nonCritUpDelay,nonCritDownDelay,critDelay;

+ (CTAnimation *)animation {
	return [[[CTAnimation alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
        mScaleX = mScaleY = 1.0f;
		mScaleFactor = 1;
        
        mAnimatedSprite = [[SPSprite alloc] init];
		mContainerSprite = [[SPSprite alloc] init];
        [mContainerSprite addChild:mAnimatedSprite];
        
		mNonCritUpTweens = [[NSMutableArray alloc] init];
        mNonCritDownTweens = [[NSMutableArray alloc] init];
        mCritTweens = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)setScaleFactor:(float)scaleFactor {
    if (SP_IS_FLOAT_EQUAL(scaleFactor, 0))
        return;
    mContainerSprite.scaleX /= mScaleFactor;
    mContainerSprite.scaleY /= mScaleFactor;
    mScaleFactor = scaleFactor;
    mContainerSprite.scaleX *= scaleFactor;
    mContainerSprite.scaleY *= scaleFactor;
}

- (double)nonCritUpDelay {
    double delay = 0;
    
    for (SPTween *tween in mNonCritUpTweens)
        delay += tween.time;
    
    return delay;
}

- (double)nonCritDownDelay {
    double delay = 0;
    
    for (SPTween *tween in mNonCritDownTweens)
        delay += tween.time;
    
    return delay;
}

- (double)critDelay {
    double delay = 0;
    
    for (SPTween *tween in mCritTweens)
        delay += tween.time;
    
    return delay;
}

- (void)addTween:(SPTween *)tween crit:(BOOL)crit dir:(int)dir{
    if (crit)
        [mCritTweens addObject:tween];
    else if (dir == -1)
        [mNonCritUpTweens addObject:tween];
    else if (dir == 1)
        [mNonCritDownTweens addObject:tween];
}

- (void)removeTween:(SPTween *)tween {
    if (tween == nil)
        return;
    [mNonCritUpTweens removeObject:tween];
    [mNonCritDownTweens removeObject:tween];
    [mCritTweens removeObject:tween];
}

- (void)reset {
    for (SPTween *tween in mNonCritUpTweens)
        [tween reset];
    for (SPTween *tween in mNonCritDownTweens)
        [tween reset];
    for (SPTween *tween in mCritTweens)
        [tween reset];
    self.scaleFactor = 1;
    mAnimatedSprite.x = mAnimatedSprite.y = 0;
    mAnimatedSprite.alpha = 1;
    [mAnimatedSprite removeAllChildren];
}

- (void)animateAsNonCritUp:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler {
    if (mNonCritUpTweens.count == 0)
        return;
    
    mAnimatedSprite.scaleX = mAnimatedSprite.scaleY = 1;
    [mAnimatedSprite addChild:object];
    
    for (SPTween *tween in mNonCritUpTweens)
        [juggler addObject:tween];
}

- (void)animateAsNonCritDown:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler {
    if (mNonCritDownTweens.count == 0)
        return;
    
    mAnimatedSprite.scaleX = mAnimatedSprite.scaleY = 1;
    [mAnimatedSprite addChild:object];
    
    for (SPTween *tween in mNonCritDownTweens)
        [juggler addObject:tween];
}

- (void)animateAsCrit:(SPDisplayObject *)object withJuggler:(SPJuggler *)juggler {
    if (mCritTweens.count == 0)
        return;
    
    mAnimatedSprite.scaleX = mScaleX;
    mAnimatedSprite.scaleY = mScaleY;
    [mAnimatedSprite addChild:object];
    
    for (SPTween *tween in mCritTweens)
        [juggler addObject:tween];
}

- (void)cleanupWithJuggler:(SPJuggler *)juggler {
    [juggler removeTweensWithTarget:mAnimatedSprite];
}

- (void)dealloc {
    [mAnimatedSprite release]; mAnimatedSprite = nil;
    [mContainerSprite release]; mContainerSprite = nil;
    [mNonCritUpTweens release]; mNonCritUpTweens = nil;
	[mNonCritDownTweens release]; mNonCritDownTweens = nil;
    [mCritTweens release]; mCritTweens = nil;
	[super dealloc];
}

@end

