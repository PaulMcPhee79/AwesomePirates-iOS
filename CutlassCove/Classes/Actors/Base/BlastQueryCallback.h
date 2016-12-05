//
//  BlastQueryCallback.h
//  CutlassCove
//
//  Created by Paul McPhee on 25/04/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#ifndef CC_BLAST_QUERY_CALLBACK
#define CC_BLAST_QUERY_CALLBACK

#import <Box2D/Box2D.h>
#import "NpcShip.h"
#import "Ignitable.h"
#import "PowderKegActor.h"
#import "OverboardActor.h"
#import "DeathBitmaps.h"


class BlastQueryCallback : public b2QueryCallback {
	
public:
    BlastQueryCallback() {
		shipVictimCount = 0;
	}
    
    bool ReportFixture(b2Fixture *fixture) {
        if (fixture) {
            b2Body *body = fixture->GetBody();
            
            if (body) {
                Actor *actor = (Actor *)(body->GetUserData());
                
                if ([actor isKindOfClass:[NpcShip class]]) {
                    NpcShip *ship = (NpcShip *)actor;
                    
                    if (fixture == ship.hull && ship.docking == NO) {
                        ship.deathBitmap = DEATH_BITMAP_ABYSSAL_SURGE;
                        [ship sink];
                        ++shipVictimCount;
                    }
                } else if ([actor isKindOfClass:[PowderKegActor class]]) {
                    PowderKegActor *keg = (PowderKegActor *)actor;
                    [keg ignite];
                } else if ([actor isKindOfClass:[OverboardActor class]]) {
                    OverboardActor *person = (OverboardActor *)actor;
                    [person environmentalDeath];
                }
            }
        }
        
        return true;
    }
    
    uint shipVictimCount;
};

#endif
