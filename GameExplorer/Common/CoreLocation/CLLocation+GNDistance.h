///
///  @file CLLocation+GNDistance.h
///
///  Created by Martin Lobger on 24/09/12.
///  Copyright (c) 2012 GN. All rights reserved.
///

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


/**
 @brief                 Meters per degree
 */
#define MetersPerDegree     111120.00071117

/**
 @brief                 Degrees per meter
 */
#define DegreesPerMeter     (1.0 / MetersPerDegree)

/**
 @brief                 Earth radius in meters
 */
#define EARTH_RADIUS        6371000 // In meters

/**
 @brief                 Definition of an invalid distance
 */
#define DISTANCE_INVALID    NAN

/**
 @brief                 'Infinite' distance in meters (re-define of DBL_MAX)
 */
#define DISTANCE_INFINITE   DBL_MAX // In meters

/**
 @brief                 Definition of an invalid direction
 */
#define DIRECTION_INVALID   NAN

/**
 @brief                 Combines a distance and a direction
 @ingroup               GNCategoriesGroup
 */
@interface GNDistanceAndDirection : NSObject

/**
 @brief                 The distance in meters to the point in question
 */
@property (assign, nonatomic) CLLocationDistance distance;

/**
 @brief                 The direction in degrees to the point in question
 */
@property (assign, nonatomic) CLLocationDirection direction;

/**
 @brief                 Initializes as invalid
 */
- (id)init;

/**
 @brief                 Initializes with given distance and direction
 @param distance        The distance to the point in question
 @param direction       The direction to the point in question
 */
- (id)initWithDistance:(CLLocationDistance)distance andDirection:(CLLocationDirection)direction;

@end

#pragma mark Helper Functions

/**
 @brief                 Test if an GNDistanceAndDirection is valid
 */
BOOL GNDistanceAndDirectionIsValid(GNDistanceAndDirection *dad);

/**
 @brief                 Compare two GNDistanceAndDirection's
 */
BOOL GNDistanceAndDirectionCompare(GNDistanceAndDirection *dad1, GNDistanceAndDirection *dad2);

/**
 @brief                 Compare two CLLocationCoordinate2D's
 */
BOOL CLLocationCoordinate2DCompare(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);

/**
 @brief                 Compose a string from a CLLocationCoordinate2D
 @param coordinate      The coordinate to get a string for
 @return                A NSString representing the cordinate
 */
NSString* CLStringFromLocationCoordinate2D(CLLocationCoordinate2D coordinate);

/**
 @brief                 Compute great-circle distance and course from starting and ending positions
 @details               Given a starting position (decimal latitude and longitude) and
                        an ending position (decimal latitude and longitude), compute
                        the great-circle distance (kilometers) and initial course.
                        This is the inverse function to GreatCirclePos().
 @param slt             The start latitude
 @param slg             The start longitude
 @param xlt             The end latitude
 @param xlg             The end longitude
 @return                The distance in meters and the direction in degrees.
 */
GNDistanceAndDirection *GreatCircleDist(double slt, double slg, double xlt, double xlg);

/**
 @brief                 Compute great-circle distance and course from starting and ending positions
 @details               Given a starting position (decimal latitude and longitude) and
                        an ending position (decimal latitude and longitude), compute
                        the great-circle distance (kilometers) and initial course.
                        This is the inverse function to GreatCirclePos().
 @param start           The start coordinate
 @param end             The end coordinate
 @return                The distance in meters and the direction in degrees.
 */
GNDistanceAndDirection *GreatCircleDistLocation(CLLocationCoordinate2D start, CLLocationCoordinate2D end);

/**
 @brief                 Compute ending position from course and great-circle distance.
 @details               Given a starting latitude (decimal), the initial great-circle
                        course and a distance along the course track, compute the ending
                        position (decimal latitude and longitude).
                        This is the inverse function to GreatCircleDist().
 @param distance        great-circle distance (meters)
 @param direction       initial great-circle direction (degrees)
 @param slt             The start latitude
 @param slg             The start longitude
 @return                Ending latitude and longitude
 */
CLLocationCoordinate2D GreatCirclePos(double distance, double direction, double slt, double slg);


#pragma mark CLLocation(GNDistance)

/**
 @brief                 Add distance calculations to CLLocation.
 */
@interface CLLocation(GNDistance)

/**
 @brief                 Get a new location based on a distance and a direction.
 @details               Calculates a new location based on the Greate Circle algorithm.
 @param distance        The distance in meters from the current location.
 @param direction       The direction in degrees.
 */
- (CLLocation*)locationByDistance:(CLLocationDistance)distance andDirection:(CLLocationDirection)direction;

@end
