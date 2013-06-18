//
//  GXGame.m
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GXGame.h"

@implementation GXGame {
    NSMutableDictionary*    _opponents;
}

- (id)init {
    if (self = [super init]) {
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

}


#pragma mark - Property Access Methods

- (NSArray*)opponents {
    return [[_opponents allValues] copy];
}

@end
