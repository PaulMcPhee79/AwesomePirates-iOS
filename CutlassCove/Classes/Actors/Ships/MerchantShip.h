//
//  MerchantShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NpcShip.h"

@interface MerchantShip : NpcShip {
    BOOL mIsDimming;
    uint mFlashColor;
    
	BOOL mTargetAcquired;
	int mTargetSide;
	float mTargetX;
	float mTargetY;
	
	b2Fixture *mDefender;
}

@property (nonatomic,readonly) b2Fixture *defender;

@end
