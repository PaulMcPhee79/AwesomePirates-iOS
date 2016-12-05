//
//  Cooldown.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Cooldown : NSObject <NSCoding> {
	BOOL mGcd;
	double mTimeRemaining;
	double mTimeTotal;
}

@property (nonatomic,assign) BOOL gcd;
@property (nonatomic,assign) double timeRemaining;
@property (nonatomic,assign) double timeTotal;
@property (nonatomic,readonly) double ratioRemaining;
@property (nonatomic,readonly) double ratioPassed;

@end
