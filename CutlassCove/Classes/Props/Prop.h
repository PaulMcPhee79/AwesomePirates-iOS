//
//  Prop.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneController.h"

#define CUST_EVENT_TYPE_PROP_HIDDEN @"propHiddenEvent"

@interface Prop : SPSprite {
	int mCategory;
	//int mPropId;
    uint mTurnID;
	BOOL mAdvanceable;
    BOOL mSlowable;
	BOOL mRemoveMe;
	SceneController *mScene;
}

@property (nonatomic,assign) int category;
@property (nonatomic,readonly) BOOL advanceable;
@property (nonatomic,readonly) BOOL slowable;
@property (nonatomic,readonly) BOOL markedForRemoval;
//@property (nonatomic,readonly) int propId;
@property (nonatomic,readonly) uint turnID;

- (id)initWithCategory:(int)category;
- (void)setupProp;
- (void)flip:(BOOL)enable;
- (void)moveToCategory:(int)category;
- (void)updateOrientation:(UIDeviceOrientation)orientation;
- (void)advanceTime:(double)time;
- (void)checkoutPooledResources;
- (void)checkinPooledResources;
+ (int)propCount;
+ (void)printProps;
+ (SceneController *)propsScene;
+ (void)setPropsScene:(SceneController *)scene;
+ (void)relinquishPropScene:(SceneController *)scene;

@end
