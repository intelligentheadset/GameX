//
//  GNFlipsideViewController.m
//  GameExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNFlipsideViewController.h"
#import "GNAppDelegate.h"
#import "IHSDevice.h"
#import "NSString+IHSDeviceConnectionState.h"

typedef enum
{
    SectionType_Gps,
    SectionType_SensorData,
    SectionType_DeviceInfo,
    SectionType_Count
} SectionType;

typedef enum
{
    // GPS section:
    SectionItem_Gps_Latitude = 0,
    SectionItem_Gps_Longitude,
    SectionItem_Gps_HorizAccuracy,
    SectionItem_Gps_FusedHeading,
    SectionItem_Gps_CompassHeading,
    SectionItem_Gps_Count,
    
    // SensorData section:
    SectionItem_SensorData_MagneticFieldStrength = 0,
    SectionItem_SensorData_MagneticDisturbance,
    SectionItem_SensorData_GyroCalibrationStatus,
    SectionItem_SensorData_Pitch,
    SectionItem_SensorData_Roll,
    SectionItem_SensorData_Yaw,
    SectionItem_SensorData_AccelerometerX,
    SectionItem_SensorData_AccelerometerY,
    SectionItem_SensorData_AccelerometerZ,
    SectionItem_SensorData_Count,
    
    // DeviceInfo section:
    SectionItem_DeviceInfo_Name = 0,
    SectionItem_DeviceInfo_ConnectionState,
    SectionItem_DeviceInfo_Firmware,
    SectionItem_DeviceInfo_APIStatus,
    SectionItem_DeviceInfo_Count,
    
} SectionItem;

@interface GNFlipsideViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSTimer*  updateTimer;
@property (strong, nonatomic) NSMutableDictionary* indexPathToValue;

@end

@implementation GNFlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 900.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indexPathToValue = [NSMutableDictionary new];

    self.updateTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateContent:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
}

- (void)viewDidUnload
{
    self.tableview = nil;
    self.updateTimer = nil;

    [super viewDidUnload];
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionType_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ( (SectionType)section )
    {
        case SectionType_Gps:           return SectionItem_Gps_Count;
        case SectionType_DeviceInfo:    return SectionItem_DeviceInfo_Count;
        case SectionType_SensorData:    return SectionItem_SensorData_Count;
            
        case SectionType_Count:         return 0;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString*   title = nil;
    
    switch ( (SectionType)section )
    {
        case SectionType_Gps:           title = @"Position and heading";    break;
        case SectionType_DeviceInfo:    title = @"Device info";             break;
        case SectionType_SensorData:    title = @"Sensor data";             break;
            
        case SectionType_Count:                                             break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*   reuseIdentifier = @"text_value_cell";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch ( (SectionType)indexPath.section )
    {
        case SectionType_Gps:
            switch ( (SectionItem)indexPath.row )
            {
                case SectionItem_Gps_Latitude:
                    cell.textLabel.text = @"Latitude";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.5g °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_Gps_Longitude:
                    cell.textLabel.text = @"Longitude";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.5g °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_Gps_FusedHeading:
                    cell.textLabel.text = @"Fused heading";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f °", [[self valueForRowAtIndexPath:indexPath] floatValue] ];
                    break;
                case SectionItem_Gps_CompassHeading:
                    cell.textLabel.text = @"Compass heading";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_Gps_HorizAccuracy:
                    cell.textLabel.text = @"Horiz accuracy";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f m", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                    
                default:
                    break;
            }
            break;

            
        case SectionType_SensorData:
            switch ( (SectionItem)indexPath.row )
            {
                case SectionItem_SensorData_MagneticFieldStrength:
                    cell.textLabel.text = @"Magnetic field strength";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mG", [[self valueForRowAtIndexPath:indexPath] integerValue]];
                    break;
                case SectionItem_SensorData_MagneticDisturbance:
                    cell.textLabel.text = @"Magnetic disturbance";
                    cell.detailTextLabel.text = [self valueForRowAtIndexPath:indexPath];
                    break;
                case SectionItem_SensorData_GyroCalibrationStatus:
                    cell.textLabel.text = @"Gyro calibrated";
                    cell.detailTextLabel.text = [self valueForRowAtIndexPath:indexPath];
                    break;
                case SectionItem_SensorData_Pitch:
                    cell.textLabel.text = @"Pitch";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.1f °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_SensorData_Roll:
                    cell.textLabel.text = @"Roll";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.1f °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_SensorData_Yaw:
                    cell.textLabel.text = @"Yaw";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.1f °", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_SensorData_AccelerometerX:
                    cell.textLabel.text = @"Accelerometer X";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.2f G", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_SensorData_AccelerometerY:
                    cell.textLabel.text = @"Accelerometer Y";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.2f G", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                case SectionItem_SensorData_AccelerometerZ:
                    cell.textLabel.text = @"Accelerometer Z";
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%.2f G", [[self valueForRowAtIndexPath:indexPath] floatValue]];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SectionType_DeviceInfo:
            switch ( (SectionItem)indexPath.row )
            {
                case SectionItem_DeviceInfo_Name:
                    cell.textLabel.text = @"Name";
                    cell.detailTextLabel.text = APP_DELEGATE.ihsDevice.name;
                    break;
                case SectionItem_DeviceInfo_ConnectionState:
                    cell.textLabel.text = @"State";
                    cell.detailTextLabel.text = [NSString stringFromIHSDeviceConnectionState:APP_DELEGATE.ihsDevice.connectionState];
                    break;
                case SectionItem_DeviceInfo_Firmware:
                    cell.textLabel.text = @"Firmware";
                    cell.detailTextLabel.text = (APP_DELEGATE.ihsDevice.firmwareRevision.length > 0) ? APP_DELEGATE.ihsDevice.firmwareRevision : @"(unknown)";
                    break;
                case SectionItem_DeviceInfo_APIStatus:
                    cell.textLabel.text = @"API Status";
                    cell.detailTextLabel.text = APP_DELEGATE.ihsDevice.isAPIExpired ? @"Expired" : @"OK";
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell ?: [UITableViewCell new];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ( indexPath.section )
    {
        default:
            break;
    }
}


#pragma mark - utilities

- (id) valueForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id  result;

    switch ( (SectionType)indexPath.section )
    {
        case SectionType_Gps:
            switch ( (SectionItem)indexPath.row ) {
                case SectionItem_Gps_Latitude:
                    result = @(APP_DELEGATE.ihsDevice.latitude);
                    break;
                case SectionItem_Gps_Longitude:
                    result = @(APP_DELEGATE.ihsDevice.longitude);
                    break;
                case SectionItem_Gps_FusedHeading:
                    result = @(APP_DELEGATE.ihsDevice.fusedHeading);
                    break;
                case SectionItem_Gps_CompassHeading:
                    result = @(APP_DELEGATE.ihsDevice.compassHeading);
                    break;
                case SectionItem_Gps_HorizAccuracy:
                    result = @(APP_DELEGATE.ihsDevice.horizontalAccuracy);
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SectionType_SensorData:
            switch ( (SectionItem)indexPath.row ) {
                case SectionItem_SensorData_MagneticFieldStrength:
                    result = @(APP_DELEGATE.ihsDevice.magneticFieldStrength);
                    break;
                case SectionItem_SensorData_MagneticDisturbance:
                    result = APP_DELEGATE.ihsDevice.magneticDisturbance ? @"Yes" : @"No";
                    break;
                case SectionItem_SensorData_GyroCalibrationStatus:
                    result = APP_DELEGATE.ihsDevice.gyroUncalibrated ? @"No" : @"Yes";
                    break;
                case SectionItem_SensorData_Pitch:
                    result = @(APP_DELEGATE.ihsDevice.pitch);
                    break;
                case SectionItem_SensorData_Roll:
                    result = @(APP_DELEGATE.ihsDevice.roll);
                    break;
                case SectionItem_SensorData_Yaw:
                    result = @(APP_DELEGATE.ihsDevice.yaw);
                    break;
                case SectionItem_SensorData_AccelerometerX:
                    result = @(APP_DELEGATE.ihsDevice.accelerometerData.x);
                    break;
                case SectionItem_SensorData_AccelerometerY:
                    result = @(APP_DELEGATE.ihsDevice.accelerometerData.y);
                    break;
                case SectionItem_SensorData_AccelerometerZ:
                    result = @(APP_DELEGATE.ihsDevice.accelerometerData.z);
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SectionType_DeviceInfo:
            switch ( (SectionItem)indexPath.row ) {
                case SectionItem_DeviceInfo_Name:
                    break;
                case SectionItem_DeviceInfo_ConnectionState:
                    result = [NSString stringFromIHSDeviceConnectionState:APP_DELEGATE.ihsDevice.connectionState];
                    break;
                case SectionItem_DeviceInfo_Firmware:
                    break;
                case SectionItem_DeviceInfo_APIStatus:
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        default:
            break;
    }
    
    return result;
}


- (BOOL) shouldUpdateCellAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL    shouldUpdate = NO;
    id      value        = [self valueForRowAtIndexPath:indexPath];
    id      lastValue    = self.indexPathToValue[ indexPath ];
    
    if ( value ) {
        if ( lastValue && ![lastValue isEqual:value] ) {
            shouldUpdate = YES;
        }
        
        self.indexPathToValue[ indexPath ] = value;
    }
    
    return shouldUpdate;    
}


- (BOOL) shouldUpdateCellAtRow:(NSInteger)row inSection:(NSInteger)section withValue:(id)value
{
    return [self shouldUpdateCellAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}


- (void) updateContent:(NSTimer*)theTimer
{
    NSMutableArray*     updates = [NSMutableArray new];
    
    for ( int section = 0; section < SectionType_Count; ++section ) {
        int   rowsInSection = [self.tableview numberOfRowsInSection:section];
        for ( int row = 0; row < rowsInSection; ++row ) {
            NSIndexPath*    indexPath = [NSIndexPath indexPathForRow:row inSection:section ];
            if ( [self shouldUpdateCellAtIndexPath:indexPath] ) {
                [updates addObject:indexPath];
            }
        }
    }
    [self.tableview reloadRowsAtIndexPaths:updates withRowAnimation:UITableViewRowAnimationNone];
}

@end
