//
//  LMDelegateHeading.m
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateHeading.h"

@implementation LMDelegateHeading : NSObject

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
                                                     name:@"lmdHeading/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdHeading/stop"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmd/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMH] LocationManager prepared for monitoring mode.");
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
        NSLog(@"[ERROR][LMH] Shared data could not be accessed while starting travel.");
        return;
    }
    // Get the measuring mode
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    if (mode) {
        if ([mode isModeKey:kModeCompassSelfLocating]) {
            NSString * itemUUID = [[NSUUID UUID] UUIDString];
            [sharedData inMeasuresDataSetMeasure:[NSNumber numberWithDouble:[newHeading trueHeading]*M_PI/180.0]
                                          ofSort:@"deviceheading"
                                    withItemUUID:itemUUID
                                  withDeviceUUID:deviceUUID
                                      atPosition:nil
                                  takenByUserDic:userDic
                       andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[INFO][LMH] Device did update its heading:");
            NSLog(@"[INFO][LMH] ->  %.3f", [newHeading trueHeading]*M_PI/180.0);
            
            NSLog(@"[INFO][LMH] Generated measures: %@",
                  [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
        } else {
            lastMeasuredHeading = newHeading;
        }
    } else {
        lastMeasuredHeading = newHeading;
    }
    return;
}

#pragma mark - Notification event handles
/*!
@method start:
@discussion This method asks the Location Manager to start positioning the device using its compass.
*/
- (void) start:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdHeading/start"]){
        NSLog(@"[NOTI][LMH] Notification \"lmdHeading/start\" recived.");
        
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
            NSLog(@"[ERROR][LMH] Shared data could not be accessed while starting measuring.");
            return;
        }
        
        // Start locating if it is posible.
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                // Request authorization initially
                NSLog(@"[ERROR][LMH] Authorization is still not known.");
                
            case kCLAuthorizationStatusRestricted:
                // Disable location features
                NSLog(@"[ERROR][LMH] User still restricts localization services.");
                break;
                
            case kCLAuthorizationStatusDenied:
                // Disable location features
                NSLog(@"[ERROR][LMH] User still doesn't allow localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                // Enable location features
                NSLog(@"[INFO][LMH] User still allows 'always' localization services.");
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                // Enable location features
                NSLog(@"[INFO][LMH] User still allows 'when-in-use' localization services.");
                break;
                
            default:
                break;
        }
        
        // Error management
        if ([CLLocationManager locationServicesEnabled]) {
            NSLog(@"[INFO][LMH] Location services still enabled.");
        }else{
            NSLog(@"[ERROR][LMH] Location services still not enabled.");
        }
        
        if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            NSLog(@"[INFO][LMH] Monitoring still available for class CLBeaconRegion.");
        }else{
            NSLog(@"[ERROR][LMH] Monitoring still not available for class CLBeaconRegion.");
        }
        
        if ([CLLocationManager isRangingAvailable]) {
            NSLog(@"[INFO][LMH] Ranging still available.");
        }else{
            NSLog(@"[ERROR][LMH] Ranging still not available.");
        }
        
        if ([CLLocationManager headingAvailable]) {
            NSLog(@"[INFO][LMH] Heading available.");
        }else{
            NSLog(@"[ERROR][LMH] Heading not available.");
        }
        
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            deviceUUID = [[NSUUID UUID] UUIDString]; // Random deviceUUID; not used
            [locationManager startUpdatingHeading];
            NSLog(@"[INFO][LMH] Start updating device heading.");
        }
        else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted)
        {
            [locationManager stopUpdatingLocation];
            NSLog(@"[ERROR][LMH] Location services not allowed; stop updating GPS location.");
        }
    }
}

/*!
@method stopUpdatingHeading:
@discussion This method asks the Location Manager to stop positioning the device using its compass.
*/
- (void) stop:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdHeading/stop"]){
        
        // Get the measuring mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        if (mode) {
            if ([mode isModeKey:kModeCompassSelfLocating]) {
                // Nothing
            } else {
            NSNumber * north = [NSNumber numberWithDouble:[lastMeasuredHeading trueHeading]*M_PI/180.0];
            [sharedData inSessionDataSetCurrentModelNorth:north
                                        toUserWithUserDic:userDic
                                   withCredentialsUserDic:credentialsUserDic];
                NSLog(@"[INFO][LMH] North value set in session data: %.2f.", [lastMeasuredHeading trueHeading]*M_PI/180.0);
            }
        } else {
            NSNumber * north = [NSNumber numberWithDouble:[lastMeasuredHeading trueHeading]*M_PI/180.0];
            [sharedData inSessionDataSetCurrentModelNorth:north
                                        toUserWithUserDic:userDic
                                   withCredentialsUserDic:credentialsUserDic];
            NSLog(@"[INFO][LMH] North value set in session data: %.2f.", [lastMeasuredHeading trueHeading]*M_PI/180.0);
        }
            
        NSLog(@"[NOTI][LMH] Notification \"lmdHeading/stop\" recived.");
        [locationManager stopUpdatingHeading];
        NSLog(@"[INFO][LMH] Stop updating device heading.");
    }
    return;
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
        NSLog(@"[NOTI][LMH] Notification \"lmd/reset\" recived.");
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}
@end
