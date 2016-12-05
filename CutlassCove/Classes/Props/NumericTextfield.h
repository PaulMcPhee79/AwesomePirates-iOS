//
//  NumericTextfield.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface NumericTextfield : Prop {
	uint mMaxChars;
	NSMutableArray *mChars;
}

- (void)positionAtX:(float)x y:(float)y;
- (void)centerOnX:(float)x y:(float)y;

@end
