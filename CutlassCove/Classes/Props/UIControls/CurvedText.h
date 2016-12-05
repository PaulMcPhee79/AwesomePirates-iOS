//
//  CurvedText.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

typedef enum {
	CurvedTextCW = 0,
	CurvedTextACW
} CurvedTextOrientation;

@interface CurvedText : Prop {
    BOOL mCompiled;
	uint mNumChars;
	uint mColor;
	CurvedTextOrientation mOrientation;
	float mOriginX;
	float mFontSize;
	float mRadius;
	float mMaxTextSeparation;
	NSString *mText;
	NSMutableArray *mChars;
}

@property (nonatomic,assign) BOOL compiled;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) uint color;
@property (nonatomic,assign) float originX;
@property (nonatomic,assign) float radius;
@property (nonatomic,assign) float maxTextSeparation;
@property (nonatomic,assign) CurvedTextOrientation orientation;

- (id)initWithCategory:(int)category fontSize:(float)fontSize maxLength:(uint)maxLength;


@end
