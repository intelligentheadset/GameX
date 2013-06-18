//
//  NSString+IHSDeviceConnectionState.h
//  GameExplorer
//
//  Created by Michael Bech Hansen on 6/11/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHSDevice.h"

@interface NSString (IHSDeviceConnectionState)

+ (NSString*) stringFromIHSDeviceConnectionState:(IHSDeviceConnectionState)connectionState;

@end
