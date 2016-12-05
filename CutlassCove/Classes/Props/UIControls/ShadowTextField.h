//
//  ShadowTextField.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface ShadowTextField : Prop {
	SPTextField *mTextField;
	SPTextField *mDropShadow;
}

@property (nonatomic,assign) uint fontColor;
@property (nonatomic,assign) uint shadowColor;
@property (nonatomic,copy) NSString *text;

- (id)initWithCategory:(int)category width:(float)width height:(float)height fontSize:(float)fontSize;
- (void)dropShadowOffsetX:(float)x y:(float)y;

@end
