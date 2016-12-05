//
//  SPTextureAtlas_Extension.m
//  Pirates
//
//  Created by Paul McPhee on 25/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPTextureAtlas_Extension.h"

const float kMaxRegionWidth = 128.0f;
const float kMaxRegionHeight = 128.0f;

@implementation SPTextureAtlas (Extension)

- (SPTexture *)atlasTexture {
	return mAtlasTexture;
}

- (void)setAtlasTexture:(SPTexture *)texture {
	if (mAtlasTexture != texture) {
		[mAtlasTexture autorelease];
		mAtlasTexture = [texture retain];
	}
}

- (NSDictionary *)textureRegions {
	return mTextureRegions;
}

@end
