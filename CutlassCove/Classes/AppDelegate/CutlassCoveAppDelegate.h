//
//  CutlassCoveAppDelegate.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/01/11.
//  Copyright Cheeky Mammoth 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CutlassCoveViewController,Game;

@interface CutlassCoveAppDelegate : UIResponder <UIApplicationDelegate> 
{
    //UIWindow *window;
	Game *mGame;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CutlassCoveViewController *viewController;

@end
