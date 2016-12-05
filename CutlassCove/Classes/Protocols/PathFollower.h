//
//  PathFollower.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 17/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Destination.h"

@protocol PathFollower

@property (nonatomic,assign) BOOL isCollidable;
@property (nonatomic,retain) Destination *destination;

- (void)dock;

@end
