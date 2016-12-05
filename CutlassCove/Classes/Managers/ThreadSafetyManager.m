//
//  ThreadSafetyManager.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/08/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ThreadSafetyManager.h"
#import "GameController.h"

@interface ThreadSafetyManager ()

- (void)purgePools;

@end


static ThreadSafetyManager *_tsManager = nil;

@implementation ThreadSafetyManager

+ (ThreadSafetyManager *)threadSafetyManager {
	if (_tsManager == nil) {
		if ([NSThread isMainThread] == NO)
			[NSException raise:NSGenericException format:@"ThreadSafetyManager may only be allocated from the main thread."];
		_tsManager = [[ThreadSafetyManager alloc] init];
	}
	return _tsManager;
}

- (id)init {
	if (self = [super init]) {
		mShouldPurgePools = NO;
		mActiveThreadCount = 0;
		mMemoryPoolKeys = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						   @"Main", @"Main",
						   @"Loading", @"Loading",
                           @"Caching", @"Caching",
						   nil];
		// Prime the memory pools
		[SPPoint pointWithX:0 y:0];
		[SPRectangle rectangleWithX:0 y:0 width:0 height:0];
		[SPMatrix matrixWithIdentity];
	}
	return self;
}

- (void)threadDidStartWithName:(NSString *)name {
	@synchronized(self) {
		//NSLog(@"Thread starting with name: %@", name);
		
		if ([mMemoryPoolKeys objectForKey:name] == nil)
			assert(0);
		[mMemoryPoolKeys removeObjectForKey:name];
		++mActiveThreadCount;
	}
}

- (void)threadWillExitWithName:(NSString *)name {
	@synchronized(self) {
		//NSLog(@"Thread exiting with name: %@", name);
		
		if ([mMemoryPoolKeys objectForKey:name] != nil)
			assert(0);
		[mMemoryPoolKeys setObject:name forKey:name];
		--mActiveThreadCount;
	}
}

- (void)didReceiveMemoryWarning {
	assert([NSThread isMainThread]);
	mShouldPurgePools = YES;
}

- (void)performDuties {
	assert([NSThread isMainThread]);
	
	if (mShouldPurgePools == YES)
		[self purgePools];
}

- (void)purgePools {
	@synchronized(self) {
		if (mActiveThreadCount == 1) {
			[[GameController GC] didReceiveMemoryWarning];
			mShouldPurgePools = NO;
		}
	}
}

- (void)dealloc {
	[mMemoryPoolKeys release]; mMemoryPoolKeys = nil;
	[_tsManager release]; _tsManager = nil;
	[super dealloc];
}

@end
