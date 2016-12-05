//
//  CutlassCoveViewController.m
//  CutlassCove
//
//  Created by Paul McPhee on 8/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CutlassCoveViewController.h"
#import "GameController.h"

@interface CutlassCoveViewController ()


@end


@implementation CutlassCoveViewController

@synthesize isShowingGCLeaderboard = mShowingGCLeaderboard;
@synthesize leaderboardCategory = mLeaderboardCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mShowingGCLeaderboard = NO;
        mLeaderboardCategory = [CC_GAME_MODE_DEFAULT copy];
        mLastTimeScope = GKLeaderboardTimeScopeAllTime;
        mGKLeaderboardVC = nil;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    }
    return self;
}

- (SPView *)sparrowView {
    return (SPView *)self.view;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    if (mShowingGCLeaderboard == NO)
        [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [self destroyGameCenterLeaderboard:^(void) {
        [GCTRL startSparrow];
    }];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)destroyGameCenterLeaderboard:(void (^)(void))onDestroyed {
    if (self.isShowingGCLeaderboard) {
        [self dismissViewControllerAnimated:YES completion:^(void) {
            mShowingGCLeaderboard = NO;
            if (onDestroyed)
                onDestroyed();
        }];
    }
    
    [mGKLeaderboardVC autorelease]; mGKLeaderboardVC = nil;
}

- (void)showGameCenterLeaderboardForCategory:(NSString *)category {
    if (mShowingGCLeaderboard)
        return;
    
//    [self destroyGameCenterLeaderboard:nil];
//    mShowingGCLeaderboard = YES;
//    
//    if (category)
//        self.leaderboardCategory = category;
//    NSString *lbCategory = self.leaderboardCategory;
//    if (lbCategory == nil)
//        lbCategory = CC_GAME_MODE_DEFAULT;
//    
//    mGKLeaderboardVC = [[GKLeaderboardViewController alloc] init];
//    mGKLeaderboardVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    mGKLeaderboardVC.leaderboardDelegate = self;
//    mGKLeaderboardVC.category = lbCategory;
//    mGKLeaderboardVC.timeScope = mLastTimeScope;
//    [self.sparrowView stop];
//    [self presentViewController:mGKLeaderboardVC animated:YES completion:nil];
    
    // Note: Above commented out because GKLeaderboard leaks, so we reuse it.
    mShowingGCLeaderboard = YES;
    
    if (category)
        self.leaderboardCategory = category;
    NSString *lbCategory = self.leaderboardCategory;
    if (lbCategory == nil)
        lbCategory = CC_GAME_MODE_DEFAULT;
    
    if (mGKLeaderboardVC == nil) {
        mGKLeaderboardVC = [[GKLeaderboardViewController alloc] init];
        
        if (mGKLeaderboardVC) {
            mGKLeaderboardVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            mGKLeaderboardVC.leaderboardDelegate = self;
            mGKLeaderboardVC.category = lbCategory;
            mGKLeaderboardVC.timeScope = mLastTimeScope;
        }
    }
    
    if (mGKLeaderboardVC) {
        [self.sparrowView stop];
        [self presentViewController:mGKLeaderboardVC animated:YES completion:nil];
        //[self presentModalViewController:mGKLeaderboardVC animated:YES]; // deprecated
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    self.leaderboardCategory = viewController.category;
    mLastTimeScope = viewController.timeScope;
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //[mGKLeaderboardVC autorelease]; mGKLeaderboardVC = nil;
        mShowingGCLeaderboard = NO;
        [GCTRL startSparrow];
    }];
}

//- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"Sub-viewcontroller WILL APPEAR!!!");
//    [super viewWillAppear:animated];
//}

@end
