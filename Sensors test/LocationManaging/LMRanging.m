//
//  LMRanging.m
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "LMRanging.h"

@implementation LMRanging: NSObject

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
        
        // This object must listen to this events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMeasuresAvalible:)
                                                     name:@"ranging/newMeasuresAvalible"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reset:)
                                                     name:@"ranging/reset"
                                                   object:nil];
        
        NSLog(@"[INFO][LMR] LM Ranging module prepared.");
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

#pragma mark - Working methods

/*!
 @method newMeasuresAvalible
 @discussion This method is called when a Location Manager Delegate takes a new measure; it modifies only the numeric values to calibrate measures.
 */
- (void)newMeasuresAvalible:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ranging/newMeasuresAvalible"]){
        NSLog(@"[NOTI][LMR] Notification \"ranging/newMeasuresAvalible\" recived.");
        
        // Check the access to data shared collections
        if (
            ![sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // TODO: handle intrusion situations. Alberto J. 2019/09/10.
            NSLog(@"[ERROR][LMR] Shared data could not be accessed before use grid aproximation.");
        }
        
        // Get the measuring mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
        
        NSMutableArray * measures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"rssi" withCredentialsUserDic:credentialsUserDic];
        
        for (NSMutableDictionary * measureDic in measures) {
            
            id measure = measureDic[@"measure"];
            CLBeacon * beacon;
            if ([measure isKindOfClass:[CLBeacon class]]) {
                beacon = (CLBeacon *)measureDic[@"measure"];
            } else {
                NSLog(@"[ERROR][LMR] Measure of sort RSSI does not contain and CLBeaconRegion object.");
                break;
            }
            
            // ...get its information...
            NSNumber * rssi = [NSNumber numberWithInteger:[beacon rssi]];
            // TODO. Calibration. Alberto J. 2019/11/14.
            // TODO: Get the 1 meter RSSI from CLBeacon. Alberto J. 2019/11/14.
            // Absolute values of speed of light, frecuency, and antenna's join gain
            float C = 299792458.0;
            float F = 2440000000.0; // 2400 - 2480 MHz
            float G = 1.0; // typically 2.16 dBi
            // Calculate the distance
            float distance = (C / (4.0 * M_PI * F)) * sqrt(G * pow(10.0, -[rssi floatValue]/ 10.0));
            NSNumber * RSSIdistance = [[NSNumber alloc] initWithFloat:distance];

            // ...prepare the measure..
            NSMutableDictionary * measureUserDic = measureDic[@"user"];
            RDPosition * measurePosition = measureDic[@"position"];
            NSString * measureItemUUID = measureDic[@"itemUUID"];
            NSString * measureDeviceUUID = measureDic[@"deviceUUID"];
            
            // ...and save it.
            [sharedData inMeasuresDataSetMeasure:RSSIdistance
                                          ofSort:@"calibratedRSSI"
                                    withItemUUID:measureItemUUID
                                  withDeviceUUID:measureDeviceUUID
                                      atPosition:measurePosition
                                  takenByUserDic:measureUserDic
                       andWithCredentialsUserDic:credentialsUserDic];
        }

        // Ask radiolocation of beacons if posible
        // Precision is arbitrary set to 10 cm
        // TODO: Make this configurable. Alberto J. 2019/09/12.
        NSDictionary * precisions = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:0.1], @"xPrecision",
                                     [NSNumber numberWithFloat:0.1], @"yPrecision",
                                     [NSNumber numberWithFloat:0.1], @"zPrecision",
                                     nil];
        NSMutableDictionary * locatedPositions;
        if ([mode isModeKey:kModeRhoThetaModelling]) {
            locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithPrecisions:precisions];
        }
        else if ([mode isModeKey:kModeRhoThetaModelling]) {
            locatedPositions = [rhoThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
        }

        if (locatedPositions) {
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
                    NSLog(@"[ERROR][LMR] Located position %@ could not be stored as an item.", infoDic[@"position"]);
                }
            }
            
        }
            
        // Save variables in device memory
        // TODO: Session control to prevent data loss. Alberto J. 2020/02/17.
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

        NSLog(@"[INFO][LMR] Generated locations:");
        NSLog(@"[INFO][LMR]  -> %@",  [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                andCredentialsUserDic:credentialsUserDic]);

        NSLog(@"[INFO][LMR] Generated measures:");
        NSLog(@"[INFO][LMR]  -> %@", [sharedData getMeasuresDataWithCredentialsUserDic:credentialsUserDic]);

        // Ask view controller to refresh the canvas
        NSLog(@"[NOTI][LMR] Notification \"canvas/refresh\" posted.");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"canvas/refresh"
         object:nil];
        
    }

    return;
}

/*!
 @method reset
 @discussion This method resets the memorized parameters
 */
- (void)reset:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ranging/reset"]){
        NSLog(@"[NOTI][LM] Notification \"ranging/reset\" recived.");
        
        
        // Components
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
    }
    return;
}

@end
