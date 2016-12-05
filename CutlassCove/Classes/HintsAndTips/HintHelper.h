//
//  HintHelper.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 2/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SceneController,Prop;

@interface HintPackage : NSObject {
    @private
    NSMutableArray *props;
    NSMutableArray *flipProps;
    NSMutableArray *loopingTweens;
}

@property (nonatomic,readonly) NSMutableArray *props;
@property (nonatomic,readonly) NSMutableArray *flipProps;
@property (nonatomic,readonly) NSMutableArray *loopingTweens;

+ (HintPackage *)hintPackageWithProp:(Prop *)prop loopingTween:(SPTween *)loopingTween;
- (id)initWithProp:(Prop *)prop loopingTween:(SPTween *)loopingTween;
- (void)addProp:(Prop *)prop;
- (void)addFlipProp:(Prop *)prop;
- (void)removeProp:(Prop *)prop;
- (void)addLoopingTween:(SPTween *)tween;
- (void)removeLoopingTween:(SPTween *)tween;

@end

@interface HintHelper : NSObject

+ (HintPackage *)thisIsYourShip:(SceneController *)scene category:(int)category target:(SPPoint *)target;
+ (HintPackage *)shipDoesntSinkPropWithScene:(SceneController *)scene category:(int)category origin:(SPPoint *)origin target:(SPPoint *)target;
+ (HintPackage *)pointerHintWithScene:(SceneController *)scene target:(SPPoint *)target radius:(float)radius text:(NSString *)text animated:(BOOL)animated;
+ (HintPackage *)pointerHintWithScene:(SceneController *)scene target:(SPPoint *)target movingTarget:(SPDisplayObject *)movingTarget radius:(float)radius text:(NSString *)text animated:(BOOL)animated;

@end
