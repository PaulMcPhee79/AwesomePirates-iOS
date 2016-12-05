//
//  SceneView.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AchievementManager.h"
#import "AchievementPanel.h"
#import "ViewParser.h"
#import "GameCoder.h"
#import "Hud.h"

@interface SceneView : SPEventDispatcher {
	Hud *mHud;
	AchievementPanel *mAchievementPanel;
}

@property (nonatomic,readonly) Hud *hud;
@property (nonatomic,readonly) AchievementPanel *achievementPanel;

- (void)setupView;
- (void)loadViewState:(GameCoder *)coder;
- (void)saveViewState:(GameCoder *)coder;
- (void)attachEventListeners;
- (void)detachEventListeners;
- (void)moveAchievementPanelToCategory:(int)category;
- (void)flip:(BOOL)enable;
- (void)advanceTime:(double)time;

@end
