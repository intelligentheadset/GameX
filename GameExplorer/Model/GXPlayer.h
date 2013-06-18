//
//  GXPlayer.h
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXPlayer : NSObject

@property (nonatomic, readonly) NSString* pid;

@property (nonatomic, copy) NSString* name;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

- (id)initWithPlayerId:(NSString*)pid;

@end
