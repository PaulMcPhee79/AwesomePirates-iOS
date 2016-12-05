//
//  SPSprite_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPSprite_Extension.h"

@implementation SPSprite (Extension)

- (NSComparisonResult)yCompare:(SPSprite *)aSprite {
	NSComparisonResult result;
	
	if (self.y < aSprite.y)
		result = NSOrderedAscending;
	else if (self.y > aSprite.y)
		result = NSOrderedDescending;
	else
		result = NSOrderedSame;
	return result;
}

@end
