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
        
        // Get calibration costants.
        NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLocating" ofType:@"plist"];
        NSDictionary * locatingDic = [NSDictionary dictionaryWithContentsOfFile:path];
        if (!minNumberOfIterations){
            NSNumber * minNumberOfIterationsSaved = locatingDic[@"calibration/measures/minNumber"];
            minNumberOfIterations = [minNumberOfIterationsSaved integerValue];
        }
        minNumberOfIterationsOfFirstStep = minNumberOfIterations;
        minNumberOfIterationsOfSecondStep = minNumberOfIterations;
        if (!maxNumberOfIterations){
            NSNumber * maxNumberOfIterationsSaved = locatingDic[@"calibration/measures/maxNumber"];
            maxNumberOfIterations = [maxNumberOfIterationsSaved integerValue];
        }
        maxNumberOfIterationsOfFirstStep = maxNumberOfIterations;
        maxNumberOfIterationsOfSecondStep = maxNumberOfIterations;
        if (!gaussThreshold) {
            NSNumber * gaussThresholdSaved = locatingDic[@"calibration/measures/gaussThreshold"];
            gaussThreshold = [gaussThresholdSaved floatValue]/100.0;
        }
        if (!minNumberOfMeasuresAfterGauss) {
            NSNumber * minNumberOfMeasuresAfterGaussSaved = locatingDic[@"calibration/measures/minMeasuresAfterGauss"];
            minNumberOfMeasuresAfterGauss = [minNumberOfMeasuresAfterGaussSaved floatValue];
        }
        numberOfConsecutiveInvalidMeasures = 0;
        if (!maxNumberOfConsecutiveInvalidMeasures) {
            NSNumber * maxNumberOfConsecutiveInvalidMeasuresSaved = locatingDic[@"calibration/measures/maxNumberOfConsecutiveInvalidMeasures"];
            maxNumberOfConsecutiveInvalidMeasures = [maxNumberOfConsecutiveInvalidMeasuresSaved integerValue];
        }
        
        firstStepFinished = NO;
        
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
        NSLog(@"[INFO][LMR] Location manager notifies new mesures of item %@", calibrationUUID);
        
        // Check the access to data shared collections
        if (
            ![sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // TODO: handle intrusion situations. Alberto J. 2019/09/10.
            NSLog(@"[ERROR][LMR] Shared data could not be accessed before use grid aproximation.");
            return;
        }
        
        // Retrieve measures by sort and decide
        NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"rssi"
                                                               withCredentialsUserDic:credentialsUserDic];
        if ([rssiMeasures count] > 0) {
            [self processRssiMeasures:rssiMeasures];
        }
        
        NSMutableArray * calibrationAtRefDistanceMeasures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"calibrationAtRefDistance"
                                                                      withCredentialsUserDic:credentialsUserDic];
        // Calibration is only allowed if number of measures is less than the maximum.
        // This is verified here to count all the measures taken and not only the valid ones.
        if (
            [calibrationAtRefDistanceMeasures count] > 0 &&
            [calibrationAtRefDistanceMeasures count] < maxNumberOfIterationsOfFirstStep
            )
        {
          [self processCalibrationAtRefDistanceMeasures:calibrationAtRefDistanceMeasures];
        } else {
            // Unless not empty
            if ([calibrationAtRefDistanceMeasures count] > 0) {
                // Notify the view that calibration is finished with errors.
                NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/firstStepFinishedWithErrors\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"vcItemSettings/firstStepFinishedWithErrors"
                 object:nil];
            }
        }
        NSMutableArray * calibrationAtOtherDistanceMeasures = [sharedData fromMeasuresDataGetMeasuresOfSort:@"calibrationAtOtherDistance"
                                                                      withCredentialsUserDic:credentialsUserDic];
        if (
            [calibrationAtOtherDistanceMeasures count] > 0 &&
            [calibrationAtOtherDistanceMeasures count] < maxNumberOfIterationsOfSecondStep
            )
        {
            [self processCalibrationAtOtherDistanceMeasures:calibrationAtOtherDistanceMeasures];
        } else {
            // Unless not empty
            if ([calibrationAtOtherDistanceMeasures count] > 0) {
                // Notify the view that calibration is finished with errors.
                NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/secondStepFinishedWithErrors\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"vcItemSettings/secondStepFinishedWithErrors"
                 object:nil];
            }
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
    if (!firstStepFinished) {
        // Each beacon must be calibrated separetly, since each BLE device can transmit a different power values
        
        // Get item to calibrate.
        NSLog(@"[INFO][LMR] Measures taken to calibrate at reference distance the item: %@", calibrationUUID);
        NSMutableArray * itemsToCalibrate = [sharedData fromItemDataGetItemsWithUUID:calibrationUUID
                                                               andCredentialsUserDic:credentialsUserDic];
        if ([itemsToCalibrate count] > 0) {
            itemToCalibrate = [itemsToCalibrate objectAtIndex:0];
        } else {
            NSLog(@"[LMR][ERROR] Item to calibrate not found %@", calibrationUUID);
            return;
        }
        
        // Gather all RSSI measured values
        NSInteger invalidMeasures = 0;
        numberOfConsecutiveInvalidMeasures = 0;
        BOOL consecutiveInvalidMeasures = NO;
        NSMutableArray * beacons = [[NSMutableArray alloc] init];
        for (NSMutableDictionary * eachMeasure in calibrationAtRefDistanceMeasures) {
            
            // Check the measures' UUID, since all measures are asked to shared data collections
            NSString * eachMeasureUUID = eachMeasure[@"itemUUID"];
            if ([eachMeasureUUID isEqualToString:calibrationUUID]) {
                                
                CLBeacon * eachBeacon = eachMeasure[@"measure"];
                
                // Check the device's accuracy; if not less than 0 means not calibrated by Apple device
                if ([eachBeacon rssi] < 0) {
                    [beacons addObject:eachBeacon];
                    numberOfConsecutiveInvalidMeasures = 0;
                } else {
                    invalidMeasures++;
                    numberOfConsecutiveInvalidMeasures++;
                }
                
                if (numberOfConsecutiveInvalidMeasures >= maxNumberOfConsecutiveInvalidMeasures) {
                    consecutiveInvalidMeasures = YES;
                }
                
            } else {
                NSLog(@"[LMR][ERROR] A measure taken from another item different to the calibrating one: %@", eachMeasureUUID);
            }
        }
        if (invalidMeasures > 0) {
            NSLog(@"[WARNING][LMR] Some of the measures taken were invalid: %tu; not using them.", invalidMeasures);
        }
        if (consecutiveInvalidMeasures) {
            NSLog(@"[ERROR][LMR] Too much measures taken were invalid: %tu/%tu; aborting.",
                  numberOfConsecutiveInvalidMeasures,
                  maxNumberOfConsecutiveInvalidMeasures
                  );
            // Notify the view that calibration is finished with errors.
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setObject:@"consecutiveInvalidMeasures" forKey:@"consecutiveInvalidMeasures"];
            NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/firstStepFinishedWithErrors\" posted.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"vcItemSettings/firstStepFinishedWithErrors"
             object:nil
             userInfo:data];
        }
        
        // Decide if the number of measures is enough for calibration
        if (beacons.count < minNumberOfIterationsOfFirstStep) {
            
            NSLog(@"[INFO][LMR] %tu/%tu valid measures taken; not calibrating.",
                  beacons.count,
                  minNumberOfIterationsOfFirstStep
                  );
            
        } else {
            
            NSLog(@"[INFO][LMR] %tu/%tu valid measures taken; calibrating.",
                  beacons.count,
                  minNumberOfIterationsOfFirstStep
                  );
            
            // Calibrate measures
            BOOL calibrationFinished = [self calibrateRefRSSIWithCLBeacons:beacons];
            if (calibrationFinished) {
                // Notify the view that calibration is finished.
                NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/firstStepFinished\" posted.");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"vcItemSettings/firstStepFinished"
                 object:nil];
                firstStepFinished = YES;
            }
            
        }
    }
    return;
}

/*!
 @method processCalibrationAtOtherDistanceMeasures:
 @discussion This method processes the calibration measures taken to calibrate the RSSI value at reference distance d0 and decides when it is calibrated
 */
- (void)processCalibrationAtOtherDistanceMeasures:(NSMutableArray *)calibrationAtOtherDistanceMeasures
{
    // Each beacon must be calibrated separetly, since each BLE device can transmit a different power values
    
    // Get item to calibrate.
    NSLog(@"[INFO][LMR] Measures taken to calibrate at other distance the item: %@", calibrationUUID);
    NSMutableArray * itemsToCalibrate = [sharedData fromItemDataGetItemsWithUUID:calibrationUUID
                                                           andCredentialsUserDic:credentialsUserDic];
    if ([itemsToCalibrate count] > 0) {
        itemToCalibrate = [itemsToCalibrate objectAtIndex:0];
    } else {
        NSLog(@"[LMR][ERROR] Item to calibrate not found %@", calibrationUUID);
        return;
    }
    
    // Gather all RSSI measured values
    NSInteger invalidMeasures = 0;
    numberOfConsecutiveInvalidMeasures = 0;
    BOOL consecutiveInvalidMeasures = NO;
    NSMutableArray * beacons = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * eachMeasure in calibrationAtOtherDistanceMeasures) {
        
        // Check the measures' UUID, since all measures are asked to shared data collections
        NSString * eachMeasureUUID = eachMeasure[@"itemUUID"];
        if ([eachMeasureUUID isEqualToString:calibrationUUID]) {
                            
            CLBeacon * eachBeacon = eachMeasure[@"measure"];
            
            // Check the device's accuracy; if not less than 0 means not calibrated by Apple device
            if ([eachBeacon rssi] < 0) {
                [beacons addObject:eachBeacon];
                numberOfConsecutiveInvalidMeasures = 0;
            } else {
                invalidMeasures++;
                numberOfConsecutiveInvalidMeasures++;
            }
            
            if (numberOfConsecutiveInvalidMeasures >= maxNumberOfConsecutiveInvalidMeasures) {
                consecutiveInvalidMeasures = YES;
            }
            
        } else {
            NSLog(@"[LMR][ERROR] A measure taken from another item different to the calibrating one: %@", eachMeasureUUID);
        }
    }
    if (invalidMeasures > 0) {
        NSLog(@"[WARNING][LMR] Some of the measures taken were invalid: %tu; not using them.", invalidMeasures);
    }
    if (consecutiveInvalidMeasures) {
        NSLog(@"[ERROR][LMR] Too much measures taken were invalid: %tu/%tu; aborting second step.",
              numberOfConsecutiveInvalidMeasures,
              maxNumberOfConsecutiveInvalidMeasures
              );
        // Notify the view that calibration is finished with errors.
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:@"consecutiveInvalidMeasures" forKey:@"consecutiveInvalidMeasures"];
        NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/secondStepFinishedWithErrors\" posted.");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"vcItemSettings/secondStepFinishedWithErrors"
         object:nil
         userInfo:data];
    }
    
    // Decide if the number of measures is enough for calibration
    if (
        beacons.count < minNumberOfIterationsOfSecondStep
        )
    {
        NSLog(@"[INFO][LMR] %tu/%tu valid measures taken; not calibrating at second step.",
              beacons.count,
              minNumberOfIterationsOfSecondStep
              );
        
    } else {
        
        NSLog(@"[INFO][LMR] %tu/%tu valid measures taken; calibrating at second step.",
              beacons.count,
              minNumberOfIterationsOfSecondStep
              );
    
        // Calibrate measures
        BOOL calibrationFinished = [self calibrateAttenuationFactorWithCLBeacons:beacons];
        if (calibrationFinished) {
            // Notify menu view that calibration is finished.
            NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/secondStepFinished\" posted.");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"vcItemSettings/secondStepFinished"
             object:nil];
             firstStepFinished = NO;
        }
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
        
    // Retrieve from item to calibrate old variables to use them as initialization point; if not, initialize them
    /*
    NSNumber * refRSSI = itemToCalibrate[@"refRSSI"];
    NSNumber * refDistance = itemToCalibrate[@"refDistance"];
    NSNumber * attenuationFactor = itemToCalibrate[@"attenuationFactor"];
    NSNumber * attenuationDistance = itemToCalibrate[@"attenuationDistance"];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLocating" ofType:@"plist"];
    NSDictionary * locatingDic = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!refRSSI) {
        NSNumber * initRefRSSI = locatingDic[@"calibration/init/refRSSI"];
        refRSSI = [NSNumber numberWithFloat:[initRefRSSI floatValue]];
        NSLog(@"[INFO][LMR] Reference RSSI value of item not found; set default.");
    }
    if(!refDistance) {
        NSNumber * initRefDistance = locatingDic[@"calibration/init/refDistance"];
        refDistance = [NSNumber numberWithFloat:[initRefDistance floatValue]];
        NSLog(@"[INFO][LMR] Reference distance value of item not found; set default.");
    }
    if(!attenuationFactor) {
        NSNumber * initAttenuationFactor = locatingDic[@"calibration/init/attenuationFactor"];
        attenuationFactor = [NSNumber numberWithFloat:[initAttenuationFactor floatValue]];
        NSLog(@"[INFO][LMR] Reference attenuation factor of item not found; set default.");
    }
    if(!attenuationDistance) {
        NSNumber * initAttenuationDistance = locatingDic[@"calibration/init/attenuationDistance"];
        attenuationDistance = [NSNumber numberWithFloat:[initAttenuationDistance floatValue]];
        NSLog(@"[INFO][LMR] Reference attenuation distance of item not found; set default.");
    }
    */
    
    // Retrieve RSSI values
    NSMutableArray * rssiValues = [[NSMutableArray alloc] init];
    for (CLBeacon * beacon in beacons) {
        NSNumber * rssiValue = [NSNumber numberWithInteger:[beacon rssi]];
        [rssiValues addObject:rssiValue];
    }
    
    // Filter the values using a gaussian filter
    NSMutableArray * filteredRSSIValues = [self gaussianFilterOfMeasures:rssiValues];
    
    // Not a valid subset if there are less than a minimum number of measures
    if (filteredRSSIValues.count < minNumberOfMeasuresAfterGauss) {
        NSLog(@"[INFO][LMR] %tu/%tu are too few measures after gaussian filter; not calibrating.",
              filteredRSSIValues.count,
              minNumberOfMeasuresAfterGauss
              );
        return NO;
    }
    
    // Calculate mean with the measures left and save it as refRSSI
    NSNumber * acc = [NSNumber numberWithFloat:0.0];
    for (NSNumber * rssiValue in filteredRSSIValues) {
        acc = [NSNumber numberWithFloat:[acc floatValue] + [rssiValue floatValue]];
    }
    NSNumber * newRefRSSI = [NSNumber numberWithFloat:
                             [acc floatValue]/filteredRSSIValues.count
                             ];
    itemToCalibrate[@"refRSSI"] = newRefRSSI;
    NSLog(@"[INFO][LMR] Reference RSSI calibrated: %.2f.", [newRefRSSI floatValue]);

    // Decide weather the calibration is finished or not
    return YES;
}

/*!
 @method calibrateAttenuationFactorWithCLBeacons:
 @discussion This method calibrate the attenuation factor of the environment, using a different distance than d0, of an item given its measures; return YES if calibration is finished and NO if more measures are needed.
 */
- (BOOL)calibrateAttenuationFactorWithCLBeacons:(NSMutableArray *)beacons
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
    
    // Retrieve from item to calibrate variables; in the second step they must exist.
    NSNumber * refRSSI = itemToCalibrate[@"refRSSI"];
    NSNumber * refDistance = itemToCalibrate[@"refDistance"];
    NSNumber * attenuationFactor = itemToCalibrate[@"attenuationFactor"];
    NSNumber * attenuationDistance = itemToCalibrate[@"attenuationDistance"];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLocating" ofType:@"plist"];
    NSDictionary * locatingDic = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!refRSSI) {
        NSNumber * initRefRSSI = locatingDic[@"calibration/init/refRSSI"];
        refRSSI = [NSNumber numberWithFloat:[initRefRSSI floatValue]];
        NSLog(@"[ERROR][LMR] Reference RSSI value of item not found; set default.");
    }
    if(!refDistance) {
        NSNumber * initRefDistance = locatingDic[@"calibration/init/refDistance"];
        refDistance = [NSNumber numberWithFloat:[initRefDistance floatValue]];
        NSLog(@"[ERROR][LMR] Reference distance value of item not found; set default.");
    }
    if(!attenuationFactor) {
        NSNumber * initAttenuationFactor = locatingDic[@"calibration/init/attenuationFactor"];
        attenuationFactor = [NSNumber numberWithFloat:[initAttenuationFactor floatValue]];
        NSLog(@"[ERROR][LMR] Reference attenuation factor of item not found; set default.");
    }
    if(!attenuationDistance) {
        NSNumber * initAttenuationDistance = locatingDic[@"calibration/init/attenuationDistance"];
        attenuationDistance = [NSNumber numberWithFloat:[initAttenuationDistance floatValue]];
        NSLog(@"[ERROR][LMR] Reference attenuation distance of item not found; set default.");
    }
    
    // Retrieve RSSI values
    NSMutableArray * rssiValues = [[NSMutableArray alloc] init];
    for (CLBeacon * beacon in beacons) {
        NSNumber * rssiValue = [NSNumber numberWithInteger:[beacon rssi]];
        [rssiValues addObject:rssiValue];
    }
    NSLog(@"[INFO][LMR] Beacon measures: %@", rssiValues);
    
    // Filter the values using a gaussian filter
    NSMutableArray * filteredRSSIValues = [self gaussianFilterOfMeasures:rssiValues];
    
    // Not a valid subset if there are less than a minimum number of measures
    if (filteredRSSIValues.count < minNumberOfMeasuresAfterGauss) {
        NSLog(@"[INFO][LMR] %tu/%tu are too few measures after gaussian filter; not calibrating.",
              filteredRSSIValues.count,
              minNumberOfMeasuresAfterGauss
              );
        return NO;
    }
    
    // Calculate attenuation factor with the mean of the measures left and save it as attenuationFactor
    NSNumber * acc = [NSNumber numberWithFloat:0.0];
    for (NSNumber * rssiValue in filteredRSSIValues) {
        acc = [NSNumber numberWithFloat:[acc floatValue] + [rssiValue floatValue]];
    }
    NSNumber * recivedRSSIValue = [NSNumber numberWithFloat:
                                   [acc floatValue]/filteredRSSIValues.count
                                   ];
    NSNumber * newAttenuationFactor = [NSNumber numberWithFloat:
                                       ([refRSSI floatValue]-[recivedRSSIValue floatValue])
                                       /
                                       (10.0*log10([attenuationDistance floatValue]/[refDistance floatValue]))
                                       ];
    itemToCalibrate[@"attenuationFactor"] = newAttenuationFactor;
    NSLog(@"[INFO][LMR] Attenuation Factor calibrated: %.2f.", [newAttenuationFactor floatValue]);

    // Decide weather the calibration is finished or not
    return YES;
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
    //NSLog(@"[INFO][LMR] Unsorted beacon measures: %@", rssiValues);
    NSSortDescriptor * highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                       ascending:NO];
    [rssiValues sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    //NSLog(@"[INFO][LMR] Sorted beacon measures: %@", rssiValues);
    NSLog(@"[INFO][LMR] There are %tu measures before filter.", rssiValues.count);
    
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
            NSLog(@"[INFO][LMR] Range found");
            NSLog(@"[INFO][LMR] The next cumulative probability integred was %.2f",
                  [cumulativeDiffValue floatValue]);
            break;
        } else {
            NSLog(@"[INFO][LMR] The cumulative probability integred is %.2f",
                  [cumulativeDiffValue floatValue]);
            // the measures can only be poped when there are more than 2.
            if ([rssiValues count] > 2 ) {
                [rssiValues removeObjectAtIndex:0];
                [rssiValues removeLastObject];
                maxRSSI = auxMaxRSSI;
                minRSSI = auxMinRSSI;
            } else {
                break;
            }
        }
    }
    NSLog(@"[INFO][LMR] There are %tu measures left after filter.", rssiValues.count);
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
    
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    
    // For every RSSI measure taken in a Rho type mode...
    for (NSMutableDictionary * measureDic in rssiMeasures) {
        
        // Get the item measured
        NSMutableDictionary * itemDic;
        NSString * itemUUID = measureDic[@"itemUUID"];
        NSMutableArray * items = [sharedData fromItemDataGetItemsWithUUID:itemUUID
                                                    andCredentialsUserDic:credentialsUserDic];
        if ([items count] > 0) {
            itemDic = [items objectAtIndex:0];
        } else {
            NSLog(@"[LMR][ERROR] Item not found when correcting it: %@", itemUUID);
            return;
        }
        
        // Retrieve from item to calibrate old variables to use them as initialization point; if not, initialize them
        NSNumber * refRSSI = itemDic[@"refRSSI"];
        NSNumber * refDistance = itemDic[@"refDistance"];
        NSNumber * attenuationFactor = itemDic[@"attenuationFactor"];
        NSNumber * attenuationDistance = itemDic[@"attenuationDistance"];
        NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLocating" ofType:@"plist"];
        NSDictionary * locatingDic = [NSDictionary dictionaryWithContentsOfFile:path];
        if(!refRSSI) {
            NSNumber * initRefRSSI = locatingDic[@"calibration/init/refRSSI"];
            refRSSI = [NSNumber numberWithFloat:[initRefRSSI floatValue]];
            NSLog(@"[WARNING][LMR] Using a not calibrated beacon device: %@.", itemUUID);
            NSLog(@"[WARNING][LMR] Reference RSSI value of item not found; set default.");
        }
        if(!refDistance) {
            NSNumber * initRefDistance = locatingDic[@"calibration/init/refDistance"];
            refDistance = [NSNumber numberWithFloat:[initRefDistance floatValue]];
            NSLog(@"[WARNING][LMR] Using a not calibrated beacon device: %@.", itemUUID);
            NSLog(@"[WARNING][LMR] Reference distance value of item not found; set default.");
        }
        if(!attenuationFactor) {
            NSNumber * initAttenuationFactor = locatingDic[@"calibration/init/attenuationFactor"];
            attenuationFactor = [NSNumber numberWithFloat:[initAttenuationFactor floatValue]];
            NSLog(@"[WARNING][LMR] Using a not calibrated beacon device: %@.", itemUUID);
            NSLog(@"[WARNING][LMR] Reference attenuation factor of item not found; set default.");
        }
        if(!attenuationDistance) {
            NSNumber * initAttenuationDistance = locatingDic[@"calibration/init/attenuationDistance"];
            attenuationDistance = [NSNumber numberWithFloat:[initAttenuationDistance floatValue]];
            NSLog(@"[WARNING][LMR] Using a not calibrated beacon device: %@.", itemUUID);
            NSLog(@"[WARNING][LMR] Reference attenuation distance of item not found; set default.");
        }
        
        id measure = measureDic[@"measure"];
        CLBeacon * beacon;
        if ([measure isKindOfClass:[CLBeacon class]]) {
            beacon = (CLBeacon *)measureDic[@"measure"];
        } else {
            NSLog(@"[ERROR][LMR] Measure of sort RSSI does not contain and CLBeaconRegion object.");
            break;
        }
        
        // Get its information and correct it
        NSNumber * recivedRSSI = [NSNumber numberWithInteger:[beacon rssi]];
        NSNumber * correctedDistance = [NSNumber numberWithFloat:
                                        powf(
                                             10.0,
                                             ([refRSSI floatValue]-[recivedRSSI floatValue])
                                             /
                                             (10.0*[attenuationFactor floatValue])
                                             )
                                             ];
        NSLog(@"[ERROR][LMR] Measure of %@ corrected.", itemUUID);
        NSLog(@"[ERROR][LMR] -> Recived RSSI %.2f set as distance  %.2f.", [recivedRSSI floatValue], [correctedDistance floatValue]);

        // ...prepare the measure..
        NSMutableDictionary * measureUserDic = measureDic[@"user"];
        RDPosition * measurePosition = measureDic[@"position"];
        NSString * measureItemUUID = measureDic[@"itemUUID"];
        NSString * measureDeviceUUID = measureDic[@"deviceUUID"];
        
        // ...and save it.
        [sharedData inMeasuresDataSetMeasure:correctedDistance
                                      ofSort:@"correctedDistance"
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
        //locatedPositions = [rhoRhoSystem getLocationsUsingGridAproximationWithPrecisions:precisions];
    }
    else if ([mode isModeKey:kModeRhoThetaModelling]) {
        //locatedPositions = [rhoThetaSystem getLocationsUsingBarycenterAproximationWithPrecisions:precisions];
    }


    NSNumber * itemPositionIdNumber = [sharedData fromSessionDataGetItemPositionIdNumberOfUserDic:userDic
                                                                          withCredentialsUserName:credentialsUserDic];
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
    // itemBeaconIdNumber
    NSNumber * itemBeaconIdNumber = [sharedData fromSessionDataGetItemBeaconIdNumberOfUserDic:userDic
                                                                      withCredentialsUserName:credentialsUserDic];
    NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
    [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    // itemPositionIdNumber
    itemPositionIdNumber = [sharedData fromSessionDataGetItemPositionIdNumberOfUserDic:userDic
                                                               withCredentialsUserName:credentialsUserDic];
    NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
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
