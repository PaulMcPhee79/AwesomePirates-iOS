//
//  LeaderboardDescription.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LeaderboardDescription : NSObject {
	int64_t mScore;
	NSInteger mRank;
	
	NSString *mFormattedScore;
	NSString *mAlias;
	NSDate *mDate;
}

- (id)initWithScore:(int64_t)score rank:(NSInteger)rank;

@property (nonatomic,assign) int64_t score;
@property (nonatomic,assign) NSInteger rank;
@property (nonatomic,copy) NSString *formattedScore;
@property (nonatomic,copy) NSString *alias;
@property (nonatomic,retain) NSDate *date;

@end
