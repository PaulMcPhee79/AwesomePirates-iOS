//
//  SPJuggler_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPJuggler_Extension.h"


@implementation SPJuggler (Extension)

- (BOOL)containsObject:(id)object {
	return [mObjects containsObject:object];
}

@end
