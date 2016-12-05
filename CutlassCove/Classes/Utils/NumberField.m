//
//  NumberField.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumberField.h"
#import "Globals.h"

@implementation NumberField

@synthesize value = mValue;

- (void)setValue:(uint)value {
	mValue = value;
	self.text = [Globals commaSeparatedValue:value];
}

@end
