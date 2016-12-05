//
//  HintHelper.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 2/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HintHelper.h"
#import "Hint.h"
#import "Prop.h"
#import "SceneController.h"

@implementation HintHelper

+ (HintPackage *)thisIsYourShip:(SceneController *)scene category:(int)category target:(SPPoint *)target {
    Prop *prop = [[[Prop alloc] initWithCategory:category] autorelease];
    
    // Cutlass pointer
    SPImage *pointerImage = [SPImage imageWithTexture:[scene textureByName:@"pointer"]];
    pointerImage.x = -pointerImage.width / 2;
    pointerImage.y = -pointerImage.height / 2;
    
    SPSprite *pointerSprite = [SPSprite sprite];
    pointerSprite.x = target.x - pointerImage.height / 1.5f;
    pointerSprite.y = target.y;
    pointerSprite.rotation = SP_D2R(90);
    [pointerSprite addChild:pointerImage];
    [prop addChild:pointerSprite];
    
    SPTween *tween = [SPTween tweenWithTarget:pointerSprite time:0.5f];
    [tween animateProperty:@"x" targetValue:pointerSprite.x - 10];
    tween.loop = SPLoopTypeReverse;
    
    // Text
    SPTextField *label = [SPTextField textFieldWithWidth:190
                                                  height:28
                                                    text:@"This is your pirate ship"
                                                fontName:scene.fontKey
                                                fontSize:24
                                                   color:0xfcc30e];
    
    //label.x = pointerSprite.x - (label.width - pointerImage.height / 3);
    //label.y = pointerSprite.y + pointerImage.width / 2;
    label.x = -label.width / 2;
    label.hAlign = SPHAlignLeft;
    label.vAlign = SPVAlignTop;
    label.compiled = NO;
    
    
    Prop *textProp = [[[Prop alloc] initWithCategory:category] autorelease];
    textProp.x = (pointerSprite.x - (label.width - pointerImage.height / 3)) + label.width / 2;
    textProp.y = pointerSprite.y + pointerImage.width / 2;
    [textProp addChild:label];
    [prop addChild:textProp];
    
    //[prop addChild:label];
    
    HintPackage *package = [HintPackage hintPackageWithProp:prop loopingTween:tween];
    [package addFlipProp:textProp];
    
    return package;
}

+ (HintPackage *)shipDoesntSinkPropWithScene:(SceneController *)scene category:(int)category origin:(SPPoint *)origin target:(SPPoint *)target {
    Prop *prop = [[[Prop alloc] initWithCategory:category] autorelease];
        
    // Navy ship
    SPSprite *navyShipSprite = [SPSprite sprite];
    navyShipSprite.x = origin.x;
    navyShipSprite.y = origin.y;
    [prop addChild:navyShipSprite];
    
    SPImage *navyShipImage = [SPImage imageWithTexture:[scene textureByName:@"ship-pf-navy_00"]];
    navyShipImage.x = -navyShipImage.width / 2;
    navyShipImage.y = -navyShipImage.height / 2;
    [navyShipSprite addChild:navyShipImage];
    
    // Cannonballs
    SPPoint *vector = [target subtractPoint:origin];
    float cannonballAngle = vector.angle;
    float navyShipAngle = cannonballAngle; // - SP_D2R(90);
    
    navyShipSprite.rotation = navyShipAngle;

    SPTexture *cannonballTexture = [scene textureByName:@"single-shot_00"];
    
    for (int i = 0; i < 5; ++i) {
        float scale = 1;
        
        switch (i) {
            case 0:
            case 4:
                scale = 0.15625f;
                break;
            case 1:
            case 3:
                scale = 0.25f;
                break;
            case 2:
                scale = 0.375f;
                break;
            default:
                break;
        }
        
        float length = ((i + 1) * 0.2f) * vector.length - vector.length * 0.1f;
        SPPoint *point = [SPPoint pointWithPolarLength:length angle:cannonballAngle];
        SPImage *cannonballImage = [SPImage imageWithTexture:cannonballTexture];
        cannonballImage.scaleX = cannonballImage.scaleY = scale;
        cannonballImage.x = navyShipSprite.x + point.x - cannonballImage.width / 2;
        cannonballImage.y = navyShipSprite.y + point.y - cannonballImage.height / 2;
        [prop addChild:cannonballImage];
    }
    
    // Explosion
    SPImage *explosionImage = [SPImage imageWithTexture:[scene textureByName:@"explode_01"]];
    explosionImage.x = target.x - explosionImage.width / 2;
    explosionImage.y = target.y - explosionImage.height / 2;
    [prop addChild:explosionImage];
    
    return [HintPackage hintPackageWithProp:prop loopingTween:nil];
}

+ (HintPackage *)pointerHintWithScene:(SceneController *)scene target:(SPPoint *)target radius:(float)radius text:(NSString *)text animated:(BOOL)animated {
    Prop *prop = [Hint hintWithCategory:0 location:target];
    
    // Get angle from target to center of the screen (this should have the favourable side-effect of placing the hint away from the edges of the screen)
    SPPoint *vector = [SPPoint pointWithX:target.x - scene.viewWidth / 2 y:target.y - scene.viewHeight / 2];
    float vectorAngle = vector.angle, pointerAngle = vector.angle + PI_HALF;
    int dir = (vectorAngle < 0) ? 1 : -1;
    
    if (pointerAngle > PI)
        pointerAngle -= TWO_PI;
    else if (pointerAngle < -PI)
        pointerAngle += TWO_PI;
    
    // Rotate pointer by this angle
    SPImage *pointerImage = [SPImage imageWithTexture:[scene textureByName:@"pointer"]];
    pointerImage.x = -pointerImage.width / 2;
    pointerImage.y = -pointerImage.height / 2;
    
    SPSprite *pointerSprite = [SPSprite sprite];
    pointerSprite.x = target.x;
    pointerSprite.y = target.y;
    pointerSprite.rotation = pointerAngle;
    [pointerSprite addChild:pointerImage];
    
    // Give pointer some clearance from its target
    pointerSprite.x -= (radius + pointerImage.height / 2) * cosf(vectorAngle);
    pointerSprite.y -= (radius + pointerImage.height / 2) * sinf(vectorAngle);
    
    // Place textfield at base of cutlass pointer
    int quadrant = 1;
    float absPointerAngle = fabsf(vectorAngle);
    SPPoint *pointerBase = nil;
    
    // Anti-clockwise positive rotation coordinate system because +y is down the screen in Sparrow
    if (vectorAngle > 0) {
        quadrant = (absPointerAngle < PI_HALF) ? 1 : 2;
    } else {
        quadrant = (absPointerAngle < PI_HALF) ? 4 : 3;
    }
    
    if (quadrant == 2 || quadrant == 4) {
        // Bottom right: Q2,Q4
        pointerBase = [pointerImage localToGlobal:[SPPoint pointWithX:pointerImage.width y:pointerImage.height]];
    } else {
        // Bottom left: Q1,Q3
        pointerBase = [pointerImage localToGlobal:[SPPoint pointWithX:0 y:pointerImage.height]];
    }
    
    float textFieldMultiplier = 0;
    
    switch (quadrant) {
        case 1: textFieldMultiplier = -0.9f; break;
        case 2: textFieldMultiplier = -0.7f; break;
        case 3: textFieldMultiplier = 0; break;
        case 4: textFieldMultiplier = -0.15f; break;
        default: textFieldMultiplier = 0; break;
    }
    
    // Create with max width
    SPTextField *textField = [SPTextField textFieldWithWidth:256
                                                      height:24 
                                                        text:text
                                                    fontName:scene.fontKey
                                                    fontSize:20
                                                       color:0xfcc30e];
    // Recreate with optimal width
    textField = [SPTextField textFieldWithWidth:1.1f * textField.textBounds.width
                                         height:24 
                                           text:text
                                       fontName:scene.fontKey
                                       fontSize:20
                                          color:0xfcc30e];
    textField.hAlign = SPHAlignCenter;
    textField.vAlign = SPVAlignTop;
    textField.compiled = NO;
    textField.x = -textField.width / 2;
    //textField.x = pointerBase.x - textField.width / 2;
    //textField.y = pointerBase.y + textFieldMultiplier * textField.height;
    
    Prop *textProp = [[[Prop alloc] initWithCategory:0] autorelease];
    textProp.x = (pointerBase.x - textField.width / 2) + textField.width / 2;
    textProp.y = pointerBase.y + textFieldMultiplier * textField.height;
    [textProp addChild:textField];
    
    // Animate the pointer
    SPTween *tween = nil;
    
    if (animated) {
        tween = [SPTween tweenWithTarget:pointerSprite time:0.5f];
        [tween animateProperty:@"x" targetValue:pointerSprite.x - dir * 10 * cosf(vectorAngle)];
        [tween animateProperty:@"y" targetValue:pointerSprite.y - dir * 10 * sinf(vectorAngle)];
        tween.loop = SPLoopTypeReverse;
    }
    
    [prop addChild:pointerSprite];
    //[prop addChild:textField];
    [prop addChild:textProp];
    
    HintPackage *package = [HintPackage hintPackageWithProp:prop loopingTween:tween];
    [package addFlipProp:textProp];
    return package;
}

+ (HintPackage *)pointerHintWithScene:(SceneController *)scene target:(SPPoint *)target movingTarget:(SPDisplayObject *)movingTarget radius:(float)radius text:(NSString *)text animated:(BOOL)animated {
    
    HintPackage *package = [HintHelper pointerHintWithScene:scene target:target radius:radius text:text animated:animated];
    
    for (Prop *prop in package.props) {
        if ([prop isKindOfClass:[Hint class]]) {
            Hint *hint = (Hint *)prop;
            hint.target = movingTarget;
        }
    }
    return package;
}

@end



@implementation HintPackage

@synthesize props,flipProps,loopingTweens;

+ (HintPackage *)hintPackageWithProp:(Prop *)prop loopingTween:(SPTween *)loopingTween {
    return [[[HintPackage alloc] initWithProp:prop loopingTween:loopingTween] autorelease];
}

- (id)initWithProp:(Prop *)prop loopingTween:(SPTween *)loopingTween {
    if (self = [super init]) {
        props = [[NSMutableArray alloc] init];
        flipProps = [[NSMutableArray alloc] init];
        loopingTweens = [[NSMutableArray alloc] init];
        
        if (prop)
            [props addObject:prop];
        if (loopingTween)
            [loopingTweens addObject:loopingTween];
    }
    return self;
}

- (id)init {
    return [self initWithProp:nil loopingTween:nil];
}

- (void)addProp:(Prop *)prop {
    if ([props containsObject:prop] == NO)
        [props addObject:prop];
}

- (void)addFlipProp:(Prop *)prop {
    if ([flipProps containsObject:prop] == NO)
        [flipProps addObject:prop];
}

- (void)removeProp:(Prop *)prop {
    if (prop) {
        [props removeObject:prop];
        [flipProps removeObject:prop];
    }
}

- (void)addLoopingTween:(SPTween *)tween {
    if ([loopingTweens containsObject:tween] == NO)
        [loopingTweens addObject:tween];
}

- (void)removeLoopingTween:(SPTween *)tween {
    if (tween)
        [loopingTweens removeObject:tween];
}

- (void)dealloc {
    [props release]; props = nil;
    [flipProps release]; flipProps = nil;
    [loopingTweens release]; loopingTweens = nil;
    [super dealloc];
}

@end
