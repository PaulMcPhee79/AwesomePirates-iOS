/*
 *  Poly.h
 *  xyzCCTestingxyz
 *
 *  Created by Paul McPhee on 3/07/11.
 *  Copyright 2011 Cheeky Mammoth. All rights reserved.
 *
 */

int pointInPoly(int numVertices, float *xp, float *yp, float x, float y);

int pointInPoly(int numVertices, float *xp, float *yp, float x, float y) {
	int i, j, c = 0;
	
	for (i = 0, j = numVertices-1; i < numVertices; j = i++) {
		if ((((yp[i] <= y) && (y < yp[j])) ||
			 ((yp[j] <= y) && (y < yp[i]))) &&
			(x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
			c = !c;
	}
	return c;
}

