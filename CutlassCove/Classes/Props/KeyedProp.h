//
//  KeyedProp.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface KeyedProp : Prop {
    NSMutableDictionary *mChildDictionary;
}

@property (nonatomic,readonly) NSArray *allChildKeys;

- (SPDisplayObject *)childForKey:(NSString *)key;
- (void)addChild:(SPDisplayObject *)child forKey:(NSString *)key;
- (void)removeChild:(SPDisplayObject *)child forKey:(NSString *)key;

@end
