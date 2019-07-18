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
- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithMeasures:(SharedData*)sharedData
                                                                andPrecisions:(NSDictionary*)precisions
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
    //                     { "type": "rssi"/"heading";    //  measureDic
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
                            if ([measureDic[@"type"] isEqualToString:@"rssi"]) {
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
                        
                        // Calculate the mean averages
                        NSNumber * measureHeadingIndexFloat = [NSNumber numberWithInteger:measureHeadingIndex];
                        NSNumber * measuresHeadingAverage = [NSNumber numberWithFloat:0.0];
                        if (measureHeadingIndex != 0) { // Division by zero preventing
                            measuresHeadingAverage = [NSNumber numberWithFloat:
                                                      [measuresHeadingAcumulation floatValue] /
                                                      [measureHeadingIndexFloat floatValue]
                                                      ];
                            
                            // Save the measure and the position
                            [measuredHeadings addObject:measuresHeadingAverage];
                            [measurePositions addObject:measurePosition];
                        }
                    }
                }
            }
        }
        
        // Finally, calculus for this UUID is only performed if there are more than two heading measures
        if (headingMeasures.count > 2) {
            
            // In this aproximate calculus, the first trigonometrical ecuation got from the measures is solved with the rest of them, in pairs, and then calculated the barycenter of the results.
            
            RDPosition * locatedPosition = [[RDPosition alloc] init];
            NSMutableArray * solutions = [[NSMutableArray alloc] init];
            
            NSNumber * firstHeading = nil;
            RDPosition * firstPosition = nil;
            NSUInteger headingIndex = 0;
            for (NSNumber * eachHeading in measuredHeadings) {
                
                // The first one is saved.
                if (headingIndex == 0) {
                    firstHeading = eachHeading;
                    firstPosition = [measurePositions objectAtIndex:headingIndex];
                } else {
                    // The rest of iterations, the code executed is the following
                    
                    RDPosition * eachPosition = [measurePositions objectAtIndex:headingIndex];
                    
                    RDPosition * solution = [[RDPosition alloc] init];
                    solution.x = [NSNumber numberWithFloat:
                                  (
                                   (cos([firstHeading doubleValue]) * [firstPosition.x floatValue]
                                    - sin([firstHeading doubleValue]) * [firstPosition.y floatValue]) *
                                   (-sin([eachHeading doubleValue])) -
                                   (cos([eachHeading doubleValue]) * [eachPosition.x floatValue]
                                    - sin([eachHeading doubleValue]) * [eachPosition.y floatValue]) *
                                   (-sin([firstHeading doubleValue]))
                                   ) /
                                  (
                                   (cos([firstHeading doubleValue])) *
                                   (- sin([eachHeading doubleValue])) -
                                   (cos([eachHeading doubleValue])) *
                                   (-sin([firstHeading doubleValue]))
                                   )
                                  ];
                    solution.y = [NSNumber numberWithFloat:
                                  (
                                   (cos([firstHeading doubleValue])) *
                                   (cos([firstHeading doubleValue]) * [firstPosition.x floatValue]
                                    - sin([firstHeading doubleValue]) * [firstPosition.y floatValue]) -
                                   (cos([eachHeading doubleValue])) *
                                   (cos([eachHeading doubleValue]) * [eachPosition.x floatValue]
                                    - sin([eachHeading doubleValue]) * [eachPosition.y floatValue])
                                   ) /
                                  (
                                   (cos([firstHeading doubleValue])) *
                                   (- sin([eachHeading doubleValue])) -
                                   (cos([eachHeading doubleValue])) *
                                   (-sin([firstHeading doubleValue]))
                                   )
                                  ];
                    solution.z = measurePosition.z;
                    
                    
                    [solutions addObject:solution];
                }
                headingIndex++;
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
