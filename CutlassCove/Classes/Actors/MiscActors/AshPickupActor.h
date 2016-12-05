//
//  AshPickupActor.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LootActor.h"

#define CUST_EVENT_TYPE_ASH_PICKUP_SPAWNED @"ashPickupSpawned"
#define CUST_EVENT_TYPE_ASH_PICKUP_EXPIRED @"ashPickupExpired"

@interface AshPickupActor : LootActor {
    uint mAshKey;
    SPTextField *mHint;
    SPMovieClip *mAshClip;
    SPSprite *mAshSprite;
    SPSprite *mPickupBase;
    SPSprite *mPickupHighlight;
    SPSprite *mPickup;
    SPSprite *mCostume;
    SPSprite *mFlipCostume;
}

- (id)initWithActorDef:(ActorDef *)def ashKey:(uint)ashKey duration:(float)duration;

@end
