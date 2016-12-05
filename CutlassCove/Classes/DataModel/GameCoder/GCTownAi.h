//
//  GCTownAi.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 2/02/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCCannonball.h"

@interface GCTownAi : NSObject <NSCoding> {
	double timeSinceLastShot;
	NSMutableArray *cannonballs;
}

@property (nonatomic,assign) double timeSinceLastShot;
@property (nonatomic,readonly) NSArray *cannonballs;

- (void)addCannonball:(GCCannonball *)cannonball;

@end
