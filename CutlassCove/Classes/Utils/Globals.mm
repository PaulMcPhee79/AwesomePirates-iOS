//
//  Globals.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "Globals.h"
#import "Idol.h"
#import <math.h>

#define TEXTURE_FOLD_HORIZ 0x1
#define TEXTURE_FOLD_VERT 0x2
#define TEXTURE_FOLD_QUAD 0x3

@implementation Globals

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);
 
+ (NSDictionary *)voodooAudioForKeys:(uint)keys sceneName:(NSString *)sceneName {
	NSDictionary *plistDict = [Globals loadPlist:@"JukeboxExtras"];
	plistDict = [plistDict objectForKey:sceneName];
	plistDict = [plistDict objectForKey:@"Playlist"];
	
	NSMutableDictionary *audioDict = [NSMutableDictionary dictionary];
	
	for (NSString *key in plistDict) {
		NSDictionary *dict = [plistDict objectForKey:key];
		NSNumber *bitmap = (NSNumber *)[dict objectForKey:@"Bitmap"];
		
		if (bitmap) {
			uint voodoo = [bitmap unsignedIntValue];
			
			if ((voodoo & keys) == voodoo)
				[audioDict setObject:dict forKey:key];
		}
	}
	
	if (audioDict.count == 0)
		audioDict = nil;
	return audioDict;
}

- (id)plistForKey:(NSString *)key {
	if (mPlists == nil)
		mPlists = [[NSMutableDictionary alloc] init];
	return [mPlists objectForKey:key];
}

- (void)setPlist:(id)plist forKey:(NSString *)key {
	if (mPlists == nil)
		mPlists = [[NSMutableDictionary alloc] init];
	[mPlists setObject:plist forKey:key];
}

+ (float)angleBetweenAngle:(float)src toAngle:(float)dest
{
	if (src > 0 && dest < 0) { // 1 -> -1 && 359 -> -359
		if (src < PI/2) {
			return -(fabsf(dest) + src);
		} else {
			return (TWO_PI+dest) + (TWO_PI-src);
		}
	} else if (src < 0 && dest > 0) { // -1 -> 1 && -359 -> 359
		if (src > -PI/2) {
			return dest + src;
		} else {
			return (TWO_PI-dest) + (TWO_PI+src);
		}
	} else {
		return dest - src;
	}
}

+ (SPPoint *)centerPoint:(SPRectangle *)bounds {
	return [SPPoint pointWithX:bounds.x+(bounds.width/2) y:bounds.y+(bounds.height/2)];
}

// TODO: Replace sinf,cosf calls with LUT
+ (void)rotatePoint:(SPPoint *)point throughAngle:(float)angle {
	float cosAngle = cosf(angle), sinAngle = sinf(angle);
	
	float x = cosAngle * point.x - sinAngle * point.y;
	point.y = sinAngle * point.x + cosAngle * point.y;
	point.x = x;
}

+ (float)vecLengthX:(float)x y:(float)y {
	return sqrtf([Globals vecLengthSquaredX:x y:y]);
}

+ (float)vecLengthSquaredX:(float)x y:(float)y {
	return x * x + y * y;
}

+ (float)normalize:(SPPoint *)vec {
	float length = [Globals vecLengthX:vec.x y:vec.y];
	
	float invLength = 1.0f / length;
	vec.x *= invLength;
	vec.y *= invLength;
	return length;
}

+ (double)diminishedReturnsForValue:(double)value scale:(double)scale {
	if (value	< 0)
		return -[Globals diminishedReturnsForValue:-value scale:scale];
	if (SP_IS_FLOAT_EQUAL(scale, 0))
		return [Globals diminishedReturnsForValue:value scale:1];
	float mult = value / scale;
	// Forumla trianglualr number is: n = p * (p + 1) / 2. Then solve for p.
	float trinum = (sqrtf(8.0 * mult + 1.0) - 1.0) / 2.0;
	return trinum * scale;
}

// TODO: Make sure we really want to cache all plist loads.
+ (NSDictionary *)loadPlist:(NSString *)fileName {
	NSDictionary *dict = (NSDictionary *)[[Globals sharedGlobals] plistForKey:fileName];
	
	if (dict == nil) {
		NSString *error;
		
		dict = [NSPropertyListSerialization propertyListFromData:
							  [NSData dataWithContentsOfFile:
							   [[NSBundle mainBundle] pathForResource:fileName
															   ofType:@"plist"]]
															  mutabilityOption:NSPropertyListImmutable
																		format:nil
															  errorDescription:&error];
		if (dict == nil) {
			NSLog(@"Error loading %@ plist: %@\n", fileName, error);
			[error release]; // Doc's say to release this...
		} else {
			[[Globals sharedGlobals] setPlist:dict forKey:fileName];
		}
	}
	return dict;
}

+ (NSArray *)loadPlistArray:(NSString *)fileName {
	NSArray *array = (NSArray *)[[Globals sharedGlobals] plistForKey:fileName];
	
	if (array == nil) {
		NSString *error;
		
		array = [NSPropertyListSerialization propertyListFromData:
				 [NSData dataWithContentsOfFile:
				  [[NSBundle mainBundle] pathForResource:fileName
												  ofType:@"plist"]]
												 mutabilityOption:NSPropertyListImmutable
														   format:nil
												 errorDescription:&error];
		if (array == nil) {
			NSLog(@"Error loading %@ plist: %@\n", fileName, error);
			[error release]; // Doc's say to release this...
		} else {
			[[Globals sharedGlobals] setPlist:array forKey:fileName];
		}
	}
	return array;
}

+ (BOOL)isWithinScreenBounds:(float)x y:(float)y {
	return (x > 0.0f && x < SCREEN_WIDTH && y > 0.0f && y < SCREEN_HEIGHT);
}

+ (NSString *)commaSeparatedInteger:(int)value showSign:(BOOL)showSign {
	if ((value >= 0 && value < 1000) || (value < 0 && value > -1000)) {
		NSString *s = nil;
		
		if (showSign)
			s = [NSString stringWithFormat:@"%+d", value];
		else
			s = [NSString stringWithFormat:@"%d", value];
		return s;
	} else {
		return [NSString stringWithFormat:@"%@,%03d", [Globals commaSeparatedInteger:value / 1000 showSign:showSign], abs(value % 1000)];
	}
}

+ (NSString *)commaSeparatedValue:(uint)value {
	if (value < 1000)
		return [NSString stringWithFormat:@"%d", value];
	else 
		return [NSString stringWithFormat:@"%@,%03d", [Globals commaSeparatedValue:value / 1000], value % 1000];
}

+ (NSString *)commaSeparatedScore:(int64_t)value {
	if (value < 1000)
		return [NSString stringWithFormat:@"%lld", value];
	else 
		return [NSString stringWithFormat:@"%@,%03lld", [Globals commaSeparatedScore:value / 1000], value % 1000];
}

+ (NSString *)formatElapsedTime:(double)time {
	int mins,secs,ms;
	
	mins = (int)(time / 60);
	time -= mins * 60;
	secs = (int)time;
	time -= secs;
	ms = (int)(time * 1000);
	return [NSString stringWithFormat:@"%d:%02d:%03d", mins, secs, ms];
}

/*
+ (SPSprite *)wholeFromQuarter:(SPTexture *)texture {
	SPSprite *sprite = nil;
	
	for (int i = 0; i < 4; ++i) {
		SPImage *image = [SPImage imageWithTexture:texture];
		
		switch (i) {
			case 0:
				image.x = -image.width;
				image.y = -image.height;
				break;
			case 1:
				image.x = image.width;
				image.y = -image.height;
				image.scaleX = -1.0f;
				break;
			case 2:
				image.x = image.width;
				image.y = image.height;
				image.scaleX = -1.0f;
				image.scaleY = -1.0f;
				break;
			case 3:
				image.x = -image.width;
				image.y = image.height;
				image.scaleY = -1.0f;
				break;
		}
		
		if (sprite == nil) {
			sprite = [SPSprite sprite];
			sprite.x = image.width;
			sprite.y = image.height;
		}
		[sprite addChild:image];
	}
	return sprite;
}

+ (SPSprite *)wholeFromHalf:(SPTexture *)texture {
	SPSprite *sprite = nil;
	
	for (int i = 0; i < 2; ++i) {
		SPImage *image = [SPImage imageWithTexture:texture];
		
		switch (i) {
			case 0:
				image.x = -image.width;
				image.y = -image.height / 2;
				break;
			case 1:
				image.x = image.width;
				image.y = -image.height / 2;
				image.scaleX = -1.0f;
				break;
		}
		
		if (sprite == nil) {
			sprite = [SPSprite sprite];
			sprite.x = image.width;
			sprite.y = image.height;
		}
		[sprite addChild:image];
	}
	return sprite;
}
 */

+ (SPTexture *)foldoutTexture:(SPTexture *)texture settings:(uint)settings {
    SPRectangle *frame = texture.frame;    
    float width  = frame ? frame.width  : texture.width;
    float height = frame ? frame.height : texture.height;
	
	if (settings & TEXTURE_FOLD_HORIZ)
		width *= 2;
	if (settings & TEXTURE_FOLD_VERT)
		height *= 2;
	
	SPRenderTexture *renderTexture = [SPRenderTexture textureWithWidth:width height:height];
	
	[renderTexture bundleDrawCalls:^ {
		SPImage *image = [SPImage imageWithTexture:texture];
		
		for (int i = 0; i < 4; ++i) {	
			switch (i) {
				case 0:
					// Always do first quadrant
					image.x = 0;
					image.y = 0;
					image.scaleX = 1.0f;
					image.scaleY = 1.0f;
					//[renderTexture drawObject:image];
					break;
				case 1:
					if ((settings & TEXTURE_FOLD_HORIZ) == 0)
						continue;
					image.x = 2 * image.width;
					image.y = 0;
					image.scaleX = -1.0f;
					image.scaleY = 1.0f;
					break;
				case 2:
					if ((settings & TEXTURE_FOLD_VERT) == 0)
						continue;
					image.x = 0;
					image.y = 2 * image.height;
					image.scaleX = 1.0f;
					image.scaleY = -1.0f;
					break;
				case 3:
					if ((settings & TEXTURE_FOLD_QUAD) != TEXTURE_FOLD_QUAD)
						continue;
					image.x = 2 * image.width;
					image.y = 2 * image.height;
					image.scaleX = -1.0f;
					image.scaleY = -1.0f;
					break;
			}
			[renderTexture drawObject:image];
		}
	}];
	
	return renderTexture;
}

+ (SPTexture *)wholeTextureFromQuarter:(SPTexture *)texture {
	return [Globals foldoutTexture:texture settings:TEXTURE_FOLD_QUAD];
}

+ (SPTexture *)wholeTextureFromHalfHoriz:(SPTexture *)texture {
	return [Globals foldoutTexture:texture settings:TEXTURE_FOLD_HORIZ];
}

+ (SPTexture *)wholeTextureFromHalfVert:(SPTexture *)texture {
	return [Globals foldoutTexture:texture settings:TEXTURE_FOLD_VERT];
}

+ (SPTexture *)repeatedTexture:(SPTexture *)texture width:(float)width height:(float)height {
	return [Globals repeatedTexture:texture width:width height:height boldness:1];	
}

+ (SPTexture *)repeatedTexture:(SPTexture *)texture width:(float)width height:(float)height boldness:(int)boldness {
	SPRenderTexture *renderTexture = [SPRenderTexture textureWithWidth:width height:height];
	
	[renderTexture bundleDrawCalls:^ {
		SPImage *image = [SPImage imageWithTexture:texture];
		float widthCounter = 0, heightCounter = 0;
		
		while (heightCounter < height) {
			image.y = heightCounter;
			widthCounter = 0;
			
			while (widthCounter < width) {
				image.x = widthCounter;
				
				//if (widthCounter == 0)
				//	[renderTexture drawObject:image];
				for (int i = 0; i < boldness; ++i)
					[renderTexture drawObject:image];
				widthCounter += texture.width;
			}
			
			heightCounter += texture.height;
		}
	}];
	
	return renderTexture;	
}

+ (SPTexture *)debugTexture {
	SPRenderTexture *renderTexture = [SPRenderTexture textureWithWidth:8 height:8];
	
	[renderTexture bundleDrawCalls:^ {
		SPQuad *quad = [SPQuad quadWithWidth:8 height:8];
		quad.color = 0xff0000;
		[renderTexture drawObject:quad];
	}];
	
	return renderTexture;
}

@end
