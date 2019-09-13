//
//  RDThetaThetaSystem.m
//  Sensors test
//
//  Created by Alberto J. on 18/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDThetaThetaSystem.h"

@implementation RDThetaThetaSystem : NSObject

- (instancetype)init
{
    self = [super init];
    return self;
}

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
 @method getLocationsUsingBarycenterAproximationWithMeasures:andPrecisions:
 @discussion This method ocates a point given the heading measures from different points aiming it and calculates the barycenter of the solutions.
 */
- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithMeasures:(SharedData *)sharedData
                                                                andPrecisions:(NSDictionary *)precisions
{
    NSLog(@"[INFO][TT] Start Radiolocating beacons");
    NSMutableDictionary * locatedPositions = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * measuresDic = [sharedData getMeasuresDic];
    
    // Inspect dictionary from location manager for data retrieving
    //
    // { "measurePosition1":                              //  measuresDic
    //     { "measurePosition": measurePosition;          //  positionDic
    //       "positionMeasures":
    //         { "measureUuid1":                          //  uuidDicDic
    //             { "uuid" : uuid1;                      //  uuidDic
    //               "uuidMeasures":
    //                 { "measure1":                      //  measureDicDic
    //                     { "sort": "rssi"/"heading";    //  measureDic
    //                       "measure": rssi/heading
    //                     };
    //                   "measure2":  { (···) }
    //                 }
    //             };
    //           "measureUuid2": { (···) }
    //         }
    //     };
    //   "measurePosition2": { (···) }
    // }
    //
    
    // Declare the inner dictionaries.
    NSMutableDictionary * measureDic;
    NSMutableDictionary * measureDicDic;
    NSMutableDictionary * uuidDic;
    NSMutableDictionary * uuidDicDic;
    NSMutableDictionary * positionDic;
    
    // In theta theta based systems each UUID represents a position that must be located, and so, for every one of them a RDPosition would be found. It is needed the info about how many UUID there are.
    NSArray * positionKeys = [measuresDic allKeys];
    NSMutableArray * diferentUUID = [[NSMutableArray alloc] init];
    for (id positionKey in positionKeys) {
        positionDic = [measuresDic objectForKey:positionKey];
        uuidDicDic = positionDic[@"positionMeasures"];
        NSArray * uuidKeys = [uuidDicDic allKeys];
        for (id uuidKey in uuidKeys) {
            NSString * uuid = uuidDicDic[uuidKey][@"uuid"];
            if(diferentUUID.count == 0) {
                [diferentUUID addObject:uuid];
            } else {
                BOOL foundUUID = NO;
                for (NSString * existingUUID in diferentUUID) {
                    if ([existingUUID isEqualToString:uuid]) {
                        foundUUID = YES;
                    } else {
                        
                    }
                }
                if (!foundUUID) {
                    [diferentUUID addObject:uuid];
                }
            }
        }
    }
    NSLog(@"[INFO][TT] Found %.2f different UUID", [[NSNumber numberWithInteger:diferentUUID.count] floatValue]);
    
    // And thus, for every beacon that must be located with it unique UUID.
    for (NSString * UUIDtoLocate in diferentUUID) {
        
        NSString * uuid;
        
        // Measures are only feasible if there are heading type measures.
        NSMutableArray * measuredHeadings = [[NSMutableArray alloc] init];
        // For saving the positions where the device were aiming with the same index than measurings
        NSMutableArray * measurePositions = [[NSMutableArray alloc] init];
        RDPosition * measurePosition = [[RDPosition alloc] init];
        measurePosition.z = [NSNumber numberWithFloat:0.0]; // For saving any z value
        
        // For every position where measuremets were aimed when taken
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
                    // TO DO Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                    
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
                            if ([measureDic[@"sort"] isEqualToString:@"rssi"]) {
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
            
            NSLog(@"[INFO][TT] Final calculus");
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
    NSLog(@"[INFO][TT] Finish Radiolocating beacons");
    return locatedPositions;
}

/*!
 @method calculateDistanceWithRssi:
 @discussion This method calculates the distance from a signal was transmited using reception's RSSI value.
 */
+ (NSNumber *) calculateDistanceWithRssi: (NSInteger) rssi
{
    // Absolute values of speed of light, frecuency, and antenna's join gain
    float C = 299792458.0;
    float F = 2440000000.0; // 2400 - 2480 MHz
    float G = 1.0; // typically 2.16 dBi
    // Calculate the distance
    NSNumber * distance = [[NSNumber alloc] initWithFloat:( (C / (4.0 * M_PI * F)) * sqrt(G * pow(10.0, (float)rssi/ 10.0)) )];
    return distance;
}

@end
