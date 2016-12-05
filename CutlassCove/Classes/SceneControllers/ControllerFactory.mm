//
//  ControllerFactory.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ControllerFactory.h"
#import "PlayfieldController.h"
#import "TextureManager.h"
#import "AudioPlayer.h"
#import "Globals.h"

@interface ControllerFactory ()

- (SceneController *)createPlayfieldController;
- (BOOL)loadNextSceneReq;
- (void)loadNextSceneReqAsync;
- (void)onSceneReqLoaded:(NSString *)name;

@end

@implementation ControllerFactory

@synthesize voodooKeys = mVoodooKeys;

- (id)init {
	if (self = [super init]) {
		mVoodooKeys = 0;
		mCaller = nil;
		mLoadingSceneName = nil;
		mCurrentResDef = nil;
		mSceneReqs = [[SceneRequirements alloc] init];
	}
	return self;
}

- (void)dealloc {
	[mCaller release]; mCaller = nil;
	[mLoadingSceneName release]; mLoadingSceneName = nil;
	[mCurrentResDef release]; mCurrentResDef = nil;
	[mSceneReqs release]; mSceneReqs = nil;
	[super dealloc];
}

- (SceneController *)createSceneByName:(NSString *)name {
	SceneController *scene = nil;
	
	if ([name isEqualToString:@"Playfield"])
		scene = [self createPlayfieldController];
	return scene;
}

- (SceneController *)createPlayfieldController {
	PlayfieldController *controller = [[[PlayfieldController alloc] init] autorelease];
	return controller;
}

- (void)loadSceneReqsByName:(NSString *)name caller:(id)caller loadedCallback:(SEL)callback {
    assert(mLoadingSceneName == nil && mCaller == nil && callback);
	mLoadingSceneName = [name copy];
	mCaller = [caller retain];
	mLoadCompleteCallback = callback;
	mProgress = 0;
	[mSceneReqs populateForSceneByKey:name];
    
    BOOL didLoadMore;
    
    do {
        didLoadMore = [self loadNextSceneReq];
        
        if (didLoadMore) {
            mProgress += mCurrentResDef.weighting;
            
            // Prepare to load next part
            [mCurrentResDef release];
            mCurrentResDef = nil;
        }
    } while (didLoadMore);
}

- (BOOL)loadNextSceneReq {
    BOOL didLoadMore = NO;
    
    assert(mCurrentResDef == nil);
	mCurrentResDef = [[mSceneReqs nextGraphicsResource] retain];
	
	if (mCurrentResDef) {
		// Load Texture Atlas
        didLoadMore = YES;
		[GCTRL.textureManager checkoutAtlasByName:mCurrentResDef.name
                                             path:mCurrentResDef.path
                                         category:mLoadingSceneName];
	} else {
		mCurrentResDef = [[mSceneReqs nextAudioResource] retain];
		
		if (mCurrentResDef) {
			// Load Audio data
			assert(GCTRL.queuedAudioPlayer);
            didLoadMore = YES;
			[[GameController GC].queuedAudioPlayer loadAudioSettingsFromPlist:mCurrentResDef.path
																	 audioKey:mCurrentResDef.name
																	   extras:[Globals voodooAudioForKeys:mVoodooKeys sceneName:mCurrentResDef.name]];
		} else {
			// Load complete
			NSString *errorMsg = nil;
			NSString *sceneName = [mLoadingSceneName autorelease];
			id caller = [mCaller autorelease];
			
			mLoadingSceneName = nil;
			mCaller = nil;
			[caller performSelector:mLoadCompleteCallback withObject:sceneName withObject:errorMsg];
		}
	}
    
    return didLoadMore;
}

- (void)loadSceneReqsAsyncByName:(NSString *)name caller:(id)caller progressCallback:(SEL)prgCallback loadedCallback:(SEL)callback {
	assert(mLoadingSceneName == nil && mCaller == nil && callback);
	mLoadingSceneName = [name copy];
	mCaller = [caller retain];
	mProgressCallback = prgCallback;
	mLoadCompleteCallback = callback;
	mProgress = 0;
	[mSceneReqs populateForSceneByKey:name];
	[self loadNextSceneReqAsync];
}

- (void)loadNextSceneReqAsync {
	assert(mCurrentResDef == nil);
	mCurrentResDef = [[mSceneReqs nextGraphicsResource] retain];
	
	if (mCurrentResDef) {
		// Load Texture Atlas
		[GCTRL.textureManager checkoutAtlasByName:mCurrentResDef.name
														   path:mCurrentResDef.path
													   category:mLoadingSceneName
														 caller:self
													   callback:@"onSceneReqLoaded:"];
	} else {
		mCurrentResDef = [[mSceneReqs nextAudioResource] retain];
		
		if (mCurrentResDef) {
			// Load Audio data
			assert(GCTRL.queuedAudioPlayer);
			[[GameController GC].queuedAudioPlayer loadAudioSettingsFromPlist:mCurrentResDef.path
																	 audioKey:mCurrentResDef.name
																	   extras:[Globals voodooAudioForKeys:mVoodooKeys sceneName:mCurrentResDef.name]
																	   caller:self
																	 callback:@"onSceneReqLoaded:"];
		} else {
			// Load complete
			NSString *errorMsg = nil;
			NSString *sceneName = [mLoadingSceneName autorelease];
			id caller = [mCaller autorelease];
			
			mLoadingSceneName = nil;
			mCaller = nil;
			[caller performSelector:mLoadCompleteCallback withObject:sceneName withObject:errorMsg];
		}
	}
}

- (void)onSceneReqLoaded:(NSString *)name {
	mProgress += mCurrentResDef.weighting;
	
	// Update progress
	if (mProgressCallback)
		[mCaller performSelector:mProgressCallback withObject:[NSNumber numberWithFloat:mProgress]];
	
	// Load next part
	[mCurrentResDef release];
	mCurrentResDef = nil;
	[self loadNextSceneReqAsync];
}

@end


@implementation SceneRequirements

- (id)init {
	if (self = [super init]) {
		mGraphicsResources = [[NSMutableArray alloc] init];
		mAudioResources = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[mGraphicsResources release]; mGraphicsResources = nil;
	[mAudioResources release]; mAudioResources = nil;
	[super dealloc];
}

- (void)populateForSceneByKey:(NSString *)sceneKey {
	[mGraphicsResources removeAllObjects];
	[mAudioResources removeAllObjects];
	
	NSDictionary *sceneReqPlist = [Globals loadPlist:@"SceneReqs"];
	NSDictionary *sceneDict = (NSDictionary *)[sceneReqPlist objectForKey:sceneKey];
	
	NSArray *resArray = (NSArray *)[sceneDict objectForKey:@"Graphics"];
	
	// Graphics
	for (NSDictionary *resDict in resArray) {
		ResDef *def = [[ResDef alloc] init];
		def.name = [resDict objectForKey:@"name"];
		def.path = [resDict objectForKey:@"path"];
		def.weighting = [(NSNumber *)[resDict objectForKey:@"weighting"] floatValue];
		[mGraphicsResources addObject:def];
		[def release];
		
		//NSLog(@"Name: %@ Path: %@ Weighting: %f", def.name, def.path, def.weighting);
	}
	
	resArray = (NSArray *)[sceneDict objectForKey:@"Audio"];
	
	// Audio
	for (NSDictionary *resDict in resArray) {
		ResDef *def = [[ResDef alloc] init];
		def.name = [resDict objectForKey:@"name"];
		def.path = [resDict objectForKey:@"path"];
		def.weighting = [(NSNumber *)[resDict objectForKey:@"weighting"] floatValue];
		[mAudioResources addObject:def];
		[def release];
		
		//NSLog(@"Name: %@ Path: %@ Weighting: %f", def.name, def.path, def.weighting);
	}
}

- (ResDef *)nextGraphicsResource {
	ResDef *def = nil;
	
	if (mGraphicsResources.count > 0) {
		def = [[mGraphicsResources objectAtIndex:0] retain];
		[mGraphicsResources removeObjectAtIndex:0];
	}
	return [def autorelease];
}

- (ResDef *)nextAudioResource {
	ResDef *def = nil;
	
	if (mAudioResources.count > 0) {
		def = [[mAudioResources objectAtIndex:0] retain];
		[mAudioResources removeObjectAtIndex:0];
	}
	return [def autorelease];
}

@end


@implementation ResDef

@synthesize name = mName;
@synthesize path = mPath;
@synthesize weighting = mWeighting;

- (id)init {
	if (self = [super init]) {
		mName = nil;
		mPath = nil;
		mWeighting = 0;
	}
	return self;
}

- (void)dealloc {
	[mName release]; mName = nil;
	[mPath release]; mPath = nil;
	[super dealloc];
}

@end


