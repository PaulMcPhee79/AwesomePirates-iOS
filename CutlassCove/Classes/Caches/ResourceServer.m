//
//  ResourceServer.m
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceServer.h"

@interface ResourceServer ()

- (NSString *)stringForKey:(uint)key;
- (void)onTweenStarted:(SPEvent *)event;
- (void)onTweenCompleted:(SPEvent *)event;
- (void)onMovieCompleted:(SPEvent *)event;

@end

@implementation ResourceServer

@synthesize client = mClient;

+ (ResourceServer *)resourceServer {
    return [[[ResourceServer alloc] initWithCategory:0] autorelease];
}

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        mTweens = nil;
        mMovies = nil;
        mDisplayObjects = nil;
        mMiscResources = nil;
        mClient = nil;
    }
    
    return self;
}

- (void)dealloc {
    for (NSString *key in mTweens) {
        SPTween *tween = (SPTween *)[mTweens objectForKey:key];
        [mScene.juggler removeObject:tween];
    }
    
    for (NSString *key in mMovies) {
        SPMovieClip *movie = (SPMovieClip *)[mMovies objectForKey:key];
        [mScene.juggler removeObject:movie];
    }
    
    for (NSString *key in mDisplayObjects) {
        SPDisplayObject *object = (SPMovieClip *)[mDisplayObjects objectForKey:key];
        [object removeFromParent];
    }
    
    [mTweens release]; mTweens = nil;
    [mMovies release]; mMovies = nil;
    [mDisplayObjects release]; mDisplayObjects = nil;
    [mMiscResources release]; mMiscResources = nil;
    mClient = nil;
    [super dealloc];
}

- (void)reassignScene:(SceneController *)scene {
    if (scene != mScene) {
        [mScene autorelease];
        mScene = [scene retain];
    }
}

- (void)setClient:(NSObject<ResourceClient> *)client {
    assert(!(mClient && client));
    mClient = client;
}

- (NSString *)stringForKey:(uint)key {
    return [NSString stringWithFormat:@"%u", key];
}

- (void)onTweenStarted:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    [mClient resourceEventFiredWithKey:tween.tag type:SP_EVENT_TYPE_TWEEN_STARTED target:tween];
}

- (void)onTweenCompleted:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    [mClient resourceEventFiredWithKey:tween.tag type:SP_EVENT_TYPE_TWEEN_COMPLETED target:tween];
}

- (void)onMovieCompleted:(SPEvent *)event {
    SPMovieClip *movie = (SPMovieClip *)event.currentTarget;
    [mClient resourceEventFiredWithKey:movie.tag type:SP_EVENT_TYPE_MOVIE_COMPLETED target:movie];
}

- (void)addTween:(SPTween *)tween forKey:(uint)key {
    if (mTweens == nil)
        mTweens = [[NSMutableDictionary alloc] init];
    tween.tag = key;
    [mTweens setObject:tween forKey:[self stringForKey:key]];
}

- (BOOL)startTweenForKey:(uint)key {
    BOOL started = NO;
    SPTween *tween = (SPTween *)[mTweens objectForKey:[self stringForKey:key]];
    
    if (tween) {
        started = YES;
        [tween reset];
        [mScene.juggler addObject:tween];
    }
    
    return started;
}

- (void)stopTweenForKey:(uint)key {
    SPTween *tween = (SPTween *)[mTweens objectForKey:[self stringForKey:key]];
    
    if (tween)
        [mScene.juggler removeObject:tween];
}

- (void)addMovie:(SPMovieClip *)movie forKey:(uint)key {
    if (mMovies == nil)
        mMovies = [[NSMutableDictionary alloc] init];
    [mMovies setObject:movie forKey:[self stringForKey:key]];
    [self addDisplayObject:movie forKey:key];
}

- (void)addDisplayObject:(SPDisplayObject *)displayObject forKey:(uint)key {
    if (mDisplayObjects == nil)
        mDisplayObjects = [[NSMutableDictionary alloc] init];
    displayObject.tag = key;
    [mDisplayObjects setObject:displayObject forKey:[self stringForKey:key]];
}

- (SPDisplayObject *)removeDisplayObjectForKey:(uint)key {
    NSString *stringKey = [self stringForKey:key];
    
    SPDisplayObject *object = [[(SPDisplayObject *)[mMovies objectForKey:stringKey] retain] autorelease];
    
    if (object) {
        [mScene.juggler removeObject:(SPMovieClip *)object];
        [mMovies removeObjectForKey:stringKey];
    } else
        object = [[(SPDisplayObject *)[mDisplayObjects objectForKey:stringKey] retain] autorelease];
    [mDisplayObjects removeObjectForKey:stringKey];
    
    if (object)
        [object removeFromParent];
    return object;
}

- (SPDisplayObject *)displayObjectForKey:(uint)key {
    return [mDisplayObjects objectForKey:[self stringForKey:key]];
}

- (void)addMiscResource:(NSObject *)resource forKey:(uint)key {
    if (mMiscResources == nil)
        mMiscResources = [[NSMutableDictionary alloc] init];
    [mMiscResources setObject:resource forKey:[self stringForKey:key]];
}

- (NSObject *)removeMiscResourceForKey:(uint)key {
    NSString *stringKey = [self stringForKey:key];
    NSObject *miscResource = [[(NSObject *)[mMiscResources objectForKey:stringKey] retain] autorelease];
    [mMiscResources removeObjectForKey:stringKey];
    return miscResource;
}

- (NSObject *)miscResourceForKey:(uint)key {
    return (NSObject *)[mMiscResources objectForKey:[self stringForKey:key]];
}

- (void)reset {
    //for (NSString *key in mTweens) {
    //    SPTween *tween = (SPTween *)[mTweens objectForKey:key];
        //[mScene.juggler removeObject:tween];
    //    [tween reset];
    //}
    
    for (NSString *key in mMovies) {
        SPMovieClip *movie = (SPMovieClip *)[mMovies objectForKey:key];
        //[mScene.juggler removeObject:movie];
        movie.currentFrame = 0;
        [movie pause];
    }
    
    for (NSString *key in mDisplayObjects) {
        SPDisplayObject *object = (SPDisplayObject *)[mDisplayObjects objectForKey:key];
        [object removeFromParent];
    }
    
    self.client = nil;
}

@end
