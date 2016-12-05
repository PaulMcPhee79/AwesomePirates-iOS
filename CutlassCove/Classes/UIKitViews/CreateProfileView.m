//
//  CreateProfileView.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CreateProfileView.h"

@interface CreateProfileView ()


@end


@implementation CreateProfileView

@dynamic profileName;

- (id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame:aRect]) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setupView {
	mProfileNameTextfield = [[UITextField alloc] init];
	//mProfileNameTextfield.font = @"MarkerFelt-Thin";
	mProfileNameTextfield.text = @"Some Text";
	[self addSubview:mProfileNameTextfield];
	[mProfileNameTextfield sizeToFit];
}

- (NSString *)profileName {
	return mProfileNameTextfield.text;
}

- (void)dealloc {
	[mProfileNameTextfield release]; mProfileNameTextfield = nil;
	[super dealloc];
}

@end
