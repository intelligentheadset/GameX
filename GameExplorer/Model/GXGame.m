//
//  GXGame.m
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GXGame.h"
#import "CLLocation+GNDistance.h"

@implementation GXGame {
    NSTimer*                _iterateTimer;
    NSMutableDictionary*    _opponents;
}

- (id)init {
    if (self = [super init]) {
        _iterateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(iterateTimerUpdate:) userInfo:nil repeats:YES];
        _opponents = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (id)initWithGameId:(NSString*)gid {
    if (self = [self init]) {
        _gid = gid;
    }
    return self;
}


- (void)dealloc {
    [_iterateTimer invalidate];
    _iterateTimer = nil;
}


- (void)joinGameAsPlayer:(GXPlayer*)player {
    _myself = player;
}


- (void)leave {
    _myself = nil;
}


- (void)addOpponent:(GXPlayer*)opponent {
    _opponents[opponent.pid] = opponent;
}


- (void)removeOpponent:(GXPlayer*)opponent {
    [_opponents removeObjectForKey:opponent.pid];
}


- (GXPlayer*)shoot:(double)direction {
    GXPlayer* result = nil;
    for (GXPlayer* opponent in _opponents) {
        GNDistanceAndDirection* dad = GreatCircleDist(_myself.latitude, _myself.longitude, opponent.latitude, opponent.longitude);
        if (dad.distance < 20.0) {
            if (fabs(direction - dad.direction) < 2.0) {
                result = opponent;
                break;
            }
        }
    }
    return result;
}


#pragma mark - Property Access Methods

- (NSArray*)opponents {
    return [[_opponents allValues] copy];
}

#pragma mark - Private Methods

- (void)iterateTimerUpdate:(NSTimer*)timer {
    for (GXPlayer* opponent in _opponents) {
        GNDistanceAndDirection* dad = GreatCircleDist(_myself.latitude, _myself.longitude, opponent.latitude, opponent.longitude);
        [opponent setDistance:dad.distance andDirection:dad.direction];
    }
}

@end
