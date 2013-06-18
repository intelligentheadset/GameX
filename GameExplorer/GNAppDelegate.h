//
//  GNAppDelegate.h
//  GameExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IHSDevice;

@interface GNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IHSDevice* ihsDevice;
@property (strong, nonatomic) NSString* preferredDevice;

@end


// Convenience getter for app delegate:
#define APP_DELEGATE    ((GNAppDelegate*)[[UIApplication sharedApplication] delegate])