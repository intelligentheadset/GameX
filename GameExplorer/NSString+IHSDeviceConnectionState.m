//
//  NSString+IHSDeviceConnectionState.m
//  GameExplorer
//
//  Created by Michael Bech Hansen on 6/11/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "NSString+IHSDeviceConnectionState.h"

@implementation NSString (IHSDeviceConnectionState)

+ (NSString*) stringFromIHSDeviceConnectionState:(IHSDeviceConnectionState)connectionState
{
    switch ( connectionState )
    {
        case IHSDeviceConnectionStateNone:              return @"(none)";
        case IHSDeviceConnectionStateBluetoothOff:      return @"N/A";
        case IHSDeviceConnectionStateDiscovering:       return @"Discovering";
        case IHSDeviceConnectionStateConnecting:        return @"Connecting";
        case IHSDeviceConnectionStateConnected:         return @"Connected";
        case IHSDeviceConnectionStateConnectionFailed:  return @"Failed connecting";
        case IHSDeviceConnectionStateLingering:         return @"Lingering";
        case IHSDeviceConnectionStateDisconnected:      return @"Disconnected";
            
        // omit default: so we get compiler warning/error if IHSDeviceConnectionState should change.
    }
    
    return @"(unknown)";
}

@end
