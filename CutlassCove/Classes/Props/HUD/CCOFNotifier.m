//
//  CCOFNotifier.m
//  CutlassCove
//
//  Created by Paul McPhee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCOFNotifier.h"
#import "GuiHelper.h"

@interface CCOFNotifier ()

- (void)displayNotification:(CCOFNotification *)notification;
- (void)onNotificationHidden:(SPEvent *)event;

@end


@implementation CCOFNotifier

- (id)initWithCategory:(int)category notificationDuration:(float)notificationDuration {
    if (self = [super initWithCategory:category]) {
        mAdvanceable = YES;
        mIsBusy = NO;
        mCanvas = nil;
        mNotificationDuration = notificationDuration;
        mNoticeQueue = [[NSMutableArray alloc] init];
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    [mScene.specialJuggler removeTweensWithTarget:mCanvas];
    
    [mIcon release]; mIcon = nil;
    [mNotice release]; mNotice = nil;
    [mCanvas release]; mCanvas = nil;
    [mNoticeQueue release]; mNoticeQueue = nil;
    
    [super dealloc];
}

- (void)setupProp {
    if (mCanvas)
        return;
    
    // Canvas
    mCanvas = [[SPSprite alloc] init];
    [self addChild:mCanvas];
    
    // Background
    SPTexture *bgTexture = [GuiHelper cachedHorizTextureByName:@"hud-scroll" scene:mScene];
    SPImage *bgImage = [SPImage imageWithTexture:bgTexture];
    bgImage.scaleX = mScene.viewWidth / 480.0f;
    [mCanvas addChild:bgImage];
    
    mIcon = [[SPImage alloc] initWithTexture:[mScene textureByName:@"cc-of-round-logo"]];
    mIcon.x = 15;
    mIcon.y = 2;
    mIcon.scaleX = mIcon.scaleY = 48.0f / 75.0f;
    [mCanvas addChild:mIcon];
    
    mNotice = [[SPTextField textFieldWithWidth:400.0f
                                        height:24.0f 
                                          text:@""
                                      fontName:@"MarkerFelt-Thin"
                                      fontSize:20.0f
                                         color:0]
               retain];
    mNotice.x = 40;
    mNotice.y = 3;
    mNotice.hAlign = SPHAlignLeft;
    mNotice.vAlign = SPVAlignTop;
    mNotice.compiled = NO;
    [mCanvas addChild:mNotice];
    
    mCanvas.y = -mCanvas.height;
    mCanvas.visible = NO;
}

- (void)displayNotification:(CCOFNotification *)notification {
    if (notification == nil)
        return;
    
    mNotice.text = notification.notification;
    mCanvas.visible = YES;
    
    SPTween *displayTween = [SPTween tweenWithTarget:mCanvas time:0.25f];
    [displayTween animateProperty:@"y" targetValue:0];
    displayTween.delay = notification.delay;
    [mScene.specialJuggler addObject:displayTween];
    
    SPTween *hideTween = [SPTween tweenWithTarget:mCanvas time:0.25f];
    [hideTween animateProperty:@"y" targetValue:-mCanvas.height];
    hideTween.delay = displayTween.time + displayTween.delay + notification.duration;
    [hideTween addEventListener:@selector(onNotificationHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.specialJuggler addObject:hideTween];
}

- (void)onNotificationHidden:(SPEvent *)event {
    mCanvas.visible = NO;
    mIsBusy = NO;
}

- (void)setIconTexture:(SPTexture *)texture {
    if (texture)
        mIcon.texture = texture;
}

- (void)addNotification:(NSString *)notification {
    [self addNotification:notification delay:0 duration:mNotificationDuration];
}

- (void)addNotification:(NSString *)notification delay:(double)delay duration:(double)duration {
    if (notification == nil || mNoticeQueue.count > 5)
        return;
    
    CCOFNotification *ccofNotification = [[CCOFNotification alloc] initWithNotification:notification delay:delay duration:duration];
    [mNoticeQueue addObject:ccofNotification];
    [ccofNotification release];
}

- (void)pumpNotificationQueue {
    if (mIsBusy == NO && mNoticeQueue.count > 0) {
        CCOFNotification *ccofNotification = (CCOFNotification *)[mNoticeQueue objectAtIndex:0];
        [self displayNotification:ccofNotification];
        [mNoticeQueue removeObjectAtIndex:0];
    }
}

- (void)clearNotificationQueue {
    [mNoticeQueue removeAllObjects];
}

- (void)advanceTime:(double)time {
    [self pumpNotificationQueue];
}

@end


@implementation CCOFNotification

@synthesize delay = mDelay;
@synthesize duration = mDuration;
@synthesize notification = mNotification;

- (id)initWithNotification:(NSString *)notification delay:(double)delay duration:(double)duration {
    if (self = [super init]) {
        mNotification = [notification copy];
        mDelay = delay;
        mDuration = duration;
    }
    return self;
}

- (void)dealloc {
    [mNotification release]; mNotification = nil;
    [super dealloc];
}

@end

