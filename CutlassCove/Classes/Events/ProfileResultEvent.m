//
//  ProfileResultEvent.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ProfileResultEvent.h"


@implementation ProfileResultEvent

@synthesize error = mError;
@synthesize achievements = mAchievements;
@synthesize leaderboard = mLeaderboard;
@synthesize localPlayerScore = mLocalPlayerScore;
@dynamic errorString;

+ (ProfileResultEvent *)profileResultEventWithType:(NSString *)type
									  achievements:(NSArray *)achievements
									   leaderboard:(NSArray *)leaderboard
								  localPlayerScore:(LeaderboardDescription *)localPlayerScore
                                             error:(NSError *)error
										   bubbles:(BOOL)bubbles {
	return [[[ProfileResultEvent alloc] initWithType:type
										achievements:achievements
										 leaderboard:leaderboard
									localPlayerScore:localPlayerScore
                                               error:error
											 bubbles:bubbles] autorelease];
}

- (id)initWithType:(NSString *)type
	  achievements:(NSArray *)achievements
	   leaderboard:(NSArray *)leaderboard
  localPlayerScore:(LeaderboardDescription *)localPlayerScore
             error:(NSError *)error
		   bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type]) {
		mError = [error copy];
		mAchievements = [achievements retain];
		mLeaderboard = [leaderboard retain];
		mLocalPlayerScore = [localPlayerScore retain];
	}
	return self;
}

- (NSString *)errorString {
    return [mError localizedDescription];
}

- (void)dealloc {
	[mError release]; mError = nil;
	[mAchievements release]; mAchievements = nil;
	[mLeaderboard release]; mLeaderboard = nil;
	[mLocalPlayerScore release]; mLocalPlayerScore = nil;
	[super dealloc];
}

@end
