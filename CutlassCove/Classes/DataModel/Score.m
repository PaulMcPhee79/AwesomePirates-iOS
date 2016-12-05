//
//  Score.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Score.h"


@implementation Score

@synthesize score = mScore;
@synthesize playerName = mPlayerName;
@synthesize date = mDate;

+ (Score *)scoreWithName:(NSString *)name score:(int64_t)score {
	return [[[Score alloc] initWithName:name score:score date:[NSDate date]] autorelease];
}

+ (Score *)scoreWithName:(NSString *)name score:(int64_t)score date:(NSDate *)date {
	return [[[Score alloc] initWithName:name score:score date:date] autorelease];
}

- (id)initWithName:(NSString *)name score:(int64_t)score date:(NSDate *)date {
	if (self = [super init]) {
		mPlayerName = [name copy];
		mScore = score;
		mDate = [date retain];
	}
	return self;
}

- (id)init {
	return [self initWithName:nil score:0 date:[NSDate date]];
}

- (void)dealloc {
	[mPlayerName release]; mPlayerName = nil;
	[mDate release]; mDate = nil;
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithLongLong:mScore] forKey:@"score"];
	[coder encodeObject:mPlayerName forKey:@"playerName"];
    [coder encodeObject:mDate forKey:@"date"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        mScore = [(NSNumber *)[decoder decodeObjectForKey:@"score"] longLongValue];
        self.playerName = (NSString *)[decoder decodeObjectForKey:@"playerName"];
        self.date = (NSDate *)[decoder decodeObjectForKey:@"date"];
	}
	return self;
}

@end
