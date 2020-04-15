//
//  LMDelegateCalibrating.m
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateCalibrating.h"

@implementation LMDelegateCalibrating : NSObject

/*!
 @method init
 @discussion Constructor given the shared data collection.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
{
    self = [super init];
    if (self) {
        
        // Components
        sharedData = initSharedData;
        
        // Initialize location manager and set this class as the delegate which implement the event response's methods
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        //[locationManager startUpdatingLocation];
        // It seems is only for background modes
        //locationManager.allowsBackgroundLocationUpdates = YES;
        //locationManager.pausesLocationUpdatesAutomatically = false;
        
        // Ask for authorization for location services
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                // Request when-in-use authorization initially
                [locationManager requestAlwaysAuthorization];
                break;
                
            case kCLAuthorizationStatusRestricted:
                // Disable location features
                [locationManager requestAlwaysAuthorization];
                break;
                
            case kCLAuthorizationStatusDenied:
                // Disable location features
                [locationManager requestAlwaysAuthorization];
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                // Enable location features
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // Enable location features
                break;
                
            default:
                break;
        }
        
        // This object must listen to this events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(start:)
                                                     name:@"lmdCalibrating/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMC] LocationManager prepared for monitoring mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = initDeviceUUID;
    }
    return self;
}

#pragma mark - Instance methods
/*!
 @method setCredentialUserDic:
 @discussion This method sets the dictionary with the user's credentials for access the collections in shared data database.
 */
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
    return;
}

/*!
 @method setUserDic:
 @discussion This method sets the dictionary of the user in whose name the measures are saved.
 */
- (void)setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
    return;
}

/*!
 @method setItemBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setItemBeaconIdNumber:(NSNumber *)givenItemBeaconIdNumber
{
    itemBeaconIdNumber = givenItemBeaconIdNumber;
}

/*!
 @method setItemPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setItemPositionIdNumber:(NSNumber *)givenItemPositionIdNumber
{
    itemPositionIdNumber = givenItemPositionIdNumber;
}

/*!
 @method setDeviceUUID:
 @discussion This method sets the UUID to identify the measures when self-locating.
 */
- (void)setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
    return;
}

#pragma mark - Location manager delegated methods - iBeacons
/*!
 @method locationManager:didChangeAuthorizationStatus:
 @discussion This method is called when the device's location permission change because user's desire or automatic routines; depending on the current permission status this delegate will start searching for beacon's regions or not.
 */
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // Request authorization initially
            NSLog(@"[ERROR][LMC] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMC] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMC] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMC] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMC] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMC] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMC] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMC] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMC] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMC] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMC] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMC] Heading available.");
    }else{
        NSLog(@"[ERROR][LMC] Heading not available.");
    }
}

/*!
 @method locationManager:didEnterRegion:
 @discussion This method is called when the device cross the border line and enters one of the monitor's monitorized regions (areas); ask the monitor to start searching for specific devices in the region.
 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLBeaconRegion *)region
{
    // Changed definition of method for (CLBeaconRegion *) instead of (CLRegion *)!!!!
    
    // Start ranging
    [manager startRangingBeaconsInRegion:region];
    NSLog(@"[INFO][LMC] Device ranged a region:");
    NSLog(@"[INFO][LMC] -> %@", [[region proximityUUID] UUIDString]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LMC] Device failed in raging a region:");
    NSLog(@"[ERROR][LMC] -> %@", [[region proximityUUID] UUIDString]);
}

/*!
 @method locationManager:didRangeBeacons:inRegion:
 @discussion This method is called when the device detects some other device in a ranged region; it saves it and ask view to show its information.
 */
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        /*
         [self alertUserWithTitle:@"Beacon ranged won't be procesed."
         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
         andHandler:^(UIAlertAction * action) {
         // TODO: handle intrusion situations. Alberto J. 2019/09/10.
         }
         ];
         */
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][LMC] Shared data could not be accessed when ranged a beacon.");
        return;
    }
    
    if (beacons.count > 0) {
                    
        for (CLBeacon *beacon in beacons) {
            // ...get its information...
            NSString * uuid = [[beacon proximityUUID] UUIDString];
            NSLog(@"[INFO][LMC] Beacon ranged %@.", uuid);
            
            // ...and compose a measure with them.
            [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithFloat:0.0]
                                          ofSort:@"calibration"
                                    withItemUUID:uuid
                                  withDeviceUUID:deviceUUID
                                      atPosition:nil
                                  takenByUserDic:userDic
                       andWithCredentialsUserDic:credentialsUserDic];
        }
        NSLog(@"[INFO][LMC] Generated measures:");
        NSLog(@"[INFO][LMC]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
        
    }
}

#pragma mark - Notification event handles

/*!
 @method start:
 @discussion This method is called when calibration process start.
 */
- (void) start:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"lmdCalibrating/start"]){
        NSLog(@"[NOTI][LMC] Notification \"lmdCalibrating/start\" recived.");
        
        NSDictionary * data = notification.userInfo;
        NSString * calibrationUUID = data[@"uuid"];
        NSLog(@"[INFO][LMC] The user asked to calibrate the iBeacon %@", calibrationUUID);
        
        // Validate the access to the data shared collection
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
        } else {
            /*
             [self alertUserWithTitle:@"Beacon ranged won't be procesed."
             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
             andHandler:^(UIAlertAction * action) {
             // TODO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            NSLog(@"[ERROR][LMC] Shared data could not be accessed while calibrating.");
            return;
        }
        
        // Search for the item that the user wants to calibrate
        NSMutableArray * itemsToCalibrate = [sharedData fromItemDataGetItemsWithUUID:calibrationUUID
                                                               andCredentialsUserDic:credentialsUserDic];
        if (itemsToCalibrate.count == 0) {
            NSLog(@"[ERROR][LMC] No item found for UUID %@ when calibrating.", calibrationUUID);
            
            // Delete registered regions and heading updates
            [self stopRoutine];
            // Notify menu that calibration is finished.
            NSLog(@"[NOTI][LMC] Notification \"calibration/finished\" posted.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"calibration/finished"
             object:nil];
            return;
        }
        if (itemsToCalibrate.count > 1) {
            NSLog(@"[ERROR][LMC] More than one item found with UUID %@ when calibrating.", calibrationUUID);
        }
        
        // Register it if it is posible.
        [self locationManager:locationManager didChangeAuthorizationStatus:CLLocationManager.authorizationStatus];
        
        itemToCalibrate = [itemsToCalibrate objectAtIndex:0];
        monitoredRegions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            
            // Resgiter the region to be calibrated
            
            // Could be a position or a beacon
            if ([@"beacon" isEqualToString:itemToCalibrate[@"sort"]]) {
                NSInteger major = [itemToCalibrate[@"major"] integerValue];
                NSInteger minor = [itemToCalibrate[@"minor"] integerValue];
                NSString * identifier = itemToCalibrate[@"identifier"];
                
                // Create a NSUUID with proximity UUID of the broadcasting beacons
                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:calibrationUUID];
                
                // Setup searching region with proximity UUID as the broadcasting beacon
                CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
                [monitoredRegions addObject:region];
                
                [locationManager startRangingBeaconsInRegion:region];
                
                NSLog(@"[INFO][LMC] Device calibrating with the iBeacon:");
                NSLog(@"[INFO][LMC] -> %@", [[region proximityUUID] UUIDString]);
            } else {
                NSLog(@"[ERROR][LMC] Trying to calibrate not a beacon.");
                // Notify menu that calibration is finished.
                
                // Delete registered regions and heading updates
                [self stopRoutine];
                
                NSLog(@"[NOTI][LMC] Notification \"calibration/finished\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"calibration/finished"
                 object:nil];
                return;
            }
            NSLog(@"[INFO][LMC] Start calibrating with UUID %@", calibrationUUID);
        
        }
            else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted)
        {
            // If is not allowed to use location services, delete registered regions and heading updates
            [self stopRoutine];
        }
    }
}

/*!
 @method stopRoutine
 @discussion Called when the location manager must stop measuring.
 */
- (void) stopRoutine {
    // Delete registered regions and heading updates
    if (locationManager) {
        if (locationManager.monitoredRegions) {
            for(CLBeaconRegion * region in  locationManager.monitoredRegions){
                [locationManager stopMonitoringForRegion:region];
                [locationManager stopRangingBeaconsInRegion:region];
            }
        }
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
    }
}

/*!
 @method reset
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) reset:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"lmd/reset"]){
        NSLog(@"[NOTI][LMC] Notification \"lmd/reset\" recived.");
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
