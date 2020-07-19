//
//  LMDelegateThetaThetaModelling.m
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMDelegateThetaThetaModelling.h"

@implementation LMDelegateThetaThetaModelling : NSObject

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
        currentCompassHeading = [locationManager heading];
        lastMeasuredHeading = nil;
        needMeasureHeading = NO;
        
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
                                                     name:@"lmdThetaThetaModelling/start"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stop:)
                                                     name:@"lmdThetaThetaModelling/stop"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"lmdThetaThetaModelling/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMTTM] LocationManager prepared for kModeThetaThetaModelling mode.");
    }
    
    return self;
}

/*!
 @method initWithSharedData:userDic:thetaThetaSystem:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self initWithSharedData:initSharedData];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        thetaThetaSystem = initThetaThetaSystem;
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
 @method locationManager:didChangeAuthorizationStatus:
 @discussion This method is called when the device's location permission change because user's desire or automatic routines; depending on the current permission status this delegate will start searching for beacon's regions or not.
 */
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // Request authorization initially
            NSLog(@"[ERROR][LMTTM] Authorization is not known.");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LMTTM] User restricts localization services.");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LMTTM] User doesn't allow localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LMTTM] User allows 'always' localization services.");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LMTTM] User allows 'when-in-use' localization services.");
            break;
            
        default:
            break;
    }
    
    // Error management
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LMTTM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LMTTM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LMTTM] Monitoring available for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LMTTM] Monitoring not available for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LMTTM] Ranging available.");
    }else{
        NSLog(@"[ERROR][LMTTM] Ranging not available.");
    }
    
    if ([CLLocationManager headingAvailable]) {
        NSLog(@"[INFO][LMTTM] Heading available.");
    }else{
        NSLog(@"[ERROR][LMTTM] Heading not available.");
    }
}

/*!
 @method locationManager:didUpdateHeading:
 @discussion This method is called when the device wants to deliver a data about its heading.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    // Upadate current compass heading
    currentCompassHeading = newHeading;
    
    // Check for asynchronous measuring needs
    if (needMeasureHeading) {
        lastMeasuredHeading = currentCompassHeading;
        needMeasureHeading = NO;
        NSLog(@"[INFO][LMTTM] Measuring needed; updated last measured heading.");
    }
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
 @discussion This method asks the Location Manager to start positioning the device using the compass.
 */
- (void) start:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdThetaThetaModelling/start"]){
        NSLog(@"[NOTI][LMTTM] Notification \"lmdThetaThetaModelling/start\" recived.");
        // TODO: Valorate this next sentence. Alberto J. 2019/12/11.
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
             // TODO: handle intrusion situations. Alberto J. 2019/09/10.
             }
             ];
             */
            NSLog(@"[ERROR][LMTTM] Shared data could not be accessed while starting compass heading measure.");
            return;
        }
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        // If using location services is allowed
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
           CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            if ([mode isModeKey:kModeThetaThetaModelling]) {
                
                // Get class variables to get the item's position facet from the item chosen by user to be the device (modelling mode)
                NSMutableDictionary * itemChosenByUserDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
                deviceUUID = itemChosenByUserDic[@"uuid"];
                if (itemChosenByUserDic[@"position"]) {
                    devicePosition = itemChosenByUserDic[@"position"];
                } else {
                    NSLog(@"[ERROR][LMTTM] No position found in item to be measured.");
                }

                // Get class variables to get the item's position facet from the item chosen by user to measure (modelling mode)
                NSDictionary * dataDic = [notification userInfo];
                NSMutableDictionary * itemDic = dataDic[@"itemDic"];
                itemToMeasureUUID = itemDic[@"uuid"];
                
                // Start heading mesures
                [locationManager startUpdatingHeading];
                NSLog(@"[INFO][LMTTM] Start updating compass heading.");
                needMeasureHeading = YES;
                
            } else {
                NSLog(@"[ERROR][LMTTM] Instantiated class %@ when using %@ mode.",
                      NSStringFromClass([self class]),
                      mode
                      );
            }
            
        }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                  CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
            [self stopRoutine];
            [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                  andWithCredentialsUserDic:credentialsUserDic];
            NSLog(@"[ERROR][LMTTM] Location services not allowed; stop updating compass heading.");
        }
    }
}

/*!
 @method stop:
 @discussion This method asks the Location Manager to stop positioning the device using the compass.
 */
- (void) stop:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"lmdThetaThetaModelling/stop"]){
        NSLog(@"[NOTI][LMTTM] Notification \"lmdThetaThetaModelling/stop\" recived.");
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self saveMeasure];
        [self stopRoutine];
        NSLog(@"[INFO][LMTTM] Stop updating compass heading.");
    }
}

/*!
@method saveMeasure:
@discussion This method is called when measured must finish and compose and save the measure.
*/
- (void) saveMeasure
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
        NSLog(@"[ERROR][LMTTM] Shared data could not be accessed while starting travel.");
        return;
    }
        
    // Get the measuring mode
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    
    if ([mode isModeKey:kModeThetaThetaModelling]) {
        
        // The heading measures in this mode are only saved if the user did select the item to aim.
        if(itemToMeasureUUID) {
            
            // Get position facet's information...
            RDPosition * measurePosition = [[RDPosition alloc] init];
            measurePosition.x = measurePosition.x;
            measurePosition.y = measurePosition.y;
            measurePosition.z = measurePosition.z;
            
            double lastMeasuredHeadingValue = [lastMeasuredHeading trueHeading]*M_PI/180.0;
            double currentCompassHeadingValue = [currentCompassHeading trueHeading]*M_PI/180.0;
            NSNumber * measure = [NSNumber numberWithDouble:currentCompassHeadingValue - lastMeasuredHeadingValue];
            
            // ...and save data
            [sharedData inMeasuresDataSetMeasure:measure
                                          ofSort:@"heading"
                                    withItemUUID:itemToMeasureUUID
                                  withDeviceUUID:deviceUUID
                                      atPosition:measurePosition
                                  takenByUserDic:userDic
                       andWithCredentialsUserDic:credentialsUserDic];
        } else {
            NSLog(@"[INFO][LMTTM] User did choose a UUID source that is not being ranging; disposing.");
        }
        
        // Precision is arbitrary set to 10 cm
        // TODO: Make this configurable. Alberto J. 2019/09/12.
        NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:0.1], @"xPrecision",
                                     [NSNumber numberWithFloat:0.1], @"yPrecision",
                                     [NSNumber numberWithFloat:0.1], @"zPrecision",
                                     nil];
        
        // Ask radiolocation of beacons if posible...
        NSMutableDictionary * locatedPositions;
        locatedPositions = [thetaThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
        // ...and save them as a located item.
        NSArray *positionKeys = [locatedPositions allKeys];
        for (id positionKey in positionKeys) {
            NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
            infoDic[@"located"] = @"YES";
            infoDic[@"sort"] = @"position";
            NSString * itemIdentifier = [@"position" stringByAppendingString:[positionKey substringFromIndex:31]];
            itemIdentifier = [itemIdentifier stringByAppendingString:@"@miso.uam.es"];
            infoDic[@"identifier"] = itemIdentifier;
            infoDic[@"position"] = [locatedPositions objectForKey:positionKey];
            
            BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                        withUUID:positionKey
                                                     withInfoDic:infoDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            if (savedItem) {
                
                // Get it as it was saved
                NSMutableArray * savedItemDics = [sharedData fromItemDataGetItemsWithIdentifier:itemIdentifier
                                                                          andCredentialsUserDic:credentialsUserDic];
                NSMutableDictionary * savedItemDic;
                if ([savedItemDics count] > 0) {
                    savedItemDic = [savedItemDics objectAtIndex:0];
                }
                if (savedItemDic) {
                    [sharedData inSessionDataSetAsChosenItem:savedItemDic
                                           toUserWithUserDic:userDic
                                      withCredentialsUserDic:credentialsUserDic];
                    
                    // Persist it in memory
                    [self updatePersistentItemsWithItem:savedItemDic];
                    
                } else {
                    NSLog(@"[ERROR][LMTTM] New position %@ could not be stored as an item.", infoDic[@"position"]);
                }
                
                // Ask view controller to refresh the canvas
                NSLog(@"[NOTI][LMTTM] Notification \"canvas/refresh\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"canvas/refresh"
                 object:nil];
            } else {
                NSLog(@"[ERROR][LMTTM] Located position %@ could not be stored as an item.", infoDic[@"position"]);
            }
        }
        
        NSLog(@"[INFO][LMTTM] Generated locations: %@",
              [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                      andCredentialsUserDic:credentialsUserDic]);
        NSLog(@"[INFO][LMTTM] Generated measures: %@",
              [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);
        
    }
}

/*!
 @method updatePersistentItemsWithItem:
 @discussion This method is called when creates a new item to upload it.
 */
- (BOOL)updatePersistentItemsWithItem:(NSMutableDictionary *)itemDic
{
    // Set the variable areItems as YES
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
    NSData * areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
    
    // Get the index and upload it
    NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
    NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
    if (!itemsIndex) {
        itemsIndex = [[NSMutableArray alloc] init];
    }
    NSString * itemIdentifier = itemDic[@"identifier"];
    [itemsIndex addObject:itemIdentifier];
    itemsIndexData = nil; // ARC disposal
    itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
    [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
    
    // Save the item itself
    NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:itemDic];
    NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
    [userDefaults setObject:itemData forKey:itemKey];
    
    return YES;
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
 @method reset:
 @discussion Setter of current position of the device using observer pattern.
 */
- (void) reset:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"lmdThetaThetaModelling/reset"]){
        NSLog(@"[NOTI][LMTTM] Notification \"lmdThetaThetaModelling/reset\" recived.");
        
        // Instance variables
        // Set device's location at the origin
        devicePosition = [[RDPosition alloc] init];
        devicePosition.x = [NSNumber numberWithFloat:0.0];
        devicePosition.y = [NSNumber numberWithFloat:0.0];
        devicePosition.z = [NSNumber numberWithFloat:0.0];
        
        // Delete registered regions and heading updates
        [self stopRoutine];
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
}

@end
