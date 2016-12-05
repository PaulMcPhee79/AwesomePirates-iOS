//
//  MenuView.h
//  CutlassCove
//
//  Created by Paul McPhee on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_IN @"menuViewDidTransitionIn"
#define CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_OUT @"menuViewDidTransitionOut"
#define CUST_EVENT_TYPE_MENU_VIEW_WAS_TOUCHED_TO_PLAY @"menuViewWasTouchedToPlay"

@class BookletSubview,MenuButton,MenuController,ObjectivesLog,TitleSubview,ViewParser,PotionView;

@interface MenuView : Prop {
    // View
    MenuButton *mCloseSubviewButton;
    TitleSubview *mMenuSubview;
    ObjectivesLog *mObjectivesLog;
    SPSprite *mCanvas;
    ViewParser *mViewParser;
    
    // Potions
    PotionView *mPotionView;
    
    // Model
    NSMutableDictionary *mSubviews;
	NSMutableArray *mSubviewStack;
    MenuController *mController; // Weak reference
}

@property (nonatomic,readonly) TitleSubview *currentSubview;
@property (nonatomic,readonly) BOOL potionWasSelected;

- (id)initWithCategory:(int)category controller:(MenuController *)controller;

- (void)attachEventListeners;
- (void)detachEventListeners;

- (void)transitionInOverTime:(float)duration;
- (void)transitionOutOverTime:(float)duration;

- (void)updateHiScoreText:(NSString *)text;
- (void)updateObjectivesLog;

- (TitleSubview *)subviewForKey:(NSString *)key;
- (BookletSubview *)bookletSubviewForKey:(NSString *)key;
- (void)pushSubviewForKey:(NSString *)key;
- (void)popSubview;
- (void)popAllSubviews;
- (void)destroySubviewForKey:(NSString *)key;

- (void)setSwitch:(NSString *)name value:(BOOL)value;

- (void)setAlertTitle:(NSString *)title text:(NSString *)text;
- (void)setQueryTitle:(NSString *)title text:(NSString *)text;

- (void)hidePotionsButton:(BOOL)hide;
- (void)populatePotionView;
- (void)unpopulatePotionView;
- (void)selectCurrentPotion;

@end
