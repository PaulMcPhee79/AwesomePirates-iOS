//
//  Prisoner.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Prisoner.h"
#import "CCMiscConstants.h"

@implementation Prisoner

@synthesize planked = mPlanked;
@synthesize infamyBonus = mInfamyBonus;

+(Prisoner *)prisonerWithName:(NSString *)name {
	return [[[Prisoner alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name {
	if (self = [super initWithName:name]) {
		mPlanked = NO;
		mInfamyBonus = CC_OVERBOARD_SCORE_BONUS;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		mPlanked = [(NSNumber *)[decoder decodeObjectForKey:@"planked"] boolValue];
		mInfamyBonus = [(NSNumber *)[decoder decodeObjectForKey:@"infamyBonus"] intValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:[NSNumber numberWithBool:mPlanked] forKey:@"planked"];
	[coder encodeObject:[NSNumber numberWithInt:mInfamyBonus] forKey:@"infamyBonus"];
}

@end
