//
//  Prisoner.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 1/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hostage.h"

@interface Prisoner : Hostage <NSCoding> {
	BOOL mPlanked;
	int mInfamyBonus;
}

@property (nonatomic,assign) BOOL planked;
@property (nonatomic,assign) int infamyBonus;

+(Prisoner *)prisonerWithName:(NSString *)name;

@end
