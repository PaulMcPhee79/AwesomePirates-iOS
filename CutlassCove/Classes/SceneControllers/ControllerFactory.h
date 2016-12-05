//
//  ControllerFactory.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SceneController;

@interface ResDef : NSObject {
	NSString *mName;
	NSString *mPath;
	float mWeighting;
}

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,assign) float weighting;

@end


@interface SceneRequirements : NSObject {
	NSMutableArray *mGraphicsResources;
	NSMutableArray *mAudioResources;
}

- (void)populateForSceneByKey:(NSString *)sceneKey;
- (ResDef *)nextGraphicsResource;
- (ResDef *)nextAudioResource;

@end


@interface ControllerFactory : NSObject {
	id mCaller;
	float mProgress;
	uint mVoodooKeys;
	NSString *mLoadingSceneName;
	SEL mProgressCallback;
	SEL mLoadCompleteCallback;
	ResDef *mCurrentResDef;
	SceneRequirements *mSceneReqs;
}

@property (nonatomic,assign) uint voodooKeys;

//- (void)unloadScene:(SceneController *)scene caller:(id)caller unloadedCallback:(SEL)callback;
- (void)loadSceneReqsByName:(NSString *)name caller:(id)caller loadedCallback:(SEL)callback;
- (void)loadSceneReqsAsyncByName:(NSString *)name caller:(id)caller progressCallback:(SEL)prgCallback loadedCallback:(SEL)callback;
- (SceneController *)createSceneByName:(NSString *)name;


@end
