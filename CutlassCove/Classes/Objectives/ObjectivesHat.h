//
//  ObjectivesHat.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class CurvedText;

typedef enum {
    ObjHatStraight = 0,
    ObjHatAngled
} ObjectivesHatType;

@interface ObjectivesHat : Prop {
    ObjectivesHatType mHatType;
    SPImage *mHatImage;
    CurvedText *mHatText;
    SPSprite *mHatTextSprite;
    SPSprite *mHatSprite;
}

- (id)initWithCategory:(int)category hatType:(ObjectivesHatType)hatType text:(NSString *)text;
- (id)initWithCategory:(int)category text:(NSString *)text;
- (void)setText:(NSString *)text;
- (void)setTextColor:(uint)color;

@end
