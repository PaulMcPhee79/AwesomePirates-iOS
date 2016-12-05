//
//  CCiTunesManager.m
//  CutlassCove
//
//  Created by Paul McPhee on 27/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCiTunesManager.h"
#import "GameSettings.h"
#import "ObjectivesManager.h"
#import "GameController.h"


//#ifdef CHEEKY_LITE_VERSION
//    #define kReviewAppURLString @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=505947630"
//#else
//    #define kReviewAppURLString @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=478268662"
//#endif

//#define kReviewAppURLString @"http://itunes.apple.com/app/id478268662"

#define kReviewAppURLString @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=478268662"
#define kReviewAppURLString_7_0 @"itms-apps://itunes.apple.com/app/id478268662"
#define kFullVersionURLString  @"itms-apps://itunes.apple.com/app/id478268662?mt=8"
#define kAppId 478268662


@interface CCiTunesManager ()

@property (nonatomic,retain) NSURL *iTunesURL;

- (void)openReferralURL:(NSURL *)referralURL;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end


@implementation CCiTunesManager

@synthesize iTunesURL;

- (id)init {
    if (self = [super init]) {
        isBusy = NO;
        iTunesURL = nil;
    }
    return self;
}

- (void)dealloc {
    self.iTunesURL = nil;
    [super dealloc];
}

- (NSInteger)appId {
    return 478268662;
}

- (NSString *)reviewURL {
    if ([ResManager isOSFeatureSupported:@"7.0"])
        return kReviewAppURLString_7_0;
    else
        return kReviewAppURLString;
}

- (BOOL)shouldPromptForRating {
    GameController *gc = GCTRL;
    BOOL shouldPrompt = YES;
    
    shouldPrompt = (shouldPrompt && gc.objectivesManager.rank >= 1);
    //shouldPrompt = (shouldPrompt && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_WILL_RATE_GAME]); // We no longer give the option to never rate.
    shouldPrompt = (shouldPrompt && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DID_RATE_GAME] == NO);
    shouldPrompt = (shouldPrompt && [gc.gameSettings hasAlarmExpiredForKey:GAME_SETTINGS_KEY_RATING_PROMPT_ALARM]);
    
    return shouldPrompt;
}

- (void)userRespondedToPrompt:(UserPromptResponse)response {
    GameController *gc = GCTRL;
    
    switch (response) {
        case UPRAccepted:
            [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_DID_RATE_GAME value:YES];
            break;
        case UPRRefused:
            [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_WILL_RATE_GAME value:NO];
            break;
        case UPRPostponed:
        {
            int numPostpones = [gc.gameSettings valueForKey:GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION];
            numPostpones = MIN(numPostpones, 24);
            double alarmDelay = (numPostpones == 0 ? 20 : numPostpones * 60) * 60;
            [gc.gameSettings setTime:(double)CFAbsoluteTimeGetCurrent() + alarmDelay forKey:GAME_SETTINGS_KEY_RATING_PROMPT_ALARM];
        }
            break;
        default:
            assert(0);
            break;
    }
    
    [gc.gameSettings setValue:[gc.gameSettings valueForKey:GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION]+1 forKey:GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION];
    [gc.gameSettings saveSettings];
}

- (void)openFullVersionURL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFullVersionURLString]];
}

- (void)openReferralURL:(NSURL *)referralURL {
    isBusy = YES;
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    [conn release];
}

// Save the most recent URL in case multiple redirects occur
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.iTunesURL = [response URL];
    
    if ([self.iTunesURL.host hasSuffix:@"itunes.apple.com"]) {
        [connection cancel];
        [self connectionDidFinishLoading:connection];
        return nil;
    } else {
        return request;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] openURL:self.iTunesURL];
    isBusy = NO;
}

@end
