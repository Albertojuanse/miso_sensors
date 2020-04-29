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

#pragma mark - Notification event handles
/*!
 @method newMeasuresAvalible
 @discussion This method is called when a Location Manager Delegate takes a new measure; it clasifies the measures and decides what to do.
 */
- (void)newMeasuresAvalible:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ranging/newMeasuresAvalible"]){
        NSLog(@"[NOTI][LMR] Notification \"ranging/newMeasuresAvalible\" recived.");
        NSDictionary * data = notification.userInfo;
        calibrationUUID = data[@"calibrationUUID"];
        NSLog(@"[INFO][LMR] Location manager notifies new calibration mesurements of the iBeacon %@", calibrationUUID);
        
        // Check the access to data shared collections
        if (
            ![sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // TODO: handle intrusion situations. Alberto J. 2019/09/10.
            NSLog(@"[ERROR][LMR] Shared data could not be accessed before use grid aproximation.");
        }
        
        // Retrieve measures by sort and decide
        NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"rssi"
                                                               withCredentialsUserDic:credentialsUserDic];
        if ([rssiMeasures count] > 0) {
            [self processRssiMeasures:rssiMeasures];
        }
        
        NSMutableArray * calibrationAtRefDistanceMeasures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"calibrationAtRefDistance"
                                                                      withCredentialsUserDic:credentialsUserDic];
        if ([calibrationAtRefDistanceMeasures count] > 0) {
          [self processCalibrationAtRefDistanceMeasures:calibrationAtRefDistanceMeasures];
        }
        
    }
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

#pragma mark - Processing methods. Calibration
/*!
 @method processCalibrationAtRefDistanceMeasures:
 @discussion This method processes the calibration measures taken to calibrate the RSSI value at reference distance d0 and decides when it is calibrated
 */
- (void)processCalibrationAtRefDistanceMeasures:(NSMutableArray *)calibrationAtRefDistanceMeasures
{
    // Each beacon must be calibrated separetly, since each BLE device can transmit a different power values
    
    // Get item to calibrate.
    NSMutableDictionary * firstMeasure = [calibrationAtRefDistanceMeasures objectAtIndex:0];
    NSString * itemToCalibrateUUID = firstMeasure[@"itemUUID"];
    NSLog(@"[LMR][INFO] Measures taken to calibrate item: %@", itemToCalibrateUUID);
    NSMutableArray * itemsToCalibrate = [sharedData fromItemDataGetItemsWithUUID:itemToCalibrateUUID
                                                           andCredentialsUserDic:credentialsUserDic];    
    if ([itemsToCalibrate count] > 0) {
        itemToCalibrate = [itemsToCalibrate objectAtIndex:0];
    } else {
        NSLog(@"[LMR][ERROR] Item to calibrate not found %@", itemToCalibrateUUID);
        return;
    }
    
    // Gather all RSSI measured values
    NSMutableArray * beacons;
    for (NSMutableDictionary * eachMeasure in calibrationAtRefDistanceMeasures) {
        
        // Check measures
        NSString * eachMeasureUUID = eachMeasure[@"itemUUID"];
        if ([eachMeasureUUID isEqualToString:itemToCalibrateUUID]) {
            
            CLBeacon * eachBeacon = eachMeasure[@"measure"];
            [beacons addObject:eachBeacon];
            
        } else {
            NSLog(@"[LMR][ERROR] A measure taken from another item different to the calibrating one: %@", eachMeasureUUID);
        }
    }
    
    // Calibrate measures
    BOOL calibrationFinished = [self calibrateRefRSSIWithCLBeacons:beacons];
    if (calibrationFinished) {
        // Notify menu view that calibration is finished.
        NSLog(@"[NOTI][LMR] Notification \"calibration/finished\" posted.");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"calibration/finished"
         object:nil];
    }
    
    return;
}

/*!
 @method calibrateRefRSSIWithCLBeacons:
 @discussion This method calibrate the RSSI recived at d0 of an item given its measures; return YES if calibration is finished and NO if more measures are needed.
 */
- (BOOL)calibrateRefRSSIWithCLBeacons:(NSMutableArray *)beacons
{
    // Propagation model used is RSSI(d) = RSSI(d0) - 10 * n * log(d/d0)
    //  where RSSI(d)  is the received RSSI
    //        RSSI(d0) is a calibration value
    //        d0       is the distance for this calibration and
    //        n        is the attenuation factor of the wave
    // When calibrating, user places the beacon at 1 meter, so
    //        d0 = 1   and
    //        d0 = d   so
    //        RSSI(d) = RSSI(d0)
    // and this value is saved.
    // Then, the attenuation factor must be calculated. Using Friis formula,
    // the minimum attenuation factor is 2, and typical values must be < 10.

    // Get calibration costants.
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * locatingDic = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!minNumberOfSteps){
        NSNumber * minNumberOfStepsSaved = locatingDic[@"calibration/measures/minNumber"];
        minNumberOfSteps = [minNumberOfStepsSaved integerValue];
    }
    if (!gaussThreshold) {
        NSNumber * gaussThresholdSaved = locatingDic[@"calibration/measures/gaussThreshold"];
        gaussThreshold = [gaussThresholdSaved floatValue]/100.0;
    }
    
    if (beacons.count <= minNumberOfSteps) {
        NSLog(@"[INFO][LMR] %tu measures taken; not calibrating.", beacons.count);
        return NO;
    } else {
        NSLog(@"[INFO][LMR] %tu measures taken; calibrating.", beacons.count);
        
        // Retrieve from item to calibrate old variables to use them as initialization point; if not, initialize them
        NSNumber * refRSSI = itemToCalibrate[@"refRSSI"];
        NSNumber * refDistance = itemToCalibrate[@"refDistance"];
        NSNumber * attenuationFactor = itemToCalibrate[@"attenuationFactor"];
        if(!refRSSI) {
            NSNumber * initRefRSSI = locatingDic[@"calibration/init/refRSSI"];
            refRSSI = [NSNumber numberWithFloat:[initRefRSSI floatValue]];
            NSLog(@"[LMR][INFO] Reference RSSI value of item not found; set default.");
        }
        if(!refDistance) {
            NSNumber * initRefDistance = locatingDic[@"calibration/init/refDistance"];
            refDistance = [NSNumber numberWithFloat:[initRefDistance floatValue]];
            NSLog(@"[LMR][INFO] Reference distance value of item not found; set default.");
        }
        if(!attenuationFactor) {
            NSNumber * initAttenuationFactor = locatingDic[@"calibration/init/attenuationFactor"];
            attenuationFactor = [NSNumber numberWithFloat:[initAttenuationFactor floatValue]];
            NSLog(@"[LMR][INFO] Reference attenuation factor of item not found; set default.");
        }
        
        // Retrieve RSSI values
        NSMutableArray * rssiValues = [[NSMutableArray alloc] init];
        for (CLBeacon * beacon in beacons) {
            NSNumber * rssiValue = [NSNumber numberWithInteger:[beacon rssi]];
            [rssiValues addObject:rssiValue];
        }
        
        // Filter the values using a gaussian filter
        NSMutableArray * filteredRSSIValues = [self gaussianFilterOfMeasures:rssiValues];
        
        // Calculate mean with the measures left and save it as refRSSI
        NSNumber * acc = [NSNumber numberWithFloat:0.0];
        for (NSNumber * rssiValue in filteredRSSIValues) {
            acc = [NSNumber numberWithFloat:[acc floatValue] + [rssiValue floatValue]];
        }
        NSNumber * newRefRSSI = [NSNumber numberWithFloat:
                                 [acc floatValue]/filteredRSSIValues.count
                                 ];
        itemToCalibrate[@"refRSSI"] = newRefRSSI;
    
        // Decide weather the calibration is finished or not
        return YES;
    }
}

/*!
@method gaussianFilterOfMeasures:
@discussion This method filters the measured values using a gaussian filter.
*/
- (NSMutableArray *)gaussianFilterOfMeasures:(NSMutableArray *)rssiValues
{
    // Mean value
    NSNumber * acc = [NSNumber numberWithFloat:0.0];
    for (NSNumber * rssiValue in rssiValues) {
        acc = [NSNumber numberWithFloat:[acc floatValue] + [rssiValue floatValue]];
    }
    NSNumber * meanValue = [NSNumber numberWithFloat:[acc floatValue]/rssiValues.count];
    
    // Variance
    acc = nil; //ARC dispose
    acc = [NSNumber numberWithFloat:0.0];
    for (NSNumber * rssiValue in rssiValues) {
        NSNumber * distance = [NSNumber numberWithFloat:
                               ([rssiValue floatValue] - [meanValue floatValue]) *
                               ([rssiValue floatValue] - [meanValue floatValue])
                               ];
        acc = [NSNumber numberWithFloat:[acc floatValue] + [distance floatValue]];
    }
    NSNumber * variance = [NSNumber numberWithFloat:
                           [acc floatValue]/(rssiValues.count - 1)
                           ];
    
    // Evaluate effective range in which measures sum the 0.6 of probability.
    // For that, a min and a max value of that range must be found.
    NSSortDescriptor * highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                       ascending:NO];
    [rssiValues sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    NSLog(@"[LMR][INFO] Sorted beacon measures: %@", rssiValues);
    NSLog(@"[LMR][INFO] There are %tu measures before filter.", rssiValues.count);
    
    // Once sorted, the max and min values are removed until the cumulative
    // probability is less than 0.6; at that point, the valid solution is the
    // previous one, greater than 0.6.
    NSNumber * maxRSSI;
    NSNumber * minRSSI;
    NSInteger iter = rssiValues.count;
    for (int i = 1; i < iter; i++) {
        NSNumber * auxMaxRSSI = [rssiValues lastObject];
        NSNumber * auxMinRSSI = [rssiValues objectAtIndex:0];
        
        NSNumber * cumulativeMinRSSI = [self gaussianFilterFunctionOf:auxMinRSSI
                                                             withMean:meanValue
                                                          andVariance:variance];
        NSNumber * cumulativeMaxRSSI = [self gaussianFilterFunctionOf:auxMaxRSSI
                                                             withMean:meanValue
                                                          andVariance:variance];
        NSNumber * cumulativeDiffValue = [NSNumber numberWithFloat:
                                          [cumulativeMaxRSSI floatValue] -
                                          [cumulativeMinRSSI floatValue]
                                          ];
        if ([cumulativeDiffValue floatValue] < gaussThreshold) {
            NSLog(@"[LMR][INFO] Range found");
            NSLog(@"[LMR][INFO] The next cumulative probability integred was %.2f",
                  [cumulativeDiffValue floatValue]);
            break;
        } else {
            NSLog(@"[LMR][INFO] The cumulative probability integred is %.2f",
                  [cumulativeDiffValue floatValue]);
            [rssiValues removeObjectAtIndex:0];
            [rssiValues removeLastObject];
            maxRSSI = auxMaxRSSI;
            minRSSI = auxMinRSSI;
        }
    }
    NSLog(@"[LMR][INFO] There are %tu measures left after filter.", rssiValues.count);
    return rssiValues;
}

/*!
 @method gaussianFilterFunctionWithMean:andVariance:
 @discussion This method defines the gaussian function used by the gaussian filter; the gaussian cumulative distribution using function error.
 */
- (NSNumber *)gaussianFilterFunctionOf:(NSNumber *)x
                              withMean:(NSNumber *)mean
                           andVariance:(NSNumber *)variance
{
    return [NSNumber numberWithFloat:
            0.5*(1 + erf(([mean floatValue]-[x floatValue])/
                         (sqrt([variance floatValue])*M_SQRT1_2)))
            ];
}

#pragma mark - Processing methods. Measures
/*!
 @method processRssiMeasures:
 @discussion This method processes the RSSI measures.
 */
- (void)processRssiMeasures:(NSMutableArray *)rssiMeasures
{
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    
    // For every RSSI measure taken in a Rho type mode...
    for (NSMutableDictionary * measureDic in rssiMeasures) {
        
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
    
    return;
}

@end
