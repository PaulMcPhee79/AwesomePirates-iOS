//
//  SpeedboatSummary.h
//  CutlassCove
//
//  Created by Paul McPhee on 9/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameSummary.h"

@interface SpeedboatSummary : GameSummary {
@private
    SPTextField *mSpeedText;
    NSArray *mLaps;
    
    SPSprite *mSpeedboatSprite;
    SPSprite *mLapsSprite;
}

@end
