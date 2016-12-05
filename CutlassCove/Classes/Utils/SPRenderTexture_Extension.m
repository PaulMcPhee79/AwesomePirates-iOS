//
//  SPRenderTexture_Extension.m
//  CutlassCove
//
//  Created by Paul McPhee on 3/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPRenderTexture_Extension.h"

@implementation SPRenderTexture (Extension)

void releaseRawImageDataBufferCallback(void *info, const void *data, size_t size)
{
	free((void*)data);
}

- (UIImage*)renderToImage
{
	__block UIImage *image = nil;
    
	[self bundleDrawCalls:^() {
		float scale = [SPStage contentScaleFactor];
		int width = scale * self.width;
		int height = scale * self.height;
		int nrOfColorComponents = 4; //RGBA
		int bitsPerColorComponent = 8;
		int rawImageDataLength = width * height * nrOfColorComponents;
		GLenum pixelDataFormat = GL_RGBA;
		GLenum pixelDataType = GL_UNSIGNED_BYTE;
		BOOL interpolateAndSmoothPixels = NO;
		CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
		CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        
		CGDataProviderRef dataProviderRef;
		CGColorSpaceRef colorSpaceRef;
		CGImageRef imageRef;
        
		@try {
			GLubyte *rawImageDataBuffer = (GLubyte *) malloc(rawImageDataLength);
            
			glReadPixels(0, 0, width, height, pixelDataFormat, pixelDataType, rawImageDataBuffer);
            
			dataProviderRef = CGDataProviderCreateWithData(NULL, rawImageDataBuffer, rawImageDataLength, releaseRawImageDataBufferCallback);
			colorSpaceRef = CGColorSpaceCreateDeviceRGB();
			imageRef = CGImageCreate(width, height, bitsPerColorComponent, bitsPerColorComponent * nrOfColorComponents, width * nrOfColorComponents, colorSpaceRef, bitmapInfo, dataProviderRef, NULL, interpolateAndSmoothPixels, renderingIntent);
			image = [UIImage imageWithCGImage:imageRef];
		}
		@finally {
			CGDataProviderRelease(dataProviderRef);
			CGColorSpaceRelease(colorSpaceRef);
			CGImageRelease(imageRef);
		}
	}];
    
	return image;
}

@end
