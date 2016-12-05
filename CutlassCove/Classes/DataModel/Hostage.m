//
//  Hostage.m
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Hostage.h"

@implementation Hostage

@synthesize name = mName;
@synthesize textureName = mTextureName;
@synthesize value = mValue;
@synthesize gender = mGender;

- (id)initWithName:(NSString *)name {
	if (self = [super init]) {
		mName = [name copy];
		mTextureName = nil;
		mValue = 0;
		mGender = kGenderFemale;
	}
	return self;
}

- (id)init {
	return [self initWithName:@"Default"];
}

- (int)infamyBonus {
	return 0;
}

- (NSComparisonResult)compare:(Hostage *)hostage {
	NSComparisonResult result;
	
	if (mValue < hostage.value)
		result = NSOrderedAscending;
	else if (mValue > hostage.value)
		result = NSOrderedDescending;
	else
		result = NSOrderedSame;
	return result;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		mName = [(NSString *)[decoder decodeObjectForKey:@"name"] copy];
		mTextureName = [(NSString *)[decoder decodeObjectForKey:@"textureName"] copy];
		mGender = [(NSNumber *)[decoder decodeObjectForKey:@"gender"] intValue];
		mValue = [(NSNumber *)[decoder decodeObjectForKey:@"value"] unsignedIntValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:mName forKey:@"name"];
	[coder encodeObject:mTextureName forKey:@"textureName"];
	[coder encodeObject:[NSNumber numberWithInt:mGender] forKey:@"gender"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mValue] forKey:@"value"];
}

- (void)dealloc {
	[mName release]; mName = nil;
	[mTextureName release]; mTextureName = nil;
	[super dealloc];
}

@end
