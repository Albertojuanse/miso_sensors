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
                                                 selector:@selector(startCompassHeadingAndBeaconRangingMeasuring:)
                                                     name:@"startCompassHeadingAndBeaconRangingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopCompassHeadingAndBeaconRangingMeasuring:)
                                                     name:@"stopCompassHeadingAndBeaconRangingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"resetLocationAndMeasures"
                                                   object:nil];
        
        NSLog(@"[INFO][LMRTM] LocationManager prepared for kModeRhoThetaModelling mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:rhoThetaSystem:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    sharedData = initSharedData;
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    deviceUUID = initDeviceUUID;
    rhoThetaSystem = initRhoThetaSystem;
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
         // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
         }
         ];
         */
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][LMRTM] Shared data could not be accessed when beacon ranged.");
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
            if ([mode isModeKey:kModeRhoThetaModelling]) {
                
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
                    
                    // ...and retrieve the aimed item information.
                    //      In this mode, the user must select an item to measure, whose item dictionary is stored in session dictionary as 'itemChosenByUser'.
                    NSMutableDictionary * itemChosenByUserDic = [sharedData
                                                                 fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                 andCredentialsUserDic:credentialsUserDic
                                                                 ];
                    // If its not null retrieve the information needed.
                    NSString * itemUUID;
                    if (itemChosenByUserDic) {
                        itemUUID = itemChosenByUserDic[@"uuid"];
                        
                        // If the UUID is not found, the measure cannot be saved
                        if (!itemUUID) {
                            NSLog(@"[ERROR][LMRTM] Measure not saved since the item selected had no UUID.");
                            return;
                        } else {
                            
                            // Minimum sensibility 5 cm; Ipad often gives unreal values near to cero
                            // TO DO: Make this configurable. Alberto J. 2019/09/12.
                            if ([RSSIdistance floatValue] > 0.05) {
                                
                                // The measure is saved only if event's uuid and the chosen one are the same; also, the heading measures only will be saved if becons measures are saved, when 'isItemChosenByUserRanged' is true.
                                if ([itemUUID isEqualToString:uuid]) {
                                    
                                    // Conditional clausule for an specific issue with Apple devices' heading measures:
                                    if (!isItemChosenByUserRanged) {
                                        // Device does not deliver heading measures unless new values available; when RSSI measures from the chosen item is saved, can occur that no heading is saved until user moves the device. If it happens, the delegated method 'locationManager:didUpdateHeading:' is never called, and so, this method saves its value once. If 'isItemChosenByUserRanged' flag is false means this is the first time that this item is ranged, and thus, this heading is saved as a first heading measure to, at least, save one.
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
                        
                    } else {
                        NSLog(@"[ERROR][LMRTM] Measure not saved since user did not choose any item.");
                        return;
                    }
                
                }
                
                NSLog(@"[INFO][LMRTM] Generated locations:");
                NSLog(@"[INFO][LMRTM]  -> %@",  [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                     andCredentialsUserDic:credentialsUserDic]);
                
                NSLog(@"[INFO][LMRTM] Generated measures:");
                NSLog(@"[INFO][LMRTM]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
                    
                // Ask view controller to refresh the canvas
                NSLog(@"[NOTI][LMRTM] Notification \"refreshCanvas\" posted.");
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
         // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
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
                NSLog(@"[INFO][LMRTM] User did choose a UUID source that is not being ranging; disposing.");
            }
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
    if(!manager.heading) return YES; // Got nothing, We can assume we got to calibrate.
    else if(manager.heading.headingAccuracy < 0 ) return YES; // 0 means invalid heading, need to calibrate
    else if(manager.heading.headingAccuracy > 3 ) return YES; // 5 degrees is a small value correct for my needs, too.
    else return NO; // All is good. Compass is precise enough.
}

#pragma mark - Notification event handles

/*!
 @method startCompassHeadingAndBeaconRangingMeasuring:
 @discussion This method asks the Location Manager to start positioning the device using compass and iBeacons.
 */
- (void) startCompassHeadingAndBeaconRangingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startCompassHeadingAndBeaconRangingMeasuring"]){
        NSLog(@"[NOTI][LMRTM] Notification \"startCompassHeadingAndBeaconRangingMeasuring\" recived.");
        
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
            
            if ([mode isModeKey:kModeRhoThetaModelling]) {
                
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
                
                // Start heading mesures
                [locationManager startUpdatingHeading];
                
                NSLog(@"[INFO][LMRTM] Start updating compass and iBeacons.");
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
 @method stopCompassHeadingAndBeaconRangingMeasuring:
 @discussion This method asks the Location Manager to stop positioning the device using compass and iBeacons.
 */
- (void) stopCompassHeadingAndBeaconRangingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopCompassHeadingAndBeaconRangingMeasuring"]){
        NSLog(@"[NOTI][LMRTM] Notification \"stopCompassHeadingAndBeaconRangingMeasuring\" recived.");
        // TO DO: Valorate this next sentence. Alberto J. 2019/12/11.
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self stopRoutine];
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
    if ([[notification name] isEqualToString:@"resetLocationAndMeasures"]){
        NSLog(@"[NOTI][LMRTM] Notification \"resetLocationAndMeasures\" recived.");
        
        // Instance variables
        // Set device's location at the origin
        position = [[RDPosition alloc] init];
        position.x = [NSNumber numberWithFloat:0.0];
        position.y = [NSNumber numberWithFloat:0.0];
        position.z = [NSNumber numberWithFloat:0.0];
        
        isItemChosenByUserRanged = NO;
        // Heading is not delivered unless new values available; when RSSI measures from the chosen UUID is saved, no heading is saved until user moves the device; thus, this location is saved if no heading measure is taken
        lastHeadingPosition = nil;
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
