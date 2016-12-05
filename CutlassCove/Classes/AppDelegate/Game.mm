//
//  Game.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright Cheeky Mammoth 2010. All rights reserved.
//

#import "Game.h" 
#import "CutlassCoveViewController.h"
#import "CCOFManager.h"
#import "ThreadSafetyManager.h"
#import "GameController.h"
#import "PlayerDetails.h"
#import "Globals.h"


@interface Game ()


@end

@implementation Game

- (void)setupWithViewController:(CutlassCoveViewController *)viewController ofDelegate:(CCOFManager *)ofDelegate {
#ifdef CC_THREADED_MEMORY_POOLING
    [[NSThread currentThread] setName:@"Main"];
	
    ThreadSafetyManager *tsm = [ThreadSafetyManager threadSafetyManager];
    [tsm threadDidStartWithName:[[NSThread currentThread] name]];
#endif
    RANDOM_SEED();
    [GCTRL setupWithStage:self viewController:viewController ofDelegate:ofDelegate];
}

- (void)pausePirates {
	[GCTRL overridingPause];
}

- (void)propagateMemoryWarning {
#ifdef CC_THREADED_MEMORY_POOLING
	[[ThreadSafetyManager threadSafetyManager] didReceiveMemoryWarning];
#else
	[GCTRL didReceiveMemoryWarning];
#endif
}

- (void)advanceTime:(double)seconds {
	[GCTRL advanceTime:seconds];
}

- (void)applicationWillTerminate {
	[GCTRL applicationWillTerminate];
}

@end
