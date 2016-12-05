//
//  SPBitmapFont_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 22/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPBitmapFont_Extension.h"


@implementation SPBitmapFont (Extension)

- (SPBitmapChar *)charWithID_CHEEKY:(int)charID {
	return (SPBitmapChar *)[mChars objectForKey:[NSNumber numberWithInt:charID]];
}

@end
