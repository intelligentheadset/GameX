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
@property (nonatomic, copy) NSURL* userVoice;

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, assign) float heading;

@property (nonatomic, readonly) double distance;
@property (nonatomic, readonly) double direction;

@property (nonatomic, readonly) BOOL needsUpdate;

@property (nonatomic, assign) NSInteger fragCount;

- (void)setLatitude:(double)latitude andLongitude:(double)longitude;
- (void)setDistance:(double)distance andDirection:(double)direction;




- (id)initWithPlayerId:(NSString*)pid;

@end
