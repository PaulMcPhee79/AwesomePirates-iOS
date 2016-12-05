//
//  ComboDisplay.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "Loadable.h"
#import "NumericValueChangedEvent.h"

@interface ComboDisplay : Prop <Loadable> {
	BOOL mFlyingDutchman;
	BOOL mProcActive;
	int mRolling;
	int mComboMultiplier;
	NSMutableArray *mCannonballClips;
	NSMutableArray *mProcClips;
	NSMutableArray *mFlyingDutchmanClips;
	NSMutableArray *mClipStack;
	NSArray *mCurrentClips; // Weak reference
	NSMutableArray *mCannonballs;
	SPJuggler *mJuggler;
}

- (void)setComboMultiplier:(int)value;
- (void)setComboMultiplierAnimated:(int)value;
- (void)setupProcWithTexturePrefix:(NSString *)texturePrefix;
- (void)activateProc;
- (void)deactivateProc;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;
- (void)onComboMultiplierChanged:(NumericValueChangedEvent *)event;
- (void)destroyComboDisplay;

@end
