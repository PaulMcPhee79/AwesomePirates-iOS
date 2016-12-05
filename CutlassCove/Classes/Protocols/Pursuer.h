//
//  Pursuer.h
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShipActor;

@protocol Pursuer

- (void)pursueeDestroyed:(ShipActor *)pursuee;

@end
