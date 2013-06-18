//
//  GXPlayer.m
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GXPlayer.h"

@implementation GXPlayer {
    NSDate* _lastUpdate;
}

- (id)initWithPlayerId:(NSString*)pid {
    if (self = [self init]) {
        _pid = pid;
    }
    return self;
}


- (void)setLatitude:(double)latitude andLongitude:(double)longitude {
    _latitude = latitude;
    _longitude = longitude;
    _lastUpdate = [NSDate date];
}


- (void)setDistance:(double)distance andDirection:(double)direction {
    _distance = distance;
    _direction = direction;
}


#pragma ark - Property Access Methods

- (BOOL)needsUpdate {
    BOOL result = _lastUpdate == nil;
    if (_lastUpdate != nil) {
        NSTimeInterval timeIntervalSinceLastUpdate = fabs([_lastUpdate timeIntervalSinceDate:[NSDate date]]);
        if (_distance < 20.0) {
            result = timeIntervalSinceLastUpdate > 1.0;
        }
        else {
            result = timeIntervalSinceLastUpdate > 5.0;
        }
    }
    return result;

}



@end
