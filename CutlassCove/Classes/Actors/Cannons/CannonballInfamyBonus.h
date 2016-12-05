//
//  CannonballInfamyBonus.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 6/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CannonballInfamyBonus : NSObject <NSCoding,NSCopying> {
	uint procType;
	int procMultiplier;
	int procAddition;
	
	int ricochetBonus;
	int ricochetAddition;
	float ricochetMultiplier;
    
    uint miscBitmap;
}

@property (nonatomic,assign) uint procType;
@property (nonatomic,assign) int procMultiplier;
@property (nonatomic,assign) int procAddition;

@property (nonatomic,assign) int ricochetBonus;
@property (nonatomic,assign) int ricochetAddition;
@property (nonatomic,assign) float ricochetMultiplier;

@property (nonatomic,assign) uint miscBitmap;

+ (CannonballInfamyBonus *)cannonballInfamyBonus;

@end
