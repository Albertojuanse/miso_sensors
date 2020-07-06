//
//  LMDelegateRhoRhoModelling.m
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateRhoRhoModelling.h"

@implementation LMDelegateRhoRhoModelling : NSObject

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
        
        // Instance variables (modelling mode)
        // Set device's location at the origin
        devicePosition = [[RDPosition alloc] init];
        devicePosition.x = [NSNumber numberWithFloat:0.0];
        devicePosition.y = [NSNumber numberWithFloat:0.0];
        devicePosition.z = [NSNumber numberWithFloat:0.0];
        
        // Initialize location manager and set this class as the delegate which implement the event response's methods
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
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
                                                     name:@"lmdRhoRhoModelling/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdRhoRhoModelling/stop"
                                                   object:nil];        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rangingMeasureFinishedWithErrors:)
                                                     name:@"lmd/rangingMeasureFinishedWithErrors"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMRRM] LocationManager prepared for kModeRhoRhoModelling mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:rhoRhoSystem:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = initDeviceUUID;
        rhoRhoSystem = initRhoRhoSystem;
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
    newPosition.x = [NSNumber numberWithFloat:[devicePosition.x floatValue]];
    newPosition.y = [NSNumber numberWithFloat:[devicePosition.y floatValue]];
    newPosition.z = [NSNumber numberWithFloat:[devicePosition.z floatValue]];
    return newPosition;
}

/*!
 @method setPosition:
 @discussion This method sets the device's position.
 */
- (void) setPosition:(RDPosition *)givenPosition{
    devicePosition = nil; // ARC disposing
    devicePosition = [[RDPosition alloc] init];
    devicePosition.x = [NSNumber numberWithFloat:[givenPosition.x floatValue]];
    devicePosition.y = [NSNumber numberWithFloat:[givenPosition.y floatValue]];
    devicePosition.z = [NSNumber numberWithFloat:[givenPosition.z floatValue]];
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
            NSLog(@"[ERROR][LMRRM] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMRRM] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMRRM] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMRRM] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMRRM] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMRRM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMRRM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMRRM] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMRRM] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMRRM] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMRRM] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMRRM] Heading available.");
    }else{
        NSLog(@"[ERROR][LMRRM] Heading not available.");
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
    
    NSLog(@"[INFO][LMRRM] Device ranged a region:");
    NSLog(@"[INFO][LMRRM] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region: %@", [[region proximityUUID] UUIDString]]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LMRRM] Device failed in raging a region:");
    NSLog(@"[ERROR][LMRRM] -> %@", [[region proximityUUID] UUIDString]);
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
        NSLog(@"[ERROR][LMRRM] Shared data could not be accessed when beacon ranged.");
        return;
    }
    
    if (beacons.count > 0) {
        
        // Different behave depending on the current state
        // If app is measuring the device user
        if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) {
            
            // Get the measuring mode
            MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                            andCredentialsUserDic:credentialsUserDic];
            
            // If a monitoring type system; needs to save the UUID
            if ([mode isModeKey:kModeRhoRhoModelling]) {
                
                BOOL newMeasuresSaved = NO;
                // For every ranged beacon...
                for (CLBeacon *beacon in beacons) {
                    
                    // ...get its information...
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = devicePosition.x;
                    measurePosition.y = devicePosition.y;
                    measurePosition.z = devicePosition.z;
                    
                    // ...and save the measure of the item.
                    if (itemToMeasureUUID) {
                        
                        // The measure is saved only if event's uuid and the chosen one are the same.
                        if ([itemToMeasureUUID isEqualToString:uuid]) {
                            // ...and save it.
                            [sharedData inMeasuresDataSetMeasure:beacon
                                                          ofSort:@"rssi"
                                                    withItemUUID:itemToMeasureUUID
                                                  withDeviceUUID:deviceUUID
                                                      atPosition:measurePosition
                                                  takenByUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
                        }
                    } else {
                        NSLog(@"[ERROR][LMRRL] Measure not saved since user did not choose any item.");
                        return;
                    }
                    
                }
                
                if(newMeasuresSaved){
                    // Notify that there are new measures
                    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                    [data setObject:itemToMeasureUUID forKey:@"calibrationUUID"];
                    NSLog(@"[NOTI][LMRRM] Notification \"ranging/newMeasuresAvalible\" posted.");
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"ranging/newMeasuresAvalible"
                     object:nil
                     userInfo:data];
                }
                
            } else {
                NSLog(@"[ERROR][LMRRM] Calling mode is not kModeRhoThetaModelling.");
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
 @method start:
 @discussion This method asks the Location Manager to start positioning the device using beacons.
 */
- (void) start:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdRhoRhoModelling/start"]){
        NSLog(@"[NOTI][LMRRM] Notification \"lmdRhoRhoModelling/start\" recived.");
        
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
            NSLog(@"[ERROR][LMRRM] Shared data could not be accessed while starting locating measure.");
            return;
        }
        
        // Get the measuring mode and items for initializing
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        monitoredRegions = [[NSMutableArray alloc] init];
        monitoredPositions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if ([mode isModeKey:kModeRhoRhoModelling]) {
                
                // Get class variables to get the item's position facet from the item chosen by user to be the device (modelling mode)
                NSMutableDictionary * itemChosenByUserDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
                deviceUUID = itemChosenByUserDic[@"uuid"];
                if (itemChosenByUserDic[@"position"]) {
                    devicePosition = itemChosenByUserDic[@"position"];
                } else {
                    NSLog(@"[ERROR][LMRRM] No position found in item to be measured.");
                }

                // Get class variables to get the item's position facet from the item chosen by user to measure (modelling mode)
                NSDictionary * dataDic = [notification userInfo];
                NSMutableDictionary * itemDic = dataDic[@"itemDic"];
                itemToMeasureUUID = itemDic[@"uuid"];
                
                // Could be only a a beacon
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
                    NSLog(@"[INFO][LMRRM] Device monitorizes a region:");
                    NSLog(@"[INFO][LMRRM] -> %@", [[region proximityUUID] UUIDString]);
                } else {
                    NSLog(@"[ERROR][LMRRM] Item to measure is not a iBeacon device.");
                }
                
                NSLog(@"[INFO][LMRRM] Start updating beacons.");
            } else {
                NSLog(@"[ERROR][LMRRM] Calling mode is not kModeRhoRhoModelling.");
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            [self stopRoutine];
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                  andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[ERROR][LMRRM] Location services not allowed; updating beacons.");
        }
    }
}

/*!
 @method stop:
 @discussion This method asks the Location Manager to stop positioning the device using beacons.
 */
- (void) stop:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdRhoRhoModelling/stop"]){
        NSLog(@"[NOTI][LMRRM] Notification \"lmdRhoRhoModelling/stop\" recived.");
        // TODO: Valorate this next sentence. Alberto J. 2019/12/11.
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self stopRoutine];
        NSLog(@"[INFO][LMRRM] Stop updating compass and iBeacons.");
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
        NSLog(@"[NOTI][LMRRM] Notification \"lmd/reset\" recived.");
        
        // Instance variables
        // Set device's location at the origin
        devicePosition = [[RDPosition alloc] init];
        devicePosition.x = [NSNumber numberWithFloat:0.0];
        devicePosition.y = [NSNumber numberWithFloat:0.0];
        devicePosition.z = [NSNumber numberWithFloat:0.0];
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
