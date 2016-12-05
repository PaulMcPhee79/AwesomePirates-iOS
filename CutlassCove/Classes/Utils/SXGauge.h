#import <Foundation/Foundation.h>
#import "Sparrow.h"

typedef enum {
    SXGaugeHorizontal = 0,
    SXGaugeVertical
} SXGaugeOrientation;

/// An SXGauge displays a texture, trimmed to its left side, depending on a ratio. 
/// This can be used to display a progress bar or a time gauge.
@interface SXGauge : SPSprite 
{
  @private
    SXGaugeOrientation mOrientation;
    SPImage *mImage;
    float mRatio;
}

/// Indicates how much of the texture is displayed. Range: 0.0f - 1.0f
@property (nonatomic,assign) float ratio;
@property (nonatomic,assign) uint color;

/// Initializes a gauge with a certain texture
- (id)initWithTexture:(SPTexture*)texture orientation:(SXGaugeOrientation)orientation;

- (void)setTexture:(SPTexture *)texture;

/// Factory method.
+ (SXGauge *)gaugeWithTexture:(SPTexture *)texture orientation:(SXGaugeOrientation)orientation;

@end