//
//  GNAppDelegate.m
//  GameExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNAppDelegate.h"
#import "IHSDevice.h"

static NSString* const kStandardUserDefaultsLastConnectedDevice = @"kStandardUserDefaultsLastConnectedDevice";

@implementation GNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Read some stored configuration:
    _preferredDevice    = [[NSUserDefaults standardUserDefaults] stringForKey:kStandardUserDefaultsLastConnectedDevice];

    return YES;
}
							

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setValue:self.preferredDevice forKey:kStandardUserDefaultsLastConnectedDevice];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ( _ihsDevice ) {
        // Remove these lines if you want the connection to the IHS device to stay open while the app is in the background
        [self.ihsDevice disconnect];
        _ihsDevice = nil;
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Property Access Methods

- (void)setPreferredDevice:(NSString *)preferredDevice {
    _preferredDevice = preferredDevice;
    [[NSUserDefaults standardUserDefaults] setValue:_preferredDevice forKey:kStandardUserDefaultsLastConnectedDevice];
    [[NSUserDefaults standardUserDefaults] synchronize]; // Make sure it is stored for next time
}


#pragma mark - IHSDevice

- (IHSDevice *)ihsDevice
{
    if ( _ihsDevice == nil ) {
        // Initialize with the name of the IHS device the app was most recently connected to
        _ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:self.preferredDevice];
    }
    return _ihsDevice;
}


@end
