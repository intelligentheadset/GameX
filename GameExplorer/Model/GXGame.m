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

    if ((_myself.latitude != 0) && (_myself.longitude!= 0)) {
        if ((opponent.latitude != 0) && (opponent.longitude != 0)) {
            GNDistanceAndDirection* dad = GreatCircleDist(_myself.latitude, _myself.longitude, opponent.latitude, opponent.longitude);
            [opponent setDistance:dad.distance andDirection:dad.direction];
        }
    }

    [self pingPlayer:opponent];
}


- (void)removeOpponent:(GXPlayer*)opponent {
    [_opponents removeObjectForKey:opponent.pid];
}


- (void)pingPlayer:(GXPlayer*)player {
    if ((player.distance >= 0.0) && (player.distance < 100.0)) {
        [_delegate game:self playerInRange:player];
    }
    else {
        [_delegate game:self playerOutOfRange:player];
    }
}


- (GXPlayer*)shoot:(double)direction {
    GXPlayer* result = nil;
    if ((_myself.latitude != 0) && (_myself.longitude!= 0)) {
        for (GXPlayer* opponent in _opponents.allValues) {
            if ((opponent.latitude != 0) && (opponent.longitude != 0)) {
                if ((opponent.distance >= 20.0) && (opponent.distance <= 40.0)) {
                    NSLog(@"Distance: %f, Direction %f", opponent.distance, opponent.direction);
                    float deltaDirection = fabs(direction - opponent
                                                .direction);
                    NSLog(@"Delta Direction %f", deltaDirection);
                    if (deltaDirection < 30.0) {
                        result = opponent;
                        break;
                    }
                }
            }
        }
    }
    _lastShot = result;
    return result;
}


#pragma mark - Property Access Methods

- (NSArray*)opponents {
    return [[_opponents allValues] copy];
}


- (void)setOpponents:(NSArray *)opponents {
    // Manual copy over, so we can check for correct object types on the fly
    [_opponents removeAllObjects];
    if (opponents != nil) {
        for (GXPlayer* opponent in opponents) {
            if ([opponent isKindOfClass:[GXPlayer class]]) {
                [self addOpponent:opponent];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)iterateTimerUpdate:(NSTimer*)timer {
    /*
    if ((_myself.latitude != 0) && (_myself.longitude != 0)) {
        for (GXPlayer* opponent in _opponents) {
            if ((opponent.latitude != 0) && (opponent.longitude != 0)) {
                GNDistanceAndDirection* dad = GreatCircleDist(_myself.latitude, _myself.longitude, opponent.latitude, opponent.longitude);
                [opponent setDistance:dad.distance andDirection:dad.direction];
            }
        }
    }
     */
}

@end
