//
//  GuiHelper.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 16/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GuiHelper.h"
#import "SceneController.h"
#import "ShipFactory.h"
#import "Globals.h"

#define kGuiHelperComboMax 7


@implementation GuiHelper

+ (NSString *)suffixForRank:(int)rank {
    int rankMod = rank % 10;
    NSString *suffix = @"th";
    
    if (((rank % 100) / 10) != 1) {
        if (rankMod == 1)
            suffix = @"st";
        else if (rankMod == 2)
            suffix = @"nd";
        else if (rankMod == 3)
            suffix = @"rd";
    }
    
    return suffix;
}

+ (NSString *)percentageStringForValue:(float)value {
    return [NSString stringWithFormat:@"%d%%", (int)(100 * value)];
}
    
+ (NSString *)romanNumeralsForDecimalValueToX:(int)value {
	NSString *romanStr = @"";
	
	if (value > 0 && value <= 10) {
		if (value == 10)
			romanStr = @"X";
		else if (value == 9)
			romanStr = @"IX";
		else if (value >= 5) {
			romanStr = @"V";
			
			while (value-- > 5)
				romanStr = [NSString stringWithFormat:@"%@I", romanStr];
		} else if (value == 4)
			romanStr = @"IV";
		else {
			while (value-- > 0)
				romanStr = [NSString stringWithFormat:@"%@I", romanStr];
		}
	}
	
	return romanStr;
}

+ (SPRectangle *)boundsForText:(NSString *)text maxWidth:(float)maxWidth fontSize:(float)fontSize fontName:(NSString *)fontName {
    SPTextField *textField = [SPTextField textFieldWithWidth:maxWidth
                                                      height:fontSize + 4
                                                        text:text
                                                    fontName:fontName
                                                    fontSize:fontSize
                                                       color:0];
    SPRectangle *textBounds = [textField textBounds];
    return [SPRectangle rectangleWithX:textBounds.x y:textBounds.y width:textBounds.width + 4 height:textBounds.height + 2];
}

+ (NSString *)commaSeparatedValue:(uint)value {
    return [Globals commaSeparatedValue:value];
}

+ (NSString *)commaSeparatedScore:(int64_t)score {
    return [Globals commaSeparatedScore:score];
}

+ (NSArray *)cannonComboForContainer:(SPSprite *)container texture:(SPTexture *)texture {
	NSMutableArray *comboArray = [NSMutableArray arrayWithCapacity:kGuiHelperComboMax];
	float x = 0;
	
	for (int i = 0; i < kGuiHelperComboMax; ++i) {
		SPImage *image = [SPImage imageWithTexture:texture];
		image.x = x;
		[container addChild:image];
		[comboArray addObject:image];
		x += image.width + 2;
	}
	return [NSArray arrayWithArray:comboArray];
}

+ (SPSprite *)wholeSpriteFromQuarterTexture:(SPTexture *)texture {
    SPSprite *sprite = [SPSprite sprite];
    
    for (int i = 0; i < 4; ++i) {
        SPImage *image = [SPImage imageWithTexture:texture];
        
        switch (i) {
            case 1:
                image.scaleX = -1;
                image.x = 2 * image.width;
                break;
            case 2:
                image.scaleY = -1;
                image.y = 2 * image.height - 1;
                break;
            case 3:
                image.scaleX = -1;
                image.scaleY = -1;
                image.x = 2 * image.width;
                image.y = 2 * image.height - 1;
                break;
            default:
                break;
        }
        
        [sprite addChild:image];
    }
    
    return sprite;
}

+ (SPTexture *)cachedHorizTextureByName:(NSString *)textureName scene:(SceneController *)scene {
    if (textureName == nil)
        return nil;
    
    NSString *cachedTextureName = [NSString stringWithFormat:@"%@-cached",textureName];
    
    // Re-use rendered texture memory
    SPTexture *texture = [scene cachedTextureByName:cachedTextureName];
    
    if (texture == nil) {
        texture = [scene textureByName:textureName];
        texture = [Globals wholeTextureFromHalfHoriz:texture];
        [scene.tm cacheTexture:texture byName:cachedTextureName];
    }
    
    return texture;
}

+ (SPTexture *)cachedScrollTextureByName:(NSString *)textureName scene:(SceneController *)scene {
    if (textureName == nil)
        return nil;
    
    NSString *cachedTextureName = [NSString stringWithFormat:@"%@-cached",textureName];
    
    // Re-use rendered texture memory
    SPTexture *texture = [scene cachedTextureByName:cachedTextureName];
    
    if (texture == nil) {
        texture = [scene textureByName:textureName];
        texture = [Globals wholeTextureFromQuarter:texture];
        [scene.tm cacheTexture:texture byName:cachedTextureName];
    }
    
    return texture;
}

+ (SPSprite *)scoreMultiplierSpriteForValue:(uint)value scene:(SceneController *)scene {
    float offsetX = 0;
    uint tens = value / 10, ones = value % 10;
    SPSprite *sprite = [SPSprite sprite];
    
    if (tens != 0) {
        SPImage *image = [SPImage imageWithTexture:[scene textureByName:[NSString stringWithFormat:@"fancy-%u", tens]]];
        image.x = offsetX;
        offsetX += image.width + 2;
        [sprite addChild:image];
    }
    
    SPImage *image = [SPImage imageWithTexture:[scene textureByName:[NSString stringWithFormat:@"fancy-%u", ones]]];
    image.x = offsetX;
    offsetX += image.width + 2;
    [sprite addChild:image];
    
    image = [SPImage imageWithTexture:[scene textureByName:@"fancy-x"]];
    image.x = offsetX;
    image.y = sprite.height - image.height;
    [sprite addChild:image];
    
    return sprite;
}

+ (SPSprite *)potionSpriteWithPotion:(Potion *)potion size:(GuiHelperSize)size scene:(SceneController *)scene {
    NSString *suffix = @"lge";
    
	switch (size) {
        case GuiSizeSml: suffix = @"sml"; break;
        case GuiSizeMed: suffix = @"med"; break;
        case GuiSizeLge:
        default: suffix = @"lge"; break;
    }
    
	SPSprite *sprite = [SPSprite sprite];
	SPImage *image = [SPImage imageWithTexture:[scene textureByName:[NSString stringWithFormat:@"potion-contents-%@", suffix]]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	image.color = potion.color;
	[sprite addChild:image];
	
	image = [SPImage imageWithTexture:[scene textureByName:[NSString stringWithFormat:@"potion-vial-%@", suffix]]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	[sprite addChild:image];
	return sprite;
}

@end
