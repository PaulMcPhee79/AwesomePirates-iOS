//
//  ResourceServer.h
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "ResourceClient.h"

@interface ResourceServer : Prop {
    NSMutableDictionary *mTweens;
    NSMutableDictionary *mMovies;
    NSMutableDictionary *mDisplayObjects;
    NSMutableDictionary *mMiscResources;
    NSObject<ResourceClient> *mClient; // Weak reference
}

@property (nonatomic,assign) NSObject<ResourceClient> *client;

+ (ResourceServer *)resourceServer;

- (void)reassignScene:(SceneController *)scene;

- (void)addTween:(SPTween *)tween forKey:(uint)key;
- (BOOL)startTweenForKey:(uint)key;
- (void)stopTweenForKey:(uint)key;

- (void)addMovie:(SPMovieClip *)movie forKey:(uint)key; // Automatically adds to mDisplayObjects list

- (void)addDisplayObject:(SPDisplayObject *)displayObject forKey:(uint)key;
- (SPDisplayObject *)removeDisplayObjectForKey:(uint)key;
- (SPDisplayObject *)displayObjectForKey:(uint)key;

- (void)addMiscResource:(NSObject *)resource forKey:(uint)key;
- (NSObject *)removeMiscResourceForKey:(uint)key;
- (NSObject *)miscResourceForKey:(uint)key;

- (void)reset;

@end
