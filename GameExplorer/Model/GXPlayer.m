//
//  GXPlayer.m
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GXPlayer.h"

@implementation GXPlayer

- (id)initWithPlayerId:(NSString*)pid {
    if (self = [self init]) {
        _pid = pid;
    }
    return self;
}

@end
