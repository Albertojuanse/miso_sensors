//
//  LMDelegateMonitoring.m
//  Sensors test
//
//  Created by Alberto J. on 16/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateMonitoring.h"

@implementation LMDelegateMonitoring : NSObject

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
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
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
                                                 selector:@selector(startMonitoringMeasures:)
                                                     name:@"startMonitoringMeasures"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopMonitoringMeasures:)
                                                     name:@"stopMonitoringMeasures"
                                                   object:nil];
        
        NSLog(@"[INFO][LMM] LocationManager prepared for monitoring mode.");
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
    sharedData = initSharedData;
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    deviceUUID = initDeviceUUID;
    self = [self initWithSharedData:initSharedData];
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
 @method setDeviceUUID:
 @discussion This method sets the UUID to identify the measures when self-locating.
 */
- (void)setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
    return;
}

/*!
 @method getPosition
 @discussion This method gets the device's position.
 */
- (RDPosition *) getPosition {
    RDPosition * newPosition = [[RDPosition alloc] init];
    newPosition.x = [NSNumber numberWithFloat:[position.x floatValue]];
    newPosition.y = [NSNumber numberWithFloat:[position.y floatValue]];
    newPosition.z = [NSNumber numberWithFloat:[position.z floatValue]];
    return newPosition;
}

/*!
 @method setPosition:
 @discussion This method sets the device's position.
 */
- (void) setPosition:(RDPosition *)givenPosition{
    position = nil; // ARC disposing
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:[givenPosition.x floatValue]];
    position.y = [NSNumber numberWithFloat:[givenPosition.y floatValue]];
    position.z = [NSNumber numberWithFloat:[givenPosition.z floatValue]];
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
            NSLog(@"[ERROR][LMM] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMM] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMM] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMM] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMM] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMM] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMM] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMM] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMM] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMM] Heading available.");
    }else{
        NSLog(@"[ERROR][LMM] Heading not available.");
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
    NSLog(@"[INFO][LMM] Device ranged a region:");
    NSLog(@"[INFO][LMM] -> %@", [[region proximityUUID] UUIDString]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LMM] Device failed in raging a region:");
    NSLog(@"[ERROR][LMM] -> %@", [[region proximityUUID] UUIDString]);
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
         // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
         }
         ];
         */
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][LMM] Shared data could not be accessed when ranged a beacon.");
        return;
    }
    
    if (beacons.count > 0) {
    
        // Different behave depending on the current state
        // If the device user is measuring
        if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) {
            
            // Get the measuring mode
            MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                            andCredentialsUserDic:credentialsUserDic];
            
            // If a monitoring type system; needs to save the UUID
            if (
                [mode isModeKey:kModeMonitoring]
                ) {
                
                // If there is any beacon in the event...
                if (beacons.count > 0) {
                    
                    for (CLBeacon *beacon in beacons) {
                        // ...get its information...
                        NSString * uuid = [[beacon proximityUUID] UUIDString];
                        NSLog(@"[INFO][LMM] Beacon ranged %@; registering.", uuid);
                        
                        RDPosition * registerPosition = [[RDPosition alloc] init];
                        registerPosition.x = position.x;
                        registerPosition.y = position.y;
                        registerPosition.z = position.z;
                        
                        // ...and compose a measure with them.
                        [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithFloat:0.0]
                                                      ofSort:@"rssi"
                                                withItemUUID:uuid
                                              withDeviceUUID:deviceUUID
                                                  atPosition:registerPosition
                                              takenByUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
                    }
                    NSLog(@"[INFO][LMM] Generated measures:");
                    NSLog(@"[INFO][LMM]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
                    
                    // Ask view controller to refresh the canvas and table
                    if(beacons.count > 0) {
                        NSLog(@"[NOTI][LMM] Notification \"refreshCanvas\" posted.");
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"refreshCanvas"
                         object:nil];
                        NSLog(@"[NOTI][LMM] Notification \"refreshRegisterTable\" posted.");
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"refreshRegisterTable"
                         object:nil];
                    }
                }
            }
            
        } else { // If is idle or traveling...
            // ...if there is any beacon in the event...
            if (beacons.count > 0) {
                // ...do something with them or it will be saved in some Ipad's buffering queue and appear later.
                for (CLBeacon *beacon in beacons) {
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    uuid = nil; // ARC dispose
                    NSNumber * rssi = [NSNumber numberWithInteger:[beacon rssi]];
                    rssi = nil;
                }
            }
        }
        
    }
}

#pragma mark - Notification event handles
/*!
 @method startMonitoringMeasures
 @discussion This method sets the flag 'measuring' true, and thus the measures are stored.
 */
- (void) startMonitoringMeasures:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"startMonitoringMeasures"]){
        NSLog(@"[NOTI][LMM] Notification \"startMonitoringMeasures\" recived.");
        
        // Register the beacons only if posible.
        [self locationManager:locationManager didChangeAuthorizationStatus:CLLocationManager.authorizationStatus];
        
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
             // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            NSLog(@"[ERROR][LMM] Shared data could not be accessed while starting locating measure.");
            return;
        }
        
        // Get the measuring mode and items for initializing
        NSMutableArray * items = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        monitoredRegions = [[NSMutableArray alloc] init];
        monitoredPositions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if ([mode isModeKey:kModeMonitoring]) {
                
                // Resgiter the regions to be monitorized
                for (NSMutableDictionary * itemDic in items) {
                    
                    // Could be a position or a beacon
                    if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                        NSString * uuidString = itemDic[@"uuid"];
                        NSInteger major = [itemDic[@"major"] integerValue];
                        NSInteger minor = [itemDic[@"minor"] integerValue];
                        NSString * identifier = itemDic[@"identifier"];
                        
                        // Create a NSUUID with proximity UUID of the broadcasting beacons
                        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
                        
                        // Setup searching region with proximity UUID as the broadcasting beacon
                        CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
                        [monitoredRegions addObject:region];
                        
                        [locationManager startRangingBeaconsInRegion:region];
                        NSLog(@"[INFO][LMM] Device monitorizes a region:");
                        NSLog(@"[INFO][LMM] -> %@", [[region proximityUUID] UUIDString]);
                        
                        // But if its position is loaded, the user wants to use it to locate itself against them
                        if (itemDic[@"position"]) {
                            [monitoredPositions addObject:itemDic[@"position"]];
                        }
                    }
                    if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                        [monitoredPositions addObject:itemDic[@"position"]];
                    }
                    
                }
                NSLog(@"[INFO][LMM] Start monitoring regions.");
            } else {
                NSLog(@"[ERROR][LMM] Instantiated class %@ when using %@ mode.",
                      NSStringFromClass([self class]),
                      mode
                      );
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            // If is not allowed to use location services, delete registered regions and heading updates
            [self stopRoutine];
        }
    }
}

/*!
 @method stopMonitoringMeasures:
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored; it also deletes the monitored regions from location manager.
 */
- (void) stopMonitoringMeasures:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopMonitoringMeasures"]) {
        NSLog(@"[NOTI][LMM] Notification \"stopMonitoringMeasures\" recived.");
        // Delete registered regions and heading updates
        [self stopRoutine];
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
    if ([[notification name] isEqualToString:@"resetLocationAndMeasures"]){
        NSLog(@"[NOTI][LM] Notification \"resetLocationAndMeasures\" recived.");
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end