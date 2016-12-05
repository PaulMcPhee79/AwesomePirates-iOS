//
//  SPView+ShareGroup.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 10/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "SPView+ShareGroup.h"


@implementation SPView (ShareGroup)

- (EAGLContext *)shareGroupContext
{
	return [[[EAGLContext alloc] initWithAPI:[mContext API] sharegroup:[mContext sharegroup]] autorelease];
}

@end
