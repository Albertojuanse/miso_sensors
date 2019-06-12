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
 @method configure
 @discussion This method is called when the app is loaded and manage some initializations and permission askings.
 */
- (void) configure{
    
    // Set device's location at the origin
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:0.0];
    position.y = [NSNumber numberWithFloat:0.0];
    position.z = [NSNumber numberWithFloat:0.0];
    
    // Orchestration variables
    measuring = NO;
    located = YES;
    currentNumberOfMeasures = [NSNumber numberWithInteger:0];
    
    // Other variables
    rangedBeacons = [[NSMutableArray alloc] init];
    rangedBeaconsDic = [[NSMutableDictionary alloc] init];
    positionIdNumber = [NSNumber numberWithInt:0];
    uuidIdNumber = [NSNumber numberWithInt:0];
    measureIdNumber = [NSNumber numberWithInt:0];
    
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
    NSLog(@"[INFO][LM] LocationManager prepared");
}

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
    
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // Create a NSUUID with proximity UUID of the broadcasting beacons
        NSUUID *uuidRaspi = [[NSUUID alloc] initWithUUIDString:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7"];
        NSUUID *uuidBeacon1 = [[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
        
        // Setup searching region with proximity UUID as the broadcasting beacon
        monitoredRegions = [[NSMutableArray alloc] init];
        CLBeaconRegion * RaspiRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuidRaspi major:1 minor:0 identifier:@"raspi@miso.uam.es"];
        [monitoredRegions addObject:RaspiRegion];
        CLBeaconRegion * Beacon1Region = [[CLBeaconRegion alloc] initWithProximityUUID:uuidBeacon1 major:1 minor:1 identifier:@"beacon1@miso.uam.es"];
        [monitoredRegions addObject:Beacon1Region];
        
        // Info to radiolocator
        NSMutableArray *rssiMeasures = [[NSMutableArray alloc] init];
        // In first element of each row it will be refereced each region UUID, and then the measuresNSMutableArray *first = [[NSMutableArray alloc] init];
        for(CLBeacon *region in monitoredRegions) {
            NSArray *rssiValues = [[NSArray alloc] initWithObjects:[region proximityUUID], nil];
            [rssiMeasures addObject:rssiValues];
        }
        
        // Configurate the region
        
        // If entry or exit must be notify; the default values are YES
        //RaspiRegion.notifyOnEntry = YES;
        //RaspiRegion.notifyOnExit = YES;
        //RaspiRegion.notifyEntryStateOnDisplay = YES;
        
        //  For normal use ob beacon regions use startMonitoringForRegion:  ...
        //[locationManager startMonitoringForRegion:RaspiRegion];
        // ...but for in-region initialization this one is needed
        rangedRegions = [[NSMutableArray alloc] init];
        [rangedRegions addObject:RaspiRegion];
        [locationManager startRangingBeaconsInRegion:RaspiRegion];
        [rangedRegions addObject:Beacon1Region];
        [locationManager startRangingBeaconsInRegion:Beacon1Region];
        
        NSLog(@"[INFO][LM] Device monitorizes a region:");
        NSLog(@"[INFO][LM] -> %@", [[RaspiRegion proximityUUID] UUIDString]);
        NSLog(@"[INFO][LM] Device monitorizes a region:");
        NSLog(@"[INFO][LM] -> %@", [[Beacon1Region proximityUUID] UUIDString]);
        
        NSLog(@"[INFO][LM] Start monitoring regions.");
    }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied || CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
        }
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
            
            // ...and save it in dictionary 'rangedBeaconsDic'.
            
            // This dictionary's schema is:
            //
            // { "measurePosition1":                              //  rangedBeaconsDic
            //     { "measurePosition": measurePosition;          //  positionDic
            //       "positionMeasures":
            //         { "measureUuid1":                          //  uuidDicDic
            //             { "uuid" : uuid1;                      //  uuidDic
            //               "uuidMeasures":
            //                 { "measure1":                      //  measureDicDic
            //                     { "type": "rssi"/"heading";    //  measureDic
            //                       "measure": rssi/heading
            //                     };
            //                   "measure2":  { (···) }
            //                 }
            //             };
            //           "measureUuid2": { (···) }
            //         }
            //     };
            //   "measurePosition2": { (···) }
            // }
            
            // Save measure value and type
            // The 'measureDic' is always new.
            NSMutableDictionary * measureDic = [[NSMutableDictionary alloc] init];
            // TO DO: Heading measures. Alberto J. 2019-06-04.
            measureDic[@"type"] = @"rssi";
            measureDic[@"measure"] = [RDRhoRhoSystem calculateDistanceWithRssi:-[rssi integerValue]];
            
            // Declare the rest of dictionaries; they will be created or gotten if they already exists.
            NSMutableDictionary * measureDicDic;
            NSMutableDictionary * uuidDic;
            NSMutableDictionary * uuidDicDic;
            NSMutableDictionary * positionDic;
            
            if (rangedBeaconsDic.count == 0) {
                // First initialization
                
                // { "measurePosition1":                              //  rangedBeaconsDic
                //     { "measurePosition": measurePosition;          //  positionDic
                //       "positionMeasures":
                //         { "measureUuid1":                          //  uuidDicDic
                //             { "uuid" : uuid1;                      //  uuidDic
                //               "uuidMeasures":
                //                 { "measure1":                      //  measureDicDic
                //                     { "type": "rssi"/"heading";    //  measureDic
                //                       "measure": rssi/heading
                //                     };
                //                   "measure2":  { (···) }
                //                 }
                //             };
                //           "measureUuid2": { (···) }
                //         }
                //     };
                //   "measurePosition2": { (···) }
                // }
                
                // Compose the dictionary from the innest to the outest
                // Wrap measureDic with another dictionary and an unique measure's identifier key
                measureDicDic = [[NSMutableDictionary alloc] init];
                if (measuring) {
                    measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                    NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                    measureDicDic[measureId] = measureDic;
                } else {
                    // saves nothing
                }
                
                
                // Create the 'uuidDic' dictionary
                uuidDic = [[NSMutableDictionary alloc] init];
                uuidDic[@"uuid"] = uuid;
                uuidDic[@"uuidMeasures"] = measureDicDic;
                
                // Wrap uuidDic with another dictionary and an unique uuid's identifier key
                uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
                NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
                uuidDicDic = [[NSMutableDictionary alloc] init];
                uuidDicDic[uuidId] = uuidDic;
                
                // Create the 'positionDic' dictionary
                positionDic = [[NSMutableDictionary alloc] init];
                positionDic[@"measurePosition"] = measurePosition;
                positionDic[@"positionMeasures"] = uuidDicDic;
                
                // Set positionDic in the main dictionary 'rangedBeaconsDic' with an unique position's identifier key
                positionIdNumber = [NSNumber numberWithInt:[positionIdNumber intValue] + 1];
                NSString * positionId = [@"measurePosition" stringByAppendingString:[positionIdNumber stringValue]];
                rangedBeaconsDic[positionId] = positionDic;
                
            } else {
                // Find if already exists position and uuid and create it if not.
                // If a 'parent' dictionary exists, there will exist at least one 'child' dictionary, since they are created that way; there not will be [ if(dic.count == 0) ] checks
                
                // { "measurePosition1":                              //  rangedBeaconsDic
                //     { "measurePosition": measurePosition;          //  positionDic
                //       "positionMeasures":
                //         { "measureUuid1":                          //  uuidDicDic
                //             { "uuid" : uuid1;                      //  uuidDic
                //               "uuidMeasures":
                //                 { "measure1":                      //  measureDicDic
                //                     { "type": "rssi"/"heading";    //  measureDic
                //                       "measure": rssi/heading
                //                     };
                //                   "measure2":  { (···) }
                //                 }
                //             };
                //           "measureUuid2": { (···) }
                //         }
                //     };
                //   "measurePosition2": { (···) }
                // }
                
                // If position and UUID already exists, the measure is allocated there; if not, they will be created later.
                BOOL positionFound = NO;
                BOOL uuidFound = NO;
                // For each position already saved...
                NSArray *positionKeys = [rangedBeaconsDic allKeys];
                for (id positionKey in positionKeys) {
                    // ...get the dictionary for this position...
                    positionDic = [rangedBeaconsDic objectForKey:positionKey];
                    // ...and checks if the current position 'measurePosition' already exists comparing it with the saved ones.
                    RDPosition *dicPosition = positionDic[@"measurePosition"];
                    if ([dicPosition isEqualToRDPosition:measurePosition]) {
                        positionFound = YES;
                        
                        // For each uuid already saved...
                        uuidDicDic = positionDic[@"positionMeasures"];
                        NSArray *uuidKeys = [uuidDicDic allKeys];
                        for (id uuidKey in uuidKeys) {
                            // ...get the dictionary for this uuid...
                            uuidDic = [uuidDicDic objectForKey:uuidKey];
                            // ...and checks if the uuid already exists.
                            if ([uuidDic[@"uuid"] isEqual:uuid]) {
                                uuidFound = YES;
                                
                                // If both position and uuid are found, set the 'measureDic' into 'measureDicDic' with an unique measure's identifier key.
                                measureDicDic = uuidDic[@"uuidMeasures"];
                                if (measuring) {
                                    measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                                    NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                                    measureDicDic[measureId] = measureDic;
                                } else {
                                    // saves nothing
                                }
                            }
                        }
                        // If only the UUID was not found, but te positions was found, create all the inner dictionaries.
                        if (uuidFound == NO) {
                            // Compose the dictionary from the innest to the outest
                            // Wrap measureDic with another dictionary and an unique measure's identifier key
                            measureDicDic = [[NSMutableDictionary alloc] init];
                            if (measuring) {
                                measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                                NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                                measureDicDic[measureId] = measureDic;
                            } else {
                            }
                            
                            // Create the 'uuidDic' dictionary
                            uuidDic = [[NSMutableDictionary alloc] init];
                            uuidDic[@"uuid"] = uuid;
                            uuidDic[@"uuidMeasures"] = measureDicDic;
                            
                            // Allocate 'uuidDic' into 'uuidDicDic' with an unique uuid's identifier key
                            uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
                            NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
                            uuidDicDic[uuidId] = uuidDic;
                        }
                    }
                }
                
                // If both position and UUID was not found create all the inner dictionaries.
                if (positionFound == NO) {
                    // Compose the dictionary from the innest to the outest
                    // Wrap measureDic with another dictionary and an unique measure's identifier key
                    measureDicDic = [[NSMutableDictionary alloc] init];
                    if (measuring) {
                        measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                        NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                        measureDicDic[measureId] = measureDic;
                    } else {
                        // saves nothing
                    }
                    
                    // Create the 'uuidDic' dictionary
                    uuidDic = [[NSMutableDictionary alloc] init];
                    uuidDic[@"uuid"] = [NSString stringWithString:uuid];
                    uuidDic[@"uuidMeasures"] = measureDicDic;
                    
                    // Wrap uuidDic with another dictionary and an unique uuid's identifier key
                    uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
                    NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
                    uuidDicDic = [[NSMutableDictionary alloc] init];
                    uuidDicDic[uuidId] = uuidDic;
                    
                    // Create the 'positionDic' dictionary
                    positionDic = [[NSMutableDictionary alloc] init];
                    positionDic[@"measurePosition"] = measurePosition;
                    positionDic[@"positionMeasures"] = uuidDicDic;
                    NSLog(@"[INFO][LM] New position saved in dictionary: (%.2f, %.2f)", [measurePosition.x floatValue], [measurePosition.y floatValue]);
                    
                    // Set positionDic in the main dictionary 'rangedBeaconsDic' with an unique position's identifier key
                    positionIdNumber = [NSNumber numberWithInt:[positionIdNumber intValue] + 1];
                    NSString * positionId = [@"measurePosition" stringByAppendingString:[positionIdNumber stringValue]];
                    rangedBeaconsDic[positionId] = positionDic;
                }
            }
        }
        
        NSLog(@"[INFO][LM] Generated dictionary:");
        NSLog(@"[INFO][LM]  -> %@", rangedBeaconsDic);
    }
    
    // Ask view controller to refresh the canvas
    if(beacons.count > 0) {
        NSLog(@"[NOTI][LM] Notification \"refreshCanvas\" posted.");
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:rangedBeaconsDic forKey:@"rangedBeaconsDic"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshCanvas"
         object:nil
         userInfo:data];
    }
    
    // Notify the event
    if(beacons.count > 0) {
        NSLog(@"[NOTI][LM] Notification \"needEvaluateState\" posted.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
    }
}

#pragma mark OrchestrationMethods

/*!
 @method setLocated
 @discussion This method sets the location status.
 */
- (void) setLocated:(BOOL) newLocated {
    located = newLocated;
}

/*!
 @method isLocated
 @discussion This method is called when a superior instance wants to know if the current location is known.
 */
- (BOOL) isLocated {
    if (measuring || located) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method startMeasuring
 @discussion This method sets the flag 'measuring' true, and thus the measures are stored.
 */
- (void) startMeasuring {
    NSLog(@"[INFO][LM] Asked to start measuring.");
    // If is not currently measuring
    if (!measuring) {
        NSLog(@"[INFO][LM] Measured flag is YES.");
        measuring = YES;
    }
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
}

/*!
 @method stopMeasuring
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored.
 */
- (void) stopMeasuring {
    // If is currently measuring
    if (measuring) {
        measuring = NO;
        // Reset the number of 'measures per measure'
        currentNumberOfMeasures = [NSNumber numberWithInteger:0];
    }
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
}

/*!
 @method stopMeasuring
 @discussion This method sets the flag 'measuring' false, and thus the measures are not stored.
 */
- (BOOL) isMeasuredWith:(NSNumber *)numberOfMeasures {
    if ([currentNumberOfMeasures integerValue] >= [numberOfMeasures integerValue] - 1) {
        return YES;
    } else {
        return NO;
    }
}

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
 @method getPosition
 @discussion Getter of current position of the device.
 */
- (void) setPosition:(RDPosition *) newPosition {
    position = [[RDPosition alloc] init];
    position.x = [NSNumber numberWithFloat:[newPosition.x floatValue]];
    position.y = [NSNumber numberWithFloat:[newPosition.y floatValue]];
    position.z = [NSNumber numberWithFloat:[newPosition.z floatValue]];
    
    // Notify the event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"needEvaluateState"
                                                        object:nil];
}

@end
