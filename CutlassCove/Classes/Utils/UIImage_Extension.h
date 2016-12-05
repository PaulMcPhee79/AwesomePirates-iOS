//
//  UIImage_Extension.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Extension)

+ (UIImage *)scale_CHEEKY:(UIImage *)image toSize:(CGSize)size;
- (UIColor *)colorAtPixel_CHEEKY:(CGPoint)point;

@end
