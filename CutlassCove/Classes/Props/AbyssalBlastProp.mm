//
//  AbyssalBlastProp.m
//  CutlassCove
//
//  Created by Paul McPhee on 25/04/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "AbyssalBlastProp.h"
#import <Box2D/Box2D.h>
#import "BlastQueryCallback.h"
#import "PlayfieldController.h"
#import "Globals.h"

@implementation AbyssalBlastProp

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category resourceKey:@"Abyssal"]) {
        mBlastWave = 0;
        [self setupProp];
    }
    return self;
}

- (id)init {
    return [self initWithCategory:CAT_PF_SURFACE];
}

- (void)dealloc {
    if (mBlastWave) {
		delete mBlastWave;
		mBlastWave = 0;
	}
    
    [super dealloc];
}

- (void)setupProp {
    if (mBlastSound == nil)
        mBlastSound = [[NSString stringWithFormat:@"AbyssalBlast"] copy];
    if (mBlastTexture == nil)
        mBlastTexture = [[mScene textureByName:@"abyssal-surge"] retain];
    [super setupProp];
}

- (void)blastDamage {
    if (mBlastWave == 0)
        mBlastWave = new BlastQueryCallback;
    b2AABB aabb;
    aabb.lowerBound = b2Vec2(P2MX(self.x - 84) , P2MY(self.y + 84));
    aabb.upperBound = b2Vec2(P2MX(self.x + 84) , P2MY(self.y - 84));
    
    //NSLog(@"%@", (aabb.IsValid()) ? @"b2VALID" : @"b2INVALID");
    //NSLog(@"ExtentsX: %f, ExtentsY: %f", aabb.GetExtents().x, aabb.GetExtents().y);
    //NSLog(@"%@", (mBlastWave) ? @"Blastwave GOOD" : @"Blastwave BAD");
    
    if ([mScene isKindOfClass:[PlayfieldController class]]) {
        PlayfieldController *playfieldScene = (PlayfieldController *)mScene;
        playfieldScene.world->QueryAABB(mBlastWave, aabb);
        //[mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_BLAST_VICTIMS count:mBlastWave->shipVictimCount];
    }
    
    [super blastDamage];
}

@end
