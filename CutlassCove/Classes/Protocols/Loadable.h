//
//  Loadable.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Loadable

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys;

@end
