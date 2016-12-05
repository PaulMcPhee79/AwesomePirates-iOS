//
//  SPTextureAtlas_Extension.h
//  Pirates
//
//  Created by Paul McPhee on 25/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTextureAtlas.h"


@interface SPTextureAtlas (Extension)

@property (nonatomic,retain) SPTexture *atlasTexture;
@property (nonatomic,readonly) NSDictionary *textureRegions;

@end
