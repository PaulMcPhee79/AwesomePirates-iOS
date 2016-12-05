#import "SXGauge.h"

@implementation SXGauge

@synthesize ratio = mRatio;
@dynamic color;

- (id)initWithTexture:(SPTexture*)texture orientation:(SXGaugeOrientation)orientation
{
    if ((self = [super init]))
    {
        mRatio = 1.0f;
        mOrientation = orientation;
        mImage = [SPImage imageWithTexture:texture];
        [self addChild:mImage];
    }
    return self;
}

- (id)init
{
    return [self initWithTexture:[SPTexture emptyTexture] orientation:SXGaugeHorizontal];
}

- (uint)color {
	return mImage.color;
}

- (void)setColor:(uint)value {
	mImage.color = value;
}

- (void)setTexture:(SPTexture *)texture {
    mImage.texture = texture;
}

- (void)update
{
    if (mOrientation == SXGaugeHorizontal) {
        mImage.scaleX = mRatio;
        [mImage setTexCoords:[SPPoint pointWithX:mRatio y:0.0f] ofVertex:1];
        [mImage setTexCoords:[SPPoint pointWithX:mRatio y:1.0f] ofVertex:3];
    } else {
        mImage.scaleY = 1;
        
        float maxHeight = mImage.height;
        mImage.scaleY = mRatio;
        mImage.y = (maxHeight - mImage.height);
        
        [mImage setTexCoords:[SPPoint pointWithX:0.0f y:1.0f-mRatio] ofVertex:0];
        [mImage setTexCoords:[SPPoint pointWithX:1.0f y:1.0f-mRatio] ofVertex:1];
    }
}

- (void)setRatio:(float)value
{
    mRatio = MAX(0.0f, MIN(1.0f, value));
    [self update];
}

+ (SXGauge *)gaugeWithTexture:(SPTexture *)texture orientation:(SXGaugeOrientation)orientation
{
    return [[[SXGauge alloc] initWithTexture:texture orientation:orientation] autorelease];
}

@end