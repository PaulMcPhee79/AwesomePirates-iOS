//
//  CutlassCoveViewController.h
//  CutlassCove
//
//  Created by Paul McPhee on 8/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GKLeaderboardViewController.h>

@interface CutlassCoveViewController : UIViewController <GKLeaderboardViewControllerDelegate> {
    BOOL mShowingGCLeaderboard;
    
    NSString *mLeaderboardCategory;
    GKLeaderboardTimeScope mLastTimeScope;
    GKLeaderboardViewController *mGKLeaderboardVC;
}

@property (nonatomic,readonly) BOOL isShowingGCLeaderboard;
@property (nonatomic, copy) NSString *leaderboardCategory;
@property (nonatomic,readonly) SPView *sparrowView;

- (void)showGameCenterLeaderboardForCategory:(NSString *)category;
- (void)destroyGameCenterLeaderboard:(void (^)(void))onDestroyed;

@end
