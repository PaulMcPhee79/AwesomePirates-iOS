

#ifndef BOX2D_UTILS_H
#define BOX2D_UTILS_H

#import <math.h>
#import <Box2D/Box2D.h>
#import "FastMath.h"

class Box2DUtils {
public:
	static void rotateVector(b2Vec2 &v, float32 angle) {
		float32 cosAngle = cosf(angle), sinAngle = sinf(angle);
	
		float32 x = cosAngle * v.x - sinAngle * v.y;
		v.y = sinAngle * v.x + cosAngle * v.y;
		v.x = x;
	}
	
	static float32 signedAngle(b2Vec2 &v1, b2Vec2 &v2) {
		return FastMath::fastAtan2(b2Cross(v1, v2), b2Dot(v1, v2));  //atan2f(b2Cross(v1, v2), b2Dot(v1, v2));
	}
};

#endif
