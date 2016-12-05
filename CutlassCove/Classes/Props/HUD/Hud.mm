//
//  Hud.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Hud.h"
#import "HudCell.h"
#import "HudMutiny.h"
#import "FloatingText.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "PlayfieldController.h"
#import "GameController.h"
#import "Globals.h"

const float kHudCellY = 2.0f;
const float kInfamyCellLabelWidth = 48.0f;
const float kDayCellLabelWidth = 32.0f;

const uint kFloatingMutinyColor = 0xbc0000;
const uint kFloatingGrogColor = 0x5a3c15;
const uint kFloatingConditionColor = 0xf9ef76;

const uint kTargetRedColor = 0xb3060e;
const uint kTargetGreenColor = 0x006d00;

@interface Hud ()

- (void)onMutinyCountdownChanged:(NumericRatioChangedEvent *)event;

@end


@implementation Hud

@synthesize tweenedUpdates = mTweenedUpdates;
@synthesize target = mTarget;

- (id)initWithCategory:(int)category textColor:(uint)textColor x:(float)x y:(float)y {
    if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mListenersAttached = NO;
		mTweenedUpdates = NO;
        mTarget = 0;
        mHudCells = nil;
        mHudMutiny = nil;
		mFloatingText = nil;
		mFloatingOffset = nil;
        mOriginX = x;
		self.x = x;
		self.y = y;
		mColor = textColor;
		[self setupProp];
    }
    return self;
}

- (id)init {
	return [self initWithCategory:0.0f textColor:0 x:0.0f y:0.0f];
}

- (void)setupProp {
    if (mHudCells)
        return;
	mFloatingOffset = [[RESM itemOffsetWithAlignment:RAUpperCenter] retain];
	
	mInfamyCell = [HudCell hudCellWithX:135.0f y:kHudCellY fontSize:20 maxChars:10];
	[mInfamyCell setupWithLabel:@"Score" labelWidth:kInfamyCellLabelWidth color:mColor];
    
    //mHiCell = [HudCell hudCellWithX:mInfamyCell.x + mInfamyCell.width y:kHudCellY maxChars:10];
	//[mHiCell setupWithIconTexture:[mScene textureByName:@"hi-score"] color:mColor];
	
	//mDoubloonsCell = [HudCell hudCellWithX:226 y:295 maxChars:7];
	//[mDoubloonsCell setupWithIconTexture:[mScene textureByName:@"doubloon"] color:0x007e00];
	
	//mAiCell = [HudCell hudCellWithX:mInfamyCell.x y:22.0f fontSize:14 maxChars:10];
	//[mAiCell setupWithLabel:@"AI  " labelWidth:20.0f color:0xff0000];
    
    //mMiscCell = [HudCell hudCellWithX:mInfamyCell.x - 110 y:37 maxChars:10];
	//[mMiscCell setupWithLabel:@"PL  " labelWidth:20.0f color:0xff0000];
	
	mHudCells = [[NSArray arrayWithObjects:mInfamyCell,nil] retain]; //mHiCell,mAiCell,mMiscCell
	
	for (HudCell *hudCell in mHudCells)
		[self addChild:hudCell];
	
	if ([mScene isKindOfClass:[PlayfieldController class]]) {
		//mFloatingText = [[FloatingText alloc] initWithCategory:self.category width:40 height:24 fontSize:20 capacity:10];
		//[mScene addProp:mFloatingText];
        
        mHudMutiny = [[HudMutiny alloc] initWithCategory:self.category maxMutinyLevel:6];
        mHudMutiny.x = 300; mHudMutiny.y = 3;
        mHudMutiny.scaleX = mHudMutiny.scaleY = 0.9f;
        [self addChild:mHudMutiny];
	}
}

- (void)attachEventListeners {
	if (mListenersAttached == YES)
		return;
	GameController *gc = [GameController GC];

	[gc.thisTurn addEventListener:@selector(onInfamyChanged:) atObject:self forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
	[gc.thisTurn addEventListener:@selector(onMutinyChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED];
	[gc.thisTurn addEventListener:@selector(onMutinyCountdownChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED];

	mListenersAttached = YES;
}

- (void)detachEventListeners {
	if (mListenersAttached == NO)
		return;
	GameController *gc = [GameController GC];

	[gc.thisTurn removeEventListener:@selector(onInfamyChanged:) atObject:self forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
	[gc.thisTurn removeEventListener:@selector(onMutinyChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED];
	[gc.thisTurn removeEventListener:@selector(onMutinyCountdownChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED];

	mListenersAttached = NO;
}

- (void)setTarget:(int64_t)target {
    mTarget = target;
    mInfamyCell.textColor = (mTarget == 0) ? 0 : kTargetRedColor;
}

- (void)setInfamyValue:(uint)value {
	mInfamyCell.value = value;
    
    if (mTarget != 0)
        mInfamyCell.textColor = (value > mTarget) ? kTargetGreenColor : kTargetRedColor;
}

- (void)floatingMutiny:(int)value {
	float x = 206 + mFloatingOffset.x, y = mScene.viewHeight - (60 + mFloatingOffset.y);
	[mFloatingText launchTextWithText:[NSString stringWithFormat:@"%@%d", ((value >= 0) ? @" " : @""), value] x:x y:y color:kFloatingMutinyColor];
}

- (void)flip:(BOOL)enable {
    if (enable) {
        self.scaleX = -1;
        self.x = mOriginX + mScene.viewWidth + ((RESM.isIpadDevice) ? 86 : 100); //[RESM resItemFx:100];
    } else {
        self.scaleX = 1;
        self.x = mOriginX;
    }
    
    //for (HudCell *hudCell in mHudCells)
    //    [hudCell flip:enable];
}

- (void)advanceTime:(double)time {
    for (HudCell *cell in mHudCells)
        [cell tick];
	//[mHudCells makeObjectsPerformSelector:@selector(tick)];
}

- (void)onInfamyChanged:(NumericValueChangedEvent *)event {
    int64_t infamy = [event.value longLongValue];
    
    if (mTarget != 0)
        mInfamyCell.textColor = (infamy > mTarget) ? kTargetGreenColor : kTargetRedColor;
	if (mTweenedUpdates)
		[mInfamyCell enqueueValueChange:[event.value longLongValue]];
	else
		mInfamyCell.value = [event.value longLongValue];
}

- (void)onMutinyChanged:(NumericRatioChangedEvent *)event {
	int value = [event.value intValue];
    mHudMutiny.mutinyLevel = value;
}

- (void)setAiValue:(int)value {
	mAiCell.value = value;
}

- (void)onAiChanged:(NumericValueChangedEvent *)event {
	if (mTweenedUpdates)
		[mAiCell enqueueValueChange:[event.value unsignedIntValue]];
	else
		mAiCell.value = [event.value unsignedIntValue];
}

- (void)setMiscValue:(int)value {
    mMiscCell.value = value;
}

- (void)onMutinyCountdownChanged:(NumericRatioChangedEvent *)event {
    float ratio = event.ratio;
    mHudMutiny.fillRatio = ratio;
}

- (void)enableScoredMode:(BOOL)enable {
    mInfamyCell.visible = enable;
    mHudMutiny.visible = enable;
}

- (void)dealloc {
	[self detachEventListeners];
	
	if (mFloatingText) {
		[mScene removeProp:mFloatingText];
        [mFloatingText destroyFloatingText];
        [mFloatingText release]; mFloatingText = nil;
    }
    
	[mHudCells release]; mHudCells = nil;
    [mHudMutiny release]; mHudMutiny = nil;
	[mFloatingOffset release]; mFloatingOffset = nil;
    [super dealloc];
}

@end

