//
//  Hint.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 26/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface Hint : Prop {
    SPPoint *mPrevPos;
    SPDisplayObject *mTarget;
}

@property (nonatomic,retain) SPDisplayObject *target;

- (id)initWithCategory:(int)category location:(SPPoint *)location;
- (id)initWithCategory:(int)category location:(SPPoint *)location target:(SPDisplayObject *)target;

+ (Hint *)hintWithCategory:(int)category location:(SPPoint *)location;
+ (Hint *)hintWithCategory:(int)category location:(SPPoint *)location target:(SPDisplayObject *)target;

@end
