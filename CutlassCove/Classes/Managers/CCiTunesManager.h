//
//  CCiTunesManager.h
//  CutlassCove
//
//  Created by Paul McPhee on 27/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UPRAccepted = 0,
    UPRRefused,
    UPRPostponed
} UserPromptResponse;

@interface CCiTunesManager : NSObject {
    BOOL isBusy;
    NSURL *iTunesURL;
}

@property (nonatomic,readonly) NSInteger appId;
@property (nonatomic,readonly) NSString *reviewURL;

- (BOOL)shouldPromptForRating;
- (void)userRespondedToPrompt:(UserPromptResponse)response;
- (void)openFullVersionURL;

@end
