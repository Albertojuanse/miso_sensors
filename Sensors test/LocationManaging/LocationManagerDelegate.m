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
        
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        // Intance variables
        measuring = NO;
        
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
             NSLog(@"[ERROR][LM] Authorization is not known");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LM] User restricts localization services");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LM] User doesn't allow localization services");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'always' localization services");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'when-in-use' localization services");
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
            
            // ...and save it in dictionary 'measuresDic'.
            
            // TO DO: Heading measures. Alberto J. 2019-06-04.
            
            // TO DO. Calibration. Alberto J.
            NSInteger calibration = -30;
            NSNumber * RSSIdistance = [RDRhoRhoSystem calculateDistanceWithRssi:-[rssi integerValue] + calibration];
            
            // Minimum sensibility 5 cm; Ipad often gives unreal values near to cero
            if ([RSSIdistance floatValue] > 0.05) {
                [sharedData inMeasuresDicSetMeasure:RSSIdistance
                                             ofType:@"rssi"
                                           withUUID:uuid
                                         atPosition:measurePosition
                                       andWithState:measuring];

                // Ask radiolocation of beacons if posible...
                // Precision is arbitrary set to 5 cm
                NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithFloat:0.5], @"xPrecision",
                                             [NSNumber numberWithFloat:0.5], @"yPrecision",
                                             [NSNumber numberWithFloat:0.5], @"zPrecision",
                                             nil];
                
                NSMutableDictionary * locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithMeasures:sharedData
                                                                                                       andPrecisions:precisions];
                
                // ...and save it in dictionary 'locatedDic'.
                // In this dictionary keys are the UUID.
                NSArray *positionKeys = [locatedPositions allKeys];
                for (id positionKey in positionKeys) {
                    [sharedData inLocatedDicSetPosition:[locatedPositions objectForKey:positionKey]
                                               fromUUID:positionKey];
                }
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
        
        // The notification payload is the array with the beacons that must be ranged
        NSDictionary *data = notification.userInfo;
        NSMutableArray * beaconsRegistered = [data valueForKey:@"beaconsRegistered"];
        
        // Register them if it is posible.
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                // Request authorization initially
                NSLog(@"[ERROR][LM] Authorization is still not known");
                
            case kCLAuthorizationStatusRestricted:
                // Disable location features
                NSLog(@"[ERROR][LM] User still restricts localization services");
                break;
                
            case kCLAuthorizationStatusDenied:
                // Disable location features
                NSLog(@"[ERROR][LM] User still doesn't allow localization services");
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                // Enable location features
                NSLog(@"[INFO][LM] User still allows 'always' localization services");
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // Enable location features
                NSLog(@"[INFO][LM] User still allows 'when-in-use' localization services");
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
        
        monitoredRegions = [[NSMutableArray alloc] init];
        rangedRegions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            for (NSMutableDictionary * regionDic in beaconsRegistered) {
                
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
            }
            
            NSLog(@"[INFO][LM] Start monitoring regions.");
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            // If is not allowed to use location services, unregister every region
            for(CLBeaconRegion * region in  locationManager.monitoredRegions){
                [locationManager stopMonitoringForRegion:region];
            }
        }
    }
}

/*!
 @method stopMeasuring
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored; it also deletes the monitored regions from location manager.
 */
- (void) stopMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopMeasuring"]){
        NSLog(@"[NOTI][LM] Notfication \"stopMeasuring\" recived.");
    
        // If is currently measuring
        measuring = NO;
        
        // Delete registered regions
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
        }
        monitoredRegions = nil; // For ARC disposing
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

@end
