//
//  GCCannonball.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 2/02/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cannonball,CannonballInfamyBonus;

@interface GCCannonball : NSObject <NSCoding> {
	NSString *shotType;
	int groupId;
	uint ricochetCount;
	CannonballInfamyBonus *infamyBonus;
	float bore;
	float x;
	float y;
	float velX;
	float velY;
	float trajectory;
	float distanceRemaining;
}

@property (nonatomic,copy) NSString *shotType;
@property (nonatomic,assign) int groupId;
@property (nonatomic,assign) uint ricochetCount;
@property (nonatomic,retain) CannonballInfamyBonus *infamyBonus;
@property (nonatomic,assign) float bore;
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float velX;
@property (nonatomic,assign) float velY;
@property (nonatomic,assign) float trajectory;
@property (nonatomic,assign) float distanceRemaining;

- (id)initWithCannonball:(Cannonball *)cannonball;

@end
