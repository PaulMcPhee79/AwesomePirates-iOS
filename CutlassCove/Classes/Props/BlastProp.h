//
//  BlastProp.h
//  CutlassCove
//
//  Created by Paul McPhee on 25/04/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "BlastCache.h"
#import "ResourceClient.h"

@interface BlastProp : Prop <ResourceClient> {
    BOOL mHasBlasted;
    
    float mBlastScale;
    double mBlastDuration;
    double mAftermathDuration;
    
    NSString *mBlastSound;
    
    SPTexture *mBlastTexture;
    SPSprite *mCostume;
    
    NSString *mResourceKey;
	ResourceServer *mResources;
}

@property (nonatomic,copy) NSString *blastSound;

- (id)initWithCategory:(int)category resourceKey:(NSString *)resourceKey;
- (void)blast;
- (void)blastDamage;
- (void)aftermath;

+ (float)blastAnimationDuration;
+ (float)aftermathAnimationDuration;

@end
