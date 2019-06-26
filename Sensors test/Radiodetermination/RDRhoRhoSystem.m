//
//  RDRhoRhoSystem.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoRhoSystem.h"

@implementation RDRhoRhoSystem : NSObject

- (instancetype)init
{
    self = [super init];
    return self;
}

/*!
 @method get2DPositionWithRssi1:andRssi2:andReference1:andReference2:andPrediction:
 @discussion This method calculates the position in 2D space given other two reference positions and two measured RSSI values.
 */
- (RDPosition *) get2DPositionWithRssi1:(NSInteger) rssi1
                               andRssi2:(NSInteger) rssi2
                          andReference1:(RDPosition *) ref1
                          andReference2:(RDPosition *) ref2
                          andPrediction:(RDPosition *) pred
{
    // Retrieve coordinates from the reference positions
    NSNumber * x1 = ref1.x;
    NSNumber * y1 = ref1.y;
    NSNumber * x2 = ref2.x;
    NSNumber * y2 = ref2.y;
    // Estimate the distance given the RSSI values
    NSNumber * dis1 = [RDRhoRhoSystem calculateDistanceWithRssi:rssi1];
    NSNumber * dis2 = [RDRhoRhoSystem calculateDistanceWithRssi:rssi2];
    
    RDPosition * pos = [[RDPosition alloc] init];
    pos.x = x1;
    return pos;
}

/*!
 @method divideSegmentStartingAt:finishingAt:andWithPrecision:
 @discussion This method saves in the parameter 'NSMutableArray' type 'values' the middle value between two given values; if the divisions are greater than the precision, the method is recursively called until reached. The maximum or minimum value given as parameter is not included in final 'values' array. This method is used for composing the grid.
 */
- (void) recursiveDivideSegmentStartingAt:(NSNumber*)minValue
                              finishingAt:(NSNumber*)maxValue
                            withPrecision:(NSNumber*)precision
                                  inArray:(NSMutableArray*)values
{
    // If equals
    if ([minValue isEqualToNumber:maxValue]) {
        [values  addObject:minValue];
        return;
    }
    
    // Middle point and save it
    NSNumber * middle = [NSNumber numberWithFloat:
                         [minValue floatValue] +
                         [[RDPosition euclideanDistance1Dfrom:minValue to:maxValue] floatValue]
                         / 2.0
                         ];
    [values addObject:middle];
    
    // Stop condition
    if (
        [[RDPosition euclideanDistance1Dfrom:minValue to:maxValue] floatValue] <
        2.0 * [precision floatValue]
        )
    {
        return;
    } else { // Recursive
        [self recursiveDivideSegmentStartingAt:minValue
                                   finishingAt:middle
                                 withPrecision:precision
                                       inArray:values];
        [self recursiveDivideSegmentStartingAt:middle
                                   finishingAt:maxValue
                                 withPrecision:precision
                                       inArray:values];
        return;
    }
}

/*!
 @method generateGridUsingPositions:andPrecisions:
 @discussion This method generates a grid using maximum and minimum coordinate values of a set of positions. It is used for sampling the space and perform thus some optimization calculus such as the one on method 'getLocationsUsingGridAproximationWithMeasures:andPrecisions:'.
 */
- (NSMutableArray *) generateGridUsingPositions:(NSMutableArray*)measurePositions
                                  andPrecisions:(NSDictionary*)precisions
{
    
    // Search for the maximum and minimum values for the coordinates.
    NSNumber * minPositionsXvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsXvalue = [NSNumber numberWithFloat:-FLT_MAX];
    NSNumber * minPositionsYvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsYvalue = [NSNumber numberWithFloat:-FLT_MAX];
    NSNumber * minPositionsZvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsZvalue = [NSNumber numberWithFloat:-FLT_MAX];
    
    for (RDPosition * position in measurePositions) {
        if ([position.x floatValue] < [minPositionsXvalue floatValue]) {
            minPositionsXvalue = position.x;
        }
        if ([position.x floatValue] > [maxPositionsXvalue floatValue]) {
            maxPositionsXvalue = position.x;
        }
        if ([position.y floatValue] < [minPositionsYvalue floatValue]) {
            minPositionsYvalue = position.y;
        }
        if ([position.y floatValue] > [maxPositionsYvalue floatValue]) {
            maxPositionsYvalue = position.y;
        }
        if ([position.z floatValue] < [minPositionsZvalue floatValue]) {
            minPositionsZvalue = position.z;
        }
        if ([position.z floatValue] > [maxPositionsZvalue floatValue]) {
            maxPositionsZvalue = position.z;
        }
    }
    
    // Get the coordinate values for the grid's positions; the method 'divideSegmentStartingAt:finishingAt:andWithPrecision:' adds to the values arrays the division points of the axis, but not add min and max value.
    NSMutableArray * xValues = [[NSMutableArray alloc] init];
    [xValues addObject:minPositionsXvalue];
    [xValues addObject:maxPositionsXvalue];
    NSMutableArray * yValues = [[NSMutableArray alloc] init];
    [yValues addObject:minPositionsYvalue];
    [yValues addObject:maxPositionsYvalue];
    NSMutableArray * zValues = [[NSMutableArray alloc] init];
    [zValues addObject:minPositionsZvalue];
    [zValues addObject:maxPositionsZvalue];
    
    [self recursiveDivideSegmentStartingAt:minPositionsXvalue
                               finishingAt:maxPositionsXvalue
                             withPrecision:[precisions objectForKey:@"xPrecision"]
                                   inArray:xValues];
    [self recursiveDivideSegmentStartingAt:minPositionsYvalue
                               finishingAt:maxPositionsYvalue
                             withPrecision:[precisions objectForKey:@"yPrecision"]
                                   inArray:yValues];
    [self recursiveDivideSegmentStartingAt:minPositionsZvalue
                               finishingAt:maxPositionsZvalue
                             withPrecision:[precisions objectForKey:@"zPrecision"]
                                   inArray:zValues];
    
    // Compose the grid
    NSMutableArray * grid = [[NSMutableArray alloc] init];
    for (NSNumber * posX in xValues) {
        for (NSNumber * posY in yValues) {
            for (NSNumber * posZ in zValues) {
                RDPosition * pos = [[RDPosition alloc] init];
                pos.x = posX;
                pos.y = posY;
                pos.z = posZ;
                [grid addObject:pos];
            }
        }
    }
    
    return grid;
}

/*!
 @method getLocationsUsingGridAproximationWithMeasures:andPrecisions:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions; it uses a simple grid search of the minimum of the least square of distances from positions were the measures were taken to the grid and the measures and the same point in the grid. In the '('NSDictionary' object 'precisions' must be defined the minimum requirement of precision for each axe, with floats in objects 'NSNumbers' set in the keys "xPrecision", "yPrecision" and "zPrecision".
 */
- (NSMutableArray *) getLocationsUsingGridAproximationWithMeasures:(SharedData*)sharedData
                                                     andPrecisions:(NSDictionary*)precisions
{
    NSMutableArray * locatedPositions = [[NSMutableArray alloc] init];
    NSMutableDictionary * measuresDic = [sharedData getMeasuresDic];
    
    // Inspect dictionary from location manager for data retrieving
    //
    // { "measurePosition1":                              //  measuresDic
    //     { "measurePosition": measurePosition;          //  positionDic
    //       "positionRangeMeasures":
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
    //       "positionHeadingMeasures":
    //         { "measureUuid1":                          //  uuidDicDic
    //             { "uuid" : uuid1;                      //  uuidDic
    //               "uuidMeasures":
    //                 { "measure3":                      //  measureDicDic
    //                     { "type": "rssi"/"heading";    //  measureDic
    //                       "measure": rssi/heading
    //                     };
    //                   "measure4":  { (···) }
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
    
    // The grid is calculed with the positions
    NSMutableArray * measurePositions = [sharedData fromMeasuresDicGetPositions];
    NSMutableArray * grid = [self generateGridUsingPositions:measurePositions
                                               andPrecisions:precisions];
    
    // Each UUID groups the measures taken from a certain beacon and so, for every one of them a RDPosition would be found. It is needed the info about how many beacons there are.
    // For every position in the grid...
    NSInteger UUIDfound = 0;
    NSArray * positionKeys = [measuresDic allKeys];
    for (id positionKey in positionKeys) {
        positionDic = [measuresDic objectForKey:positionKey];
        uuidDicDic = positionDic[@"positionRangeMeasures"];
        NSArray * uuidKeys = [uuidDicDic allKeys];
        for (id uuidKey in uuidKeys) {
            UUIDfound++;
        }
    }
    
    // And thus, for every beacon that must be located with it unique UUID.
    for (NSInteger UUIDindex = 0; UUIDindex < UUIDfound; UUIDindex++) {
        // Optimization search over the grid
        NSNumber * minarg = [NSNumber numberWithFloat:FLT_MAX];
        RDPosition * minargPosition;
    
        // For every position in the grid...
        for (RDPosition * gridPosition in grid) {
            
            NSNumber * sum = [NSNumber numberWithFloat:0.0];
            
            // Measures are only feasible if measures were take from at least 3 positions with measures.
            NSInteger positionsWithMeasures = 0;
            
            // ...and for every position where measures were taken
            NSArray * positionKeys = [measuresDic allKeys];
            for (id positionKey in positionKeys) {
                // ...get the dictionary for this position, and also get the position,...
                positionDic = [measuresDic objectForKey:positionKey];
                RDPosition * measurePosition = positionDic[@"measurePosition"];
                
                // ...and thus calculate the euclidean distance between them...
                NSNumber * positionsDistance = [measurePosition euclideanDistance3Dto:gridPosition];
                // ...this will be used for comparing with each beacon's measures and minimization.
                
                
                // Get the the dictionary with the UUID's dictionaries...
                uuidDicDic = positionDic[@"positionRangeMeasures"];
                // ...and for the current UUID...
                NSInteger UUIDsubIndex = 0;
                NSArray * uuidKeys = [uuidDicDic allKeys];
                for (id uuidKey in uuidKeys) {
                    if (UUIDsubIndex == UUIDindex) {
                        // ...get the dictionary.
                        uuidDic = [uuidDicDic objectForKey:uuidKey];
                    
                        // Get the the dictionary with the measures dictionaries...
                        measureDicDic = uuidDic[@"uuidMeasures"];
                        // ...and for every measure calculate its mean average.
                        // TO DO Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                    
                        NSNumber * measuresAcumulation = [NSNumber numberWithFloat:0.0];
                        NSInteger measureIndex = 0;
                        NSArray * measuresKeys = [measureDicDic allKeys];
                        for (id measureKey in measuresKeys) {
                            measureDic = [measureDicDic objectForKey:measureKey];
                            measuresAcumulation = [NSNumber numberWithFloat:
                                                   [measuresAcumulation floatValue] +
                                                   [measureDic[@"measure"] floatValue]
                                                   ];
                            measureIndex++;
                        }
                        NSNumber * measureIndexFloat = [NSNumber numberWithInteger:measureIndex];
                        NSNumber * measuresAverage = [NSNumber numberWithFloat:
                                                      [measuresAcumulation floatValue] / [measureIndexFloat floatValue]
                                                      ];
                        // Count as valid position with measures
                        if (measureIndex > 0) {
                            positionsWithMeasures++;
                        }
                        
                        // And perform the calculus to minimizate
                        sum = [NSNumber numberWithFloat:
                               [sum floatValue] +
                               [positionsDistance floatValue] -
                               [measuresAverage floatValue]
                               ];
                    }
                    UUIDsubIndex++;
                }
            }
            // Evaluate feasibility
            if (positionsWithMeasures > 2) {
                
                // Minimization
                if ([sum floatValue] <[minarg floatValue]) {
                    minarg = [NSNumber numberWithFloat:[sum floatValue]];
                    minargPosition = [[RDPosition alloc] init];
                    minargPosition.x = gridPosition.x;
                    minargPosition.y = gridPosition.y;
                    minargPosition.z = gridPosition.z;
                }
                
            } else {
                minargPosition = nil;
            }
        }
        // Add the minimum position for this UUID
        if (minargPosition) {
            NSLog(@"[INFO][RR] Beacon radiolocated at %@", minargPosition);
            [locatedPositions addObject:minargPosition];
        }
    }
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
