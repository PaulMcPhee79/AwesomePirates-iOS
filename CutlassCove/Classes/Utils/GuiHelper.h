//
//  GuiHelper.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 16/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GuiSizeSml = 0,
    GuiSizeMed,
    GuiSizeLge
} GuiHelperSize;

@class SceneController,Potion;

@interface GuiHelper : NSObject

+ (NSString *)suffixForRank:(int)rank;
+ (NSString *)percentageStringForValue:(float)value;
+ (NSString *)romanNumeralsForDecimalValueToX:(int)value;
+ (SPRectangle *)boundsForText:(NSString *)text maxWidth:(float)maxWidth fontSize:(float)fontSize fontName:(NSString *)fontName;
+ (NSString *)commaSeparatedValue:(uint)value;
+ (NSString *)commaSeparatedScore:(int64_t)score;
+ (NSArray *)cannonComboForContainer:(SPSprite *)container texture:(SPTexture *)texture;
+ (SPSprite *)wholeSpriteFromQuarterTexture:(SPTexture *)texture;
+ (SPTexture *)cachedHorizTextureByName:(NSString *)textureName scene:(SceneController *)scene;
+ (SPTexture *)cachedScrollTextureByName:(NSString *)textureName scene:(SceneController *)scene;
+ (SPSprite *)scoreMultiplierSpriteForValue:(uint)value scene:(SceneController *)scene;
+ (SPSprite *)potionSpriteWithPotion:(Potion *)potion size:(GuiHelperSize)size scene:(SceneController *)scene;

@end
