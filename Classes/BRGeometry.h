//
//  BRGeometry.h
//  Sun Tracker
//
//  Created by Julien Ducret on 30/01/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#ifndef SunTracker_BRGeometry_h
#define SunTracker_BRGeometry_h

#import <CoreMotion/CoreMotion.h>

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

#define     ANIMATION_SPEED                 320.0f      // (In pixels per second)
#define     MOTION_UPDATE_INTERVAL          1.0f/60.0f  // Frequency of motion sampling
#define     LOCKING_DISTANCE                20.0        // Minimal screen distance to lock the sun in the center of the screen
#define     UNLOCKING_DISTANCE              80.0        // Minimal screen distance to release the sun for the center of the screen

typedef struct {
    CGFloat azimuth;
    CGFloat elevation;
} BRSunSphericalPosition;

typedef struct {
    CGFloat x;
    CGFloat y;
    CGFloat z;
} BRSunTrackingVector;

static inline CGPoint
CGPointDifference(CGPoint a, CGPoint b){
    CGPoint p; p.x = a.x-b.x; p.y = a.y-b.y; return p;
}

static inline double
CGPointDistanceSquared(CGPoint a, CGPoint b){
    return pow((a.x - b.x), 2.0) + pow((a.y - b.y), 2.0);
}

static inline double
CGPointDistance(CGPoint a, CGPoint b){
    return sqrt(CGPointDistanceSquared(a, b));
}

typedef float mat4f_t[16];	// 4x4 matrix in column major order
typedef float vec4f_t[4];	// 4D vector
typedef float vec3f_t[3];   // 3D vector

// Structures and functions implemented below are taken from the Apple augmented reality sample code pARk
// https://developer.apple.com/library/ios/samplecode/pARk/Introduction/Intro.html

void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);

#endif