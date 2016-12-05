//
//  CutlassCoveAppDelegate.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/01/11.
//  Copyright Cheeky Mammoth 2011. All rights reserved.
//

#import "CutlassCoveAppDelegate.h"
#import "CutlassCoveViewController.h"
#import "CCOFManager.h"
#import "Game.h"
#import "CCMiscConstants.h"
#import "Sparrow.h"
#import "SPNSExtensions.h"
#import "GameController.h"
#import "GameSettings.h"
#import "PersistenceManager.h"

//#define CC_OF_DISTRIBUTION


#ifdef CHEEKY_LITE_VERSION
    #define CC_OF_PRODUCT_KEY @"L1Dq9jH5k6nrPPtNw7wcQ"
    #define CC_OF_PRODUCT_SECRET @"Qyjl9Bi76ceJGpA6y70ntheLqT75eetIhMuKGgFOra8"
    #define CC_OF_SHORT_DISPLAY_NAME @"C. Cove Lite"
    #define CC_OF_DISPLAY_NAME @"Cutlass Cove Lite"
#else
    #define CC_OF_PRODUCT_KEY @"T97BeYsaMcFheQAsP4eQw"
    #define CC_OF_PRODUCT_SECRET @"D2h8cn1VLhGjYayczRZ0GFNdIbAScELqwxfHtuJ8Q"
    #define CC_OF_SHORT_DISPLAY_NAME @"Cutlass Cove"
    #define CC_OF_DISPLAY_NAME @"Cutlass Cove"
#endif

// --- c functions ---

void onUncaughtException(NSException *exception) {
	NSLog(@"uncaught exception: %@", exception.description);
}

// ---

@interface CutlassCoveAppDelegate ()

- (void)commonInitForApplication:(UIApplication *)application;

@end


@implementation CutlassCoveAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [mGame release];
    [SPAudioEngine stop];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)commonInitForApplication:(UIApplication *)application {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    //
    
    BOOL isRetina4Inch = NO;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.viewController = [[[CutlassCoveViewController alloc] initWithNibName:@"CutlassCoveViewController_iPad" bundle:nil] autorelease];
    else
    {
        isRetina4Inch = [UIScreen mainScreen].bounds.size.height == 568;
        
        if (isRetina4Inch)
            self.viewController = [[[CutlassCoveViewController alloc] initWithNibName:@"CutlassCoveViewController_iPhone-568h" bundle:nil] autorelease];
        else
            self.viewController = [[[CutlassCoveViewController alloc] initWithNibName:@"CutlassCoveViewController_iPhone" bundle:nil] autorelease];
    }
    
    SP_CREATE_POOL(pool);
    
    [RESM setIsRetina4Inch:isRetina4Inch];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    [SPAudioEngine start:SPAudioSessionCategory_AmbientSound];
    [SPStage setSupportHighResolutions:YES]; // use the provided hd textures on suitable hardware
	
	// This is for using HD textures (960x640) on iPad even though it is an iPhone-only app
	//if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location == 0)
	//	[SPStage setContentScaleFactor:2.0f];
    
    NSString *reqSysVer = @"4.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported)
        self.window.rootViewController = self.viewController;
    else
        [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
    
    float gameWidth, gameHeight;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[SPStage setContentScaleFactor:2.0f];
		[RESM setIsRetina:NO];
		[RESM setIsIpadDevice:YES];
        gameWidth = 512;
		gameHeight = 384;
	} else {
		[RESM setIsRetina:(SP_IS_FLOAT_EQUAL([SPStage contentScaleFactor],2))];
		[RESM setIsIpadDevice:NO];
        NSLog(@"ContentScaleFactor: %f", [SPStage contentScaleFactor]);
        NSLog(@"Screen bounds: %@", NSStringFromCGRect([UIScreen mainScreen].bounds));
        gameWidth = isRetina4Inch ? 568 : 480;
		gameHeight = 320;
	}
    
    // Splash Screen
    UIImage *splashImage = [UIImage imageWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:((RESM.isIpadDevice) ? @"Default-Portrait" : (isRetina4Inch) ? @"Splash-568h@2x" : @"Default") ofType:@"png"]];
    
    if (splashImage) {
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:splashImage] autorelease];
        imageView.tag = SPLASH_VIEW_TAG;
        [self.viewController.view addSubview:imageView];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        imageView.center = CGPointMake(screenBounds.size.height / 2, screenBounds.size.width / 2);
        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(SP_D2R(-90));
        imageView.transform = rotateTransform;
    }
    
    // SPView
    SPView *sparrowView = self.viewController.sparrowView;
    CCOFManager *ofDelegate = [[[CCOFManager alloc] init] autorelease];
    mGame = [[Game alloc] initWithWidth:gameWidth height:gameHeight];
    sparrowView.stage = mGame;
    sparrowView.multipleTouchEnabled = YES;
    
    float fps = [RESM recommendedFps];
    NSLog(@"Recommended FPS: %f", fps);
    
    sparrowView.frameRate = fps;
    [sparrowView start];
    [mGame setupWithViewController:self.viewController ofDelegate:ofDelegate];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    SP_RELEASE_POOL(pool);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [self commonInitForApplication:application];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self commonInitForApplication:application];
    
    // Attempt to enable iCloud.
    if ([GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_CLOUD_APPROVED]) {
        [PersistenceManager PM].isCloudApproved = YES;
        [[PersistenceManager PM] enableCloud];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {   
    [GCTRL stopSparrow];
    [[PersistenceManager PM] applicationWillResignActive];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    GCTRL.isAppActive = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    GCTRL.isAppActive = YES;
    [GCTRL startSparrow];
    
	[mGame pausePirates];
    [[PersistenceManager PM] applicationDidBecomeActive];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return (NSUInteger)[application supportedInterfaceOrientationsForWindow:window] | (1<<UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutoRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[mGame propagateMemoryWarning];
	NSLog(@" ----------------------------------- ");
	NSLog(@"---- DID RECEIVE MEMORY WARNING! ----");
	NSLog(@" ----------------------------------- ");
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[mGame applicationWillTerminate];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", [NSString stringWithFormat:@"Failed to register for remote notifications with error: %@", [error localizedDescription]]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

}

@end
