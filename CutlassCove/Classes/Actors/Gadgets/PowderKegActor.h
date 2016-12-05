//
//  PowderKegActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Ignitable.h"

@class Prop;

@interface PowderKegActor : Actor <Ignitable> {
	BOOL mDetonated; // Prevents infinite recursion with other PowderKegActors during chain reactions
	SPSprite *mCostume;
}

+ (PowderKegActor *)powderKegActorAtX:(float)x y:(float)y rotation:(float)rotation;
- (BOOL)detonate;

@end
