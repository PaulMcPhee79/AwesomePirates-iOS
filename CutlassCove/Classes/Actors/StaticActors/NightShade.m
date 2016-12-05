//
//  NightShade.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "NightShade.h"
#import "TimeOfDayChangedEvent.h"

const int kShadeInterval = 0x10101;

@implementation NightShade

@synthesize shade = mShade;

- (id)initWithShaders:(NSArray *)shaders {
	if (self = [super init]) {
		mShade = 0xff;
		
		if (shaders)
			mShaders = [[NSMutableArray alloc] initWithArray:shaders];
		else
			mShaders = [[NSMutableArray alloc] init];
		mJuggler = [[SPJuggler alloc] init];
	}
	return self;
}

- (void)addShader:(SPImage *)shader {
	[mShaders addObject:shader];
}

- (void)removeShader:(SPImage *)shader {
	[mShaders removeObject:shader];
}

- (void)advanceTime:(double)time {
	[mJuggler advanceTime:time];
}

- (void)setShade:(int)value {
	mShade = value;
	
	for (SPImage *image in mShaders)
		image.color = mShade * kShadeInterval;
}

- (void)transitionTimeOfDay:(int)timeOfDay transitionDuration:(float)transitionDuration proportionRemaining:(float)proportionRemaining {
	[mJuggler removeTweensWithTarget:self];
	
	BOOL transition = NO;
	int colorFrom = 0xffffff, colorTo = 0xffffff;
	
	switch (timeOfDay) {
		case DuskTransition:
			transition = YES;
			colorFrom = 0xffffff;
			colorTo = 0xe0e0e0;
			break;
		case Dusk:
			colorFrom = 0xe0e0e0;
			colorTo = 0xe0e0e0;
			break;
		case EveningTransition:
			transition = YES;
			colorFrom = 0xe0e0e0;
			colorTo = 0x808080;
			break;
        case Evening:
		case Midnight:
			colorFrom = 0x808080;
			colorTo = 0x808080;
			break;
		case DawnTransition:
			transition = YES;
			colorFrom = 0x808080;
			colorTo = 0xe0e0e0;
			break;
        case Dawn:
            colorFrom = 0xe0e0e0;
            colorTo = 0xe0e0e0;
            break;
		case SunriseTransition:
			transition = YES;
			colorFrom = 0xe0e0e0;
			colorTo = 0xffffff;
			break;
        case NewGameTransition:
            transition = YES;
            colorFrom = self.shade * kShadeInterval;
			colorTo = 0xe0e0e0;
            break;
		default:
			break;
	}
	
	if (transition == NO) {
		self.shade = colorTo / kShadeInterval;
	} else {
		int colorRange = colorTo - colorFrom;
		colorFrom += (1.0f - proportionRemaining) * colorRange;
		self.shade = colorFrom / kShadeInterval;
		
		SPTween *tween = [SPTween tweenWithTarget:self time:transitionDuration];
		[tween animateProperty:@"shade" targetValue:colorTo / kShadeInterval];
		[mJuggler addObject:tween];
	}
}

- (void)destroyNightShade {
	[mJuggler removeAllObjects];
}

- (void)dealloc {
	[mShaders release]; mShaders = nil;
	[mJuggler release]; mJuggler = nil;
	[super dealloc];
}

@end
