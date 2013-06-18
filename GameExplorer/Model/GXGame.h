//
//  GXGame.h
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXPlayer.h"

@interface GXGame : NSObject

@property (nonatomic, readonly) NSString* gid;

@property (nonatomic, readonly) GXPlayer* myself;
@property (nonatomic, readonly) NSArray* opponents;

- (id)initWithGameId:(NSString*)gid;

- (void)joinGameAsPlayer:(GXPlayer*)player;
- (void)leave;

- (void)addOpponent:(GXPlayer*)opponent;
- (void)removeOpponent:(GXPlayer*)opponent;

- (GXPlayer*)shoot:(double)direction;

@end
