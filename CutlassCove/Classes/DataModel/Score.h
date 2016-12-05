//
//  Score.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Score : NSObject <NSCoding> {
	int64_t mScore;
	NSString *mPlayerName;
	NSDate *mDate;
}

@property (nonatomic,assign) int64_t score;
@property (nonatomic,copy) NSString *playerName; // GKPlayer.playerID
@property (nonatomic,retain) NSDate *date;

+ (Score *)scoreWithName:(NSString *)name score:(int64_t)score;
+ (Score *)scoreWithName:(NSString *)name score:(int64_t)score date:(NSDate *)date;
- (id)initWithName:(NSString *)name score:(int64_t)score date:(NSDate *)date;

@end
