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
    NSMutableDictionary*    _players;
}

- (id)init {
    if (self = [super init]) {
        _iterateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(iterateTimerUpdate:) userInfo:nil repeats:YES];
        _players = [[NSMutableDictionary alloc] init];
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
    _players[opponent.pid] = opponent;
}


- (void)removeOpponent:(GXPlayer*)opponent {
    [_players removeObjectForKey:opponent.pid];
}


- (GXPlayer*)shoot:(double)direction {
    GXPlayer* result = nil;
    for (GXPlayer* opponent in _players) {
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

- (NSArray*)players {
    return [[_players allValues] copy];
}


- (void)setPlayers:(NSArray *)opponents {
    // Manual copy over, so we can check for correct object types on the fly
    [_players removeAllObjects];
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
    if ((_myself.latitude != 0) && (_myself.longitude != 0)) {
        for (GXPlayer* opponent in _players) {
            if ((opponent.latitude != 0) && (opponent.longitude != 0)) {
                GNDistanceAndDirection* dad = GreatCircleDist(_myself.latitude, _myself.longitude, opponent.latitude, opponent.longitude);
                [opponent setDistance:dad.distance andDirection:dad.direction];
            }
        }
    }
}

@end
