//
//  LMDelegateGPS.m
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateGPS.h"

@implementation LMDelegateGPS : NSObject

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
                                                     name:@"lmdGPS/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdGPS/stop"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMG] LocationManager prepared for monitoring mode.");
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
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = initDeviceUUID;
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
 @method setDeviceUUID:
 @discussion This method sets the UUID to identify the measures when self-locating.
 */
- (void)setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
    return;
}

#pragma mark - Location manager delegated methods - GPS
/*!
@method locationManager:didUpdateLocations:
@discussion This method is called when the GPS based location is updated.
*/
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"[INFO][LMG] Device did update locations:");
    for (CLLocation * location in locations) {
        CLLocationCoordinate2D coordinates = [location coordinate];
        CLLocationDegrees latitude = coordinates.latitude;
        CLLocationDegrees longitude = coordinates.longitude;
        CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;
        NSLog(@"[INFO][LMG] -> (%.10f,%.10f) ± %.3f", latitude, longitude, horizontalAccuracy);
        NSString * itemUUID = [[NSUUID UUID] UUIDString];
        [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:latitude]
                                      ofSort:@"devicelatitude"
                                withItemUUID:itemUUID
                              withDeviceUUID:deviceUUID
                                  atPosition:nil
                              takenByUserDic:userDic
                   andWithCredentialsUserDic:credentialsUserDic];
        [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:longitude]
                                      ofSort:@"devicelongitude"
                                withItemUUID:itemUUID
                              withDeviceUUID:deviceUUID
                                  atPosition:nil
                              takenByUserDic:userDic
                   andWithCredentialsUserDic:credentialsUserDic];
        [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic];
        NSLog(@"[INFO][LMG] Generated measures:");
        NSLog(@"[INFO][LMG]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
    }
}

#pragma mark - Notification event handles
/*!
 @method start:
 @discussion This method asks the Location Manager to start positioning the device using GPS.
 */
- (void) start:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdGPS/start"]){
        NSLog(@"[NOTI][LMG] Notification \"lmdGPS/start\" recived.");
        
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
            NSLog(@"[ERROR][LMG] Shared data could not be accessed while starting measuring.");
            return;
        }
        
        // Start locating if it is posible.
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                // Request authorization initially
                NSLog(@"[ERROR][LMG] Authorization is still not known.");
                
            case kCLAuthorizationStatusRestricted:
                // Disable location features
                NSLog(@"[ERROR][LMG] User still restricts localization services.");
                break;
                
            case kCLAuthorizationStatusDenied:
                // Disable location features
                NSLog(@"[ERROR][LMG] User still doesn't allow localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                // Enable location features
                NSLog(@"[INFO][LMG] User still allows 'always' localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // Enable location features
                NSLog(@"[INFO][LMG] User still allows 'when-in-use' localization services.");
                break;
                
            default:
                break;
        }
        
        // Error management
        if ([CLLocationManager locationServicesEnabled]) {
            NSLog(@"[INFO][LMG] Location services still enabled.");
        }else{
            NSLog(@"[ERROR][LMG] Location services still not enabled.");
        }
        
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            NSLog(@"[INFO][LMG] Monitoring still available for class CLBeaconRegion.");
        }else{
            NSLog(@"[ERROR][LMG] Monitoring still not available for class CLBeaconRegion.");
        }
        
        if ([CLLocationManager isRangingAvailable]) {
            NSLog(@"[INFO][LMG] Ranging still available.");
        }else{
            NSLog(@"[ERROR][LMG] Ranging still not available.");
        }
        
        if ([CLLocationManager headingAvailable]) {
            NSLog(@"[INFO][LMG] Heading available.");
        }else{
            NSLog(@"[ERROR][LMG] Heading not available.");
        }
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [locationManager startUpdatingLocation];
            NSLog(@"[INFO][LMG] Start updating GPS location.");
        }
        else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted)
        {
            [locationManager stopUpdatingLocation];
            NSLog(@"[ERROR][LMG] Location services not allowed; stop updating GPS location.");
        }
    }
}

/*!
 @method stop:
 @discussion This method asks the Location Manager to stop positioning the device using GPS.
 */
- (void) stopUpdatingLocation:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdGPS/stop"]){
        NSLog(@"[NOTI][LMG] Notification \"lmdGPS/stop\" recived.");
        [locationManager stopUpdatingLocation];
        NSLog(@"[INFO][LMG] Stop updating GPS location.");
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
        NSLog(@"[NOTI][LMG] Notification \"lmd/reset\" recived.");
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
