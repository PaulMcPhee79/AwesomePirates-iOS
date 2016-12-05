//
//  NightShade.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NightShade : NSObject {
	int mShade;
	NSMutableArray *mShaders;
	SPJuggler *mJuggler;
}

@property (nonatomic,assign) int shade;

- (id)initWithShaders:(NSArray *)shaders;
- (void)addShader:(SPImage *)shader;
- (void)removeShader:(SPImage *)shader;
- (void)advanceTime:(double)time;
- (void)transitionTimeOfDay:(int)timeOfDay transitionDuration:(float)transitionDuration proportionRemaining:(float)proportionRemaining;
- (void)destroyNightShade;

@end
