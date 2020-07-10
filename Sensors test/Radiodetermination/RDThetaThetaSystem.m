//
//  RDThetaThetaSystem.m
//  Sensors test
//
//  Created by Alberto J. on 18/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDThetaThetaSystem.h"

@implementation RDThetaThetaSystem : NSObject

/*!
 @method init
 @discussion Constructor.
 */
- (instancetype)init
{
    self = [super init];
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
    self = [self init];
    sharedData = initSharedData;
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
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

#pragma mark - Localization methods
/*!
 @method getBarycenterOf:
 @discussion This method calculated the barycenter of a given set of RDPosition objects.
 */
- (RDPosition *) getBarycenterOf:(NSMutableArray *)points {
    RDPosition * barycenter = [[RDPosition alloc] init];
    float sumx = 0.0;
    float sumy = 0.0;
    float sumz = 0.0;
    for (RDPosition * point in points) {
        sumx = sumx + [point.x floatValue];
        sumy = sumy + [point.y floatValue];
        sumz = sumz + [point.z floatValue];
    }
    barycenter.x = [[NSNumber alloc] initWithFloat: sumx / points.count];
    barycenter.y = [[NSNumber alloc] initWithFloat: sumy / points.count];
    barycenter.z = [[NSNumber alloc] initWithFloat: sumz / points.count];
    return barycenter;
}

/*!
@method getMeanOf:
@discussion This method calculated the barycenter of a given set of RDPosition objects.
*/
- (NSNumber *)getMeanOf:(NSMutableArray *)numbers
{
    NSNumber * average;
    if (numbers.count > 0) {
        NSNumber * accumulation = [NSNumber numberWithFloat:0.0];
        for (NSNumber * number in numbers) {
            accumulation = [NSNumber numberWithFloat:
                            [accumulation floatValue] +
                            [number floatValue]
                            ];
        }
        NSNumber * countFloat = [NSNumber numberWithInteger:numbers.count];
        average = [NSNumber numberWithFloat:
                   [accumulation floatValue] /
                   [countFloat floatValue]
                   ];
    }
    return average;
}

/*!
 @method getLocationsUsingBarycenterAproximationWithPrecisions:
 @discussion This method ocates a point given the heading measures from different points aiming it and calculates the barycenter of the solutions.
 */
- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithPrecisions:(NSDictionary *)precisions
{
    NSLog(@"[INFO][TT] Start locating positions.");
    // Check the access to data shared collections
    if (
        ![sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][TT] Shared data could not be accessed before use barycenter aproximation.");
    }
    
    // Declare collections
    NSMutableDictionary * locatedPositions = [[NSMutableDictionary alloc] init];
    
    // Different behaviour depending on location mode
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    
    if ([mode isModeKey:kModeThetaThetaLocating]) {
    
        // In a locating mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the adding menu, and
        // - as the 'itemUUID' the UUID of the item chosen in the canvas.
        // A location will be found for each 'deviceUUID'
        
        // Also, in this system, the measures for each tuple (itemUUID, deviceUUID) will be found, averaged and saved as single new measures for doing the final calculus with all of them at the same time; ordering them is needed.
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * deviceUUID in allDeviceUUID) {
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            
            // Create a collection for saving this new single new measures
            NSMutableArray * itemsDicWithMeasures = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * itemUUID in allItemUUID) {
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                
                // ...and for every measure compose a new measure with the mean value; the calculus will be done when every item has its own measure because they have to be ordered.
                // TODO: IF headingMeasures.count > 0. Alberto J. 2020/07/10.

                NSNumber * measuresHeadingAverage = [self getMeanOf:headingMeasures];
                
                // Get the item position using its UUID
                NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:itemUUID
                                                                    andCredentialsUserDic:credentialsUserDic];
                if (itemsMeasured.count == 0) {
                    NSLog(@"[ERROR][TT] No items found with the itemUUID in measures.");
                    break;
                }
                if (itemsMeasured.count > 1) {
                    NSLog(@"[ERROR][TT] More than one items stored with the same UUID: using first one.");
                }
                NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                RDPosition * itemPosition = itemMeasured[@"position"];
                
                if (itemPosition) {
                    // Valid item measured
                    
                    // Save the new measure in data
                    NSMutableDictionary * itemDic = [[NSMutableDictionary alloc] init];
                    itemDic[@"itemUUID"] = itemUUID;
                    itemDic[@"deviceUUID"] = deviceUUID;
                    itemDic[@"position"] = itemPosition;
                    itemDic[@"measure"] = measuresHeadingAverage;
                    [itemsDicWithMeasures addObject:itemDic];
                    
                }
            }
                        
            NSMutableArray * deviceUUIDPositions = [[NSMutableArray alloc] init];
            
            // Evaluate feasibility
            if (itemsDicWithMeasures.count > 2) {
                
                // Perform the calculus.
                NSLog(@"[INFO][TT] Final calculus.");
                // In this aproximate calculus, one of the trigonometrical equation got from the measures is solved with another one, this second with aother third, etc., in pairs, and then calculated the barycenter of the results. The selection criteria of this first, second, third... equations is to order from the lowest to the higest, and thus the dilution of precision is minimized; convergence problems appears if not.
                
                // Sort the measures
                NSMutableDictionary * sortedItemsDic = [[NSMutableDictionary alloc] init];
                NSInteger index = 0;
                NSNumber * lastSavedMin = [NSNumber numberWithFloat:-FLT_MAX];
                for (NSUInteger i = 0; i < [itemsDicWithMeasures count]; i++) {
                    
                    // As many times as elements to be sorted
                    NSNumber * min = [NSNumber numberWithFloat:FLT_MAX];
                    NSDictionary * minItemDic;
                    
                    // Search for the next min
                    for (NSUInteger j = 0; j < [itemsDicWithMeasures count]; j++) {
                        NSMutableDictionary * eachItemDic = [itemsDicWithMeasures objectAtIndex:j];
                        NSNumber * eachMeasure = eachItemDic[@"measure"];
                        NSLog(@"[INFO][TT] Evaluating heading %.2f ", [eachMeasure floatValue]);
                        NSLog(@"[INFO][TT] -> with last min saved heading %.2f ", [lastSavedMin floatValue]);
                        if ([eachMeasure floatValue] > [lastSavedMin floatValue]) {
                            NSLog(@"[INFO][TT] -> and with the partial min %.2f ", [min floatValue]);
                            if ([eachMeasure floatValue] <= [min floatValue]) {
                                min = eachMeasure;
                                minItemDic = eachItemDic;
                            }
                        }
                    }
                    
                    // Save this min and update the last saved min
                    NSLog(@"[INFO][TT] Ordered the heading %.2f ", [min floatValue]);
                    NSLog(@"[INFO][TT] -> at index %tuf ", index);
                    NSString * indexKey = [NSString stringWithFormat:@"%tu", index];
                    [sortedItemsDic setObject:minItemDic forKey:indexKey];
                    lastSavedMin = min;
                    index++;
                }
                
                // Once sorted, perform the calculus
                // Angle between the north and the model 'north'
                // NSNumber * north = [NSNumber numberWithFloat:-1.11];
                NSNumber * north = [NSNumber numberWithFloat:0.0]; // Gyroscope measures
                
                NSNumber * accumulatedHeading = nil;
                NSNumber * lastAccumulatedHeading = nil;
                RDPosition * lastPosition = nil;
                
                for (NSUInteger m = 0; m < [sortedItemsDic count]; m++) {
                    
                    NSString * indexKey = [NSString stringWithFormat:@"%tu", m];
                    NSDictionary * eachItemDic = sortedItemsDic[indexKey];
                    
                    NSNumber * eachHeading = eachItemDic[@"measure"];
                    RDPosition * eachPosition = eachItemDic[@"position"];
                    
                    // The first one is saved.
                    if (m == 0) {
                        lastAccumulatedHeading = eachHeading;
                        lastPosition = eachPosition;
                        NSLog(@"[INFO][TT] First heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] First position %@", lastPosition);
                    } else {
                        
                        // The rest of iterations, the code executed is the following
                        lastAccumulatedHeading = [NSNumber numberWithFloat:[accumulatedHeading floatValue]];
                        accumulatedHeading = [NSNumber numberWithFloat:[accumulatedHeading floatValue] + [eachHeading floatValue]];
                        NSLog(@"[INFO][TT] LastAccumulated heading %.2f ", [lastAccumulatedHeading floatValue]);
                        NSLog(@"[INFO][TT] Each heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] Accumulated heading %.2f ", [accumulatedHeading floatValue]);
                        NSLog(@"[INFO][TT] Last position %@", lastPosition);
                        NSLog(@"[INFO][TT] Each position %@", eachPosition);
                        
                        RDPosition * solution = [[RDPosition alloc] init];
                        solution.x = [NSNumber numberWithFloat:
                                      (
                                       (
                                        ([eachPosition.y floatValue] - tan( M_PI/2.0 - [accumulatedHeading doubleValue] - [north floatValue]) * [eachPosition.x floatValue]) -
                                        ([lastPosition.y floatValue] - tan( M_PI/2.0 - [lastAccumulatedHeading doubleValue] - [north floatValue]) * [lastPosition.x floatValue])
                                        )
                                       /
                                       (
                                        -tan(M_PI/2.0 - [accumulatedHeading doubleValue] - [north floatValue]) +
                                        tan(M_PI/2.0 - [lastAccumulatedHeading doubleValue] - [north floatValue])
                                        )
                                       )
                                      ];
                        solution.y = [NSNumber numberWithFloat:
                                      (
                                       (
                                        ([lastPosition.y floatValue] - tan( M_PI/2.0 - [lastAccumulatedHeading doubleValue] - [north floatValue]) * [lastPosition.x floatValue]) *
                                        (-tan( M_PI/2.0 - [accumulatedHeading doubleValue] - [north floatValue])) -
                                        ([eachPosition.y floatValue] - tan( M_PI/2.0 - [accumulatedHeading doubleValue] - [north floatValue]) * [eachPosition.x floatValue]) *
                                        (-tan( M_PI/2.0 - [lastAccumulatedHeading doubleValue] - [north floatValue]))
                                        )
                                       /
                                       (
                                        -tan(M_PI/2.0 - [accumulatedHeading doubleValue] - [north floatValue]) +
                                        tan(M_PI/2.0 - [lastAccumulatedHeading doubleValue] - [north floatValue])
                                        )
                                       )
                                      ];
                        // ARC disposing
                        lastPosition = nil;
                        lastPosition = eachPosition;
                        
                        // TODO: Z coordinate. Alberto J. 2019/09/24.
                        solution.z = [NSNumber numberWithFloat:0.0];
                        
                        NSLog(@"[INFO][TT] Solution %@", solution);
                        [deviceUUIDPositions addObject:solution];
                    }
                }
                
            }
            
            // Get the barycenter as an aproximation and save the result for this deviceUUID.
            RDPosition * deviceUUIDPosition = [self getBarycenterOf:deviceUUIDPositions];
            [locatedPositions setObject:deviceUUIDPosition forKey:deviceUUID];
            
        }
    
    } else if ([mode isModeKey:kModeRhoThetaModelling]) {
        
        // In a modelling mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the canvas, and
        // - as the 'itemUUID' the UUID of the item chosen in the adding menu.
        // A location will be found for each 'itemUUID'
        
        /*
        
        // It is also needed the info about the UUID that must be located.
        // TODO: Multiuser measures. Alberto J. 2019/09/24.
        NSMutableArray * everyUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located with its unique UUID, get the measures that aim it.
        for (NSString * UUIDtoLocate in everyUUID) {
            
            NSString * uuid;
            
            // Measures are only feasible if there are heading type measures.
            NSMutableArray * headingMeasures = [[NSMutableArray alloc] init];
            // For saving the positions where the device were aiming with the same index than measurings
            NSMutableArray * measurePositions = [[NSMutableArray alloc] init];
            RDPosition * measurePosition = [[RDPosition alloc] init];
            measurePosition.z = [NSNumber numberWithFloat:0.0]; // For saving any z value
            
            // For every position where heading measuremets were taken
            NSMutableArray * allMeasurePositions = [sharedData fromMeasuresDataGetPositionsOfUserDic:userDic
                                                                              withCredentialsUserDic:credentialsUserDic];
            
            NSArray * positionKeys = [measuresDic allKeys];
            for (id positionKey in positionKeys) {
                // ...get the dictionary for this position, and also get the position,...
                positionDic = [measuresDic objectForKey:positionKey];
                measurePosition = nil; // For ARC disposing
                measurePosition = positionDic[@"measurePosition"];
                
                // Get the the dictionary with the UUID's dictionaries...
                uuidDicDic = positionDic[@"positionMeasures"];
                NSArray * uuidKeys = [uuidDicDic allKeys];
                for (id uuidKey in uuidKeys) {
                    // ...get the dictionary and the UUID...
                    uuidDic = [uuidDicDic objectForKey:uuidKey];
                    uuid = uuidDic[@"uuid"];
                    
                    // ...and only perform the calculus if is the current searched UUID...
                    NSLog(@"[INFO][TT] UUIDtoLocate %@", UUIDtoLocate);
                    NSLog(@"[INFO][TT] uuid %@", uuid);
                    if ([UUIDtoLocate isEqualToString:uuid]) {
                        
                        // Get the the dictionary with the measures dictionaries...
                        measureDicDic = uuidDic[@"uuidMeasures"];
                        
                        // ...and for every measure calculate its mean average.
                        // TODO Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                        
                        // But only do this if the 'measureDicDic' exists
                        if (measureDicDic.count == 0) {
                            // Not evaluate
                        } else {
                            NSNumber * measuresHeadingAcumulation = [NSNumber numberWithFloat:0.0];
                            NSInteger measureHeadingIndex = 0;
                            NSArray * measuresKeys = [measureDicDic allKeys];
                            for (id measureKey in measuresKeys) {
                                measureDic = [measureDicDic objectForKey:measureKey];
                                
                                // Get the data and acumulate it
                                if ([measureDic[@"sort"] isEqualToString:@"correctedDistance"]) {
                                    // Do nothing; they should no exist.
                                }
                                if ([measureDic[@"type"] isEqualToString:@"heading"]) {
                                    measuresHeadingAcumulation = [NSNumber numberWithFloat:
                                                                  [measuresHeadingAcumulation floatValue] +
                                                                  [measureDic[@"measure"] floatValue]
                                                                  ];
                                    measureHeadingIndex++;
                                }
                            }
                            
                            NSLog(@"[INFO][TT] Found %.2f different measures for this position", [[NSNumber numberWithInteger:measureHeadingIndex] floatValue]);
                            NSLog(@"[INFO][TT] Sum average %.2f", [measuresHeadingAcumulation floatValue]);
                            // Calculate the mean averages
                            NSNumber * measureHeadingIndexFloat = [NSNumber numberWithInteger:measureHeadingIndex];
                            NSNumber * measuresHeadingAverage = [NSNumber numberWithFloat:0.0];
                            if (measureHeadingIndex != 0) { // Division by zero preventing
                                measuresHeadingAverage = [NSNumber numberWithFloat:
                                                          [measuresHeadingAcumulation floatValue] /
                                                          [measureHeadingIndexFloat floatValue]
                                                          ];
                                
                                NSLog(@"[INFO][TT] Measures average %.2f", [measuresHeadingAverage floatValue]);
                                // Save the measure and the position
                                [measuredHeadings addObject:measuresHeadingAverage];
                                [measurePositions addObject:measurePosition];
                            }
                        }
                    }
                }
            }
            
            NSLog(@"[INFO][TT] Found %.2f different heading measures", [[NSNumber numberWithInteger:measuredHeadings.count] floatValue]);
            // Finally, calculus for this UUID is only performed if there are more than two heading measures
            if (measuredHeadings.count > 2) {
                
                NSLog(@"[INFO][TT] Final calculus.");
                // In this aproximate calculus, one of the trigonometrical equation got from the measures is solved with another one, this second with aother third, etc., in pairs, and then calculated the barycenter of the results. The selection criteria of this first, second, third... equations is to order from the lowest to the higest, and thus the dilution of precision is minimized; convergence problems appears if not.
                
                // Order the measures; search for the min of the set, save it and search for the min of the rest that are greater than the saved one, and so on.
                NSMutableArray * orderedMeasureHeadings = [[NSMutableArray alloc] init];
                NSMutableArray * orderedMeasurePositions = [[NSMutableArray alloc] init];
                for (NSUInteger k = 0; k < [measuredHeadings count]; k++) {
                    // Pre initialize the arrays for future replacing; the index order must be carefully set.
                    [orderedMeasureHeadings addObject:[NSNumber numberWithInteger:0]];
                    [orderedMeasurePositions addObject:[NSNumber numberWithInteger:0]];
                }
                
                NSNumber * lastSavedMin = [NSNumber numberWithFloat:-FLT_MAX];
                // As many times as elements to be ordered...
                for (NSUInteger i = 0; i < [measuredHeadings count]; i++) {
                    
                    NSUInteger minPositionIndex = INT_MIN;
                    NSNumber * min = [NSNumber numberWithFloat:FLT_MAX];
                    
                    // ...for every of them...
                    for (NSUInteger j = 0; j < [measuredHeadings count]; j++) {
                        
                        // ...get its reference...
                        NSNumber * eachHeading = [measuredHeadings objectAtIndex:j];
                        NSLog(@"[INFO][TT] Evaluating heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] -> with last min saved heading %.2f ", [lastSavedMin floatValue]);
                        
                        // ...and if it is greater than the last saved one...
                        if ([eachHeading floatValue] > [lastSavedMin floatValue]) {
                            
                            NSLog(@"[INFO][TT] -> and with the partial min %.2f ", [min floatValue]);
                            
                            // ...compare with the others to get the minimum.
                            if ([eachHeading floatValue] < [min floatValue]) {
                                min = eachHeading;
                                minPositionIndex = j;
                            }
                        }
                    }
                    
                    // Save it and its position and upload lastSavedMin
                    NSLog(@"[INFO][TT] Ordered the heading %.2f ", [min floatValue]);
                    NSLog(@"[INFO][TT] -> at index %.2f ", [[NSNumber numberWithInteger:i] floatValue]);
                    NSLog(@"[INFO][TT] -> and its position %@ ", [measurePositions objectAtIndex:minPositionIndex]);
                    [orderedMeasureHeadings replaceObjectAtIndex:i withObject:min];
                    [orderedMeasurePositions replaceObjectAtIndex:i withObject:[measurePositions objectAtIndex:minPositionIndex]];
                    lastSavedMin = min;
                }
                
                // Angle between the north and the model 'north'
                NSNumber * north = [NSNumber numberWithFloat:70*M_PI/180.0];
                
                // Perform the calculus
                RDPosition * locatedPosition = [[RDPosition alloc] init];
                NSMutableArray * solutions = [[NSMutableArray alloc] init];
                
                NSNumber * firstHeading = nil;
                RDPosition * firstPosition = nil;
                for (NSUInteger m = 0; m < [orderedMeasureHeadings count]; m++) {
                    
                    NSNumber * eachHeading = [orderedMeasureHeadings objectAtIndex:m];
                    
                    // The first one is saved.
                    if (m == 0) {
                        firstHeading = eachHeading;
                        firstPosition = [orderedMeasurePositions objectAtIndex:m];
                        NSLog(@"[INFO][TT] First heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] First position %@", firstPosition);
                    } else {
                        // The rest of iterations, the code executed is the following
                        
                        RDPosition * eachPosition = [orderedMeasurePositions objectAtIndex:m];
                        NSLog(@"[INFO][TT] First heading %.2f ", [firstHeading floatValue]);
                        NSLog(@"[INFO][TT] First position %@", firstPosition);
                        NSLog(@"[INFO][TT] Each position %@", eachPosition);
                        NSLog(@"[INFO][TT] Each heading %.2f ", [eachHeading floatValue]);
                        
                        RDPosition * solution = [[RDPosition alloc] init];
                        solution.x = [NSNumber numberWithFloat:
                                      (
                                       (
                                        tan(M_PI/2.0 - [eachHeading doubleValue] - [north floatValue]) * [eachPosition.x floatValue] -
                                        tan(M_PI/2.0 - [firstHeading doubleValue] - [north floatValue]) * [firstPosition.x floatValue] -
                                        [eachPosition.y floatValue] +
                                        [firstPosition.y floatValue]
                                        )
                                       /
                                       (
                                        tan(M_PI/2.0 - [eachHeading doubleValue] - [north floatValue]) -
                                        tan(M_PI/2.0 - [firstHeading doubleValue] - [north floatValue])
                                        )
                                       )
                                      ];
                        solution.y = [NSNumber numberWithFloat:
                                      (
                                       (
                                        tan(M_PI/2.0 - [firstHeading doubleValue] - [north floatValue]) *
                                        (
                                         tan(M_PI/2.0 - [eachHeading doubleValue] - [north floatValue]) *
                                         [eachPosition.x floatValue] -
                                         [eachPosition.y floatValue]
                                         )
                                        -
                                        tan(M_PI/2.0 - [eachHeading doubleValue] - [north floatValue]) *
                                        (
                                         tan(M_PI/2.0 - [firstHeading doubleValue] - [north floatValue]) *
                                         [firstPosition.x floatValue] -
                                         [firstPosition.y floatValue]
                                         )
                                        )
                                       /
                                       (
                                        tan(M_PI/2.0 - [eachHeading doubleValue] - [north floatValue]) -
                                        tan(M_PI/2.0 - [firstHeading doubleValue] - [north floatValue])
                                        )
                                       )
                                      ];
                        solution.z = measurePosition.z;
                        
                        NSLog(@"[INFO][TT] Solution %@", solution);
                        [solutions addObject:solution];
                        
                        // upload the first heading and position
                        firstPosition = eachPosition;
                        firstHeading = eachHeading;
                        
                    }
                }
                
                // And aproximate the solution by the barycenter of the set of parcial solutions
                locatedPosition = [self getBarycenterOf:solutions];
                
                NSLog(@"[INFO][TT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                NSLog(@"[INFO][TT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                NSLog(@"[INFO][TT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                
                [locatedPositions setObject:locatedPosition forKey:uuid];
            }
        }
        */
        
    } else {
        NSLog(@"[ERROR][TT] Instantiated theta-theta type system  when using %@ mode.", mode);
    }
    
    NSLog(@"[INFO][TT] Finish Radiolocating beacons.");
    
    return locatedPositions;
}

@end
