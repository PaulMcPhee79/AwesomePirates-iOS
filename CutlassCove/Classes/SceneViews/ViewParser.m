//
//  ViewParser.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 20/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ViewParser.h"
#import "TitleSubview.h"
#import "MenuButton.h"
#import "SPButton_Extension.h"
#import "NumericValueChangedEvent.h"
#import "SceneController.h"
#import "GameController.h"
#import "Globals.h"

const float kDefaultMenuFontSize = 16.0f;


@interface ViewParser ()

@property (nonatomic,readonly) ResOffset *resOffset;

- (MenuDetailView *)parseSubview:(MenuDetailView *)view name:(NSString *)name viewName:(NSString *)viewName;
- (MenuDetailView *)parseSubview:(MenuDetailView *)view name:(NSString *)name viewName:(NSString *)viewName index:(int)index;
- (SPTexture *)textureByName:(NSString *)textureName;
- (ResOffset *)parseResOffset:(NSDictionary *)dict;
- (void)applyTransform:(SPDisplayObject *)transform toDisplayObject:(SPDisplayObject *)displayObject;
- (void)parseTransform:(NSDictionary *)dict forDisplayObject:(SPDisplayObject *)displayObject;
- (SPTween *)parseTween:(NSDictionary *)dict forDisplayObject:(SPDisplayObject *)displayObject;
- (void)parseTouchThumbs:(NSArray *)thumbs view:(MenuDetailView *)view;

@end

@implementation ViewParser

@synthesize category = mCategory;
@synthesize fontKey = mFont;
@dynamic resOffset;

- (id)initWithScene:(SceneController *)scene eventListener:(id)eventListener plistPath:(NSString *)path {
	if (self = [super init]) {
		mScene = scene;
		mEventListener = eventListener;
		mCategory = 0;
		mViewData = [[Globals loadPlist:path] retain];
		mFont = [[NSString stringWithFormat:BITMAP_FONT_NAME] copy];
	}
	return self;
}

- (void)dealloc {
	mScene = nil;
	[mFont release]; mFont = nil;
	[mViewData release]; mViewData = nil;
	[super dealloc];
}

- (void)changePlistPath:(NSString *)path {
    if (mViewData) {
        [mViewData release];
        mViewData = nil;
    }
    
    mViewData = [[Globals loadPlist:path] retain];
}

- (MenuDetailView *)parseSubviewByName:(NSString *)name forViewName:(NSString *)viewName {
	return [self parseSubviewByName:name forViewName:viewName index:-1];
}

- (MenuDetailView *)parseSubviewByName:(NSString *)name forViewName:(NSString *)viewName index:(int)index {
	MenuDetailView *detailView = [[[MenuDetailView alloc] initWithCategory:mCategory] autorelease];
	[self parseSubview:detailView name:name viewName:viewName index:index];
	return detailView;
}

- (TitleSubview *)parseTitleSubviewByName:(NSString *)name forViewName:(NSString *)viewName {
	return [self parseTitleSubviewByName:name forViewName:viewName index:-1];
}

- (TitleSubview *)parseTitleSubviewByName:(NSString *)name forViewName:(NSString *)viewName index:(int)index {
	TitleSubview *detailView = [[[TitleSubview alloc] initWithCategory:mCategory] autorelease];
	[self parseSubview:detailView name:name viewName:viewName index:index];
	return detailView;
}

- (MenuDetailView *)parseSubview:(MenuDetailView *)view name:(NSString *)name viewName:(NSString *)viewName {
	return [self parseSubview:view name:name viewName:viewName index:-1];
}

- (MenuDetailView *)parseSubview:(MenuDetailView *)view name:(NSString *)name viewName:(NSString *)viewName index:(int)index {
	NSArray *array = nil;
	NSDictionary *viewDict = [mViewData objectForKey:viewName];
	
	if (index != -1) {
		array = [viewDict objectForKey:name];
		assert(index < array.count);
		viewDict = [array objectAtIndex:index];
	} else {
		viewDict = [viewDict objectForKey:name];
	}
	
	NSNumber *x = (NSNumber *)[viewDict objectForKey:@"x"];
	NSNumber *y = (NSNumber *)[viewDict objectForKey:@"y"];
	
	view.x = (x) ? [x floatValue] : 0;
	view.y = (y) ? [y floatValue] : 0;
	
	if ([view isKindOfClass:[TitleSubview class]]) {
		TitleSubview *titleSubview = (TitleSubview *)view;
		
		NSString *selString = [viewDict objectForKey:@"closeSelector"];
		
		if (selString != nil)
			titleSubview.closeSelectorName = selString;
		
		NSNumber *closeX = (NSNumber *)[viewDict objectForKey:@"closeX"];
		NSNumber *closeY = (NSNumber *)[viewDict objectForKey:@"closeY"];
		
		if (closeX && closeY)
			titleSubview.closePosition = [SPPoint pointWithX:[closeX floatValue] y:[closeY floatValue]];
	}
	
	[RESM pushOffset:[self parseResOffset:(NSDictionary *)[viewDict objectForKey:@"ResOffset"]]];
	
	NSArray *scrolls = (NSArray *)[viewDict objectForKey:@"Scrolls"];
	[self parseQuarterFoldouts:scrolls view:view];
	
	NSArray *images = (NSArray *)[viewDict objectForKey:@"Images"];
	[self parseImages:images view:view];
	
	NSArray *labels = (NSArray *)[viewDict objectForKey:@"Labels"];
	[self parseLabels:labels view:view];
    
    NSArray *touchThumbs = (NSArray *)[viewDict objectForKey:@"Thumbs"];
    [self parseTouchThumbs:touchThumbs view:view];
	
	NSArray *buttons = (NSArray *)[viewDict objectForKey:@"Buttons"];
	[self parseButtons:buttons view:view];
	
	[RESM popOffset];
	
	return view;
}

- (NSDictionary *)parseSubviewsByViewName:(NSString *)viewName {
	NSMutableDictionary *subviews = [NSMutableDictionary dictionary];
	NSDictionary *viewDict = [mViewData objectForKey:viewName];
	
	for (NSString *key in viewDict) {
		MenuDetailView *detailView = [[MenuDetailView alloc] initWithCategory:mCategory];
		[self parseSubview:detailView name:key viewName:viewName];
			
		if (detailView)
			[subviews setObject:detailView forKey:key];
		[detailView release];
	}
	return [NSDictionary dictionaryWithDictionary:subviews];
}

- (NSDictionary *)parseTitleSubviewsByViewName:(NSString *)viewName {
	NSMutableDictionary *subviews = [NSMutableDictionary dictionary];
	NSDictionary *viewDict = [mViewData objectForKey:viewName];
	
	for (NSString *key in viewDict) {
		TitleSubview *detailView = [[TitleSubview alloc] initWithCategory:mCategory];
		[self parseSubview:detailView name:key viewName:viewName];
		
		if (detailView)
			[subviews setObject:detailView forKey:key];
		[detailView release];
	}
	return [NSDictionary dictionaryWithDictionary:subviews];
}

- (SPTexture *)textureByName:(NSString *)textureName {
	SPTexture *texture = nil;
	
	if (textureName != nil)
		texture = [mScene textureByName:textureName];
	else
		texture = [Globals debugTexture];
	return texture;
}

- (ResOffset *)parseResOffset:(NSDictionary *)dict {
	float x = 0, y = 0, custX = 0, custY = 0;
	
	for (NSString *key in dict) {
		if ([key isEqualToString:@"x"])
			x = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"y"])
			y = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"padX"])
			custX = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"padY"])
			custY = [(NSNumber *)[dict objectForKey:key] floatValue];
	}
    
    if (custX != 0)
        custX *= CUSTX / 32.0f;
    if (custY != 0)
        custY *= CUSTY / 64.0f;
	
	return [ResOffset resOffsetWithX:x y:y custX:custX custY:custY];
}

- (void)applyTransform:(SPDisplayObject *)transform toDisplayObject:(SPDisplayObject *)displayObject {
	displayObject.x = transform.x;
	displayObject.y = transform.y;
	displayObject.scaleX = transform.scaleX;
	displayObject.scaleY = transform.scaleY;
	displayObject.rotation = transform.rotation;
}

- (void)parseTransform:(NSDictionary *)dict forDisplayObject:(SPDisplayObject *)displayObject {
	assert(dict && displayObject);
	ResOffset *offset = nil;
	
	NSDictionary *offsetDict = (NSDictionary *)[dict objectForKey:@"ResOffset"];
	
	if (offsetDict) {
		offset = [self parseResOffset:offsetDict];
		[RESM pushOffset:offset];
	}
	
	for (NSString *key in dict) {
		if ([key isEqualToString:@"x"])
			displayObject.rx = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"y"])
			displayObject.ry = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"scaleX"])
			displayObject.scaleX = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"scaleY"])
			displayObject.scaleY = [(NSNumber *)[dict objectForKey:key] floatValue];
        else if ([key isEqualToString:@"pivotX"])
			displayObject.pivotX = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"pivotY"])
			displayObject.pivotY = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"rotation"])
			displayObject.rotation = SP_D2R([(NSNumber *)[dict objectForKey:key] floatValue]);
        else if ([key isEqualToString:@"alpha"])
			displayObject.alpha = [(NSNumber *)[dict objectForKey:key] floatValue];
	}
    
    
	
	if (offset)
		[RESM popOffset];
}

- (SPTween *)parseTween:(NSDictionary *)dict forDisplayObject:(SPDisplayObject *)displayObject {
    assert(dict && displayObject);
    SPTween *tween = nil;
	ResOffset *offset = nil;
    
    NSDictionary *offsetDict = (NSDictionary *)[dict objectForKey:@"ResOffset"];
	
	if (offsetDict)
		offset = [self parseResOffset:offsetDict];
    if (offset == nil)
        offset = [ResOffset resOffsetWithX:0 y:0];
    
    float duration = 1.0f;
    NSString *transition = SP_TRANSITION_LINEAR;
    SPLoopType loopType = SPLoopTypeNone;
    float delay = 0, repeatDelay = 0;
    NSArray *properties = nil;
    
    for (NSString *key in dict) {
        if ([key isEqualToString:@"duration"])
            duration = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"transition"])
			transition = (NSString *)[dict objectForKey:key];
        else if ([key isEqualToString:@"loop"])
			loopType = (SPLoopType)[(NSNumber *)[dict objectForKey:key] intValue];
        else if ([key isEqualToString:@"delay"])
			delay = [(NSNumber *)[dict objectForKey:key] floatValue];
        else if ([key isEqualToString:@"repeatDelay"])
			repeatDelay = [(NSNumber *)[dict objectForKey:key] floatValue];
		else if ([key isEqualToString:@"Properties"])
            properties = (NSArray *)[dict objectForKey:key];
	}
    
    if (properties && properties.count > 0) {
        tween = [SPTween tweenWithTarget:displayObject time:duration transition:transition];
        
        for (NSDictionary *property in properties) {
            float targetValue = [(NSNumber *)[property objectForKey:@"targetValue"] floatValue];
            
            if (RESM.isIpadDevice)
                targetValue += [(NSNumber *)[property objectForKey:@"iPadOffset"] floatValue];
            [tween animateProperty:(NSString *)[property objectForKey:@"name"] targetValue:targetValue];
        }
        
        tween.loop = loopType;
        tween.delay = delay;
        tween.repeatDelay = repeatDelay;
    }
    
    return tween;
}

- (void)parseLabels:(NSArray *)labels view:(MenuDetailView *)view {
	for (NSDictionary *dict in labels) {
		SP_CREATE_POOL(pool);
		
		uint color = 0;
		float width = 0, height = 0;
		float fontSize = 0;
		NSString *prefix = @"";
		NSString *suffix = @"";
		SPHAlign halign = SPHAlignLeft;
        SPVAlign valign = SPVAlignTop;
		NSString *viewKey = nil;
		NSArray *textArray = nil;
		SPSprite *transform = [SPSprite sprite];
        NSArray *tweens = nil;
		
		[self parseTransform:dict forDisplayObject:transform];
		
		for (NSString *key in dict) {
			if ([key isEqualToString:@"color"])
				color = [(NSNumber *)[dict objectForKey:key] unsignedIntValue];
			else if ([key isEqualToString:@"width"])
				width = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"height"])
				height = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"fontSize"])
				fontSize = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"halign"])
				halign = [(NSNumber *)[dict objectForKey:key] intValue];
            else if ([key isEqualToString:@"valign"])
				valign = [(NSNumber *)[dict objectForKey:key] intValue];
			else if ([key isEqualToString:@"name"])
				viewKey = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"text"])
				textArray = (NSArray *)[dict objectForKey:key];
			else if ([key isEqualToString:@"prefix"])
				prefix = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"suffix"])
				suffix = (NSString *)[dict objectForKey:key];
            else if ([key isEqualToString:@"Tweens"])
				tweens = (NSArray *)[dict objectForKey:key];
		}
		
		NSMutableArray *labelArray = nil;
		
		if (textArray == nil)
			textArray = [NSArray arrayWithObject:@""];
		
		for (NSString *text in textArray) {
			if (fontSize == 0)
				fontSize = kDefaultMenuFontSize;
			if (width == 0)
				width = 0.5f * fontSize * text.length;
			if (height == 0)
				height = fontSize;
			
			SPTextField *textField = [SPTextField  textFieldWithWidth:width height:height text:[NSString stringWithFormat:@"%@%@%@", prefix, text, suffix]];
			[self applyTransform:transform toDisplayObject:textField];
			textField.fontName = mFont;
			textField.fontSize = fontSize;
			textField.color = color;
			textField.hAlign = halign;
			textField.vAlign = valign;
			textField.touchable = NO;
			[view addChild:textField];
            
            for (NSDictionary *tweenDict in tweens) {
                SPTween *tween = [self parseTween:tweenDict forDisplayObject:textField];
                
                if (tween && tween.loop != SPLoopTypeNone)
                    [view addLoopingTween:tween];
                [mScene.juggler addObject:tween];
            }
			
			if (viewKey) {
				if (textArray.count > 1) {
					if (labelArray == nil) {
						labelArray = [NSMutableArray arrayWithCapacity:textArray.count];
						[view setControlArray:labelArray forKey:viewKey];
					}
					
					[labelArray addObject:textField];
				} else {
					[view setControl:textField forKey:viewKey];
				}
			}
		}
		
		SP_RELEASE_POOL(pool);
	}
}

- (void)parseImages:(NSArray *)images view:(MenuDetailView *)view {
	for (NSDictionary *dict in images) {
		SP_CREATE_POOL(pool);
		
		NSString *viewKey = nil, *textureName = nil;
        NSArray *tweens = nil;
		SPSprite *transform = [SPSprite sprite];
        		
		[self parseTransform:dict forDisplayObject:transform];
		
		for (NSString *key in dict) {
			if ([key isEqualToString:@"texture"])
				textureName = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"name"])
				viewKey = (NSString *)[dict objectForKey:key];
            else if ([key isEqualToString:@"Tweens"])
				tweens = (NSArray *)[dict objectForKey:key];
		}
		
		SPImage *image = [SPImage imageWithTexture:[self textureByName:textureName]];
		[self applyTransform:transform toDisplayObject:image];
		image.touchable = NO;
		[view addChild:image];
        
        for (NSDictionary *tweenDict in tweens) {
            SPTween *tween = [self parseTween:tweenDict forDisplayObject:image];
            
            if (tween && tween.loop != SPLoopTypeNone)
                [view addLoopingTween:tween];
            [mScene.juggler addObject:tween];
        }
			
		if (viewKey)
			[view setControl:image forKey:viewKey];
		
		SP_RELEASE_POOL(pool);
	}
}

- (void)parseButtons:(NSArray *)buttons view:(MenuDetailView *)view {
	for (NSDictionary *dict in buttons) {
		SP_CREATE_POOL(pool);
		
        float touchQuadScale = 1;
		float scaleWhenDown = 0.9f, alphaWhenDisabled = 1.0f;
		NSString *viewKey = nil, *textureName = nil, *selString = nil, *sfxKey = @"Button";
		NSArray *touchBounds = nil;
        NSArray *tweens = nil;
		SPSprite *transform = [SPSprite sprite];
		
		[self parseTransform:dict forDisplayObject:transform];
		
		for (NSString *key in dict) {
			if ([key isEqualToString:@"scaleWhenDown"])
				scaleWhenDown = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"alphaWhenDisabled"])
				alphaWhenDisabled = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"texture"])
				textureName = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"selector"])
				selString = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"name"])
				viewKey = (NSString *)[dict objectForKey:key];
			else if ([key isEqualToString:@"sfxKey"])
				sfxKey = (NSString *)[dict objectForKey:key];
            else if ([key isEqualToString:@"touchQuadScale"])
				touchQuadScale = [(NSNumber *)[dict objectForKey:key] floatValue];
			else if ([key isEqualToString:@"touchBounds"])
				touchBounds = (NSArray *)[dict objectForKey:key];
            else if ([key isEqualToString:@"Tweens"])
				tweens = (NSArray *)[dict objectForKey:key];
		}
		
		assert(selString);
		
		SPTexture *texture = [self textureByName:textureName];
		MenuButton *button = [MenuButton menuButtonWithSelector:selString upState:texture downState:texture];
		[self applyTransform:transform toDisplayObject:button];
		button.scaleWhenDown = scaleWhenDown;
		button.alphaWhenDisabled = alphaWhenDisabled;
		button.sfxKey = sfxKey;
		
        if (SP_IS_FLOAT_EQUAL(1, touchQuadScale) == NO)
            [button addTouchQuadWithWidth:touchQuadScale * button.width height:touchQuadScale * button.height];
		if (touchBounds)
			[button populateTouchBoundsWithVerts:touchBounds];
		
		if ([mEventListener respondsToSelector:@selector(onButtonTriggered:)])
			[button addEventListener:@selector(onButtonTriggered:) atObject:mEventListener forType:SP_EVENT_TYPE_TRIGGERED];
		[view addChild:button];
        
        for (NSDictionary *tweenDict in tweens) {
            SPTween *tween = [self parseTween:tweenDict forDisplayObject:button];
            
            if (tween && tween.loop != SPLoopTypeNone)
                [view addLoopingTween:tween];
            [mScene.juggler addObject:tween];
        }
		
		if (viewKey)
			[view setControl:button forKey:viewKey];
		
		SP_RELEASE_POOL(pool);
	}
}

- (void)parseQuarterFoldouts:(NSArray *)foldouts view:(MenuDetailView *)view {
	for (NSDictionary *dict in foldouts) {
		SP_CREATE_POOL(pool);
		
		SPSprite *transform = [SPSprite sprite];
		[self parseTransform:dict forDisplayObject:transform];
		
		SPTexture *texture = nil;
		NSString *textureName = (NSString *)[dict objectForKey:@"texture"];
		NSString *cachedTextureName = [NSString stringWithFormat:@"%@-cached",textureName];
		
		// Re-use rendered texture memory
		texture = [mScene cachedTextureByName:cachedTextureName];
		
		if (texture == nil) {
			texture = [mScene textureByName:textureName];
			texture = [Globals wholeTextureFromQuarter:texture];
			[mScene.tm cacheTexture:texture byName:cachedTextureName];
		}
		
		SPImage *image = [SPImage imageWithTexture:texture];
		image.x = -image.width / 2;
		image.y = -image.height / 2;
		
		SPSprite *sprite = [SPSprite sprite];
		sprite.touchable = NO;
		sprite.x = transform.x + image.width / 2;
		sprite.y = transform.y + image.height / 2;
		sprite.scaleX = transform.scaleX;
		sprite.scaleY = transform.scaleY;
		sprite.rotation = SP_D2R(transform.rotation);
		[sprite addChild:image];
		[view addChild:sprite];
		
		NSString *viewKey = (NSString *)[dict objectForKey:@"name"];
		
		if (viewKey != nil)
			[view setControl:sprite forKey:viewKey];
		
		SP_RELEASE_POOL(pool);
	}
}

- (void)parseTouchThumbs:(NSArray *)thumbs view:(MenuDetailView *)view {
    if (thumbs == nil)
        return;
    SPTexture *thumbTexture = [mScene textureByName:@"touch-thumb"];
    SPTexture *textTexture = [mScene textureByName:@"touch-text"];
    
    for (NSDictionary *dict in thumbs) {
        SP_CREATE_POOL(pool);
        
        BOOL leftThumb = NO;
        NSString *viewKey = nil;
        NSArray *tweens = nil;
        
        SPSprite *transform = [SPSprite sprite];
		[self parseTransform:dict forDisplayObject:transform];
        
        for (NSString *key in dict) {
            if ([key isEqualToString:@"name"])
                viewKey = (NSString *)[dict objectForKey:key];
            else if ([key isEqualToString:@"leftThumb"])
                leftThumb = [(NSNumber *)[dict objectForKey:key] boolValue];
            else if ([key isEqualToString:@"Tweens"])
				tweens = (NSArray *)[dict objectForKey:key];
        }
        
        SPImage *thumbImage = [SPImage imageWithTexture:thumbTexture];
        thumbImage.x = -thumbImage.width / 2;
        thumbImage.y = -thumbImage.height / 2;
        thumbImage.alpha = transform.alpha;
        
        SPImage *thumbText = [SPImage imageWithTexture:textTexture];
        thumbText.x = thumbImage.x;
        thumbText.y = thumbImage.y;
        
        if (leftThumb == NO) {
            thumbText.x += 15;
            thumbText.y += 23;
        } else {
            thumbImage.scaleX = -1;
            thumbImage.x += thumbImage.width;
            thumbText.x += 41;
            thumbText.y += 23;
        }
        
        SPSprite *thumbSprite = [SPSprite sprite];
        thumbSprite.x = transform.x;
        thumbSprite.y = transform.y;
        thumbSprite.scaleX = transform.scaleX;
        thumbSprite.scaleY = transform.scaleY;
        thumbSprite.rotation = SP_D2R(transform.rotation);
        
        [thumbSprite addChild:thumbImage];
        [thumbSprite addChild:thumbText];
        [view addChild:thumbSprite];
        
        for (NSDictionary *tweenDict in tweens) {
            SPTween *tween = [self parseTween:tweenDict forDisplayObject:thumbSprite];
            
            if (tween && tween.loop != SPLoopTypeNone)
                [view addLoopingTween:tween];
            [mScene.juggler addObject:tween];
        }
        
        if (viewKey != nil)
			[view setControl:thumbSprite forKey:viewKey];
        
        SP_RELEASE_POOL(pool);
    }
}

@end
