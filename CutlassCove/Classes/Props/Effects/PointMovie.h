//
//  PointMovie.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "ResourceClient.h"

typedef enum {
	MovieTypeSplash = 0,
	MovieTypeExplosion,
	MovieTypeCannonFire
} PointMovieType;

@interface PointMovie : Prop <ResourceClient> {
	NSString *mResourceKey;
	SPMovieClip *mMovie;
	ResourceServer *mResources;
}

@property (nonatomic,assign) BOOL loop;

+ (PointMovie *)pointMovieWithType:(int)movieType x:(float)x y:(float)y;
- (id)initWithCategory:(int)category type:(PointMovieType)movieType x:(float)x y:(float)y;
- (void)setupMovie;

+ (NSString *)resourceKeyForType:(int)movieType;

@end
