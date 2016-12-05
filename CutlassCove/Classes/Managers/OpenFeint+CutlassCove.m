//
//  OpenFeint+CutlassCove.m
//  CutlassCove
//
//  Created by Paul McPhee on 4/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenFeint+CutlassCove.h"
#import "OpenFeint/OpenFeint+Private.h"

@implementation OpenFeint (CutlassCove)

+ (void)disableOFGameCenter {
#if CC_OF_ENABLED
    OpenFeint* instance = [OpenFeint sharedInstance];
    instance->mIsUsingGameCenter = NO;
#endif
}

@end
