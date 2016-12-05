//
//  GCVoodoo.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCVoodoo : NSObject <NSCoding> {
	uint bitmapID;
	/*
		- Ignitable Protocol:	0x1 Ignited.
	 */
	uint bitmapSettings;
	
	float x;
	float y;
	float rotation;
	float durationRemaining;
	
	// Net
	float collidableRadiusFactor;
}

@property (nonatomic,assign) uint bitmapID;
@property (nonatomic,assign) uint bitmapSettings;
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float rotation;
@property (nonatomic,assign) float durationRemaining;
@property (nonatomic,assign) float collidableRadiusFactor;

@end
