//
//  LocationManagerDelegate.m
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "LocationManagerDelegate.h"

@implementation LocationManagerDelegate : NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)initWithSharedData:(SharedData *)sharedDataFromAppDelegate
{
    self = [super init];
    if (self) {
        
        // Components
        sharedData = sharedDataFromAppDelegate;
        rhoRhoSystem = [[RDRhoRhoSystem alloc] init];
        rhoThetaSystem = [[RDRhoThetaSystem alloc] init];
        thetaThetaSystem = [[RDThetaThetaSystem alloc] init];
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        measuring = NO;
        idle = YES;
        mode = nil;
        uuidChosenByUser = nil;
        positionChosenByUser = nil;
        isUuidChosenByUserRanged = NO;
        // Heading is not delivered unless new values avalible; when RSSI measures from the chosen UUID is saved, no heading is saved until user moves the device; thus, this location is saved if no heading measure is taken
        lastHeadingPosition = [NSNumber numberWithFloat:0.0];
        
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
                                                 selector:@selector(startMeasuring:)
                                                     name:@"startMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopMeasuring:)
                                                     name:@"stopMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getPositionUsingNotification:)
                                                     name:@"getPosition"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setPositionUsingNotification:)
                                                     name:@"setPosition"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LM] LocationManager prepared");
    }
    return self;
}

#pragma mark - Location manager delegated methods

/*!
 @method locationManager:didChangeAuthorizationStatus:
 @discussion This method is called when the device's location permission change because user's desire or automatic rutines; depending on the current permission status this delegate will start searching for beacon's regions or not.
 */
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // Request authorization initially
             NSLog(@"[ERROR][LM] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LM] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LM] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error managment
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LM] Monitoring avalible for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LM] Monitoring not avalible for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LM] Ranging avalible.");
    }else{
        NSLog(@"[ERROR][LM] Ranging not avalible.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LM] Heading avalible.");
    }else{
        NSLog(@"[ERROR][LM] Heading not avalible.");
    }
}

/*!
 @method locationManager:didEnterRegion:
 @discussion This method is called when the device cross the border line and enters one of the monitor's monitorized regions (areas); ask the monitor to start searching for specific devices in the region.
 */
- (void)locationManager:(CLLocationManager*)manager
         didEnterRegion:(CLBeaconRegion*)region
{
    // Changed definition of method for (CLBeaconRegion*) instead of (CLRegion*)!!!!
    
    // Start ranging
    rangedRegions = [[NSMutableArray alloc] init];
    [rangedRegions addObject:region];
    [manager startRangingBeaconsInRegion:region];
    
    NSLog(@"[INFO][LM] Device ranged a region:");
    NSLog(@"[INFO][LM] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region:", [[region proximityUUID] UUIDString]]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LM] Device failed in raging a region:");
    NSLog(@"[ERROR][LM] -> %@", [[region proximityUUID] UUIDString]);
}

/*!
 @method locationManager:didRangeBeacons:inRegion:
 @discussion This method is called when the device detects some other device in a ranged region; it saves it and ask view to show its information.
 */
-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    // If app is not in main menu
    if (!idle) {
        
        // If a rho type system
        if (
            [mode isEqualToString:@"RHO_RHO_MODELING"] ||
            [mode isEqualToString:@"RHO_THETA_MODELING"] ||
            [mode isEqualToString:@"RHO_RHO_LOCATING"] ||
            [mode isEqualToString:@"RHO_THETA_LOCATING"]
            )
        {
            // If there is any beacon in the event...
            if (beacons.count > 0) {
                for (CLBeacon *beacon in beacons) {
                    // ...save it and get its information...
                    [rangedBeacons addObject:beacon];
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    NSNumber * rssi = [NSNumber numberWithInteger:[beacon rssi]];
                    
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = position.x;
                    measurePosition.y = position.y;
                    measurePosition.z = position.z;
                    
                    // TO DO. Calibration. Alberto J.
                    NSInteger calibration = -30;
                    NSNumber * RSSIdistance = [RDRhoRhoSystem calculateDistanceWithRssi:-[rssi integerValue] + calibration];
                    
                    NSMutableDictionary * locatedPositions;
                    
                    // Precision is arbitrary set to 10 cm
                    NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:0.1], @"xPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"yPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"zPrecision",
                                                 nil];
                    
                    // ...and save it in dictionary 'measuresDic'.
                    // Minimum sensibility 5 cm; Ipad often gives unreal values near to cero
                    if ([RSSIdistance floatValue] > 0.05) {
                        
                        if (
                            [mode isEqualToString:@"RHO_THETA_MODELING"] ||
                            [mode isEqualToString:@"RHO_THETA_LOCATING"]
                            )
                        {
                            
                            // If the system used is a ro teta system, 'uuidChosenByUser' exists, and the measure is saved only if event's uuid and the chosen one are the same; also, the heading measures only will be saved if becons measures are saved, when 'isUuidChosenByUserRanged' is true.
                            if (uuidChosenByUser) {
                                if ([uuidChosenByUser isEqualToString:uuid]) {
                                    
                                    if (!isUuidChosenByUserRanged) {
                                        // Heading is not delivered unless new values avalible; when RSSI measures from the chosen UUID is saved, no heading is saved until user moves the device. If 'isUuidChosenByUserRanged' flag is false, this is the first time that this UUID is ranged, and thus, this heading is saved; user can never move the device.
                                        [sharedData inMeasuresDicSetMeasure:lastHeadingPosition
                                                                     ofType:@"heading"
                                                                   withUUID:uuidChosenByUser
                                                                 atPosition:measurePosition
                                                               andWithState:measuring];
                                    }
                                    isUuidChosenByUserRanged = YES;
                                    
                                    // Save the measure
                                    [sharedData inMeasuresDicSetMeasure:RSSIdistance
                                                                 ofType:@"rssi"
                                                               withUUID:uuid
                                                             atPosition:measurePosition
                                                           andWithState:measuring];
                                    
                                    // Ask radiolocation of beacons if posible...
                                    locatedPositions = [rhoThetaSystem getLocationsWithMeasures:sharedData
                                                                                  andPrecisions:precisions];
                                }
                            }
                        }
                        
                        if (
                            [mode isEqualToString:@"RHO_RHO_MODELING"] ||
                            [mode isEqualToString:@"RHO_RHO_LOCATING"]
                            )
                        {
                            // Save the measure
                            [sharedData inMeasuresDicSetMeasure:RSSIdistance
                                                         ofType:@"rssi"
                                                       withUUID:uuid
                                                     atPosition:measurePosition
                                                   andWithState:measuring];
                            
                            // Ask radiolocation of beacons if posible...
                            locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithMeasures:sharedData
                                                                                             andPrecisions:precisions];
                        }
                        
                        // ...and save it in dictionary 'locatedDic'.
                        // In this dictionary keys are the UUID.
                        NSArray *positionKeys = [locatedPositions allKeys];
                        for (id positionKey in positionKeys) {
                            [sharedData inLocatedDicSetPosition:[locatedPositions objectForKey:positionKey]
                                                       fromUUID:positionKey];
                        }
                        
                        NSLog(@"[INFO][LM] Generated locations dictionary:");
                        NSLog(@"[INFO][LM]  -> %@", [sharedData getLocatedDic]);
                        
                    }
                    
                    NSLog(@"[INFO][LM] Generated measures dictionary:");
                    NSLog(@"[INFO][LM]  -> %@", [sharedData getMeasuresDic]);
                }
                
                // Ask view controller to refresh the canvas
                if(beacons.count > 0) {
                    NSLog(@"[NOTI][LM] Notification \"refreshCanvas\" posted.");
                    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                    [data setObject:[sharedData getMeasuresDic] forKey:@"measuresDic"];
                    [data setObject:[sharedData getLocatedDic] forKey:@"locatedDic"];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"refreshCanvas"
                     object:nil
                     userInfo:data];
                }
            }
            
            
            // If a theta theta type system; it is supposed that in this case regions are ot registered, but just in case
            if (
                [mode isEqualToString:@"THETA_THETA_MODELING"] ||
                [mode isEqualToString:@"THETA_THETA_LOCATING"]
                ) {
                // Do nothing
                NSLog(@"[ERROR][LM] Beacons ranged in Theta Theta system based mode.");
            }
            
            
        } else { // If is idle...
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

/*!
 @method locationManager:didUpdateHeading:
 @discussion This method is called when the device wants to deliver a data about its heading.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    // If app is not in main menu
    if (!idle) {
        
        // If a rho type system
        if (
            [mode isEqualToString:@"RHO_THETA_MODELING"]
            )
        {
            
            if(isUuidChosenByUserRanged) {
                if (uuidChosenByUser) {
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = position.x;
                    measurePosition.y = position.y;
                    measurePosition.z = position.z;
                    
                    [sharedData inMeasuresDicSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                                 ofType:@"heading"
                                               withUUID:uuidChosenByUser
                                             atPosition:measurePosition
                                           andWithState:measuring];
                }
            } else {
                NSLog(@"[INFO][LM] User did choose a UUID source that is not being ranging; disposing.");
            }
        }
        
        if (
            [mode isEqualToString:@"RHO_THETA_LOCATING"]
            )
        {
            // TO DO: RHO_THETA_MODELING mode. Alberto J. 2019/07/18.
        }
        
        if (
            [mode isEqualToString:@"THETA_THETA_MODELING"]
            )
        {
            // TO DO: THETA_THETA_MODELING mode. Alberto J. 2019/07/18.
        }
        
        if (
            [mode isEqualToString:@"THETA_THETA_LOCATING"]
            )
        {
            
            if(positionChosenByUser && locatedPositionUUID) {
                // The system is reciprocal, so it calculates the device position using the reference positions instead of the way round.
                
                // Save the measure
                RDPosition * measurePosition = [[RDPosition alloc] init];
                measurePosition.x = positionChosenByUser.x;
                measurePosition.y = positionChosenByUser.y;
                measurePosition.z = positionChosenByUser.z;
                
                [sharedData inMeasuresDicSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                             ofType:@"heading"
                                           withUUID:locatedPositionUUID
                                         atPosition:measurePosition
                                       andWithState:measuring];
                
                NSMutableDictionary * locatedPositions;
                // Precision is arbitrary set to 10 cm
                NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:0.1], @"xPrecision",
                                             [NSNumber numberWithFloat:0.1], @"yPrecision",
                                             [NSNumber numberWithFloat:0.1], @"zPrecision",
                                             nil];
                
                // Ask radiolocation of beacons if posible...
                locatedPositions = [thetaThetaSystem getLocationsUsingBarycenterAproximationWithMeasures:sharedData
                                                                                           andPrecisions:precisions];
                
                // ...and save it in dictionary 'locatedDic'.
                // In this dictionary keys are the UUID.
                NSArray *positionKeys = [locatedPositions allKeys];
                for (id positionKey in positionKeys) {
                    [sharedData inLocatedDicSetPosition:[locatedPositions objectForKey:positionKey]
                                               fromUUID:locatedPositionUUID];
                }
                
                NSLog(@"[INFO][LM] Generated locations dictionary:");
                NSLog(@"[INFO][LM]  -> %@", [sharedData getLocatedDic]);
            
                NSLog(@"[INFO][LM] Generated measures dictionary:");
                NSLog(@"[INFO][LM]  -> %@", [sharedData getMeasuresDic]);
            } else {
                NSLog(@"[ERROR][LM] positionChosenByUser && locatedPositionUUID missing in Theta theta system based mode");
            }
            
        }
        
    } else { // If is idle...
        
    }
    lastHeadingPosition = [NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0];
}

/*!
 @method locationManagerShouldDisplayHeadingCalibration:
 @discussion Adverts the user that compass need calibration.
 */
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    if(!manager.heading) return YES; // Got nothing, We can assume we got to calibrate.
    else if(manager.heading.headingAccuracy < 0 ) return YES; // 0 means invalid heading, need to calibrate
    else if(manager.heading.headingAccuracy > 5 ) return YES; // 5 degrees is a small value correct for my needs, too.
    else return NO; // All is good. Compass is precise enough.
}

#pragma mark - Instance method

/*!
 @method getPosition
 @discussion Getter of current position of the device.
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
 @discussion Setter of current position of the device.
 */
- (void) setPosition:(RDPosition *) newPosition {
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:[newPosition.x floatValue]];
    position.y = [NSNumber numberWithFloat:[newPosition.y floatValue]];
    position.z = [NSNumber numberWithFloat:[newPosition.z floatValue]];
}

#pragma mark - Notification event handles

/*!
 @method startMeasuring
 @discussion This method sets the flag 'measuring' true, and thus the measures are stored.
 */
- (void) startMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startMeasuring"]){
        NSLog(@"[NOTI][LM] Notfication \"startMeasuring\" recived.");
    
        measuring = YES;
        idle = NO;
        
        // The notification payload is the array with the positions or beacons that must be ranged, its associated entities, modeling mode and UUID or position source selected by user
        NSDictionary *data = notification.userInfo;
        // This cannot be null
        mode = data[@"mode"];
        NSMutableArray * beaconsAndPositions = data[@"beaconsAndPositions"];
        
        // This can be null
        // In rho theta based system, user must choose which beacon is the source
        uuidChosenByUser = data[@"uuidChosenByUser"];
        positionChosenByUser = data[@"positionChosenByUser"];
        positionChosenByUser = data[@"positionChosenByUser"];
        locatedPositionUUID = data[@"locatedPositionUUID"];
        
        // Register them if it is posible.
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                // Request authorization initially
                NSLog(@"[ERROR][LM] Authorization is still not known.");
                
            case kCLAuthorizationStatusRestricted:
                // Disable location features
                NSLog(@"[ERROR][LM] User still restricts localization services.");
                break;
                
            case kCLAuthorizationStatusDenied:
                // Disable location features
                NSLog(@"[ERROR][LM] User still doesn't allow localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                // Enable location features
                NSLog(@"[INFO][LM] User still allows 'always' localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // Enable location features
                NSLog(@"[INFO][LM] User still allows 'when-in-use' localization services.");
                break;
                
            default:
                break;
        }
        
        // Error managment
        if ([CLLocationManager locationServicesEnabled]) {
            NSLog(@"[INFO][LM] Location services still enabled.");
        }else{
            NSLog(@"[ERROR][LM] Location services still not enabled.");
        }
        
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            NSLog(@"[INFO][LM] Monitoring still avalible for class CLBeaconRegion.");
        }else{
            NSLog(@"[ERROR][LM] Monitoring still not avalible for class CLBeaconRegion.");
        }
        
        if ([CLLocationManager isRangingAvailable]) {
            NSLog(@"[INFO][LM] Ranging still avalible.");
        }else{
            NSLog(@"[ERROR][LM] Ranging still not avalible.");
        }
        
        if ([CLLocationManager headingAvailable]) {
            NSLog(@"[INFO][LM] Heading avalible.");
        }else{
            NSLog(@"[ERROR][LM] Heading not avalible.");
        }
        
        monitoredRegions = [[NSMutableArray alloc] init];
        monitoredPositions = [[NSMutableArray alloc] init];
        rangedRegions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if (
                [mode isEqualToString:@"RHO_RHO_MODELING"] ||
                [mode isEqualToString:@"RHO_THETA_MODELING"] ||
                [mode isEqualToString:@"RHO_RHO_LOCATING"] ||
                [mode isEqualToString:@"RHO_THETA_LOCATING"]
                ) {
                
                // Resgiter the regions to be monitorized
                for (NSMutableDictionary * regionDic in beaconsAndPositions) {
                    
                    // Could be a position or a beacon
                    if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                        NSString * uuidString = regionDic[@"uuid"];
                        NSInteger major = [regionDic[@"major"] integerValue];
                        NSInteger minor = [regionDic[@"minor"] integerValue];
                        NSString * identifier = regionDic[@"identifier"];
                        
                        // Create a NSUUID with proximity UUID of the broadcasting beacons
                        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
                        
                        // Setup searching region with proximity UUID as the broadcasting beacon
                        CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
                        [monitoredRegions addObject:region];
                        
                        [locationManager startRangingBeaconsInRegion:region];
                        [rangedRegions addObject:region];
                        NSLog(@"[INFO][LM] Device monitorizes a region:");
                        NSLog(@"[INFO][LM] -> %@", [[region proximityUUID] UUIDString]);
                        
                        // But if its position is loaded, the user wants to use it to locate itself against them
                        if (regionDic[@"position"]) {
                            [monitoredPositions addObject:regionDic[@"position"]];
                        }
                    }
                    if ([@"position" isEqualToString:regionDic[@"type"]]) {
                        [monitoredPositions addObject:regionDic[@"position"]];
                    }
                    if ([@"model" isEqualToString:regionDic[@"type"]]) {
                        // TO DO: What needs Location manager of previus models?. Alberto J. 2019/07/18.
                    }
                    
                }
                NSLog(@"[INFO][LM] Start monitoring regions.");
            }
            // If a theta type system
            if (
                [mode isEqualToString:@"THETA_THETA_MODELING"] ||
                [mode isEqualToString:@"RHO_THETA_MODELING"] ||
                [mode isEqualToString:@"THETA_THETA_LOCATING"] ||
                [mode isEqualToString:@"RHO_THETA_LOCATING"]
                ) {
                
                [locationManager startUpdatingHeading];
                NSLog(@"[INFO][LM] Start updating heading.");
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            // If is not allowed to use location services, delete registered regions and heading updates
            for(CLBeaconRegion * region in  locationManager.monitoredRegions){
                [locationManager stopMonitoringForRegion:region];
                [locationManager stopRangingBeaconsInRegion:region];
            }
            [locationManager stopUpdatingHeading];
            monitoredRegions = nil; // For ARC disposing
            monitoredPositions = nil;
            rangedRegions = nil;
        }
    }
}

/*!
 @method stopMeasuring
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored; it also deletes the monitored regions from location manager.
 */
- (void) stopMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopMeasuring"]) {
        NSLog(@"[NOTI][LM] Notfication \"stopMeasuring\" recived.");
    
        // Instance variables
        measuring = NO;
        isUuidChosenByUserRanged = NO;
        
        // Delete registered regions and heading updates
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
            [locationManager stopRangingBeaconsInRegion:region];
        }
        [locationManager stopUpdatingHeading];
        monitoredRegions = nil; // For ARC disposing
        monitoredPositions = nil;
        rangedRegions = nil;
    }
}

/*!
 @method getPositionUsingNotification:
 @discussion Getter of current position of the device using observer pattern.
 */
- (void) getPositionUsingNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"getPosition"]){
        NSLog(@"[NOTI][LM] Notfication \"getPosition\" recived.");
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        // Create a copy of the current position for sending it; concurrence issues prevented
        RDPosition * newPosition = [[RDPosition alloc] init];
        newPosition.x = [NSNumber numberWithFloat:[position.x floatValue]];
        newPosition.y = [NSNumber numberWithFloat:[position.y floatValue]];
        newPosition.z = [NSNumber numberWithFloat:[position.z floatValue]];
        [data setObject:newPosition forKey:@"currentPosition"];
        // And send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getPositionRespond"
                                                            object:nil
                                                          userInfo:data];
        NSLog(@"[NOTI][VCRRM] Notification \"getPositionRespond\" posted.");
    }
}

/*!
 @method setPositionUsingNotification:
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) setPositionUsingNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"setPosition"]){
        NSLog(@"[NOTI][LM] Notfication \"setPosition\" recived.");
        
        NSDictionary * data = notification.userInfo;
        RDPosition * newPosition = data[@"currentPosition"];
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:[newPosition.x floatValue]];
        position.y = [NSNumber numberWithFloat:[newPosition.y floatValue]];
        position.z = [NSNumber numberWithFloat:[newPosition.z floatValue]];
    }
}

/*!
 @method reset
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) reset:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"reset"]){
        NSLog(@"[NOTI][LM] Notfication \"reset\" recived.");
        
        // Components
        [sharedData reset];
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        measuring = NO;
        idle = YES;
        mode = nil;
        uuidChosenByUser = nil;
        positionChosenByUser = nil;
        isUuidChosenByUserRanged = NO;
        // Heading is not delivered unless new values avalible; when RSSI measures from the chosen UUID is saved, no heading is saved until user moves the device; thus, this location is saved if no heading measure is taken
        lastHeadingPosition = nil;
        
        // Delete registered regions and heading updates
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
            [locationManager stopRangingBeaconsInRegion:region];
        }
        [locationManager stopUpdatingHeading];
        monitoredRegions = nil; // For ARC disposing
        monitoredPositions = nil;
        rangedRegions = nil;
    }
}

@end
