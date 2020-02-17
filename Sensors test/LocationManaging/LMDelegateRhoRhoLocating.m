//
//  LMDelegateRhoRhoLocating.m
//  Sensors test
//
//  Created by MISO on 21/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateRhoRhoLocating.h"

@implementation LMDelegateRhoRhoLocating : NSObject

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
                                                 selector:@selector(startBeaconRangingMeasuring:)
                                                     name:@"startBeaconRangingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopBeaconRangingMeasuring:)
                                                     name:@"stopBeaconRangingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"resetLocationAndMeasures"
                                                   object:nil];
        
        NSLog(@"[INFO][LMRRL] LocationManager prepared for kModeRhoRhoLocating mode.");
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
    sharedData = initSharedData;
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    deviceUUID = initDeviceUUID;
    rhoRhoSystem = initRhoRhoSystem;
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
            NSLog(@"[ERROR][LMRRL] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMRRL] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMRRL] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMRRL] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMRRL] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMRRL] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMRRL] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMRRL] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMRRL] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMRRL] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMRRL] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMRRL] Heading available.");
    }else{
        NSLog(@"[ERROR][LMRRL] Heading not available.");
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
    
    NSLog(@"[INFO][LMRRL] Device ranged a region:");
    NSLog(@"[INFO][LMRRL] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region: %@", [[region proximityUUID] UUIDString]]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LMRRL] Device failed in raging a region:");
    NSLog(@"[ERROR][LMRRL] -> %@", [[region proximityUUID] UUIDString]);
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
        NSLog(@"[ERROR][LMRRL] Shared data could not be accessed when beacon ranged.");
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
                
                // For every ranged beacon...
                for (CLBeacon *beacon in beacons) {
                    
                    // ...get its information...
                    NSString * uuid = [[beacon proximityUUID] UUIDString];
                    NSNumber * rssi = [NSNumber numberWithInteger:[beacon rssi]];
                    // TO DO. Calibration. Alberto J. 2019/11/14.
                    // TO DO: Get the 1 meter RSSI from CLBeacon. Alberto J. 2019/11/14.
                    // Absolute values of speed of light, frecuency, and antenna's join gain
                    float C = 299792458.0;
                    float F = 2440000000.0; // 2400 - 2480 MHz
                    float G = 1.0; // typically 2.16 dBi
                    // Calculate the distance
                    float distance = (C / (4.0 * M_PI * F)) * sqrt(G * pow(10.0, -[rssi floatValue]/ 10.0));
                    NSNumber * RSSIdistance = [[NSNumber alloc] initWithFloat:distance];
                    
                    // ...prepare the measure..
                    RDPosition * measurePosition = [[RDPosition alloc] init];
                    measurePosition.x = position.x;
                    measurePosition.y = position.y;
                    measurePosition.z = position.z;
                    NSMutableDictionary * locatedPositions;
                    
                    // Precision is arbitrary set to 10 cm
                    // TO DO: Make this configurable. Alberto J. 2019/09/12.
                    NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:0.1], @"xPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"yPrecision",
                                                 [NSNumber numberWithFloat:0.1], @"zPrecision",
                                                 nil];
                    
                    // ...and save it.
                    [sharedData inMeasuresDataSetMeasure:RSSIdistance
                                                  ofSort:@"rssi"
                                            withItemUUID:uuid
                                          withDeviceUUID:deviceUUID
                                              atPosition:measurePosition
                                          takenByUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
            
                    // Ask radiolocation of beacons if posible...
                    locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithPrecisions:precisions];
            
                    // Save the positions as located items.
                    NSArray *positionKeys = [locatedPositions allKeys];
                    for (id positionKey in positionKeys) {
                        NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
                        infoDic[@"located"] = @"YES";
                        infoDic[@"sort"] = @"position";
                        NSString * positionId = [@"position" stringByAppendingString:[itemPositionIdNumber stringValue]];
                        itemPositionIdNumber = [NSNumber numberWithInteger:[itemPositionIdNumber integerValue] + 1];
                        positionId = [positionId stringByAppendingString:@"@miso.uam.es"];
                        infoDic[@"identifier"] = positionId;
                        infoDic[@"position"] = [locatedPositions objectForKey:positionKey];
                        BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                                    withUUID:positionKey
                                                                 withInfoDic:infoDic
                                                   andWithCredentialsUserDic:credentialsUserDic];
                        if (!savedItem) {
                            NSLog(@"[ERROR][LMRTM] Located position %@ could not be stored as an item.", infoDic[@"position"]);
                        }
                    }
                    
                }
                
                NSLog(@"[INFO][LMRRL] Generated locations:");
                NSLog(@"[INFO][LMRRL]  -> %@",  [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                        andCredentialsUserDic:credentialsUserDic]);
                
                NSLog(@"[INFO][LMRRL] Generated measures:");
                NSLog(@"[INFO][LMRRL]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
                
                // Ask view controller to refresh the canvas
                NSLog(@"[NOTI][LMRRL] Notification \"refreshCanvas\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"refreshCanvas"
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
        
        
        
        // Save variables in device memory
        // TO DO: Session control to prevent data loss. Alberto J. 2020/02/17.
        // Remove previous collection
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"es.uam.miso/variables/areIdNumbers"];
        [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
        [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
        
        // Save information
        NSData * areIdNumbersData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
        [userDefaults setObject:areIdNumbersData forKey:@"es.uam.miso/variables/areIdNumbers"];
        NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
        NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
        [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
        [userDefaults setObject:itemPositionIdNumberData forKey:@"es.uam.miso/variables/itemPositionIdNumber"];
        
    }
}

#pragma mark - Notification event handles

/*!
 @method startBeaconRangingMeasuring:
 @discussion This method asks the Location Manager to start positioning the device using beacons.
 */
- (void) startBeaconRangingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startBeaconRangingMeasuring"]){
        NSLog(@"[NOTI][LMRRL] Notification \"startBeaconRangingMeasuring\" recived.");
        
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
        NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                              andCredentialsUserDic:credentialsUserDic];
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        monitoredRegions = [[NSMutableArray alloc] init];
        monitoredPositions = [[NSMutableArray alloc] init];
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if ([mode isModeKey:kModeRhoRhoLocating]) {
                
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
                
                NSLog(@"[INFO][LMRRL] Start updating beacons.");
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            [self stopRoutine];
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                  andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[ERROR][LMRRL] Location services not allowed; updating beacons.");
        }
    }
}

/*!
 @method stopBeaconRangingMeasuring:
 @discussion This method asks the Location Manager to stop positioning the device using beacons.
 */
- (void) stopBeaconRangingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopBeaconRangingMeasuring"]){
        NSLog(@"[NOTI][LMRRL] Notification \"stopBeaconRangingMeasuring\" recived.");
        // TO DO: Valorate this next sentence. Alberto J. 2019/12/11.
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self stopRoutine];
        NSLog(@"[INFO][LMRRL] Stop updating compass and iBeacons.");
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
        NSLog(@"[NOTI][LMRRL] Notification \"resetLocationAndMeasures\" recived.");
        
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
