//
//  SPButton_Extension.h
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPButton.h"

@interface SPButton (Extension)

@property (nonatomic,readonly) SPImage *backgroundImage;
@property (nonatomic,readonly) SPSprite *contents;
@property (nonatomic,readonly) BOOL isDown;

- (void)addTouchQuadWithWidth:(float)width height:(float)height;

@end
