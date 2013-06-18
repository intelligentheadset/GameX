//
//  IHSDevice.h
//  IHS API
//
//  Created by Lars Johansen (GN) on 29/5/13.
//  Copyright (c) 2012 GN Store Nord A/S. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

@class GNAudio3DSound;
@class IHSDevice;


/**
 @brief                 IHS device connection states
 */
typedef enum {
    IHSDeviceConnectionStateNone,
    IHSDeviceConnectionStateBluetoothOff,
    IHSDeviceConnectionStateDiscovering,
    IHSDeviceConnectionStateDisconnected,
    IHSDeviceConnectionStateLingering,
    IHSDeviceConnectionStateConnecting,
    IHSDeviceConnectionStateConnected,
    IHSDeviceConnectionStateConnectionFailed = -1,
} IHSDeviceConnectionState;

/**
 @brief                 IHS buttons
 */
typedef enum {
    IHSButtonRight                      = 0,
    IHSButtonLeft                       = 4,
    IHSButtonNoButton                   = -1
} IHSButton;

/**
 @brief                 IHS button events
 @note                  IHSButtonEventTap, IHSButtonEventPress and IHSButtonEventDoubleTap are available on IHSButtonRight
                        IHSButtonEventTap is available on IHSButtonLeft
*/
typedef enum {
    IHSButtonEventTap                   = 0,
    IHSButtonEventPress                 = 1,
    IHSButtonEventDoubleTap             = 2,
    IHSButtonEventNoEvent               = -1
} IHSButtonEvent;


/**
 @brief                 Structure used when handling 3 axis data (x, y, z)
 */
typedef struct IHSAHRS3AxisStruct {
    double x;           ///< The x value of the 3 axis (X, y, z)
    double y;           ///< The y value of the 3 axis (x, Y, z)
    double z;           ///< The z value of the 3 axis (x, y, Z)
} IHSAHRS3AxisStruct;


#pragma mark IHSDeviceDelegate

@protocol IHSDeviceDelegate <NSObject>
@required

/**
 @brief                 Notify that the connection state has changed
 @details               Called everytime the connection state of the IHS changes
 @param ihsDevice       The IHS device the connection state was changed on
 @param connectionState The new connection state the IHS device changed to
 */
- (void)ihsDevice:(IHSDevice*)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState;

@end


#pragma mark IHSSensorsDelegate

@protocol IHSSensorsDelegate <NSObject>
@required

/**
 @brief                 Notify that the fused heading has changed
 @details               Called everytime the fused heading reported by the IHS changes
 @param ihsDevice       The IHS device the fused heading was changed on
 @param heading         Fused heading (gyro and magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading;


/**
 @brief                 Notify that the compass heading has changed
 @details               Called everytime the compass heading reported by the IHS changes
 @param ihsDevice       The IHS device the compass heading was changed on
 @param heading         Heading (magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading;


/**
 @brief                 Notify that the yaw (gyro heading) has changed
 @details               Called everytime the yaw (gyro heading) reported by the IHS changes
 @param ihsDevice       The IHS device the yaw (gyro heading) was changed on
 @param yaw             Yaw (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs yawChanged:(float)yaw;


/**
 @brief                 Notify that the pitch has changed
 @details               Called everytime the pitch reported by the IHS changes
 @param ihsDevice       The IHS device the pitch was changed on
 @param pitch           Pitch (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs pitchChanged:(float)pitch;


/**
 @brief                 Notify that the roll has changed
 @details               Called everytime the roll reported by the IHS changes
 @param ihsDevice       The IHS device the roll was changed on
 @param roll            Roll (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs rollChanged:(float)roll;


/**
 @brief                 Notify that the horizontal accuracy has changed
 @details               Called everytime the horizontal accuracy reported by the IHS changes
 @param ihsDevice       The IHS device the horizontal accuracy was changed on
 @param horAccuracy     Horizontal accuracy (GPS)
 */
- (void)ihsDevice:(IHSDevice*)ihs accuracyChangedForHorizontal:(double)horAccuracy;


/**
 @brief                 Notify that the GPS position has changed
 @details               Called everytime the GPS position reported by the IHS changes
 @param ihsDevice       The IHS device the GPS position was changed on
 @param latitude        Latitude (GPS)
 @param longitude       Longitude (GPS)
 */
- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude;


/**
 @brief                 Notify that the accelerometer data has changed
 @details               Called everytime the accelerometer data reported by the IHS changes
 @param ihsDevice       The IHS device which the accelerometer data was changed on
 @param data            3 axis accelerometer data (accelerometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct) data;

@end


#pragma mark IHSButtonDelegate

@protocol IHSButtonDelegate <NSObject>
@required
/**
 @brief                 Notify that an IHS button was pressed
 @details               Called everytime an IHS button is pressed
 @param ihsDevice       The IHS device which the IHS button was pressed on
 @param button          The IHS button that was pressed
 @param event           The IHS button event on the pressed button
 */
- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event;

@end


#pragma mark IHS3DAudioDelegate

@protocol IHS3DAudioDelegate <NSObject>
@optional

/**
 @brief                 Sent as a result of a call to the play method
 @param ihs             The IHS device instance the playback is requested started on
 @param success         YES if playback has started, else NO
 */
- (void)ihsDevice:(id)ihs playerDidStartSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the pause method
 @param ihs             The IHS device instance the playback is requested paused on
 @param success         YES if playback was paused, else NO
 */
- (void)ihsDevice:(id)ihs playerDidPauseSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the stop method
 @param ihs             The IHS device instance the playback is requested stopped on
 @param success         YES if playback was stopped, else NO
 */
- (void)ihsDevice:(id)ihs playerDidStopSuccessfully:(BOOL)success;


/**
 @brief                 Sent as progress during playback moves forward
 @details               This message is sent twice a second
 @param ihs             The IHS device instance playing the audio
 @param currentTime     The current time in seconds
 @param duration        The duration of the sound resource
 */
- (void)ihsDevice:(id)ihs playerCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;


/**
 @brief                 Sent if it an error occured during sound rendering
 @details               A typical error that can occur is an unsupported file or data format.
                        E.g. 32bit samples are not supported
 @param status          Error status '0x3dee' indicates that 3D audio playback was attempted started
                        before the IHS device was connected.
 */
- (void)ihsDevice:(id)ihs playerRenderError:(OSStatus)status;

@end


#pragma IHSDevice interface

@interface IHSDevice: NSObject

/**
 @brief                 The object to receive device notifications on
 */
@property (weak, nonatomic) id<IHSDeviceDelegate> deviceDelegate;

/**
 @brief                 The object to receive sensor data notifications on
 */
@property (weak, nonatomic) id<IHSSensorsDelegate> sensorsDelegate;

/**
 @brief                 The object to receive 3D audio notifications on
 */
@property (nonatomic, weak) id<IHS3DAudioDelegate> audioDelegate;

/**
 @brief                 The object to receive button notifications on
 */
@property (weak, nonatomic) id<IHSButtonDelegate> buttonDelegate;

/**
 @brief                 Name of the preferred physical IHS device
 */
@property (readonly, nonatomic) NSString* preferredDevice;

/**
 @brief                 Last known latitude
 */
@property (readonly, nonatomic) double latitude;

/**
 @brief                 Last known longitude
 */
@property (readonly, nonatomic) double longitude;

/**
 @brief                 Last known GPS location
 */
@property (readonly, nonatomic) CLLocation* location;

/**
 @brief                 Last known GPS signal indicator
 @details               0.00:   No signal
                        0.25:   2D fix
                        0.50:   2D fix and SBAS fix
                        0.75:   3D fix
                        1.00:   3D fix and SBAS fix
 */
@property (readonly, nonatomic) float GPSSignalIndicator;

/**
 @brief                 Last known horizontal accuracy
 @details               A value of '-1' indicates that the GPS position is not valid
 */
@property (readonly, nonatomic) double horizontalAccuracy;

/**
 @brief                 Last known fused heading (gyro and magnetometer)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float fusedHeading;

/**
 @brief                 Last known compass heading (magnetometer)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float compassHeading;

/**
 @brief                 Last known yaw (gyro heading)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float yaw;

/**
 @brief                 Last known roll (gyro)
 @details               The range goes from -180.0 -> +180.0
 */
@property (readonly, nonatomic) float roll;

/**
 @brief                 Last known pitch (gyro)
 @details               The range goes from -90.0 -> +90.0
 */
@property (readonly, nonatomic) float pitch;

/**
 @brief                 Last known accelerometer data (accelerometer)
 @details               The range goes from -2g -> 2g for each axis
 */
@property (readonly, nonatomic) IHSAHRS3AxisStruct accelerometerData;

/**
 @brief                 Set to YES if sensors detect magnetic disturbance, else NO
 */
@property (readonly, assign) BOOL magneticDisturbance;

/**
 @brief                 The last known magnetic field strength for the IHS device
 @details               Field strength is reported in milligauss.
 */
@property (readonly, assign) NSInteger magneticFieldStrength;

/**
 @brief                 Set to NO if no movement detected for at least 10s after startup,
                        i.e., the gyro can be assumed autocalibrated.
                        Otherwise YES
 */
@property (readonly, assign) BOOL gyroUncalibrated;

/**
 @brief                 Name of the connected IHS device
 */
@property (readonly, nonatomic) NSString* name;

/**
 @brief                 Firmware revision of the connected IHS device
 */
@property (readonly, nonatomic) NSString* firmwareRevision;

/**
 @brief                 Connection state of the IHSDevice
 */
@property (readonly, nonatomic) IHSDeviceConnectionState connectionState;

/**
 @brief                 The sounds currently in the playback pool.
 @details               A sound being present here does not mean that it is nessesary being played back.
                        It can be paused, or have an offset in the future or have finished already.
 */
@property (nonatomic, readonly) NSArray* sounds;

/**
 @brief                 Flag controlling the order of how sounds are played back.
 @details               If YES, all sounds are played back in sequence and new sounds added are played last.
                        If NO, all sounds are played simultaniously taking sound offset etc. into account.
 */
@property (nonatomic, assign) BOOL sequentialSounds;

/**
 @brief                 The total duration of the loaded sound resources including offsets
 */
@property (nonatomic, readonly) NSTimeInterval playerDuration;

/**
 @brief                 The current time of the sound resource
 */
@property (nonatomic) NSTimeInterval playerCurrentTime;

/**
 @brief                 Update the 3D audio player with the direction the user is looking
 @details               The 3D audio player will rotate all the loaded sounds based on the heading set here 
                        without manipulating the individual sound's heading
 */
@property (nonatomic, assign) float playerHeading;

/**
 @brief                 Update the 3D audio player with the altitude of the user (in millimeters)
 @details               The 3D audio player will adjust all the loaded sounds based on the altitude set here 
                        without manipulating the individual sound's altitude
 */
@property (nonatomic, assign) SInt32 playerAltitude;

/**
 @brief                 The reverb level in millibels (1/100 dB)
 @details               The reverb level goes from -infinit to 0 where 0 is full reverb.
                        A value of INT_MIN will disable reverb
 */
@property (nonatomic, assign) SInt32 playerReverbLevel;

/**
 @brief                 Is the 3D audio player playing?
 */
@property (nonatomic, readonly) BOOL isPlaying;

/**
 @brief                 Is the 3D audio player paused?
 */
@property (nonatomic, readonly) BOOL isPaused;

/**
 @brief                 Check if the 3D audio player is able to play sound
 */
@property (nonatomic, readonly) BOOL canPlay;


/**
 @brief                 Set the preferred device upon initializing the IHSDevice
 @details               The API will attempt to connect to the preferred set here, when connect is called
 @param                 Name of the preferred device to connect to
 */
- (id)initWithPreferredDevice:(NSString*)preferredDevice;


/**
 @brief                 Establish connection to the physical IHS
 @details               If no preferred device has previously been set, a list of available devices will be shown
                        Calling connect while the IHSDevice is in IHSDeviceConnectionStateConnected state will result
                        in a disconnect followed by a (re)connect
 */
- (void)connect;


/**
 @brief                 Close the connection to the physical IHS and pause all 3D audio playback
 */
- (void)disconnect;


/**
 @brief                 Check if the API is expired
 @details               The API will not allow connections to the IHS after the expiration date
 */
- (BOOL) isAPIExpired;

#pragma mark 3D audio handling

/**
 @brief                 Adds a sound to playback along with other sounds.
 @details               Currently only files on the local file system is supported.
 @param sound           The sound resource to load and playback
 @return                YES on success, else NO
 */
- (void)addSound:(GNAudio3DSound*)sound;

/**
 @brief                 Removes a sound from the playback pool.
 @param sound           The sound to remove. This sound will stop playing and then be removed.
 */
- (void)removeSound:(GNAudio3DSound*)sound;

/**
 @brief                 Removes all sounds from the player.
 */
- (void)clearSounds;

/**
 @brief                 Start the playback of the sound resource
 @details               The sound resource to playback must have been set with loadURL: before calling this method.
 @note                  Playback can only be started when the IHS device is connected. If the play method is called
                        while the IHS device is not connected, error status '0x3dee' will be returned through the delegate via
                        ihsDevice:playerRenderError:
 */
- (void)play;

/**
 @brief                 Pauses playback.
 @details               Playback can be resumed with a call to the play method and will resume at the point where it was paused.
 */
- (void)pause;

/**
 @brief                 Stops playback.
 @details               Playback can be resumed with a call to the play method and will resume from the beginning of the sound resource.
 */
- (void)stop;

@end
