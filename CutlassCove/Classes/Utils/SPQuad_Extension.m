//
//  SPQuad_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPQuad_Extension.h"


@implementation SPQuad (Extension)

@dynamic vertexColors,vertexCoords;

- (uint *)vertexColors {
	return mVertexColors;
}

- (float *)vertexCoords {
	return mVertexCoords;
}

@end
