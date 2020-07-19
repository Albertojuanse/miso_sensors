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
                                                 selector:@selector(start:)
                                                     name:@"lmdMonitoring/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdMonitoring/stop"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rangingMeasureFinishedWithErrors:)
                                                     name:@"lmd/rangingMeasureFinishedWithErrors"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMM] LocationManager prepared for monitoring mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
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

#pragma mark - Location manager delegated methods - iBeacons
/*
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
         // TODO: handle intrusion situations. Alberto J. 2019/09/10.
         }
         ];
         */
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
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
                    
                for (CLBeacon *beacon in beacons) {
                    // ...get its information...
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    NSLog(@"[INFO][LMM] Beacon ranged %@; registering.", uuid);
                    //NSLog(@"[HOLA][LMM] RSSI: %.6f", (float)[beacon rssi]);
                    //float C = 299792458.0;
                    //float F = 2440000000.0; // 2400 - 2480 MHz
                    //float G = 1.0; // typically 2.16 dBi
                    // Calculate the distance pow(10.0, -[[beacon rssi] floatValue]/ 10.0)
                    //float power = 0.001*pow(10.0,(0.0/10.0))*pow(10.0,(-(float)[beacon rssi]/10.0));
                    //NSLog(@"[HOLA][LMM] power: %.6f", power);
                    //float distance = (C / (4.0 * M_PI * F)) * sqrt(G * power);
                    //NSLog(@"[HOLA][LMM] distance: %.6f", distance);
                    
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
                NSLog(@"[INFO][LMM] Generated measures: %@",
                      [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
                
                // Ask view controller to refresh the canvas and table
                NSLog(@"[NOTI][LMM] Notification \"canvas/refresh\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"canvas/refresh"
                 object:nil];
                NSLog(@"[NOTI][LMM] Notification \"cvm/registerTable/refresh\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"cvm/registerTable/refresh"
                 object:nil];
            }
            
        } else { // If is idle or traveling...
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

#pragma mark - Notification event handles
/*!
 @method start
 @discussion This method configures the location manager and registers all items that must be located.
 */
- (void) start:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"lmdMonitoring/start"]){
        NSLog(@"[NOTI][LMM] Notification \"lmdMonitoring/start\" recived.");
        
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
             // TODO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            NSLog(@"[ERROR][LMM] Shared data could not be accessed while starting locating measure.");
            return;
        }
        // TODO: This as the rest. Alberto J. 2020/07/07
        // Get class variables to get the item's position facet from the item chosen by user to measure (modelling mode)
        NSDictionary * dataDic = [notification userInfo];
        position = dataDic[@"position"];
        
        // (···)
        // Get the measuring mode and items for initializing
        NSMutableArray * items = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        monitoredRegions = [[NSMutableArray alloc] init];
        
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
 @method stop:
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored; it also deletes the monitored regions from location manager.
 */
- (void) stop:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdMonitoring/stop"]) {
        NSLog(@"[NOTI][LMM] Notification \"lmdMonitoring/stop\" recived.");
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
 @method rangingMeasureFinishedWithErrors:
 @discussion This method asks the Location Manager to stop positioning the device due an error, and reset the measures.
 */
- (void) rangingMeasureFinishedWithErrors:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmd/rangingMeasureFinishedWithErrors"]){
        NSLog(@"[NOTI][LMRTM] Notification \"lmd/rangingMeasureFinishedWithErrors\" recived.");
        [self stopRoutine];
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
        NSLog(@"[INFO][LMRTM] Stop updating compass and iBeacons.");
    }
}

/*!
 @method reset
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) reset:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"lmd/reset"]){
        NSLog(@"[NOTI][LMM] Notification \"lmd/reset\" recived.");
        
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
