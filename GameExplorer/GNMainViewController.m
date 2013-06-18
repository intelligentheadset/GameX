//
//  GNMainViewController.m
//  GameExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNMainViewController.h"
#import "IHSDevice.h"
#import "GNAppDelegate.h"
#import "NSString+IHSDeviceConnectionState.h"
#import "GNAudio3DSound.h"

#import "GXGame.h"
#import "GXGame+UITableViewDataSource.h"

#import <AVFoundation/AVFoundation.h>

@interface GNMainViewController () <UITableViewDataSource, UITableViewDelegate, IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate, IHS3DAudioDelegate> {
    GXGame*                         _game;
    __weak IBOutlet UILabel*        statusLabel;
    __weak IBOutlet UITextField *_playerNameTextField;
    
    __weak IBOutlet UIButton *_joinButton;
    __weak IBOutlet UITableView*    _opponentsTableView;
}

@property (strong, nonatomic) AVAudioPlayer*        audioPlayer;

- (IBAction)joinAction:(id)sender;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation GNMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _joinButton.enabled = NO;
    _opponentsTableView.dataSource = _game;
    
    // Register to get notified via 'appDidBecomeActive' when the app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)viewDidUnload {
    _opponentsTableView = nil;
    _playerNameTextField = nil;
    _joinButton = nil;
    [super viewDidUnload];
}


#pragma mark - Interface Builder Actions

- (IBAction)addPlayerAction:(id)sender {
    GXPlayer* oponent = [[GXPlayer alloc] initWithPlayerId:@"__kat__"];
    oponent.name = @"Katrine";
    [_game addOpponent:oponent];
    [_opponentsTableView reloadData];
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(GNFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"])
    {
        GNFlipsideViewController*   vc = segue.destinationViewController;
        vc.delegate = self;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}


- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}


#pragma mark - IHSDeviceDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihsDevice connectedStateChanged:(IHSDeviceConnectionState)connectionState
{    
    DEBUGLog( @"IHS Device:connectedStateChanged:  %d", connectionState );
    
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = APP_DELEGATE.ihsDevice.name ?: @"Game X";
    NSString* statusText = [NSString stringWithFormat:@"%@ (%@)", deviceName, connectionString ];
    
    statusLabel.text = statusText;
    
    switch ( connectionState )
    {
        case IHSDeviceConnectionStateConnected: {
            // Save the name of the connected IHS device to automatically connect to it next time the app starts
            APP_DELEGATE.preferredDevice = ihsDevice.preferredDevice;

            // Play a sound through the standard player to indicate that the IHS is connected
            [self playSystemSoundWithName:@"TestConnectSound"];

            _joinButton.enabled = _game != nil;
        }

        case IHSDeviceConnectionStateDisconnected: {
            [_game leave];
            break;
        }

        case IHSDeviceConnectionStateNone:
        case IHSDeviceConnectionStateBluetoothOff:
        case IHSDeviceConnectionStateDiscovering:
        case IHSDeviceConnectionStateLingering:
        case IHSDeviceConnectionStateConnecting:
        case IHSDeviceConnectionStateConnectionFailed:
            break;
    }
}


#pragma mark - IHSSensorsDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading
{
    DEBUGLog(@"1: Fused Heading changed: %.1f", heading);

    // Use the fused heading as reference for the 3D audio player in the IHS
    ihs.playerHeading = heading;
}


- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading
{
    DEBUGLog(@"2: Compass Heading changed: %.1f", heading);
}


- (void)ihsDevice:(IHSDevice*)ihs yawChanged:(float)yaw
{
    DEBUGLog(@"3: Yaw: %.1f", yaw);
}


- (void)ihsDevice:(IHSDevice*)ihs pitchChanged:(float)pitch
{
    DEBUGLog(@"4: Pitch: %.1f", pitch);
}


- (void)ihsDevice:(IHSDevice*)ihs rollChanged:(float)roll
{
    DEBUGLog(@"5: Roll: %.1f", roll);
}


- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct) data
{
    DEBUGLog(@"6: Accelerometer data: (%f, %f, %f)", data.x, data.y, data.z);
}


- (void)ihsDevice:(IHSDevice*)ihs accuracyChangedForHorizontal:(double)horizontalAccuracy
{
    DEBUGLog(@"7: Horizontal accuracy: %.1f", horizontalAccuracy);
}


- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude
{
    DEBUGLog(@"8: Position: (%.4g, %.4g)", latitude, longitude);
    DEBUGLog(@"   %@", APP_DELEGATE.ihsDevice.location );
}


#pragma mark - IHSButtonDelegate implementation

- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event
{
    IHSDevice*  ihsDevice = ihs;
    
    switch (button) {
        case IHSButtonLeft: {
            [ihsDevice stop];
            [ihsDevice clearSounds];

            ihsDevice.sequentialSounds = YES;

            // Create north and south GNAudio3DSound objects from embedded sound resources:
            NSURL* northUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsNorth" withExtension:@"wav"];
            GNAudio3DSound* northSound = [[GNAudio3DSound alloc] initWithURL:northUrl];

            northSound.heading  = 0;        // Place the "north" sound straight north
            northSound.volume   = 1.0;      // Set the volume to the maximum level
            northSound.distance = 1000;     // Set the distance of the sound

            [ihsDevice addSound:northSound];

            NSURL *southUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsSouth" withExtension:@"wav"];
            GNAudio3DSound* southSound = [[GNAudio3DSound alloc] initWithURL:southUrl];

            southSound.heading  = 180;      // Place the "south" sound straight south
            southSound.volume   = 1.0;      // Set the volume to the maximum level
            southSound.distance = 1000;     // Set the distance of the sound

            [ihsDevice addSound:southSound];

            // Start the playback
            [ihsDevice play];
            break;
        }
            
        case IHSButtonRight: {
            // Stop the playback
            [ihsDevice stop];
            // Clear the list of sounds
            [ihsDevice clearSounds];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Notification Handler Methods

- (void)appDidBecomeActive:(NSNotification *)notification
{
    // Setup delegates to receive various kinds of information from the IHS:
    APP_DELEGATE.ihsDevice.deviceDelegate = self;   // ... connection information
    APP_DELEGATE.ihsDevice.sensorsDelegate = self;  // ... receive data from the IHS sensors
    APP_DELEGATE.ihsDevice.buttonDelegate = self;   // ... receive button presses
    APP_DELEGATE.ihsDevice.audioDelegate = self;    // ... receive 3daudio notifications.
    
    // Establish connection to the physical IHS
    [APP_DELEGATE.ihsDevice connect];
}


#pragma mark - Sound handling

- (void)playSystemSoundWithName:(NSString*)name {
    NSError *error;
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"wav"];
    
    [self.audioPlayer stop];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Error playing sound '%@': %@", name, error);
        self.audioPlayer = nil;
    }
    else {
        self.audioPlayer.volume = 1.0;
        
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}


#pragma mark - IHS3DAudioDelegate implementation

- (void)ihsDevice:(id)ihs playerDidStartSuccessfully:(BOOL)success {
    DEBUGLog(@"playerDidStartSuccessfully? %s", success ? "YES" : "NO");
}


- (void)ihsDevice:(id)ihs playerDidPauseSuccessfully:(BOOL)success {
    DEBUGLog(@"playerDidPauseSuccessfully? %s", success ? "YES" : "NO");
}


- (void)ihsDevice:(id)ihs playerDidStopSuccessfully:(BOOL)success {
    IHSDevice*  ihsDevice = ihs;
    
    DEBUGLog(@"playerDidStopSuccessfully? %s", success ? "YES" : "NO");

    // Restart playback (until right button press).
    [ihsDevice play];
}


- (void)ihsDevice:(id)ihs playerCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    DEBUGLog(@"playerCurrentTime: %f, duration: %f", currentTime, duration);
}


- (void)ihsDevice:(id)ihs playerRenderError:(OSStatus)status {
    DEBUGLog(@"playerRenderError? %li", status);
}


- (IBAction)joinAction:(id)sender {
    GXPlayer* player = [[GXPlayer alloc] initWithPlayerId:APP_DELEGATE.ihsDevice.preferredDevice];
    player.name = @"Martin";
    [_game joinGameAsPlayer:player];
}

@end
