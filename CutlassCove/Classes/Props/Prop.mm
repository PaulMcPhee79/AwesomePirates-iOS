//
//  Prop.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Prop.h"
#import "GameController.h"


@implementation Prop

@synthesize category = mCategory;
@synthesize advanceable = mAdvanceable;
@synthesize slowable = mSlowable;
@synthesize markedForRemoval = mRemoveMe;
//@synthesize propId = mPropId;
@synthesize turnID = mTurnID;

static NSMutableArray *_props = nil;
static SceneController *_scene = nil;
//static int _propIdCounter = 0;

+ (int)propCount {
	return _props.count;
}

+ (void)printProps {
	/*
	for (NSValue *value in _props) {
		Prop *prop = [value nonretainedObjectValue];
		
		if (![prop isKindOfClass:[CannonSmoke class]])
			NSLog(@"Alive Prop: %@",NSStringFromClass([prop class]));
			//NSLog(@"Alive Prop: %@ ID:%d",NSStringFromClass([prop class]), prop.propId);
	}
	 */
}

+ (SceneController *)propsScene {
	SceneController *scene = nil;
	
	@synchronized(_scene) {
		scene = _scene;
	}
	
	return scene;
}

+ (void)setPropsScene:(SceneController *)scene {
	@synchronized(_scene) {
		_scene = scene;
	}
}

+ (void)relinquishPropScene:(SceneController *)scene {
	@synchronized(_scene) {
		if (scene == _scene)
			_scene = nil;
	}
}

- (id)initWithCategory:(int)category {
	if (self = [super init]) {
		if (_props == nil)
			_props = [[NSMutableArray alloc] init];
		
		[_props addObject:[NSValue valueWithNonretainedObject:self]];
		
		mScene = [_scene retain];
		mCategory = category;
		mAdvanceable = NO;
        mSlowable = YES;
		self.touchable = mScene.touchableDefault;
        mTurnID = GCTRL.thisTurn.turnID;
		//mPropId = _propIdCounter;
		//++_propIdCounter;
    }
    return self;
}

- (id)init {
	return [self initWithCategory:0];
}

- (void)setupProp { }

- (void)flip:(BOOL)enable { }

- (void)moveToCategory:(int)category {
    [mScene removeProp:self];
    self.category = category;
    [mScene addProp:self];
}

- (void)updateOrientation:(UIDeviceOrientation)orientation { }

- (void)advanceTime:(double)time { }

- (void)checkoutPooledResources { }

- (void)checkinPooledResources { }

- (void)dealloc {
	//[mScene.juggler removeTweensWithTarget:self]; // We wouldn't be in here if we were targets of any tweens.
	[_props removeObject:[NSValue valueWithNonretainedObject:self]];
	//NSLog(@"Prop Count: %d",[Prop propCount]);
	
	//if ([Prop propCount] < 4)
	//	[Prop printProps];
	[mScene release]; mScene = nil;
    [super dealloc];
}

@end

