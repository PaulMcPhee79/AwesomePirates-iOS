//
//  Ignitable.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 23/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Ignitable

@property (nonatomic,readonly) BOOL ignited;

- (void)ignite;

@end
