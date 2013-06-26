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

#import "Constants.h"

#import "RecorderView.h"
#import "ArangoAPIClient.h"

#import "GXGame.h"
#import "GXGame+UITableViewDataSource.h"

#import <AVFoundation/AVFoundation.h>

@interface GNMainViewController () <UITextFieldDelegate, UITableViewDelegate, IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate, IHS3DAudioDelegate, RecorderViewDelegate, GXGameDelegate> {
    GXGame*                         _game;
    NSURL*                          _urlUserVoice;
    AVAudioPlayer*                  _shootAudioPlayer;
    NSMutableDictionary*            _opponentUserVoices;

    __weak IBOutlet UIView*         _statusView;
    __weak IBOutlet UILabel*        _statusLabel;

    __weak IBOutlet UIView*         _joinGameView;
    __weak IBOutlet UIButton*       _recordButton;
    __weak IBOutlet UITextField*    _playerNameTextField;
    __weak IBOutlet UIButton*       _joinButton;
    __weak IBOutlet UITableView*    _playersTableView;
    
    __weak IBOutlet UIActivityIndicatorView *_networkActivityIndicator;

    
}

@property (strong, nonatomic) AVAudioPlayer*        audioPlayer;

- (IBAction)recordAction:(id)sender;
- (IBAction)joinAction:(id)sender;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation GNMainViewController {
    NSTimer*    _gameIterator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _opponentUserVoices = [[NSMutableDictionary alloc] init];

    _gameIterator = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(gameIteratorTimer:) userInfo:nil repeats:YES];

    _joinButton.enabled = NO;
    _playerNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardUserDefaultsPlayerName];

    _playersTableView.dataSource = _game;

    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _urlUserVoice = [NSURL fileURLWithPathComponents:@[documentsPath, @"uservoice.wav"]];


    // Register to get notified via 'appDidBecomeActive' when the app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self prepareShootSound];
}


- (void)viewDidUnload {
    _playersTableView = nil;
    _playerNameTextField = nil;
    _joinButton = nil;
    _recordButton = nil;
    _networkActivityIndicator = nil;
    _joinGameView = nil;
    _statusView = nil;
    [super viewDidUnload];
}


#pragma mark - Interface Builder Actions

- (IBAction)addPlayerAction:(id)sender {
    /*
    GXPlayer* oponent = [[GXPlayer alloc] initWithPlayerId:@"__kat__"];
    oponent.name = @"Katrine";
    [_game addOpponent:oponent];
    [_playersTableView reloadData];
    */
}

- (IBAction)shootAction:(id)sender {
    [self shoot];
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


#pragma mark - Private Methods

- (void)setJoinGameShowing:(BOOL)showing animated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? .33 : .00) animations:^{
        _joinButton.hidden = NO;
        _joinButton.enabled = APP_DELEGATE.ihsDevice.connectionState == IHSDeviceConnectionStateConnected;
        [_networkActivityIndicator stopAnimating];
        if (showing) {
            _joinGameView.frame = CGRectMake(0, CGRectGetMaxY(_statusView.frame), CGRectGetWidth(_joinGameView.frame), CGRectGetHeight(_joinGameView.frame));
        }
        else {
            _joinGameView.frame = CGRectMake(0, -CGRectGetHeight(_joinGameView.frame), CGRectGetWidth(_joinGameView.frame), CGRectGetHeight(_joinGameView.frame));
        }
    }];
}


- (void)gameIteratorTimer:(NSTimer*)timer {
    [_game readOpponents:^{
        _playersTableView.dataSource = _game;
        [_playersTableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (void)setGame:(GXGame*)game {
    if (game != _game) {
        _game = game;
        _game .delegate = self;
        _playersTableView.dataSource = _game;
        [UIView animateWithDuration:0.33 animations:^{
            _playersTableView.alpha = _game != nil ? 1.0 : 0.0;
        }];
    }
}


- (void)joinGameWithName:(NSString*)name andVoice:(NSURL*)urlVoice {
    // First fetch game (one hardcoded game)
    _joinButton.hidden = YES;
    [_networkActivityIndicator startAnimating];
    [GXGame getGame:^(GXGame *game) {
        [self setGame:game];
        if (_game != nil) {
            GXPlayer* player = [[GXPlayer alloc] initWithPlayerId:[self uniqueDeviceName]];
            player.name = name;
            [player joinGame:_game success:^() {
                [_game joinGameAsPlayer:player];
                [self setJoinGameShowing:NO animated:YES];
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
                [self setJoinGameShowing:YES animated:YES];
            }];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self setJoinGameShowing:NO animated:YES];
    }];
}


- (void)leaveGame {
    [_game.myself leaveGame:_game success:^{
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    [_game leave];
    [self setGame:nil];
    [self setJoinGameShowing:YES animated:YES];
}

- (void)shoot {
    GXPlayer* opponent = [_game shoot:APP_DELEGATE.ihsDevice.fusedHeading];
    if (opponent != nil) {
        _game.myself.fragCount++;
        [_game.myself updateFragCount:^{

        } failure:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }

    // Play a sound through the standard player to indicate that the IHS is connected
    [self playShootSound];
}


#pragma mark - Notification Handler Methods

- (void)appDidBecomeActive:(NSNotification *)notification
{
    // Setup delegates to receive various kinds of information from the IHS:
    APP_DELEGATE.ihsDevice.deviceDelegate = self;   // ... connection information
    APP_DELEGATE.ihsDevice.sensorsDelegate = self;  // ... receive data from the IHS sensors
    APP_DELEGATE.ihsDevice.buttonDelegate = self;   // ... receive button presses
    APP_DELEGATE.ihsDevice.audioDelegate = self;    // ... receive 3daudio notifications.
    APP_DELEGATE.ihsDevice.sequentialSounds = NO;

    // Establish connection to the physical IHS
    if (APP_DELEGATE.ihsDevice.connectionState != IHSDeviceConnectionStateConnected) {
        [APP_DELEGATE.ihsDevice connect];
    }
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


- (void)prepareShootSound {
    if (_shootAudioPlayer == nil) {
        NSError *error = nil;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"shoot" withExtension:@"wav"];

        _shootAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error != nil) {
            NSLog(@"Error playing sound '%@': %@", @"shoot.wav", error);
            _shootAudioPlayer = nil;
        }
        _shootAudioPlayer.volume = 1.0;
        [_shootAudioPlayer prepareToPlay];
    }
}


- (void)playShootSound {
    [_shootAudioPlayer stop];
    [_shootAudioPlayer play];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kStandardUserDefaultsPlayerName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self joinAction:_joinButton];
    return YES;
}


#pragma mark - IHSDeviceDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihsDevice connectedStateChanged:(IHSDeviceConnectionState)connectionState
{    
    DEBUGLog( @"IHS Device:connectedStateChanged:  %d", connectionState );
    
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = APP_DELEGATE.ihsDevice.name ?: @"Game X";
    NSString* statusText = [NSString stringWithFormat:@"%@ (%@)", deviceName, connectionString ];
    
    _statusLabel.text = statusText;
    
    switch (connectionState)
    {
        case IHSDeviceConnectionStateConnected: {
            // Save the name of the connected IHS device to automatically connect to it next time the app starts
            APP_DELEGATE.preferredDevice = ihsDevice.preferredDevice;

            // Play a sound through the standard player to indicate that the IHS is connected
            [self playSystemSoundWithName:@"TestConnectSound"];

            _joinButton.enabled = YES;
        }

        case IHSDeviceConnectionStateDisconnected: {
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

    if (connectionState == IHSDeviceConnectionStateConnected) {
    }
    else {
        [self leaveGame];
    }
}


#pragma mark - IHSSensorsDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading
{
    DEBUGLog(@"1: Fused Heading changed: %.1f", heading);

    // Use the fused heading as reference for the 3D audio player in the IHS
    ihs.playerHeading = heading;
    _game.myself.heading = heading;
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

    [_game.myself setLatitude:latitude andLongitude:longitude];
    [_game.myself updatePosition:^{

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
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
            /*
            // Stop the playback
            [ihsDevice stop];
            // Clear the list of sounds
            [ihsDevice clearSounds];
             */
            [self shoot];
            break;
        }
            
        default:
            break;
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


- (IBAction)recordAction:(id)sender {
    if (!_recordButton.selected) {
        _recordButton.selected = YES;
        RecorderView* rv = [[RecorderView alloc] init];
        rv.delegate = self;
        rv.alpha = 0.0;
        rv.frame = CGRectOffset(rv.frame, 0, 44);
        [self.view addSubview:rv];
        [UIView animateWithDuration:0.33 animations:^{
            rv.alpha = 1.0;
        } completion:^(BOOL finished) {
            [rv startRecording];
        }];
    }
}

- (IBAction)joinAction:(id)sender {
    if (_playerNameTextField.text.length == 0) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Title for generic warning")
                                                     message:NSLocalizedString(@"Please fill in your player name", @"Tell the user to fill in player name")
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Generic dismiss title")
                                           otherButtonTitles:nil];
        [av show];
    }
    else if (![_urlUserVoice checkResourceIsReachableAndReturnError:nil]) {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"Title for generic warning")
                                                     message:NSLocalizedString(@"Please record your player name", @"Tell the user to record player name")
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Generic dismiss title")
                                           otherButtonTitles:nil];
        [av show];
    }
    else {
        [self joinGameWithName:_playerNameTextField.text andVoice:nil];
    }
}


#pragma mark - RecorderViewDelegate

- (void)recorderView:(RecorderView*)recorderView didStopRecordingToURL:(NSURL*)url {

    // Remove any existing recording, and move the new one into place
    [[NSFileManager defaultManager] removeItemAtURL:_urlUserVoice error:nil];
    [[NSFileManager defaultManager] moveItemAtURL:url toURL:_urlUserVoice error:nil];

    // Remove the recorder view
    [UIView animateWithDuration:0.33 animations:^{
        recorderView.alpha = 0.0;
        _recordButton.selected = NO;
    } completion:^(BOOL finished) {
        [recorderView removeFromSuperview];
    }];
}


- (void)recorderView:(RecorderView*)recorderView errorDidOccur:(NSError*)error {
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recording Error", @"Title for recording error")
                                                 message:error.localizedDescription
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Generic dismiss title")
                                       otherButtonTitles:nil];
    [av show];
}


- (NSString*)uniqueDeviceName {
    NSString* result = APP_DELEGATE.ihsDevice.name;
    if ([result isEqualToString:@"Simulated"]) {
        NSString* uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
        if (uuidString == nil) {
            uuidString = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"UUID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSUUID* uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        result = [result stringByAppendingString:uuid.UUIDString];
    }
    return result;
}


#pragma mark - GXGameDelegate

- (void)game:(GXGame *)game playerInRange:(GXPlayer *)player {
    IHSDevice* ihsDevice = APP_DELEGATE.ihsDevice;

    /*
    // first some cleanup - remove playerd sounds
    NSMutableArray* finishedSounds = [NSMutableArray new];
    for (GNAudio3DSound* sound in ihsDevice.sounds) {
        if (sound.currentTime >= sound.duration) {
            [finishedSounds addObject:sound];
        }
    }

    for (GNAudio3DSound* sound in finishedSounds) {
        [ihsDevice removeSound:sound];
    }

    finishedSounds = nil;
     */
    GNAudio3DSound* sound = _opponentUserVoices[player.pid];
    if (sound == nil) {
        // Create north and south GNAudio3DSound objects from embedded sound resources:
        NSURL* playerUrl = [[NSBundle mainBundle] URLForResource:@"player" withExtension:@"wav"];
        sound = [[GNAudio3DSound alloc] initWithURL:playerUrl];
        sound.volume = 1.0;
        _opponentUserVoices[player.pid] = sound;
    }

    if (![ihsDevice.sounds containsObject:sound]) {
        [ihsDevice addSound:sound];
    }

    sound.heading = player.direction;
    sound.distance = player.distance / 1000;

    if (!ihsDevice.isPlaying) {
        [ihsDevice play];
    }
}


- (void)game:(GXGame*)game playerOutOfRange:(GXPlayer*)player {
    GNAudio3DSound* sound = _opponentUserVoices[player.pid];
    if (sound != nil) {
        sound.repeats = NO;
    }
}


@end
