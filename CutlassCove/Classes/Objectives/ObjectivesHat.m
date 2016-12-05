//
//  ObjectivesHat.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesHat.h"
#import "CurvedText.h"

@interface ObjectivesHat ()

- (void)setupHat;
- (void)setupStraightHat;
- (void)setupAngledHat;
- (void)dismantleHat;

@end

@implementation ObjectivesHat

- (id)initWithCategory:(int)category hatType:(ObjectivesHatType)hatType text:(NSString *)text {
    if (self = [super initWithCategory:category]) {
        mHatType = hatType;
        mHatImage = nil;
        mHatSprite = nil;
        [self setText:text];
    }
    return self;
}

- (id)initWithCategory:(int)category text:(NSString *)text {
    return [self initWithCategory:category hatType:ObjHatStraight text:text];
}

- (id)initWithCategory:(int)category {
    return [self initWithCategory:category text:nil];
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mHatSprite];
    [mHatSprite release]; mHatSprite = nil;
    [mHatTextSprite release]; mHatTextSprite = nil;
    [mHatImage release]; mHatImage = nil;
    [mHatText release]; mHatText = nil;
    [super dealloc];
}

- (void)setupHat {
    if (mHatType == ObjHatAngled)
        [self setupAngledHat];
    else
        [self setupStraightHat];
    [self setTextColor:SP_WHITE];
}

- (void)setupStraightHat {
    if (mHatSprite)
        return;
    mHatSprite = [[SPSprite alloc] init];
    [self addChild:mHatSprite];
    
    mHatImage = [[SPImage alloc] initWithTexture:[mScene textureByName:@"objectives-hat-logbook"]];
    mHatImage.x = -mHatImage.width / 2;
    mHatImage.y = -mHatImage.height / 2;
    [mHatSprite addChild:mHatImage];
    
    mHatTextSprite = [[SPSprite alloc] init];
    
    uint maxLength = 8; //(mScene.objectivesManager.rank == 0) ? 8 : 7;
    mHatText = [[CurvedText alloc] initWithCategory:-1 fontSize:16 maxLength:maxLength];
	[mHatText setupProp];
    mHatText.x = -mHatText.width / 2;
    mHatText.y = -mHatText.height / 2;
	mHatText.radius = 60;
    mHatText.maxTextSeparation = 5;
	mHatText.originX = mHatText.x;
    [mHatTextSprite addChild:mHatText];
	[mHatSprite addChild:mHatTextSprite];
    
    mHatTextSprite.x = (maxLength == 7) ? 58 : 66;
    mHatTextSprite.y = 6;
}

- (void)setupAngledHat {
    if (mHatSprite)
        return;
    mHatSprite = [[SPSprite alloc] init];
    [self addChild:mHatSprite];
    
    mHatImage = [[SPImage alloc] initWithTexture:[mScene textureByName:@"objectives-hat"]];
    mHatImage.x = -mHatImage.width / 2;
    mHatImage.y = -mHatImage.height / 2;
    [mHatSprite addChild:mHatImage];
    
    mHatTextSprite = [[SPSprite alloc] init];
    mHatTextSprite.rotation = SP_D2R(-19);
    
    uint maxLength = 8; //(mScene.objectivesManager.rank == 0) ? 8 : 7;
    mHatText = [[CurvedText alloc] initWithCategory:-1 fontSize:16 maxLength:maxLength];
	[mHatText setupProp];
    mHatText.x = -mHatText.width / 2;
    mHatText.y = -mHatText.height / 2;
	mHatText.radius = 60;
    mHatText.maxTextSeparation = 5;
	mHatText.originX = mHatText.x;
    [mHatTextSprite addChild:mHatText];
	[mHatSprite addChild:mHatTextSprite];
    
    mHatTextSprite.x = (maxLength == 7) ? 50 : 58;
    mHatTextSprite.y = (maxLength == 7) ? -23 : -25;
}

- (void)dismantleHat {
    if (mHatSprite)
        [self removeChild:mHatSprite];
    [mHatImage release]; mHatImage = nil;
    [mHatSprite release]; mHatSprite = nil;
    [mHatText release]; mHatText = nil;
    [mHatTextSprite release ]; mHatTextSprite = nil;
}

- (void)setText:(NSString *)text {
    if ([mHatText.text isEqualToString:text])
        return;
    [self dismantleHat];
    [self setupHat];
    mHatText.text = text;
}

- (void)setTextColor:(uint)color {
    mHatText.color = color;
}

@end
