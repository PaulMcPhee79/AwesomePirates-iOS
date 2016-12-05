//
//  SPTween_Extension.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: Don't use this extension if you don't understand how it can fail!
@interface SPTween (Extension)

- (void)commitProperties;
- (void)resetProperties;

@end
