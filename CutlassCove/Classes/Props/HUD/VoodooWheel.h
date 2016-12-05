//
//  VoodooWheel.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class Cooldown;

#define CUST_EVENT_TYPE_VOODOO_MENU_CLOSING @"voodooMenuClosingEvent"
#define CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED @"voodooDialPressedEvent"
#define CUST_EVENT_TYPE_VOODOO_DIAL_CD_COMPLETE @"voodooDialCDCompleteEvent"
#define CUST_EVENT_TYPE_VOODOO_DIAL_PULSE_COMPLETE @"voodooDialPulseCompleteEvent"


@interface VoodooDial : Prop {
	uint mNumericKey;
	NSString *mStringKey;
	SPButton *mButton;
}

@property (nonatomic,readonly) uint numericKey;
@property (nonatomic,readonly) NSString *stringKey;
@property (nonatomic,readonly) SPButton *button;
@property (nonatomic,assign) BOOL enabled;

- (id)initWithCategory:(int)category key:(uint)key;

@end



@interface VoodooWheel : Prop {
	int mState;
	float mMaxWidth;
	float mMaxHeight;
	
	SPButton *mCancelButton;
    SPSprite *mCanvas;
	
	NSArray *mTrinketSettings;
	NSArray *mGadgetSettings;
	
	VoodooDial *mActivePulse;
	NSMutableDictionary *mGadgets;
	NSMutableDictionary *mTrinkets;
	NSMutableArray *mVoodooDialArray;
	NSMutableDictionary *mVoodooDialDictionary;
}

@property (nonatomic,readonly) NSArray *trinketSettings;
@property (nonatomic,readonly) NSArray *gadgetSettings;

- (id)initWithCategory:(int)category trinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets;
- (void)showAtX:(float)x y:(float)y;
- (void)hide;
- (VoodooDial *)dialForKey:(uint)key;
- (void)enableItem:(BOOL)enable forKey:(uint)key;
- (void)enableAllItems:(BOOL)enable;
- (void)destroyWheel;

+ (NSString *)keyToString:(uint)key;

@end
