//
//  ResourceClient.h
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResourceClient

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target;

@end
