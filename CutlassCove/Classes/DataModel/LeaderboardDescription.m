//
//  LeaderboardDescription.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "LeaderboardDescription.h"


@implementation LeaderboardDescription

@synthesize score = mScore;
@synthesize rank = mRank;
@synthesize formattedScore = mFormattedScore;
@synthesize alias = mAlias;
@synthesize date = mDate;

- (id)initWithScore:(int64_t)score rank:(NSInteger)rank {
	if (self = [super init]) {
		mScore = score;
		mRank = rank;
		mFormattedScore = nil;
		mAlias = nil;
		mDate = nil;
	}
	return self;
}

- (void)dealloc {
	[mFormattedScore release]; mFormattedScore = nil;
	[mAlias release]; mAlias = nil;
	[mDate release]; mDate = nil;
	[super dealloc];
}

@end
