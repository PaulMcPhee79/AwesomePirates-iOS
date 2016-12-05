//
//  MenuDetailView.m
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "MenuDetailView.h"
#import "MenuButton.h"
#import "Globals.h"


@implementation MenuDetailView

@synthesize mutableLabels = mMutableLabels;
@synthesize labelArrays = mLabelArrays;
@synthesize mutableImages = mMutableImages;
@synthesize buttons = mButtons;
@synthesize mutableSprites = mMutableSprites;
@synthesize miscProps = mMiscProps;
@synthesize loopingTweens = mLoopingTweens;

- (id)initWithCategory:(int)category {
	if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mMutableLabels = [[NSMutableDictionary alloc] init];
		mLabelArrays = [[NSMutableDictionary alloc] init];
		mMutableImages = [[NSMutableDictionary alloc] init];
		mButtons = [[NSMutableDictionary alloc] init];
		mMutableSprites = [[NSMutableDictionary alloc] init];
		mMiscProps = [[NSMutableArray alloc] init];
        mFlipProps = [[NSMutableArray alloc] init];
        mLoopingTweens = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)init {
	return [self initWithCategory:0];
}

- (void)setTexture:(NSString *)textureName forKey:(NSString *)key {
	SPImage *image = [mMutableImages objectForKey:key];
	
	if (image)
		image.texture = [mScene textureByName:textureName];
}

- (void)setText:(NSString *)text forKey:(NSString *)key {
	SPTextField *textField = [mMutableLabels objectForKey:key];
	
	if (textField)
		textField.text = text;
}

- (void)setTextIndex:(int)index forKey:(NSString *)key {
	NSArray *array = (NSArray *)[mLabelArrays objectForKey:key];
	
	for (SPTextField *textField in array)
		textField.visible = NO;
	if (index >= 0 && index < array.count) {
		SPTextField *textField = (SPTextField *)[array objectAtIndex:index];
		textField.visible = YES;
	}
}

- (void)setRepeatingTexture:(NSString *)textureName repeats:(int)repeats forKey:(NSString *)key {
	SPSprite *sprite = [mMutableSprites objectForKey:key];
	
	if (sprite) {
		SPTexture *texture = [mScene textureByName:textureName];
		[sprite removeAllChildren];
		
		for (int i = 0; i < repeats; ++i) {
			SPImage *image = [SPImage imageWithTexture:texture];
			image.x = i*image.width;
			[sprite addChild:image];
		}
	}
}

- (void)deconstruct {
	for (Prop *prop in mMiscProps)
		[mScene removeProp:prop];
	[mMiscProps removeAllObjects];
	[mMutableLabels removeAllObjects];
	[mLabelArrays removeAllObjects];
	[mMutableImages removeAllObjects];
	[mButtons removeAllObjects];
	[mMutableSprites removeAllObjects];
	[self removeAllChildren];
}

- (SPDisplayObject *)controlForKey:(NSString *)key {
	SPDisplayObject *control = [mMutableLabels objectForKey:key];
	
	if (control == nil)
		control = [mMutableImages objectForKey:key];
	if (control == nil)
		control = [mButtons objectForKey:key];
	if (control == nil)
		control = [mMutableSprites objectForKey:key];
	
	return control;
}

- (void)setControl:(SPDisplayObject *)control forKey:(NSString *)key {
	if ([control isKindOfClass:[Prop class]])
		[mMiscProps addObject:control];
	else if ([control isKindOfClass:[SPTextField class]])
		[mMutableLabels setObject:control forKey:key];
	else if ([control isKindOfClass:[SPImage class]])
		[mMutableImages setObject:control forKey:key];
	else if ([control isKindOfClass:[SPButton class]])
		[mButtons setObject:control forKey:key];
	else if ([control isKindOfClass:[SPSprite class]])
		[mMutableSprites setObject:control forKey:key];
}

- (void)removeControl:(SPDisplayObject *)control forKey:(NSString *)key {
    if ([control isKindOfClass:[Prop class]])
		[mMiscProps removeObject:control];
	else if ([control isKindOfClass:[SPTextField class]])
		[mMutableLabels removeObjectForKey:key];
	else if ([control isKindOfClass:[SPImage class]])
		[mMutableImages removeObjectForKey:key];
	else if ([control isKindOfClass:[SPButton class]])
		[mButtons removeObjectForKey:key];
	else if ([control isKindOfClass:[SPSprite class]])
		[mMutableSprites removeObjectForKey:key];
}

- (NSArray *)controlArrayForKey:(NSString *)key {
    return [mLabelArrays objectForKey:key];
}

- (void)setControlArray:(NSArray *)array forKey:(NSString *)key {
    if (array && key)
        [mLabelArrays setObject:array forKey:key];
}

- (void)removeControlArrayForKey:(NSString *)key {
    if (key)
        [mLabelArrays removeObjectForKey:key];
}

- (void)addMiscProp:(Prop *)prop {
    if (prop)
        [mMiscProps addObject:prop];
}

- (void)removeMiscProp:(Prop *)prop {
    [mMiscProps removeObject:prop];
}

- (void)addFlipProp:(Prop *)prop {
    if (prop)
        [mFlipProps addObject:prop];
}

- (void)removeFlipProp:(Prop *)prop {
    [mFlipProps removeObject:prop];
}

- (void)addLoopingTween:(SPTween *)tween {
    if (tween)
        [mLoopingTweens addObject:tween];
}

- (void)removeLoopingTween:(SPTween *)tween {
    [mLoopingTweens removeObject:tween];
}

- (void)enableButton:(BOOL)enable forKey:(NSString *)key {
	SPButton *button = [mButtons objectForKey:key];
	button.enabled = enable;
}

- (void)setVisible:(BOOL)value forKey:(NSString *)key {
	SPDisplayObject *control = [self controlForKey:key];
	control.visible = value;
}

- (void)flip:(BOOL)enable {
    float flipScaleX = (enable) ? -1 : 1;
    
    for (Prop *prop in mFlipProps)
        prop.scaleX = flipScaleX;
}

- (void)advanceTime:(double)time {
	for (Prop *prop in mMiscProps)
		[prop advanceTime:time];
}

- (void)dealloc {
    for (SPTween *tween in mLoopingTweens) {
        id target = tween.target;
        [mScene.juggler removeTweensWithTarget:target];
    }
    
    [mLoopingTweens release]; mLoopingTweens = nil;
	[mMutableLabels release]; mMutableLabels = nil;
	[mLabelArrays release]; mLabelArrays = nil;
	[mMutableImages release]; mMutableImages = nil;
	[mButtons release]; mButtons = nil;
	[mMutableSprites release]; mMutableSprites = nil;
	[mMiscProps release]; mMiscProps = nil;
    [mFlipProps release]; mFlipProps = nil;
    [super dealloc];
}

@end

