//
//  SPEventDispatcher_Extension.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEventDispatcher.h"

@interface SPEventDispatcher (Extension)

@property (nonatomic,readonly) NSMutableDictionary *eventListeners;

@end
