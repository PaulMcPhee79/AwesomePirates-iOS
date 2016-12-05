//
//  FirstMate.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "FirstMate.h"
#import "MessageCloud.h"

@interface FirstMate ()

- (BOOL)annonouceNextMessage;
- (void)onArrivedAtDest:(SPEvent *)event;
- (void)onRetiredToCabin:(SPEvent *)event;
- (void)onMessageCloudNext:(SPEvent *)event;
- (void)onMessageCloudChoice:(SPEvent *)event;
- (void)onMessageCloudDismissed:(SPEvent *)event;
- (void)attachMessageCloudEvents;
- (void)detachMessageCloudEvents;

@end


@implementation FirstMate

@synthesize decision = mDecision;
@synthesize dest = mDest;
@synthesize despawn = mDespawn;
@synthesize continuousFeed = mContinuousFeed;
@synthesize userData = mUserData;

+ (FirstMate *)firstMateWithCategory:(int)category msgs:(NSArray *)msgs textureName:(NSString *)textureName dir:(int)dir choice:(BOOL)choice {
	return [[[FirstMate alloc] initWithCategory:category msgs:msgs textureName:textureName dir:dir choice:choice] autorelease];
}

- (id)initWithCategory:(int)category msgs:(NSArray *)msgs textureName:(NSString *)textureName dir:(int)dir choice:(BOOL)choice {
	if (self = [super initWithCategory:category]) {
		self.touchable = YES;
		mRetiring = NO;
		mDecision = NO;
		mContinuousFeed = NO;
		mChoice = choice;
		mMsgIndex = 0;
		mUserData = 0;
        
        mTextureName = [textureName copy];
		
        SPPoint *spawn = (dir == -1) ? [SPPoint pointWithX:-68.0f y:mScene.viewHeight - 80.0f] : [SPPoint pointWithX:mScene.viewWidth y:mScene.viewHeight - 80.0f];
        SPPoint *dest = (dir == -1) ? [SPPoint pointWithX:spawn.x + 68.0f y:spawn.y] : [SPPoint pointWithX:spawn.x - 68.0f y:spawn.y];
        
		self.x = spawn.x;
		self.y = spawn.y;
		self.dest = dest;
		self.despawn = spawn;
		mMsgs = [msgs retain];
		mMsgCloud = nil;
		mTouchBarrier = nil;
		mDir = (dir == 0) ? 1 : dir / abs(dir);
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category msgs:nil textureName:@"first-mate" dir:1 choice:NO];
}

- (void)setupProp {
	if (mTouchBarrier != nil)
		return;
    
    SPTexture *texture = [mScene.helpAtlas textureByName:mTextureName];
    
    if (texture == nil)
        texture = [mScene.achievementAtlas textureByName:mTextureName];
    if (texture == nil)
        texture = [mScene textureByName:mTextureName];

	SPImage *image = [SPImage imageWithTexture:texture];
	[self addChild:image];
	
	mTouchBarrier = [[Prop alloc] initWithCategory:mCategory];
	mTouchBarrier.touchable = NO;
	
	SPQuad *quad = [SPQuad quadWithWidth:mScene.viewWidth height:mScene.viewHeight];
	quad.alpha = 0;
	[mTouchBarrier addChild:quad];
	[mScene addProp:mTouchBarrier];
}

- (void)deployTouchBarrier {
	mTouchBarrier.touchable = YES;
}

- (void)retractTouchBarrier {
	mTouchBarrier.touchable = NO;
}

- (void)beginAnnoucements {
	float duration = MAX(fabs(self.x - mDest.x) / self.width,fabs(self.y - mDest.y) / self.height);
	SPTween *tween = [SPTween tweenWithTarget:self time:duration / 2.0f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"x" targetValue:mDest.x];
	[tween animateProperty:@"y" targetValue:mDest.y];
	[tween addEventListener:@selector(onArrivedAtDest:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (BOOL)annonouceNextMessage {
	if (mMsgIndex >= mMsgs.count)
		return NO;
	[mMsgCloud setMessageText:(NSString *)[mMsgs objectAtIndex:mMsgIndex++]];
	
	if (mMsgIndex == mMsgs.count && mContinuousFeed == NO) {
		mMsgCloud.state = (mChoice) ? kMsgCloudStateChoice : kMsgCloudStateAye;
	} else {
		mMsgCloud.state = kMsgCloudStateNext;
	}
	return YES;
}

- (void)retireToCabin {
	if (mRetiring)
		return;
	if (mMsgCloud != nil) {
		[mMsgCloud dismissOverTime:0.25f];
	} else {
		float duration = MAX(fabs(self.x - mDespawn.x) / self.width,fabs(self.y - mDespawn.y) / self.height);
		SPTween *tween = [SPTween tweenWithTarget:self time:duration / 2.0f transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"x" targetValue:mDespawn.x];
		[tween animateProperty:@"y" targetValue:mDespawn.y];
		[tween addEventListener:@selector(onRetiredToCabin:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
		[mScene.juggler addObject:tween];
		mRetiring = YES;
	}
}

- (void)addMsgs:(NSArray *)msgs {
	[mMsgs release];
	mMsgs = [msgs retain];
	mMsgIndex = 0;
	[self annonouceNextMessage];
}

- (void)onArrivedAtDest:(SPEvent *)event {
	if (mMsgCloud != nil)
		return;
	mMsgCloud = [[MessageCloud alloc] initWithCategory:mCategory dir:mDir];
	mMsgCloud.alpha = 0.0f;
	mMsgCloud.x = (mDir == 1) ? self.x - mMsgCloud.width + 18.0f : self.x + self.width - 18.0f;
	mMsgCloud.y = self.y - mMsgCloud.height / 2;
	
	[mScene addProp:mMsgCloud];
	[self attachMessageCloudEvents];
	[self annonouceNextMessage];
	
	SPTween *tween = [SPTween tweenWithTarget:mMsgCloud time:0.25f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
}

- (void)onRetiredToCabin:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_FIRST_MATE_RETIRED]];
}

- (void)onMessageCloudNext:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_FIRST_MATE_NEXT_MSG]];
	
	if ([self annonouceNextMessage] == NO && mContinuousFeed == YES)
		[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_FIRST_MATE_ALL_MSGS_SPOKEN]];
}

- (void)onMessageCloudChoice:(SPEvent *)event {
	mDecision = mMsgCloud.choice;
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_FIRST_MATE_DECISION]];
}

- (void)onMessageCloudDismissed:(SPEvent *)event {
	[self detachMessageCloudEvents];
	[mScene.juggler removeTweensWithTarget:mMsgCloud];
	[mScene removeProp:mMsgCloud];
	[mMsgCloud autorelease];
	mMsgCloud = nil;
	
	[self retireToCabin];
}

- (void)attachMessageCloudEvents {
	[mMsgCloud addEventListener:@selector(onMessageCloudNext:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_NEXT];
	[mMsgCloud addEventListener:@selector(onMessageCloudChoice:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_CHOICE];
	[mMsgCloud addEventListener:@selector(onMessageCloudDismissed:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_DISMISSED];
}

- (void)detachMessageCloudEvents {
	[mMsgCloud removeEventListener:@selector(onMessageCloudNext:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_NEXT];
	[mMsgCloud removeEventListener:@selector(onMessageCloudChoice:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_CHOICE];
	[mMsgCloud removeEventListener:@selector(onMessageCloudDismissed:) atObject:self forType:CUST_EVENT_TYPE_MSG_CLOUD_DISMISSED];
}

- (void)dealloc {
	if (mMsgCloud != nil) {
		[self detachMessageCloudEvents];
		[mScene.juggler removeTweensWithTarget:mMsgCloud];
		[mScene removeProp:mMsgCloud];
		[mMsgCloud release];
	}
	
	if (mTouchBarrier != nil)
		[mScene removeProp:mTouchBarrier];
	
    [mTextureName release]; mTextureName = nil;
	[mTouchBarrier release]; mTouchBarrier = nil;
	[mDest release]; mDest = nil;
	[mDespawn release]; mDespawn = nil;
	[mMsgs release]; mMsgs = nil;
	[super dealloc];
}

@end
