//
//  CLLocation+GNDistance.m
//
//  Created by Martin Lobger on 24/09/12.
//  Copyright (c) 2012 GN. All rights reserved.
//

#import "CLLocation+GNDistance.h"
#import "GNMath.h"

@implementation GNDistanceAndDirection

- (id)initWithDistance:(CLLocationDistance)distance andDirection:(CLLocationDirection)direction {
    self = [super init];
    if (self) {
        _distance = distance;
        _direction = direction;
    }
    
    return self;
}

- (id)init {
    return [self initWithDistance:DISTANCE_INVALID andDirection:DIRECTION_INVALID];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p> Distance: %f Direction: %f", NSStringFromClass([self class]), self, _distance, _direction];
}

@end

BOOL GNDistanceAndDirectionIsValid(GNDistanceAndDirection *dad) {
    return !isnan(dad.direction) && !isnan(dad.distance);
}

BOOL GNDistanceAndDirectionCompare(GNDistanceAndDirection *dad1, GNDistanceAndDirection *dad2) {
    return ((dad1.direction == dad2.direction) && (dad1.distance == dad2.distance)) || (!GNDistanceAndDirectionIsValid(dad1) && !GNDistanceAndDirectionIsValid(dad2));
}

BOOL CLLocationCoordinate2DCompare(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2) {
    return (c1.latitude == c2.latitude) && (c1.longitude == c2.longitude);
}

NSString* CLStringFromLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
    return [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
}


/*
 ** GreatCircleDist() --
 **
 ** Compute great-circle distance and course from starting
 ** and ending positions.
 **
 ** Given a starting position (decimal latitude and longitude) and
 ** an ending position (decimal latitude and longitude), compute
 ** the great-circle distance (kilometers) and initial course.
 ** This is the inverse function to GreatCirclePos().
 **     *
 ** Parameters:
 **     slt     -> starting decimal latitude (-S)
 **     slg;	-> starting decimal longitude(-W)
 **     xlt;	-> ending decimal latitude (-S)
 **     xlg;	-> ending decimal longitude(-W)
 **
 ** Return Value:
 **     Returns the distance and direction
 */
GNDistanceAndDirection* GreatCircleDist(double slt, double slg, double xlt, double xlg)
{
    GNDistanceAndDirection *result = [GNDistanceAndDirection new];
	double	c, d, dLo, L1, L2, coL1, coL2, l;
    /*
     **  Translate longitude to starting position
     */
	if (slg < 0.0){
        slg += 360.0;
    }
    if (xlg < 0.0) {
        xlg += 360.0;
    }
    dLo  = (xlg - slg) * M_PI_180;
    if (fabs(dLo) > M_PI) {
        dLo += (dLo < 0.0) ? M_2PI : -M_2PI;
    }
    slt *= M_PI_180;
    xlt *= M_PI_180;
    L1   = slt;
    L2   = xlt;
    if ((dLo == 0.0) && (L1 == L2)) {
        result.direction = 0.0;
        result.distance = 0.0;
        return result;;
    }
	l    = L2 - L1;
	coL1 = (M_PI_2 - slt);
	coL2 = (M_PI_2 - xlt);
    
    /*
     **  Calculate great-circle distance in radians.
     */
	d    = ahav(hav(dLo) * cos(L1) * cos(L2) + hav(l));
    
    /*
     **  Calculate initial course in radians.
     */
    c = ahav(sec(L1) * csc(d) * (hav(coL2) - hav(d - coL1)));
    if (isnan(c)) {
        c = 0.0;
    }
    if (dLo < 0.0) {
        c = -c;
    }
    if (c < 0.0) {
        c += M_2PI;
    }
    /* initial course angle in degrees  */
    result.direction = c * M_180_PI;

    /*
     **  Return great-circle distance in meters.
     */
    result.distance = d * M_180_PI * MetersPerDegree;
    return result;
}

/*
 ** GreatCircleDistLocation() --
 **
 ** Wrapper for GreatCircleDist which takes two CLLocationCoordinate2Ds
 ** instead of two sets of lat/lon.
 **
 **     *
 ** Parameters:
 **     start   -> start location
 **     end;	-> end location
 **
 ** Return Value:
 **     Returns the distance and direction
 */
GNDistanceAndDirection* GreatCircleDistLocation(CLLocationCoordinate2D start, CLLocationCoordinate2D end) {
    return GreatCircleDist(start.latitude, start.longitude, end.latitude, end.longitude);
}

/*
 **  GreatCirclePos() --
 **
 **  Compute ending position from course and great-circle distance.
 **
 **  Given a starting latitude (decimal), the initial great-circle
 **  course and a distance along the course track, compute the ending
 **  position (decimal latitude and longitude).
 **  This is the inverse function to GreatCircleDist).
 **
 **  Parameters:
 **     distance   -> great-circle distance (meters)
 **     direction  -> initial great-circle course (degrees)
 **     slt        -> starting decimal latitude (-S)
 **     slg        -> starting decimal longitude(-W)
 **
 **  Returns:
 **     (ending decimal latitude (-S), ending decimal longitude(-W))
 */
CLLocationCoordinate2D GreatCirclePos(double distance, double direction, double slt, double slg) {
    double  c, d, dLo, L1, L2, coL1, coL2, l;
    
    if (distance > (MetersPerDegree * 180.0)) {
        direction -= 180.0;
        if (direction < 0.0)
            direction += 360.0;
        distance = MetersPerDegree * 360.0 - distance;
    }
    
    if (direction > 180.0) {
        direction -= 360.0;
    }
    
    c    = direction * M_PI_180;
    d    = distance * DegreesPerMeter * M_PI_180;
    L1   = slt * M_PI_180;
    slg *= M_PI_180;
    coL1 = (90.0 - slt) * M_PI_180;
    coL2 = ahav(hav(c) / (sec(L1) * csc(d)) + hav(d - coL1));
    L2   = M_PI_2 - coL2;
    l    = L2 - L1;
    if ((dLo = (cos(L1) * cos(L2))) != 0.0) {
        dLo  = ahav((hav(d) - hav(l)) / dLo);
    }
    if (c < 0.0) {
        dLo = -dLo;
    }
    slg += dLo;
    if (slg < -M_PI) {
        slg += M_2PI;
    }
    else if (slg > M_PI) {
        slg -= M_2PI;
    }
    
    return CLLocationCoordinate2DMake(L2 * M_180_PI, slg * M_180_PI);
}




@implementation CLLocation(GNDistance)

- (CLLocation*)locationByDistance:(CLLocationDistance)distance andDirection:(CLLocationDirection)direction {
    CLLocationCoordinate2D result = GreatCirclePos(distance, direction, self.coordinate.latitude, self.coordinate.longitude);
    return [[CLLocation alloc] initWithLatitude:result.latitude longitude:result.longitude];
}

@end
