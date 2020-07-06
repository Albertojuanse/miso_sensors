//
//  LMDelegteRhoThetaModelling.m
//  Sensors test
//
//  Created by Alberto J. on 20/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateRhoThetaModelling.h"

@implementation LMDelegateRhoThetaModelling : NSObject

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
                                                     name:@"lmdRhoThetaModelling/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdRhoThetaModelling/stop"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rangingMeasureFinishedWithErrors:)
                                                     name:@"lmd/rangingMeasureFinishedWithErrors"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMRTM] LocationManager prepared for kModeRhoThetaModelling mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:rhoThetaSystem:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    // TODO: deviceUUID is the one chosen by user each time. Alberto J. 2020/06/25.
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        rhoThetaSystem = initRhoThetaSystem;
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
            NSLog(@"[ERROR][LMRTM] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMRTM] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMRTM] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMRTM] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMRTM] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMRTM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMRTM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMRTM] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMRTM] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMRTM] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMRTM] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMRTM] Heading available.");
    }else{
        NSLog(@"[ERROR][LMRTM] Heading not available.");
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
    
    NSLog(@"[INFO][LMRTM] Device ranged a region:");
    NSLog(@"[INFO][LMRTM] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region: %@", [[region proximityUUID] UUIDString]]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LMRTM] Device failed in raging a region:");
    NSLog(@"[ERROR][LMRTM] -> %@", [[region proximityUUID] UUIDString]);
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
        NSLog(@"[ERROR][LMRTM] Shared data could not be accessed when beacon ranged.");
        return;
    }
    
    if (beacons.count > 0) {
        
        // Different behave depending on the current state
        // If app is measuring the device user
        if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic
                                            andCredentialsUserDic:credentialsUserDic]) {
            
            // Get the measuring mode
            MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                            andCredentialsUserDic:credentialsUserDic];
            
            // If a monitoring type system; needs to save the UUID
            if ([mode isModeKey:kModeRhoThetaModelling]) { // (modelling mode)
                
                BOOL newMeasuresSaved = NO;
                // For every ranged beacon...
                for (CLBeacon *beacon in beacons) {
                    
                    // ...get its information...
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    
                    // ...get position facet's information...
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = devicePosition.x;
                    measurePosition.y = devicePosition.y;
                    measurePosition.z = devicePosition.z;
                    
                    // ...and save the measure of the item.
                    if (itemToMeasureUUID) {
                    
                        // The measure is saved only if event's uuid and the chosen one are the same; also, the heading measures only will be saved if becons measures are saved, when 'isItemToMeasureRanged' is true.
                        if ([itemToMeasureUUID isEqualToString:uuid]) {
                            
                            // Conditional clausule for an specific issue with Apple devices' heading measures:
                            if (!isItemToMeasureRanged) {
                                // Device does not deliver heading measures unless new values available; when RSSI measures from the chosen item is saved, can occur that no heading is saved until user moves the device. If it happens, the delegated method 'locationManager:didUpdateHeading:' is never called, and so, this method saves its value once. If 'isItemToMeasureRanged' flag is false means this is the first time that this item is ranged, and thus, this heading is saved as a first heading measure to, at least, save one.
                                [sharedData inMeasuresDataSetMeasure:lastHeadingPosition
                                                              ofSort:@"heading"
                                                        withItemUUID:itemToMeasureUUID
                                                      withDeviceUUID:deviceUUID
                                                          atPosition:measurePosition
                                                      takenByUserDic:userDic
                                           andWithCredentialsUserDic:credentialsUserDic];
                            }
                            
                            isItemToMeasureRanged = YES;
                            newMeasuresSaved = YES;
                            // Save the measure
                            [sharedData inMeasuresDataSetMeasure:beacon
                                                          ofSort:@"rssi"
                                                    withItemUUID:itemToMeasureUUID
                                                  withDeviceUUID:deviceUUID
                                                      atPosition:measurePosition
                                                  takenByUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
                        }
                    
                    } else {
                        NSLog(@"[ERROR][LMRTM] Measure not saved since user did not choose any item.");
                        return;
                    }
                    
                }
                
                if(newMeasuresSaved){
                    // Notify that there are new measures
                    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                    [data setObject:itemToMeasureUUID forKey:@"calibrationUUID"];
                    NSLog(@"[NOTI][LMRTM] Notification \"ranging/newMeasuresAvalible\" posted.");
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"ranging/newMeasuresAvalible"
                     object:nil
                     userInfo:data];
                }
                                    
            } else {
                NSLog(@"[ERROR][LMRTM] Calling mode is not kModeRhoThetaModelling.");
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

#pragma mark - Location manager delegated methods - Compass
/*!
 @method locationManager:didUpdateHeading:
 @discussion This method is called when the device wants to deliver a data about its heading.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
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
        NSLog(@"[ERROR][LMRTM] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // Different behave depending on the current state
    // If app is measuring the device user
    if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) {
        
        // Get the measuring mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        
        // If a rho type system
        if ([mode isModeKey:kModeRhoThetaModelling]) {
            
            // The heading measures in this mode are only saved if there is already any beacon measure saved
            if(isItemToMeasureRanged) {
                
                if (itemToMeasureUUID) {
                    
                    // Get position facet's information...
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = devicePosition.x;
                    measurePosition.y = devicePosition.y;
                    measurePosition.z = devicePosition.z;
                    
                    // ...and save the measure of the item.
                    [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                                  ofSort:@"heading"
                                            withItemUUID:itemToMeasureUUID
                                          withDeviceUUID:deviceUUID
                                              atPosition:measurePosition
                                          takenByUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
                }
                
            } else {
                NSLog(@"[INFO][LMRTM] User did choose a UUID source that is not being ranging; disposing.");
            }
        } else {
            NSLog(@"[ERROR][LMRTM] Calling mode is not kModeRhoThetaModelling.");
        }
        
    } else { // If is idle...
        // Do nothing
    }
    
    // Save it even if measure is not needed because when a beacon is located, the first one is saved.
    lastHeadingPosition = [NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0];
}

/*!
 @method locationManagerShouldDisplayHeadingCalibration:
 @discussion Adverts the user that compass needs calibration.
 */
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    CLLocationDirection accuracy = [[manager heading] headingAccuracy];
    return !accuracy || accuracy <= 0.0f || accuracy > 3.0f; // 0 means invalid heading, need to calibrate
}

#pragma mark - Notification event handles
/*!
 @method start:
 @discussion This method asks the Location Manager to start positioning the device using compass and iBeacons.
 */
- (void) start:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdRhoThetaModelling/start"]){
        NSLog(@"[NOTI][LMRTM] Notification \"lmdRhoThetaModelling/start\" recived.");
        
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
            NSLog(@"[ERROR][LMRTM] Shared data could not be accessed while starting locating measure.");
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
            
            // Resgiter the region to be monitorized
            if ([mode isModeKey:kModeRhoThetaModelling]) {
                
                // Get class variables to get the item's position facet from the item chosen by user to be the device (modelling mode)
                NSMutableDictionary * itemChosenByUserDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
                deviceUUID = itemChosenByUserDic[@"uuid"];
                if (itemChosenByUserDic[@"position"]) {
                    devicePosition = itemChosenByUserDic[@"position"];
                } else {
                    NSLog(@"[ERROR][LMRTM] No position found in item to be measured.");
                }
                
                // Get class variables to get the item's position facet from the item chosen by user to measure (modelling mode)
                NSDictionary * dataDic = [notification userInfo];
                NSMutableDictionary * itemDic = dataDic[@"itemDic"];
                itemToMeasureUUID = itemDic[@"uuid"];
                    
                // Could be only a a beacon
                if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                    NSString * uuidString = itemToMeasureUUID;
                    NSInteger major = [itemDic[@"major"] integerValue];
                    NSInteger minor = [itemDic[@"minor"] integerValue];
                    NSString * identifier = itemDic[@"identifier"];
                    
                    // Create a NSUUID with proximity UUID of the broadcasting beacons
                    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
                    
                    // Setup searching region with proximity UUID as the broadcasting beacon
                    CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
                    [monitoredRegions addObject:region];
                    
                    [locationManager startRangingBeaconsInRegion:region];
                    NSLog(@"[INFO][LMRTM] Device monitorizes a region:");
                    NSLog(@"[INFO][LMRTM] -> %@", [[region proximityUUID] UUIDString]);
                    
                } else {
                    NSLog(@"[ERROR][LMRTM] Item to measure is not a iBeacon device.");
                }
                
                // Start heading mesures
                [locationManager startUpdatingHeading];
                
                NSLog(@"[INFO][LMRTM] Start updating compass and iBeacons.");
            } else {
                NSLog(@"[ERROR][LMRTM] Calling mode is not kModeRhoThetaModelling.");
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            [self stopRoutine];
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                  andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[ERROR][LMRTM] Location services not allowed; updating compass and iBeacons.");
        }
    }
}

/*!
 @method stop:
 @discussion This method asks the Location Manager to stop positioning the device using compass and iBeacons.
 */
- (void) stop:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdRhoThetaModelling/stop"]){
        NSLog(@"[NOTI][LMRTM] Notification \"lmdRhoThetaModelling/stop\" recived.");
        // TODO: Valorate this next sentence. Alberto J. 2019/12/11.
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self stopRoutine];
        NSLog(@"[INFO][LMRTM] Stop updating compass and iBeacons.");
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
        NSLog(@"[NOTI][LMRTM] Notification \"lmd/reset\" recived.");
        
        // Instance variables
        // Reset position facet
        devicePosition = [[RDPosition alloc] init];
        devicePosition.x = [NSNumber numberWithFloat:0.0];
        devicePosition.y = [NSNumber numberWithFloat:0.0];
        devicePosition.z = [NSNumber numberWithFloat:0.0];
        itemToMeasureUUID = nil;
        
        isItemToMeasureRanged = NO;
        // Heading is not delivered unless new values available; when RSSI measures from the chosen UUID is saved, no heading is saved until user moves the device; thus, this location is saved if no heading measure is taken
        lastHeadingPosition = nil;
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
