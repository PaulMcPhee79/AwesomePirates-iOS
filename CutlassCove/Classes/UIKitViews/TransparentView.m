//
//  TransparentView.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransparentView.h"


@implementation TransparentView

// Both methods should pass through events to Sparrow.

#if 0
- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	id hitView = [super hitTest:point withEvent:event];
	
	if (hitView == self)
		return nil;
	else
		return hitView;
}

#else 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesEnded:touches withEvent:event];
}

#endif

@end
