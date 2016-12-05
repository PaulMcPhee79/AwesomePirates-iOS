//
//  GameSummary.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 28/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_GAME_SUMMARY_RETRY @"gameSummaryRetryEvent"
#define CUST_EVENT_TYPE_GAME_SUMMARY_MENU @"gameSummaryMenuEvent"
#define CUST_EVENT_TYPE_GAME_SUMMARY_SUBMIT @"gameSummarySubmitEvent"

@interface GameSummary : Prop {
    SPButton *mRetryButton;
    SPButton *mMenuButton;
    SPButton *mSubmitButton;
    SPSprite *mCanvasSprite;
    
    NSMutableDictionary *mButtons;
    
@private
    SPTextField *mScoreText;
    SPTextField *mAccuracyText;
    SPTextField *mPlankingsText;
    SPTextField *mDaysAtSeaText;
    
    SPSprite *mBestSprite;
    SPSprite *mScoreSprite;
    SPSprite *mStatsSprite;
    SPSprite *mDeathSprite;
}

@property (nonatomic,readonly) float stampsDelay;

- (void)addMenuButtons;
- (void)enableMenuButton:(BOOL)enable forKey:(NSString *)key;
- (void)setMenuButtonHidden:(BOOL)hidden forKey:(NSString *)key;
- (void)displaySummaryScroll;
- (void)hideSummaryScroll;
- (float)displayGameOverSequence;
- (float)displayStamps;
- (void)onStamping:(SPEvent *)event;
- (void)onStamped:(SPEvent *)event;
- (void)destroy;

@end
