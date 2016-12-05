//
//  MenuView.m
//  CutlassCove
//
//  Created by Paul McPhee on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuView.h"
#import "MenuController.h"
#import "MenuButton.h"
#import "TitleSubview.h"
#import "BookletSubview.h"
#import "ObjectivesLog.h"
#import "SwitchControl.h"
#import "ViewParser.h"
#import "PotionView.h"
#import "NumericValueChangedEvent.h"
#import "SPButton_Extension.h"
#import "GuiHelper.h"
#import "Globals.h"

@interface MenuView ()

- (void)transitionOverTime:(float)duration inward:(BOOL)inward;
- (void)onTransitionedIn:(SPEvent *)event;
- (void)onTransitionedOut:(SPEvent *)event;
- (SPDisplayObject *)displayObjectFromSubview:(NSString *)key byName:(NSString *)objectName;
- (void)pushSubview:(TitleSubview *)subview;
- (void)playPushSubviewSound;
- (void)playPopSubviewSound;
- (void)onTouchedToPlay:(SPTouchEvent *)event;

// Booklets
- (BookletSubview *)loadBookletSubviewForKey:(NSString *)key;
- (void)onBookletPageTurned:(SPEvent *)event;

@end


@implementation MenuView

@dynamic currentSubview,potionWasSelected;

- (id)initWithCategory:(int)category controller:(MenuController *)controller {
    if (self = [super initWithCategory:category]) {
        mController = controller;
        mPotionView = nil;
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    // View
    SPSprite *sprite = (SPSprite *)[mMenuSubview controlForKey:@"TouchToPlay"];
    [sprite removeEventListener:@selector(onTouchedToPlay:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    BookletSubview *subview = (BookletSubview *)[mSubviews objectForKey:@"Credits"];
	[subview removeEventListener:@selector(onBookletPageTurned:) atObject:self forType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED];
    
    [mCloseSubviewButton release]; mCloseSubviewButton = nil;
    [mMenuSubview release]; mMenuSubview = nil;
    [mObjectivesLog release]; mObjectivesLog = nil;
    [mCanvas release]; mCanvas = nil;
    [mViewParser release]; mViewParser = nil;
    
    [self unpopulatePotionView];
    
    // Model
    [mSubviews release]; mSubviews = nil;
    [mSubviewStack release]; mSubviewStack = nil;
    mController = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mViewParser)
        return;
    
    mCanvas = [[SPSprite alloc] init];
    [self addChild:mCanvas];

// 1. Load plist subviews
    mViewParser = [[ViewParser alloc] initWithScene:mScene eventListener:mController plistPath:@"Title"];
    mViewParser.category = self.category;
    mViewParser.fontKey = mScene.fontKey;
	
	NSDictionary *parserOutputDict = [mViewParser parseTitleSubviewsByViewName:@"Subviews"];
	assert(parserOutputDict);
	mSubviews = [[NSMutableDictionary alloc] initWithDictionary:parserOutputDict];
    mSubviewStack = [[NSMutableArray alloc] init];
    
// 2. Create menu subview
    mMenuSubview = [[TitleSubview alloc] initWithCategory:self.category];
    [mSubviews setObject:mMenuSubview forKey:@"Menu"];
    
    // Touch Listener
    SPQuad *touchQuad = [SPQuad quadWithWidth:mScene.viewWidth - 160 height:mScene.viewHeight];
    touchQuad.alpha = 0;
    
    SPSprite *touchSprite = [SPSprite sprite];
    [touchSprite addChild:touchQuad];
    [touchSprite addEventListener:@selector(onTouchedToPlay:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [mMenuSubview addChild:touchSprite];
    [mMenuSubview setControl:touchSprite forKey:@"TouchToPlay"];
    
    // Shady
//[RESM pushItemOffsetWithAlignment:RALowerCenter];
    SPImage *shadyImage = [SPImage imageWithTexture:[mScene textureByName:@"shady"]];
    SPSprite *shady = [SPSprite sprite];
    shady.touchable = NO;
    
    if (RESM.isCustResX) {
        shady.x = -38 + 18 * 32.0f / CUSTX;
        
        if (RESM.isCustResY)
            shady.y = 151;
        else
            shady.y = 103;
    } else {
        shady.x = -45;
        shady.y = 103;
    }
    
    [shady addChild:shadyImage];
    [mMenuSubview addChild:shady];
    [mMenuSubview setControl:shady forKey:@"Shady"];
//[RESM popOffset];
    
    // Logo
//[RESM pushItemOffsetWithAlignment:RACenter];
    SPImage *logoImage = [SPImage imageWithTexture:[mScene textureByName:@"logo"]];
    
    SPSprite *logo = [SPSprite sprite];
    logo.touchable = NO;
    
    if (RESM.isCustResX && RESM.isCustResY) {
        logo.x = 64 + 15 * CUSTX / 32.0f;
        logo.y = 74;
    } else {
        logo.x = (RESM.isCustResX) ? 64 + 15 * CUSTX / 32.0f : 62;
        logo.y = 50;
        logo.scaleX = logo.scaleY = 230.0f / 256.0f;
    }
    [logo addChild:logoImage];
    
    SPTextField *logoText = [SPTextField textFieldWithWidth:128
                                                     height:24
                                                       text:@"TOUCH  TO  PLAY"
                                                   fontName:mScene.fontKey
                                                   fontSize:20
                                                      color:0xfcc30e];
    logoText.x = logoImage.x + (logoImage.width - logoText.width) / 2;
    logoText.y = logoImage.y + logoImage.height + 42;
    logoText.hAlign = SPHAlignCenter;
    logoText.vAlign = SPVAlignTop;
    [logo addChild:logoText];
    [mMenuSubview setControl:logoText forKey:@"LogoText"];
    
    SPTween *logoTextTween = [SPTween tweenWithTarget:logoText time:1.0f];
    [logoTextTween animateProperty:@"alpha" targetValue:0];
    logoTextTween.loop = SPLoopTypeReverse;
    [mScene.juggler addObject:logoTextTween];
    [mMenuSubview addLoopingTween:logoTextTween];
    
    [mMenuSubview addChild:logo];
    [mMenuSubview setControl:logo forKey:@"Logo"];
//[RESM popOffset];
    
    // Side Scroll
    SPImage *sideScrollImage = [SPImage imageWithTexture:[mScene textureByName:@"menu-side-scroll"]];
    sideScrollImage.touchable = NO;
    SPSprite *sideScroll = [SPSprite sprite];
    sideScroll.x = mScene.viewWidth - sideScrollImage.width;
    sideScroll.y = 0;
    [sideScroll addChild:sideScrollImage];
    [mMenuSubview addChild:sideScroll];
    [mMenuSubview setControl:sideScroll forKey:@"SideScroll"];
    
    // Hi Score
    SPImage *hiScoreImage = [SPImage imageWithTexture:[mScene textureByName:@"hi-score"]];
    hiScoreImage.y = 5;
    SPSprite *hiScore = [SPSprite sprite];
    hiScore.x = sideScrollImage.width - 200;
    hiScore.y = 6;
    [hiScore addChild:hiScoreImage];
    [sideScroll addChild:hiScore];
    
    SPTextField *hiScoreText = [SPTextField textFieldWithWidth:128
                                                        height:28
                                                          text:@""
                                                      fontName:mScene.fontKey
                                                      fontSize:24
                                                         color:0];
    hiScoreText.x = hiScoreImage.x + hiScoreImage.width + 2;
    hiScoreText.hAlign = SPHAlignLeft;
    hiScoreText.vAlign = SPVAlignTop;
    [hiScore addChild:hiScoreText];
    [mMenuSubview setControl:hiScoreText forKey:@"HiScoreText"];
    [mMenuSubview setControl:hiScore forKey:@"HiScore"];
    
    // Buttons
    if ([ResManager isGameCenterAvailable]) {
        MenuButton *objectivesButton = [MenuButton menuButtonWithSelector:@"objectives:" upState:[mScene textureByName:@"objectives-button"]];
        objectivesButton.sfxKey = @"Button";
        objectivesButton.x = sideScrollImage.width - 137;
        objectivesButton.y = 60;
        [objectivesButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:objectivesButton forKey:@"ObjectivesButton"];
        [sideScroll addChild:objectivesButton];

        MenuButton *achievementsButton = [MenuButton menuButtonWithSelector:@"achievements:" upState:[mScene textureByName:@"achievements-button"]];
        achievementsButton.sfxKey = @"Button";
        achievementsButton.x = sideScrollImage.width - 135;
        achievementsButton.y = 108;
        [achievementsButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:achievementsButton forKey:@"AchievementsButton"];
        [sideScroll addChild:achievementsButton];

        MenuButton *gcButton = [MenuButton menuButtonWithSelector:@"launchGameCenter:" upState:[mScene textureByName:@"gc-button"]];
        gcButton.sfxKey = @"Button";
        gcButton.x = sideScrollImage.width - 132;
        gcButton.y = 156;
        [gcButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:gcButton forKey:@"GameCenterButton"];
        [sideScroll addChild:gcButton];

        {
            MenuButton *infoButton = [MenuButton menuButtonWithSelector:@"info:" upState:[mScene textureByName:@"info-button"]];
            infoButton.sfxKey = @"Button";
            infoButton.x = sideScrollImage.width - 136;
            infoButton.y = 204;
            [infoButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
            [mMenuSubview setControl:infoButton forKey:@"InfoButton"];
            [sideScroll addChild:infoButton];
        }

        MenuButton *optionsButton = [MenuButton menuButtonWithSelector:@"options:" upState:[mScene textureByName:@"options-button"]];
        optionsButton.sfxKey = @"Button";
        optionsButton.x = sideScrollImage.width - 164;
        optionsButton.y = 252;
        [optionsButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:optionsButton forKey:@"OptionsButton"];
        [sideScroll addChild:optionsButton];
    } else {
        MenuButton *objectivesButton = [MenuButton menuButtonWithSelector:@"objectives:" upState:[mScene textureByName:@"objectives-button"]];
        objectivesButton.sfxKey = @"Button";
        objectivesButton.x = sideScrollImage.width - 140;
        objectivesButton.y = 72;
        [objectivesButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:objectivesButton forKey:@"ObjectivesButton"];
        [sideScroll addChild:objectivesButton];
        
        MenuButton *achievementsButton = [MenuButton menuButtonWithSelector:@"achievements:" upState:[mScene textureByName:@"achievements-button"]];
        achievementsButton.sfxKey = @"Button";
        achievementsButton.x = sideScrollImage.width - 134;
        achievementsButton.y = 128;
        [achievementsButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:achievementsButton forKey:@"AchievementsButton"];
        [sideScroll addChild:achievementsButton];
        
        {
            MenuButton *infoButton = [MenuButton menuButtonWithSelector:@"info:" upState:[mScene textureByName:@"info-button"]];
            infoButton.sfxKey = @"Button";
            infoButton.x = sideScrollImage.width - 136;
            infoButton.y = 184;
            [infoButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
            [mMenuSubview setControl:infoButton forKey:@"InfoButton"];
            [sideScroll addChild:infoButton];
        }
        
        MenuButton *optionsButton = [MenuButton menuButtonWithSelector:@"options:" upState:[mScene textureByName:@"options-button"]];
        optionsButton.sfxKey = @"Button";
        optionsButton.x = sideScrollImage.width - 160;
        optionsButton.y = 240;
        [optionsButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
        [mMenuSubview setControl:optionsButton forKey:@"OptionsButton"];
        [sideScroll addChild:optionsButton];
    }
    
[RESM pushOffset:[RESM itemOffsetWithAlignment:RALowerCenter]];
    MenuButton *potionsButton = [MenuButton menuButtonWithSelector:@"potions:" upState:[mScene textureByName:@"potions-button"]];
    potionsButton.sfxKey = @"Button";
    potionsButton.x = RESM.isCustResY ? 10 : 36;
    potionsButton.ry = 180;
    [potionsButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
    [mMenuSubview setControl:potionsButton forKey:@"PotionsButton"];
    [sideScroll addChild:potionsButton];
[RESM popOffset];
    
/*    
    // Social Network Icons
    MenuButton *facebookButton = [MenuButton menuButtonWithSelector:@"likeUsFacebook:" upState:[mScene textureByName:@"facebook"]];
    facebookButton.sfxKey = @"Button";
    facebookButton.x = 4;
    facebookButton.y = mScene.viewHeight - facebookButton.height;
    [facebookButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
    [mMenuSubview setControl:facebookButton forKey:@"FacebookButton"];
    [mMenuSubview addChild:facebookButton];
    
    MenuButton *twitterButton = [MenuButton menuButtonWithSelector:@"followUsTwitter:" upState:[mScene textureByName:@"twitter"]];
    twitterButton.sfxKey = @"Button";
    twitterButton.x = 4;
    twitterButton.y = facebookButton.y - (twitterButton.height - 2);
    [twitterButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
    [mMenuSubview setControl:twitterButton forKey:@"TwitterButton"];
    [mMenuSubview addChild:twitterButton];
*/
    
// 3. Create Objectives Log
    TitleSubview *objectivesSubview = [[[TitleSubview alloc] initWithCategory:self.category] autorelease];
    objectivesSubview.closeSelectorName = @"closeObjectives:";
    objectivesSubview.closePosition = [SPPoint pointWithX:386 y:48];
    [mSubviews setObject:objectivesSubview forKey:@"Objectives"];
    
    mObjectivesLog = [[ObjectivesLog alloc] initWithCategory:self.category rank:mScene.objectivesManager.rank];
    [objectivesSubview addChild:mObjectivesLog];
    [objectivesSubview addMiscProp:mObjectivesLog];
    
// 4. Close Subview Button
[RESM pushItemOffsetWithAlignment:RACenter];
	SPTexture *closeButtonTexture = [mScene textureByName:@"menu-close"];
	mCloseSubviewButton = [[MenuButton menuButtonWithSelector:@"closeSubview:" upState:closeButtonTexture] retain];
	mCloseSubviewButton.rx = 375;
	mCloseSubviewButton.ry = 36;
	mCloseSubviewButton.sfxKey = @"Button";
	mCloseSubviewButton.scaleX = 0.8f;
	mCloseSubviewButton.scaleY = 0.8f;
	mCloseSubviewButton.scaleWhenDown = 0.72f;
	[mCloseSubviewButton addTouchQuadWithWidth:60 height:60];
	[mCloseSubviewButton addEventListener:@selector(onButtonTriggered:) atObject:mController forType:SP_EVENT_TYPE_TRIGGERED];
[RESM popOffset];
    
// 5. Options Switches
[RESM pushItemOffsetWithAlignment:RACenter];
    {
        TitleSubview *optionsSubview = [self subviewForKey:@"Options"];
        
        if (optionsSubview) {
            SwitchControl *switchControl = [[SwitchControl alloc] initWithCategory:0 state:mScene.audioPlayer.sfxOn];
            switchControl.name = @"SfxSwitch";
            switchControl.rx = 128;
            switchControl.ry = 68;
            [switchControl addEventListener:@selector(onSfxSwitchFlipped:) atObject:mController forType:CUST_EVENT_TYPE_SWITCH_CONTROL_FLIPPED];
            [optionsSubview addChild:switchControl];
            [switchControl release];
            
            switchControl = [[SwitchControl alloc] initWithCategory:0 state:mScene.audioPlayer.musicOn];
            switchControl.name = @"MusicSwitch";
            switchControl.rx = 128;
            switchControl.ry = 116;
            [switchControl addEventListener:@selector(onMusicSwitchFlipped:) atObject:mController forType:CUST_EVENT_TYPE_SWITCH_CONTROL_FLIPPED];
            [optionsSubview addChild:switchControl];
            [switchControl release];
        }
    }
[RESM popOffset];
    
// 6. Info subview
    SPButton *infoButton = (SPButton *)[self displayObjectFromSubview:@"Info" byName:@"statsLogInfo"];
    SPTextField *infoLabel = (SPTextField *)[self displayObjectFromSubview:@"Info" byName:@"statsLogLabel"];
    
    if (infoButton && infoLabel)
        [infoButton.contents addChild:infoLabel];
    infoLabel.touchable = YES;
    
    infoButton = (SPButton *)[self displayObjectFromSubview:@"Info" byName:@"gameConceptsInfo"];
    infoLabel = (SPTextField *)[self displayObjectFromSubview:@"Info" byName:@"gameConceptsLabel"];
    
    if (infoButton && infoLabel)
        [infoButton.contents addChild:infoLabel];
    infoLabel.touchable = YES;
    
    infoButton = (SPButton *)[self displayObjectFromSubview:@"Info" byName:@"spellsMunitionsInfo"];
    infoLabel = (SPTextField *)[self displayObjectFromSubview:@"Info" byName:@"spellsMunitionsLabel"];
    
    if (infoButton && infoLabel)
        [infoButton.contents addChild:infoLabel];
    infoLabel.touchable = YES;
    
// 7. Lite Subview
[RESM pushItemOffsetWithAlignment:RACenter];
    {
        TitleSubview *liteSubview = [self subviewForKey:@"Lite"];

        SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:[Potion potencyPotion] size:GuiSizeLge scene:mScene];
        potionSprite.rx = 71;
        potionSprite.ry = 202;
        potionSprite.scaleX = potionSprite.scaleY = 64.0f / potionSprite.height;
        potionSprite.x += potionSprite.width / 2;
        potionSprite.y += potionSprite.height / 2;
        [liteSubview addChild:potionSprite];
        
        SPImage *liteAchievementsImage = [SPImage imageWithTexture:[mScene textureByName:@"lite-achievements"]];
        liteAchievementsImage.rx = 42;
        liteAchievementsImage.ry = 228;
        [liteSubview addChild:liteAchievementsImage];
    }
[RESM popOffset];
    SPButton *buyNowButton = (SPButton *)[self displayObjectFromSubview:@"Lite" byName:@"liteBuyNow"];
    SPTextField *buyNowLabel = (SPTextField *)[self displayObjectFromSubview:@"Lite" byName:@"liteBuyNowLabel"];
    
    if (buyNowButton && buyNowLabel)
        [buyNowButton.contents addChild:buyNowLabel];
    buyNowLabel.touchable = YES;
    
// 8. Synchronize Achievements
    if ([ResManager isGameCenterAvailable] == NO) {
        {
            TitleSubview *optionsSubview = [self subviewForKey:@"Options"];
            
            if (optionsSubview) {
                // Follow Us
                float followUsX = 40;
                SPDisplayObject *uiElement = [optionsSubview controlForKey:@"followUsLabel"];
                uiElement.x += followUsX;
                
                uiElement = [optionsSubview controlForKey:@"twitterButton"];
                uiElement.x += followUsX;
                
                uiElement = [optionsSubview controlForKey:@"facebookButton"];
                uiElement.x += followUsX;
            }
        }
    }
}

- (void)attachEventListeners {

}

- (void)detachEventListeners {

}

// Note: MenuController FSM prevents DBZ in this method.
- (void)transitionOverTime:(float)duration inward:(BOOL)inward {
    SPSprite *shady = (SPSprite *)[mMenuSubview controlForKey:@"Shady"];
    SPSprite *logo = (SPSprite *)[mMenuSubview controlForKey:@"Logo"];
#ifdef CHEEKY_LITE_VERSION
    MenuButton *fullVersion = (MenuButton *)[mMenuSubview controlForKey:@"FullVersionButton"];
#endif
   // MenuButton *twitter = (MenuButton *)[mMenuSubview controlForKey:@"TwitterButton"];
    //MenuButton *facebook = (MenuButton *)[mMenuSubview controlForKey:@"FacebookButton"];
    SPSprite *sideScroll = (SPSprite *)[mMenuSubview controlForKey:@"SideScroll"];
    
    [mScene.specialJuggler removeTweensWithTarget:shady];
    [mScene.specialJuggler removeTweensWithTarget:logo];
#ifdef CHEEKY_LITE_VERSION
    [mScene.specialJuggler removeTweensWithTarget:fullVersion];
#endif
    //[mScene.specialJuggler removeTweensWithTarget:twitter];
    //[mScene.specialJuggler removeTweensWithTarget:facebook];
    [mScene.specialJuggler removeTweensWithTarget:sideScroll];
    
    float maxDuration = -1;
    SPTween *eventTween = nil;
    
    // Shady
    float shadyOriginX = (inward) ? -shady.width : (RESM.isCustResX ? -38 + 18 * 32.0f / CUSTX: -45);
    float shadyTargetX = (inward) ? (RESM.isCustResX ? -38 + 18 * 32.0f / CUSTX : -45) : -shady.width;
    float shadyMaxDist = shadyTargetX - shadyOriginX;
    float shadyActualDist = shadyTargetX - shady.x;
    float shadyDuration = duration * (shadyActualDist / shadyMaxDist);
    
    SPTween *shadyTween = [SPTween tweenWithTarget:shady time:shadyDuration];
    [shadyTween animateProperty:@"x" targetValue:shadyTargetX];
    [mScene.specialJuggler addObject:shadyTween];
    
    maxDuration = shadyDuration;
    eventTween = shadyTween;
    
    // Logo
    float logoOriginY = (inward) ? -logo.height : (RESM.isCustResY ? 74 : 50);
    float logoTargetY = (inward) ? (RESM.isIpadDevice ? 74 : 50) : -logo.height;
    float logoMaxDist = logoTargetY - logoOriginY;
    float logoActualDist = logoTargetY - logo.y;
    float logoDuration = duration * (logoActualDist / logoMaxDist);
    
    SPTween *logoTween = [SPTween tweenWithTarget:logo time:logoDuration];
    [logoTween animateProperty:@"y" targetValue:logoTargetY];
    [mScene.specialJuggler addObject:logoTween];
    
    if (logoDuration > maxDuration) {
        maxDuration = logoDuration;
        eventTween = logoTween;
    }
    
    // Get the Full Version
#ifdef CHEEKY_LITE_VERSION
    float fullVersionOriginY = (inward) ? mScene.viewHeight : mScene.viewHeight - 0.75f * fullVersion.height;
    float fullVersionTargetY = (inward) ? mScene.viewHeight - 0.75f * fullVersion.height : mScene.viewHeight;
    float fullVersionMaxDist = fullVersionTargetY - fullVersionOriginY;
    float fullVersionActualDist = fullVersionTargetY - fullVersion.y;
    float fullVersionDuration = duration * (fullVersionActualDist / fullVersionMaxDist);
    
    SPTween *fullVersionTween = [SPTween tweenWithTarget:fullVersion time:fullVersionDuration];
    [fullVersionTween animateProperty:@"y" targetValue:fullVersionTargetY];
    [mScene.specialJuggler addObject:fullVersionTween];
    
    if (fullVersionDuration > maxDuration) {
        maxDuration = fullVersionDuration;
        eventTween = fullVersionTween;
    }
#endif
    
    // Side Scroll
    float sideScrollOriginX = (inward) ? mScene.viewWidth : mScene.viewWidth - (sideScroll.width-1);
    float sideScrollTargetX = (inward) ? mScene.viewWidth - (sideScroll.width-1) : mScene.viewWidth;
    float sideScrollMaxDist = sideScrollOriginX - sideScrollTargetX;
    float sideScrollActualDist = sideScroll.x - sideScrollTargetX;
    float sideScrollDuration = duration * (sideScrollActualDist / sideScrollMaxDist);
    
    SPTween *sideScrollTween = [SPTween tweenWithTarget:sideScroll time:sideScrollDuration];
    [sideScrollTween animateProperty:@"x" targetValue:sideScrollTargetX];
    [mScene.specialJuggler addObject:sideScrollTween];
    
    if (sideScrollDuration > maxDuration) {
        maxDuration = sideScrollDuration;
        eventTween = sideScrollTween;
    }
    
    if (inward)
        [eventTween addEventListener:@selector(onTransitionedIn:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    else
        [eventTween addEventListener:@selector(onTransitionedOut:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
}

- (void)transitionInOverTime:(float)duration {
    [self transitionOverTime:duration inward:YES];
}

- (void)transitionOutOverTime:(float)duration {
    [self transitionOverTime:duration inward:NO];
}

- (void)onTransitionedIn:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_IN]];
}

- (void)onTransitionedOut:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_OUT]];
}

- (void)updateHiScoreText:(NSString *)text {
    SPSprite *hiScore = (SPSprite *)[self displayObjectFromSubview:@"Menu" byName:@"HiScore"];
    
    if (text) {
        hiScore.visible = YES;
        
        SPTextField *hiScoreText = (SPTextField *)[self displayObjectFromSubview:@"Menu" byName:@"HiScoreText"];
        hiScoreText.text = text;
    } else {
        hiScore.visible = NO;
    }
}

- (void)updateObjectivesLog {
    mObjectivesLog.rank = mScene.objectivesManager.rank;
    [mObjectivesLog syncWithObjectives];
}

- (TitleSubview	*)currentSubview {
	TitleSubview *current = nil;
	
	if (mSubviewStack.count > 0)
		current = [mSubviewStack lastObject];
	return current;
}

- (TitleSubview *)subviewForKey:(NSString *)key {
	return [mSubviews objectForKey:key];
}

- (SPDisplayObject *)displayObjectFromSubview:(NSString *)key byName:(NSString *)objectName {
	TitleSubview *subview = [self subviewForKey:key];
	SPDisplayObject *displayObject = [subview controlForKey:objectName];
	return displayObject;
}

- (void)pushSubviewForKey:(NSString *)key {
	TitleSubview *subview = (TitleSubview *)[mSubviews objectForKey:key];
	[self pushSubview:subview];
}

- (void)pushSubview:(TitleSubview *)subview {
	if (subview != nil && [mSubviewStack containsObject:subview] == NO) {
		if (mSubviewStack.count > 0) {
			TitleSubview *top = (TitleSubview *)[mSubviewStack lastObject];
			top.touchable = NO;
			[top removeChild:mCloseSubviewButton];
		}
		
		subview.visible = YES;
		subview.touchable = YES;
		
		if (subview.closeSelectorName != nil) {
			SPPoint *closePosition = subview.closePosition;
            
            [RESM pushItemOffsetWithAlignment:RACenter];			
			if (closePosition) {
				mCloseSubviewButton.rx = closePosition.x;
				mCloseSubviewButton.ry = closePosition.y;
			} else {
				mCloseSubviewButton.rx = 375;
				mCloseSubviewButton.ry = 36;
			}
            [RESM popOffset];
			
			[subview addChild:mCloseSubviewButton];
		}
		[mSubviewStack addObject:subview];
		
        if (mSubviewStack.count > 1)
            [self playPushSubviewSound];
        [mCanvas addChild:subview];
	}
}

- (void)popSubview {
	if (mSubviewStack.count > 0) {
		TitleSubview *subview = (TitleSubview *)[mSubviewStack lastObject];
		subview.visible = NO;
		subview.touchable = NO;
		[subview removeChild:mCloseSubviewButton];
        [mCanvas removeChild:subview];
		[mScene.juggler removeTweensWithTarget:subview];
		[mSubviewStack removeLastObject];
		
		if (mSubviewStack.count > 0) {
			TitleSubview *top = (TitleSubview *)[mSubviewStack lastObject];
			top.touchable = YES;
			
			if (top.closeSelectorName != nil) {
                SPPoint *closePosition = top.closePosition;
                
                [RESM pushItemOffsetWithAlignment:RACenter];			
                if (closePosition) {
                    mCloseSubviewButton.rx = closePosition.x;
                    mCloseSubviewButton.ry = closePosition.y;
                } else {
                    mCloseSubviewButton.rx = 375;
                    mCloseSubviewButton.ry = 36;
                }
                [RESM popOffset];
                
				[top addChild:mCloseSubviewButton];
            }
		}
		[self playPopSubviewSound];
	}
}

- (void)popAllSubviews {
    while (mSubviewStack.count > 1)
        [self popSubview];
}

- (void)destroySubviewForKey:(NSString *)key {
    if (key == nil)
        return;
    TitleSubview *subview = (TitleSubview *)[mSubviews objectForKey:key];
    
    if (subview && [mSubviewStack containsObject:subview])
        NSLog(@"MenuView: Attempt to destroy a subview while it is still on the stack.");
    [mSubviews removeObjectForKey:key];
}

- (void)advanceTime:(double)time {
    [self.currentSubview advanceTime:time];
    [mPotionView advanceTime:time];
}

- (void)setSwitch:(NSString *)name value:(BOOL)value {
    if (name == nil)
        return;
    
    TitleSubview *optionsSubview = [self subviewForKey:@"Options"];
    if (optionsSubview) {
        SwitchControl *switchControl = (SwitchControl *)[optionsSubview childByName:name];
        if (switchControl)
            switchControl.state = value;
    }
}

- (void)setAlertTitle:(NSString *)title text:(NSString *)text {
	TitleSubview *subview = (TitleSubview *)[mSubviews objectForKey:@"Alert"];
	[subview setText:title forKey:@"alertTitle"];
	[subview setText:text forKey:@"alertDesc"];
}

- (void)setQueryTitle:(NSString *)title text:(NSString *)text {
	TitleSubview *subview = (TitleSubview *)[mSubviews objectForKey:@"Query"];
	[subview setText:title forKey:@"queryTitle"];
	[subview setText:text forKey:@"queryDesc"];
}

- (void)playPushSubviewSound {
	[mScene.audioPlayer playSoundWithKey:@"PageTurn"];
}

- (void)playPopSubviewSound {
	[mScene.audioPlayer playSoundWithKey:@"PageTurn"];
}

- (BOOL)potionWasSelected {
    return (mPotionView && mPotionView.potionWasSelected);
}

- (void)hidePotionsButton:(BOOL)hide {
#ifdef CHEEKY_LITE_VERSION
    MenuButton *potionsButton = (MenuButton *)[mMenuSubview controlForKey:@"PotionsButton"];
    potionsButton.visible = !hide;
#endif
}

- (void)populatePotionView {
    if (mPotionView)
        return;
    TitleSubview *subview = (TitleSubview *)[mSubviews objectForKey:@"Potions"];
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    mPotionView = [[PotionView alloc] initWithCategory:0];
    mPotionView.x = offset.x;
    mPotionView.y = offset.y;
    [subview addChild:mPotionView];
}

- (void)unpopulatePotionView {
    [mPotionView destroyView];
    [mPotionView removeFromParent];
    [mPotionView release]; mPotionView = nil;
}

- (void)selectCurrentPotion {
    [mPotionView selectCurrentPotion];
}

- (void)onTouchedToPlay:(SPTouchEvent *)event {
    SPSprite *sprite = (SPSprite *)[mMenuSubview controlForKey:@"TouchToPlay"];
    
    if (sprite) {
        SPTouch *touch = [[event touchesWithTarget:sprite andPhase:SPTouchPhaseEnded] anyObject];
	
        if (touch)
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_VIEW_WAS_TOUCHED_TO_PLAY]];
    }
}

- (BookletSubview *)loadBookletSubviewForKey:(NSString *)key {
	NSString *plistPath = @"Title";
	
	if (mViewParser == nil) {
		mViewParser = [[ViewParser alloc] initWithScene:mScene eventListener:mController plistPath:plistPath];
		mViewParser.category = self.category;
		mViewParser.fontKey = mScene.fontKey;
	}
	
	NSDictionary *dict = [Globals loadPlist:plistPath];
	dict = [dict objectForKey:key];
	
	NSArray *pages = [dict objectForKey:@"Pages"];
	
	BookletSubview *subview = [BookletSubview bookletSubviewWithCategory:self.category key:key];
	subview.cover = [mViewParser parseTitleSubviewByName:@"Cover" forViewName:key];
    subview.closePosition = subview.cover.closePosition;
	subview.currentPage = [mViewParser parseSubviewByName:@"Pages" forViewName:key index:0];
	subview.numPages = pages.count;
	[subview refreshPageNo];
	[subview addEventListener:@selector(onBookletPageTurned:) atObject:self forType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED];
	[mSubviews setObject:subview forKey:key];
    
    // Current: v1.1
    if ([key isEqualToString:@"UpdatePreview"]) {
        ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
        
        // Add potion
        SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:[Potion potencyPotion] size:GuiSizeMed scene:mScene];
        potionSprite.x = 81 + offset.x;
        potionSprite.y = 80 + offset.y;
        [subview.currentPage addChild:potionSprite];        
    }
	
	return subview;
}

- (BookletSubview *)bookletSubviewForKey:(NSString *)key {
	BookletSubview *subview = (BookletSubview *)[mSubviews objectForKey:key];
	
	if (subview == nil) {
		subview = [self loadBookletSubviewForKey:key];
		[subview enablePageSwipe];
		[mSubviews setObject:subview forKey:key];
	}
	return subview;
}

- (void)onBookletPageTurned:(SPEvent *)event {
	BookletSubview *subview = (BookletSubview *)event.currentTarget;
	MenuDetailView *page = [mViewParser parseSubviewByName:@"Pages" forViewName:subview.bookKey index:subview.pageIndex];
	subview.currentPage = page;
}

@end
