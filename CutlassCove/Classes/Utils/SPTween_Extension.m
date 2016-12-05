//
//  SPTween_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPTween_Extension.h"
#import "SPTweenedProperty.h"


@implementation SPTween (Extension)

- (void)commitProperties {
	for (SPTweenedProperty *property in mProperties)
		property.startValue = property.currentValue;
}

- (void)resetProperties {
	for (SPTweenedProperty *property in mProperties)
		property.currentValue = property.startValue;
	mCurrentTime = 0;
}

@end
