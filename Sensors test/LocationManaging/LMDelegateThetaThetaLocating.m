//
//  LMDelegateThetaThetaLocating.m
//  Sensors test
//
//  Created by Alberto J. on 20/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateThetaThetaLocating.h"

@implementation LMDelegateThetaThetaLocating : NSObject

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
                                                 selector:@selector(startCompassHeadingMeasuring:)
                                                     name:@"startCompassHeadingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopCompassHeadingMeasuring:)
                                                     name:@"stopCompassHeadingMeasuring"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"resetLocationAndMeasures"
                                                   object:nil];
        
        NSLog(@"[INFO][LMTTL] LocationManager prepared for monitoring mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:thetaThetaSystem:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    sharedData = initSharedData;
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    deviceUUID = initDeviceUUID;
    thetaThetaSystem = initThetaThetaSystem;
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

#pragma mark - Location manager delegated methods - Compass
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
            NSLog(@"[ERROR][LMTTL] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMTTL] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMTTL] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMTTL] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMTTL] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMTTL] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMTTL] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMTTL] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMTTL] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMTTL] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMTTL] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMTTL] Heading available.");
    }else{
        NSLog(@"[ERROR][LMTTL] Heading not available.");
    }
}

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
        NSLog(@"[ERROR][LMTTL] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // Different behave depending on the current state
    // If app is measuring the device user
    if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic
                                        andCredentialsUserDic:credentialsUserDic]) {
        
        // Get the measuring mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        
        if ([mode isModeKey:kModeThetaThetaLocating]) {
            
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
                NSLog(@"[INFO][LMTTL] User did choose a UUID source that is not being ranging; disposing.");
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
            // ...and save them as a located item.
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
                // Check if it is a item chosen by user
                MDType * type = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                            andCredentialsUserDic:credentialsUserDic];
                if(type) {
                    infoDic[@"type"] = type;
                }
                BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                            withUUID:positionKey
                                                         withInfoDic:infoDic
                                           andWithCredentialsUserDic:credentialsUserDic];
                if (savedItem) {
                    
                } else {
                    NSLog(@"[ERROR][LMTTL] Located position %@ could not be stored as an item.", infoDic[@"position"]);
                }
            }
            
            NSLog(@"[INFO][LMTTL] Generated locations:");
            NSLog(@"[INFO][LMTTL]  -> %@", [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                andCredentialsUserDic:credentialsUserDic]);
            NSLog(@"[INFO][LMTTL] Generated measures:");
            NSLog(@"[INFO][LMTTL]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
            
            // Ask view controller to refresh the canvas
            NSLog(@"[NOTI][LMTTL] Notification \"refreshCanvas\" posted.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"refreshCanvas"
             object:nil];
            
        }
        
    } else { // If is idle...
        // Do nothing
    }
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
 @method startCompassHeadingMeasuring:
 @discussion This method asks the Location Manager to start positioning the device using the compass.
 */
- (void) startCompassHeadingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"startCompassHeadingMeasuring"]){
        NSLog(@"[NOTI][LMTTL] Notification \"startCompassHeadingMeasuring\" recived.");
        // TO DO: Valorate this next sentence. Alberto J. 2019/12/11.
        [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];        
        
        // Start locating if it is posible.
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
            NSLog(@"[ERROR][LMTTL] Shared data could not be accessed while starting compass heading measure.");
            return;
        }
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if ([mode isModeKey:kModeThetaThetaLocating]) {
                
                [locationManager startUpdatingHeading];
                NSLog(@"[INFO][LMTTL] Start updating compass heading.");
            } else {
                NSLog(@"[ERROR][LMTTL] Instantiated class %@ when using %@ mode.",
                      NSStringFromClass([self class]),
                      mode
                      );
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            [locationManager stopUpdatingLocation];
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                  andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[ERROR][LMTTL] Location services not allowed; stop updating compass heading.");
        }
    }
}

/*!
 @method stopCompassHeadingMeasuring:
 @discussion This method asks the Location Manager to stop positioning the device using the compass.
 */
- (void) stopCompassHeadingMeasuring:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"stopCompassHeadingMeasuring"]){
        NSLog(@"[NOTI][LMTTL] Notification \"stopCompassHeadingMeasuring\" recived.");
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self stopRoutine];
        NSLog(@"[INFO][LMTTL] Stop updating compass heading.");
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
        NSLog(@"[NOTI][LM] Notification \"resetLocationAndMeasures\" recived.");
        
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
