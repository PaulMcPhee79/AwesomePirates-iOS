//
//  Hostage.h
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Infamous.h"

#define kGenderFemale 0
#define kGenderMale 1

@interface Hostage : NSObject <Infamous,NSCoding> {
	NSString *mName;
	NSString *mTextureName;
	int mGender;
	uint mValue;
}

@property (nonatomic,readonly) NSString *name;
@property (nonatomic,retain) NSString *textureName;
@property (nonatomic,assign) uint value;
@property (nonatomic,assign) int gender;

- (id)initWithName:(NSString *)name;
- (NSComparisonResult)compare:(Hostage *)hostage;

@end
