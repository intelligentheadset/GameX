//
//  GXGame.h
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXPlayer.h"

@protocol GXGameDelegate;

@interface GXGame : NSObject

@property (nonatomic, weak) id<GXGameDelegate> delegate;

@property (nonatomic, readonly) NSString* gid;

@property (nonatomic, readonly) GXPlayer* myself;
@property (nonatomic, copy) NSArray* opponents;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, readonly) GXPlayer* lastShot;


- (id)initWithGameId:(NSString*)gid;

- (void)joinGameAsPlayer:(GXPlayer*)player;
- (void)leave;

- (GXPlayer*)shoot:(double)direction;

@end


@protocol GXGameDelegate <NSObject>

- (void)game:(GXGame*)game playerInRange:(GXPlayer*)player;
- (void)game:(GXGame*)game playerOutOfRange:(GXPlayer*)player;

@end
