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
 @discussion Constructor given the shared data collection.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
{
    self = [super init];
    if (self) {
        
        // Components
        sharedData = initSharedData;
        rhoRhoSystem = [[RDRhoRhoSystem alloc] initWithSharedData:sharedData
                                                          userDic:userDic
                                                       deviceUUID:deviceUUID
                                            andCredentialsUserDic:credentialsUserDic];
        rhoThetaSystem = [[RDRhoThetaSystem alloc] initWithSharedData:sharedData
                                                              userDic:userDic
                                                           deviceUUID:deviceUUID
                                                andCredentialsUserDic:credentialsUserDic];
        thetaThetaSystem = [[RDThetaThetaSystem alloc] initWithSharedData:sharedData
                                                                  userDic:userDic
                                                               deviceUUID:deviceUUID
                                                    andCredentialsUserDic:credentialsUserDic];
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        isItemChosenByUserRanged = NO;
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
 @discussion This method sets the dictionary with the user's credentials for acess the collections in shared data database.
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
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:[givenPosition.x floatValue]];
    position.y = [NSNumber numberWithFloat:[givenPosition.y floatValue]];
    position.z = [NSNumber numberWithFloat:[givenPosition.z floatValue]];
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
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLBeaconRegion *)region
{
    // Changed definition of method for (CLBeaconRegion *) instead of (CLRegion *)!!!!
    
    // Start ranging
    [manager startRangingBeaconsInRegion:region];
    
    NSLog(@"[INFO][LM] Device ranged a region:");
    NSLog(@"[INFO][LM] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region: %@", [[region proximityUUID] UUIDString]]);
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
-(void)locationManager:(CLLocationManager *)manager
       didRangeBeacons:(NSArray *)beacons
              inRegion:(CLBeaconRegion *)region
{
    // First, validate the acess to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        /*
         [self alertUserWithTitle:@"Beacon ranged won't be procesed."
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
         */
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting travel.");
        return;
    }
    
    // Different behave depending on the current state
    // If app is measuring the device user
    if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) {
        
        // Get the measuring mode
        NSString * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        
        // If a rho type system which needs ranging
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
                    // ...get its information...
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
                    // TO DO: Make this configurable. Alberto J. 2019/09/12.
                    NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:0.1], @"xPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"yPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"zPrecision",
                                                 nil];
                    
                    // ...and save it in dictionary 'measuresDic'.
                    // Minimum sensibility 5 cm; Ipad often gives unreal values near to cero
                    // TO DO: Make this configurable. Alberto J. 2019/09/12.
                    if ([RSSIdistance floatValue] > 0.05) {
                        
                        // Different behave depending on the current mode
                        if (
                            [mode isEqualToString:@"RHO_THETA_MODELING"] ||
                            [mode isEqualToString:@"RHO_THETA_LOCATING"]
                            )
                        {
                            
                            // In this modes, the user must select an item to measure, whose item dictionary is stored in session dictionary as 'itemChosenByUser'.
                            NSMutableDictionary * itemChosenByUserDic = [sharedData
                                                                         fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                         andCredentialsUserDic:credentialsUserDic
                                                                         ];
                            // If its not null retrieve the information needed.
                            NSString * itemUUID;
                            if (itemChosenByUserDic) {
                                itemUUID = itemChosenByUserDic[@"uuid"];
                            }
                            
                            // If the UUID is not found, the measure cannot be saved
                            if (!itemUUID) {
                                NSLog(@"[ERROR][LM] Measure not saved since the item selected had no UUID.");
                                return;
                            } else {
                                
                                // The measure is saved only if event's uuid and the chosen one are the same; also, the heading measures only will be saved if becons measures are saved, when 'isItemChosenByUserRanged' is true.
                                if ([itemUUID isEqualToString:uuid]) {
                                    
                                    
                                    
                                    // Conditional clausule for an specific issue with Apple devices' heading measures:
                                    if (!isItemChosenByUserRanged) {
                                        // Device does not deliver heading measures unless new values avalible; when RSSI measures from the chosen item is saved, can occur that no heading is saved until user moves the device. If it happens, the delegated method 'locationManager:didUpdateHeading:' is never called, and so, this method saves its value once. If 'isItemChosenByUserRanged' flag is false means this is the first time that this item is ranged, and thus, this heading is saved as a first heading measure to, at least, save one.
                                        [sharedData inMeasuresDataSetMeasure:lastHeadingPosition
                                                                      ofSort:@"heading"
                                                                withItemUUID:itemUUID
                                                              withDeviceUUID:deviceUUID
                                                                  atPosition:measurePosition
                                                              takenByUserDic:userDic
                                                   andWithCredentialsUserDic:credentialsUserDic];
                                    }
                                    
                                    
                                    isItemChosenByUserRanged = YES;
                                    // Save the measure
                                    [sharedData inMeasuresDataSetMeasure:RSSIdistance
                                                                  ofSort:@"rssi"
                                                            withItemUUID:itemUUID
                                                          withDeviceUUID:deviceUUID
                                                              atPosition:measurePosition
                                                          takenByUserDic:userDic
                                               andWithCredentialsUserDic:credentialsUserDic];
                                    
                                    // Ask radiolocation of beacons if posible...
                                    locatedPositions = [rhoThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
                                }
                            }
                        }
                        
                        if (
                            [mode isEqualToString:@"RHO_RHO_MODELING"] ||
                            [mode isEqualToString:@"RHO_RHO_LOCATING"]
                            )
                        {
                            // Save the measure
                            [sharedData inMeasuresDataSetMeasure:RSSIdistance
                                                          ofSort:@"rssi"
                                                    withItemUUID:uuid
                                                  withDeviceUUID:deviceUUID
                                                      atPosition:measurePosition
                                                  takenByUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
                            
                            // Ask radiolocation of beacons if posible...
                            locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithPrecisions:precisions];
                        }
                        
                        // ...and save it in dictionary 'locatedDic'.
                        NSArray *positionKeys = [locatedPositions allKeys];
                        for (id positionKey in positionKeys) {
                            NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
                            infoDic[@"located"] = @"YES";
                            infoDic[@"sort"] = @"position";
                            infoDic[@"identifier"] = [NSString
                                                      stringWithFormat:@"location%@@miso.uam.es",
                                                      [positionKey substringFromIndex:
                                                       [positionKey length] - 4]
                                                      ];
                            infoDic[@"position"] = [locatedPositions objectForKey:positionKey];
                            [sharedData inItemDataAddItemOfSort:@"position"
                                                       withUUID:positionKey
                                                    withInfoDic:infoDic
                                      andWithCredentialsUserDic:credentialsUserDic];
                        }
                        NSLog(@"[INFO][LM] Generated locations:");
                        NSLog(@"[INFO][LM]  -> %@",  [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                             andCredentialsUserDic:credentialsUserDic]);
                        
                    }
                    NSLog(@"[INFO][LM] Generated measures:");
                    NSLog(@"[INFO][LM]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
                    
                }
                
                // Ask view controller to refresh the canvas
                if(beacons.count > 0) {
                    NSLog(@"[NOTI][LM] Notification \"refreshCanvas\" posted.");
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"refreshCanvas"
                     object:nil];
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

/*!
 @method locationManager:didUpdateHeading:
 @discussion This method is called when the device wants to deliver a data about its heading.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    // First, validate the acess to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        /*
         [self alertUserWithTitle:@"Beacon ranged won't be procesed."
         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
         andHandler:^(UIAlertAction * action) {
         // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
         }
         ];
         */
        NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting travel.");
        return;
    }
    
    // Different behave depending on the current state
    // If app is measuring the device user
    if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) {
        
        // Get the measuring mode
        NSString * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        
        // If a rho type system
        if (
            [mode isEqualToString:@"RHO_THETA_MODELING"]
            )
        {
            
            // The heading measures in this mode are only saved if there is already any beacon measure saved...
            if(isItemChosenByUserRanged) {
                // ...and if the user did select the item to aim to, whose item dictionary is stored in session dictionary as 'itemChosenByUser'.
                NSMutableDictionary * itemChosenByUserDic = [sharedData
                                                             fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic
                                                             ];
                // If its not null retrieve the information needed.
                NSString * itemUUID;
                if (itemChosenByUserDic) {
                    itemUUID = itemChosenByUserDic[@"uuid"];
                }
                
                if (itemChosenByUserDic) {
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = position.x;
                    measurePosition.y = position.y;
                    measurePosition.z = position.z;
                    
                    [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                                  ofSort:@"heading"
                                            withItemUUID:itemUUID
                                          withDeviceUUID:deviceUUID
                                              atPosition:nil
                                          takenByUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
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
            
            // The heading measures in this mode are only saved if the user did select the item to aim to whose item dictionary is stored in session dictionary as 'itemChosenByUser'.
            NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                                 andCredentialsUserDic:credentialsUserDic];
            if(itemChosenByUser) {
                // If its not null retrieve the information needed.
                NSString * itemUUID = itemChosenByUser[@"uuid"];
                RDPosition * measurePosition = [[RDPosition alloc] init];
                measurePosition.x = position.x;
                measurePosition.y = position.y;
                measurePosition.z = position.z;
                
                [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                              ofSort:@"heading"
                                        withItemUUID:itemUUID
                                      withDeviceUUID:deviceUUID
                                          atPosition:nil
                                      takenByUserDic:userDic
                           andWithCredentialsUserDic:credentialsUserDic];
            } else {
                NSLog(@"[INFO][LM] User did choose a UUID source that is not being ranging; disposing.");
            }
            
            NSMutableDictionary * locatedPositions;
            
            // Precision is arbitrary set to 10 cm
            // TO DO: Make this configurable. Alberto J. 2019/09/12.
            NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithFloat:0.1], @"xPrecision",
                                         [NSNumber numberWithFloat:0.1], @"yPrecision",
                                         [NSNumber numberWithFloat:0.1], @"zPrecision",
                                         nil];
            
            // Ask radiolocation of beacons if posible...
            locatedPositions = [thetaThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
            // ...and save it in dictionary 'locatedDic'.
            NSArray *positionKeys = [locatedPositions allKeys];
            for (id positionKey in positionKeys) {
                NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
                infoDic[@"located"] = @"YES";
                infoDic[@"sort"] = @"position";
                infoDic[@"identifier"] = [NSString
                                          stringWithFormat:@"location%@@miso.uam.es",
                                          [positionKey substringFromIndex:
                                           [positionKey length] - 4]
                                          ];
                infoDic[@"position"] = [locatedPositions objectForKey:positionKey];
                [sharedData inItemDataAddItemOfSort:@"position"
                                           withUUID:positionKey
                                        withInfoDic:infoDic
                          andWithCredentialsUserDic:credentialsUserDic];
            }
            
            NSLog(@"[INFO][LM] Generated locations:");
            NSLog(@"[INFO][LM]  -> %@", [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                andCredentialsUserDic:credentialsUserDic]);
            NSLog(@"[INFO][LM] Generated measures:");
            NSLog(@"[INFO][LM]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
            
        }
            
        // Ask view controller to refresh the canvas
        NSLog(@"[NOTI][LM] Notification \"refreshCanvas\" posted.");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshCanvas"
         object:nil];
        
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
    if(!manager.heading) return YES; // Got nothing, We can assume we got to calibrate.
    else if(manager.heading.headingAccuracy < 0 ) return YES; // 0 means invalid heading, need to calibrate
    else if(manager.heading.headingAccuracy > 3 ) return YES; // 5 degrees is a small value correct for my needs, too.
    else return NO; // All is good. Compass is precise enough.
}

#pragma mark - Notification event handles

/*!
 @method startMeasuring
 @discussion This method sets the flag 'measuring' true, and thus the measures are stored.
 */
- (void) startMeasuring:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"startMeasuring"]){
        NSLog(@"[NOTI][LM] Notfication \"startMeasuring\" recived.");
        
        NSMutableArray * items = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
        
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
        
        // Validate the acess to the data shared collection
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
        } else {
            /*
             [self alertUserWithTitle:@"Beacon ranged won't be procesed."
             message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
             andHandler:^(UIAlertAction * action) {
             // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting measuring.");
            return;
        }
        
        // Get the measuring mode
        NSString * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        monitoredRegions = [[NSMutableArray alloc] init];
        monitoredPositions = [[NSMutableArray alloc] init];
        
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
                        NSLog(@"[INFO][LM] Device monitorizes a region:");
                        NSLog(@"[INFO][LM] -> %@", [[region proximityUUID] UUIDString]);
                        
                        // But if its position is loaded, the user wants to use it to locate itself against them
                        if (itemDic[@"position"]) {
                            [monitoredPositions addObject:itemDic[@"position"]];
                        }
                    }
                    if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                        [monitoredPositions addObject:itemDic[@"position"]];
                    }
                    if ([@"model" isEqualToString:itemDic[@"sort"]]) {
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
        isItemChosenByUserRanged = NO;
        
        // Delete registered regions and heading updates
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
            [locationManager stopRangingBeaconsInRegion:region];
        }
        [locationManager stopUpdatingHeading];
        monitoredRegions = nil; // For ARC disposing
        monitoredPositions = nil;
    }
}

/*!
 @method getPositionUsingNotification:
 @discussion Getter of current position of the device using observer pattern.
 */
- (void) getPositionUsingNotification:(NSNotification *) notification
{
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
        NSLog(@"[NOTI][LM] Notification \"getPositionRespond\" posted.");
    }
}

/*!
 @method setPositionUsingNotification:
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) setPositionUsingNotification:(NSNotification *) notification
{
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
- (void) reset:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"reset"]){
        NSLog(@"[NOTI][LM] Notfication \"reset\" recived.");
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        isItemChosenByUserRanged = NO;
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
        
        // Components
        [sharedData resetWithCredentialsUserDic:credentialsUserDic];
    }
}

@end
