//
//  ThreadSafetyManager.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/08/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThreadSafetyManager : NSObject {
	BOOL mShouldPurgePools;
	int mActiveThreadCount;
	NSMutableDictionary *mMemoryPoolKeys;
}

+ (ThreadSafetyManager *)threadSafetyManager;
- (void)threadDidStartWithName:(NSString *)name;
- (void)threadWillExitWithName:(NSString *)name;
- (void)didReceiveMemoryWarning;
- (void)performDuties; // Pump this from the main thread only.

@end
