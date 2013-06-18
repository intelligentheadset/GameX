///
///  @file GNMath.h
///
///  Created by Martin Lobger on 24/09/12.
///  Copyright (c) 2012 GN. All rights reserved.
///

#ifndef GNMath_h
#define GNMath_h

/**
 PI devided by 180 (PI/180)
 */
#define M_PI_180                         0.01745329251994329576923690768488611 // M_PI / 180.0

/**
 180 devided by PI (180/PI)
 */
#define M_180_PI                        57.29577951308232087679815481410517041 // 180.0 / M_PI

/**
 Two time PI (2*PI)
 */
#define M_2PI                            6.28318530717958647692528676655900576 // 2 * M_PI

/**
 Convert degrees to radians
 */
#define DEGREES_TO_RADIANS(degrees)     ((degrees) * M_PI_180)

/**
 Convert radians to degrees
 */
#define RADIANS_TO_DEGREES(radians)     ((radians) * M_180_PI)


/// @cond INTERNAL
#define copysign(x,y)       (((y) < 0.0) ? -fabs(x) : fabs(x))
#define NGT1(x)             (fabs(x) > 1.0 ? copysign(1.0, x) : (x))
#define ArcCos(x)           (fabs(x) > 1 ? NAN : acos(x))
#define hav(x)              ((1.0 - cos(x)) * 0.5)              /* haversine */
#define ahav(x)             (ArcCos(NGT1(1.0 - ((x) * 2.0))))   /* arc haversine */
#define sec(x)              (1.0 / cos(x))                      /* secant */
#define csc(x)              (1.0 / sin(x))                      /* cosecant */
/// @endcond

/**
 @brief     Generate a random number between min and max.
 @param min Lower bound of the randum number generated.
 @param max Upper bound of the randum number generated.
 */
double frand(double min, double max);


#endif
