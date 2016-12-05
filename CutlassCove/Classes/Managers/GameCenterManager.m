//
//  GameCenterManager.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GameCenterManager.h"

@interface GameCenterManager ()

- (void)callDelegate:(SEL)selector withArg:(id)arg info:(id)info;
- (void)callDelegateOnMainThread:(SEL)selector withArg:(id)arg info:(id)info;
- (void)callDelegate:(SEL)selector info:(GCInfo *)info;
- (void)callDelegateOnMainThread:(SEL)selector info:(GCInfo *)info;

- (void)udpateEarnedAchievementCacheWithAchievements:(NSDictionary *)achievements; // Main thread only

- (void)playerAuthenticationDidChange:(NSNotification *)notification;

@end


@implementation GameCenterManager

@synthesize playerID = mPlayerID;
@synthesize earnedAchievementCache = mEarnedAchievementCache;
@synthesize delegate = mDelegate;
@dynamic authenticated;

- (id) init {
	if (self = [super init]) {
        mPlayerID = nil;
		mEarnedAchievementCache = nil;
		mDelegate = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticationDidChange:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	}
	return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	mDelegate = nil;
    [mPlayerID release]; mPlayerID = nil;
	[mEarnedAchievementCache release]; mEarnedAchievementCache = nil;
	[super dealloc];
}

- (BOOL)authenticated {
	return [GKLocalPlayer localPlayer].authenticated;
}

- (void)callDelegate:(SEL)selector withArg:(id)arg info:(id)info {
	assert([NSThread isMainThread]);
	
	if ([mDelegate respondsToSelector: selector]) {
		[mDelegate performSelector:selector withObject:arg withObject:info];
	} else {
		NSLog(@"Selector Not Found.");
	}
}

- (void)callDelegateOnMainThread:(SEL)selector withArg:(id)arg info:(id)info {
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self callDelegate:selector withArg:arg info:info];
	});
}

- (void)callDelegate:(SEL)selector info:(GCInfo *)info {
	assert([NSThread isMainThread]);
	
	if ([mDelegate respondsToSelector: selector]) {
		[mDelegate performSelector:selector withObject:info];
	} else {
		NSLog(@"Selector Not Found.");
	}
}

- (void)callDelegateOnMainThread:(SEL)selector info:(GCInfo *)info {
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self callDelegate:selector info:info];
	});
}

- (void)resetAchievementCache {
    self.earnedAchievementCache = nil;
}

- (void)playerAuthenticationDidChange:(NSNotification *)notification {
    [mDelegate playerAuthenticationWillChange];
}

- (BOOL)authenticateLocalUser:(QueryID *)qid {
    if ([[GKLocalPlayer localPlayer] respondsToSelector:@selector(setAuthenticateHandler:)]) {
        // iOS 6+
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            GCInfo *info = [GCInfo gcInfoWithQid:qid data:viewController error:error];
            [self callDelegateOnMainThread:@selector(processGameCenterAuthentication:) info:info];
            
            [pool release];
        };
    } else {
        // iOS 5
        if ([GKLocalPlayer localPlayer].authenticated)
            return false;
        
        // authenticateWithCompletionHandler can block sometimes, so we explicitly dispath on another thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
                GCInfo *info = [GCInfo gcInfoWithQid:qid error:error];
                [self callDelegateOnMainThread:@selector(processGameCenterAuthentication:) info:info];
            }];
#pragma clang diagnostic pop
            
            [pool release];
        });
    }
    
    return true;
}

- (void)fetchScoresForCategory:(NSString *)category range:(NSRange)range playerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope qid:(QueryID *)qid {
    range.length = MIN(100, range.length);
	
	GKLeaderboard *leaderBoard = [[[GKLeaderboard alloc] init] autorelease];
	leaderBoard.category = category;
	leaderBoard.timeScope = timeScope;
	leaderBoard.range = range;
	leaderBoard.playerScope = playerScope;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            GCInfo *info = [GCInfo gcInfoWithQid:qid error:error];
            [self callDelegateOnMainThread:@selector(fetchScoresComplete:info:) withArg:leaderBoard info:info];
        }];
        
        [pool release];
    });
}

- (void)udpateEarnedAchievementCacheWithAchievements:(NSDictionary *)achievements {
    assert([NSThread isMainThread]);
    
    if (achievements && achievements.count > 0) {
        if (self.earnedAchievementCache == nil)
            self.earnedAchievementCache = [NSMutableDictionary dictionaryWithCapacity:achievements.count];
        [self.earnedAchievementCache addEntriesFromDictionary:achievements];
    }
}

- (void)fetchAchievements:(QueryID *)qid {
	if (self.earnedAchievementCache && self.earnedAchievementCache.count == GCM_ACHIEVEMENT_COUNT) {
        GCInfo *info = [GCInfo gcInfoWithQid:qid error:nil];
		[self callDelegateOnMainThread:@selector(fetchAchievementsComplete:info:) withArg:[NSDictionary dictionaryWithDictionary:self.earnedAchievementCache] info:info];
        return;
    }
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            NSMutableDictionary *tempCache = nil;
            
            for (GKAchievement *achievement in achievements) {
                if (tempCache == nil)
                    tempCache = [NSMutableDictionary dictionaryWithCapacity:[achievements count]];
                
                if (achievement.identifier)
                    [tempCache setObject:achievement forKey:achievement.identifier];
            }
            
            [self performSelectorOnMainThread:@selector(udpateEarnedAchievementCacheWithAchievements:) withObject:tempCache waitUntilDone:YES];
            
            GCInfo *info = [GCInfo gcInfoWithQid:qid error:error];
            [self callDelegateOnMainThread:@selector(fetchAchievementsComplete:info:) withArg:tempCache info:info];
        }];
        
        [pool release];
    });
}

- (void)resetAchievements {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) {
            [self callDelegateOnMainThread: @selector(resetAchievementsComplete:error:) withArg:error info:error];
        }];
        
        [pool release];
    });
}

- (void)reportScore:(GKScore *)score {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [score reportScoreWithCompletionHandler: ^(NSError *error) {
            [self callDelegateOnMainThread: @selector(scoreReported:error:) withArg:score info:error];
        }];
        
        [pool release];
    });
}

- (void)reportScore:(int64_t)score forCategory:(NSString *)category {
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];	
	scoreReporter.value = score;
    [self reportScore:scoreReporter];
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete {
    GKAchievement* achievement = [self.earnedAchievementCache objectForKey:identifier];
    
    if (achievement != nil) {
        if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete)) {
            //Achievement has already been earned so we're done.
            achievement = nil;
        }
        else
            achievement.percentComplete = percentComplete;
    } else {
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        achievement.percentComplete = percentComplete;
        //Add achievement to achievement cache...
        [self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
    }
    
    if (achievement == nil)
        return;
    
    //Submit the Achievement...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [achievement reportAchievementWithCompletionHandler: ^(NSError *error) {
            [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg:achievement info:error];
        }];
        
        [pool release];
    });
}

- (void)fetchPlayerForID:(NSString *)playerID qid:(QueryID *)qid {
	if (playerID == nil || qid == nil)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error) {
            GKPlayer* player = nil;
            
            for (GKPlayer* tempPlayer in playerArray) {
                if([tempPlayer.playerID isEqualToString:playerID]) {
                    player = tempPlayer;
                    break;
                }
            }
            GCInfo *info = [GCInfo gcInfoWithQid:qid error:error];
            [self callDelegateOnMainThread: @selector(playerFetched:info:) withArg:player info:info];
        }];
        
        [pool release];
    });
}

- (void)fetchPlayersForIDs:(NSArray *)playerIDs qid:(QueryID *)qid {
    if (playerIDs == nil || qid == nil)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *playerArray, NSError *error) {
            GCInfo *info = [GCInfo gcInfoWithQid:qid error:error];
            [self callDelegateOnMainThread: @selector(playersFetched:info:) withArg:playerArray info:info];
        }];
        
        [pool release];
    });
}

@end

@implementation QueryID

@synthesize seqNo = mSeqNo;
@synthesize tag = mTag;

- (id)initWithQueryID:(QueryID *)qid {
	if (self = [super init]) {
		mSeqNo = qid.seqNo;
		mTag = [qid.tag copy];
	}
	return self;
}

+ (QueryID *)qidWithTag:(NSString *)tag {
    QueryID *qid = [[[QueryID alloc] init] autorelease];
    qid.tag = tag;
    return qid;
}

- (void)dealloc {
	[mTag release]; mTag = nil;
	[super dealloc];
}

@end

@implementation GCInfo

@synthesize qid = mQid;
@synthesize data = mData;
@synthesize error = mError;

+ (GCInfo *)gcInfoWithQid:(QueryID *)qid error:(NSError *)error {
	return [GCInfo gcInfoWithQid:qid data:nil error:error];
}

+ (GCInfo *)gcInfoWithQid:(QueryID *)qid data:(NSObject *)data error:(NSError *)error {
	return [[[GCInfo alloc] initWithQid:qid data:data error:error] autorelease];
}

- (id)initWithQid:(QueryID *)qid data:(NSObject *)data error:(NSError *)error {
	if (self = [super init]) {
		mQid = [qid retain];
        mData = [data retain];
		mError = [error retain];
	}
	return self;
}

- (void)dealloc {
	[mQid release]; mQid = nil;
    [mData release]; mData = nil;
	[mError release]; mError = nil;
	[super dealloc];
}

@end


