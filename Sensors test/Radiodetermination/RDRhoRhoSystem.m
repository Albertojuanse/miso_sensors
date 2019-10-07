//
//  RDRhoRhoSystem.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoRhoSystem.h"

@implementation RDRhoRhoSystem : NSObject

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
 @method initWithSharedData:userDic:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [self init];
    credentialsUserDic = initCredentialsUserDic;
    userDic = initUserDic;
    deviceUUID = initDeviceUUID;
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

#pragma mark - Localization methods
/*!
 @method divideSegmentStartingAt:finishingAt:andWithPrecision:
 @discussion This method saves in the parameter 'NSMutableArray' type 'values' the middle value between two given values; if the divisions are greater than the precision, the method is recursively called until reached. The maximum or minimum value given as parameter is not included in final 'values' array. This method is used for composing the grid.
 */
- (void) recursiveDivideSegmentStartingAt:(NSNumber *)minValue
                              finishingAt:(NSNumber *)maxValue
                            withPrecision:(NSNumber *)precision
                                  inArray:(NSMutableArray *)values
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
 @method generateGridUsingPositions:andMaxMeasure:andPrecisions:
 @discussion This method generates a grid using maximum and minimum coordinate values of a set of positions and the maximum of the measures taken. It is used for sampling the space and perform thus some optimization calculus such as the one on method 'getLocationsUsingGridAproximationWithMeasures:andPrecisions:'.
 */
- (NSMutableArray *) generateGridUsingPositions:(NSMutableArray *)measurePositions
                                  andMaxMeasure:(NSNumber *)maxMeasure
                                  andPrecisions:(NSDictionary *)precisions
{
    
    // Search for the maximum and minimum values for the coordinates.
    NSNumber * minPositionsXvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsXvalue = [NSNumber numberWithFloat:-FLT_MAX];
    NSNumber * minPositionsYvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsYvalue = [NSNumber numberWithFloat:-FLT_MAX];
    NSNumber * minPositionsZvalue = [NSNumber numberWithFloat:FLT_MAX];
    NSNumber * maxPositionsZvalue = [NSNumber numberWithFloat:-FLT_MAX];
    
    for (RDPosition * position in measurePositions) {
        if (([position.x floatValue] - [maxMeasure floatValue]) < [minPositionsXvalue floatValue]) {
            minPositionsXvalue = position.x;
        }
        if (([position.x floatValue] + [maxMeasure floatValue]) > [maxPositionsXvalue floatValue]) {
            maxPositionsXvalue = position.x;
        }
        if (([position.y floatValue] - [maxMeasure floatValue]) < [minPositionsYvalue floatValue]) {
            minPositionsYvalue = position.y;
        }
        if (([position.y floatValue] + [maxMeasure floatValue]) > [maxPositionsYvalue floatValue]) {
            maxPositionsYvalue = position.y;
        }
        if (([position.y floatValue] - [maxMeasure floatValue]) < [minPositionsZvalue floatValue]) {
            minPositionsZvalue = position.z;
        }
        if (([position.z floatValue] + [maxMeasure floatValue]) > [maxPositionsZvalue floatValue]) {
            maxPositionsZvalue = position.z;
        }
    }
    
    // Get the coordinate values for the grid's positions; the method 'divideSegmentStartingAt:finishingAt:andWithPrecision:' adds to the values arrays the division points of the axis, but not add min and max value.
    NSMutableArray * xValues = [[NSMutableArray alloc] init];
    if ([minPositionsXvalue isEqualToNumber:maxPositionsXvalue]) {
        [xValues addObject:minPositionsXvalue];
    } else { // Only evaluate axis partition if the max and min value are not equal.
        [xValues addObject:minPositionsXvalue];
        [xValues addObject:maxPositionsXvalue];
        [self recursiveDivideSegmentStartingAt:minPositionsXvalue
                                   finishingAt:maxPositionsXvalue
                                 withPrecision:[precisions objectForKey:@"xPrecision"]
                                       inArray:xValues];
    }
    NSMutableArray * yValues = [[NSMutableArray alloc] init];
    if ([minPositionsYvalue isEqualToNumber:maxPositionsYvalue]) {
        [yValues addObject:minPositionsYvalue];
    } else { // Only evaluate axis partition if the max and min value are not equal.
        [yValues addObject:minPositionsYvalue];
        [yValues addObject:maxPositionsYvalue];
        [self recursiveDivideSegmentStartingAt:minPositionsYvalue
                                   finishingAt:maxPositionsYvalue
                                 withPrecision:[precisions objectForKey:@"yPrecision"]
                                       inArray:yValues];
    }
    NSMutableArray * zValues = [[NSMutableArray alloc] init];
    if ([minPositionsZvalue isEqualToNumber:maxPositionsZvalue]) {
        [zValues addObject:minPositionsZvalue];
    } else { // Only evaluate axis partition if the max and min value are not equal.
        [zValues addObject:minPositionsZvalue];
        [zValues addObject:maxPositionsZvalue];
        [self recursiveDivideSegmentStartingAt:minPositionsZvalue
                                   finishingAt:maxPositionsZvalue
                                 withPrecision:[precisions objectForKey:@"zPrecision"]
                                       inArray:zValues];
    }
    
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
 @method getLocationsUsingGridAproximationWithPrecisions:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions; it uses a simple grid search of the minimum of the least square of distances from positions were the measures were taken to the grid and the measures and the same point in the grid. In the '('NSDictionary' object 'precisions' must be defined the minimum requirement of precision for each axe, with floats in objects 'NSNumbers' set in the keys "xPrecision", "yPrecision" and "zPrecision".
 */
- (NSMutableDictionary *) getLocationsUsingGridAproximationWithPrecisions:(NSDictionary *)precisions
{
    NSLog(@"[INFO][RR] Start radiolocating items");
    
    // Check the access to data shared collections
    if (
        ![sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][RR] Shared data could not be accessed while loading cells' item.");
    }
    
    // Declare collections
    NSMutableDictionary * locatedPositions = [[NSMutableDictionary alloc] init];
    
    // Different behaviour depending on location mode
    NSString * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
    if ([mode isEqualToString:@"RHO_RHO_MODELING"]) {
        
        // In a modeling mode the items must be located using the measures taken by the device or devices. That implies that, each UUID groups the measures taken from a certain beacon and so, for every one of them a RDPosition would be found.
        
        // It is needed the whole of positions where measures were taken and its maximun value to caluculate a grid in which locate every item. Retrieve that data.
        NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithCredentialsUserDic:credentialsUserDic];
        NSNumber * maxMeasure = [sharedData fromMeasuresDataGetMaxMeasureOfSort:@"rssi" withCredentialsUserDic:credentialsUserDic];
        NSMutableArray * grid = [self generateGridUsingPositions:measurePositions
                                                   andMaxMeasure:maxMeasure
                                                   andPrecisions:precisions];
        
        // It is also needed the info about the UUID that must be located; in this case the beacons.
        // TO DO: Multiuser measures. Alberto J. 2019/09/24.
        NSMutableArray * everyUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every beacon that must be located with its unique UUID, get from every position the measures that come from this UUID.
        for (NSString * UUIDtoLocate in everyUUID) {
            
            // Optimization search over the grid
            NSNumber * minarg = [NSNumber numberWithFloat:FLT_MAX];
            RDPosition * minargPosition;
            NSString * minargUUID;
            
            // For every position in the grid,...
            for (RDPosition * gridPosition in grid) {
                
                NSNumber * sum = [NSNumber numberWithFloat:0.0];
                
                // Measures are only feasible if measures were take from at least 3 positions with measures.
                NSInteger positionsWithMeasures = 0;
                
                // ...for every position where measures were taken
                NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithMeasuresOfUserDic:userDic
                                                                                           withCredentialsUserDic:credentialsUserDic];
                for (RDPosition * measurePosition in measurePositions) {
                    
                    // ...and thus calculate the euclidean distance between them;...
                    NSNumber * positionsDistance = [measurePosition euclideanDistance3Dto:gridPosition];
                    // ...this will be used for comparing with each beacon's measures and minimization.
                    
                    // Now, get the UUID of the items measured from this position...
                    NSMutableArray * allMeasuredUUIDs = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                                     takenFromPosition:measurePosition
                                                                                withCredentialsUserDic:credentialsUserDic];
                    
                    // ...and search in them the current searched UUID...
                    for (NSString * measuredUUID in allMeasuredUUIDs) {
                        
                        // For optimization process
                        minargUUID = measuredUUID;
                        
                        // ...but only perform the calculus if is the current searched UUID.
                        if ([UUIDtoLocate isEqualToString:measuredUUID]) {
                            
                            // Now, get only the measures taken from that position and from that UUID...
                            NSMutableArray * measures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                                       takenFromPosition:measurePosition
                                                                                            fromItemUUID:measuredUUID
                                                                                                  ofSort:@"rssi"
                                                                                  withCredentialsUserDic:credentialsUserDic];
                            // ...and for every measure calculate its mean average.
                            // TO DO: Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                            
                            if (measures.count == 0) {
                                // Not evaluate
                            } else {
                                NSNumber * measuresAcumulation = [NSNumber numberWithFloat:0.0];
                                NSInteger measureIndex = 0;
                                for (NSNumber * measure in measures) {
                                    // Only evaluate if it is a RSSI measure
                                    measuresAcumulation = [NSNumber numberWithFloat:
                                                           [measuresAcumulation floatValue] +
                                                           [measure floatValue]
                                                           ];
                                    measureIndex++;
                                }
                                NSNumber * measureIndexFloat = [NSNumber numberWithInteger:measureIndex];
                                NSNumber * measuresAverage = [NSNumber numberWithFloat:0.0];
                                if (measureIndex != 0) { // Division by zero preventing
                                    measuresAverage = [NSNumber numberWithFloat:
                                                       [measuresAcumulation floatValue] / [measureIndexFloat floatValue]
                                                       ];
                                }
                                // Count as valid position with measures
                                if (measureIndex > 0) {
                                    positionsWithMeasures++;
                                }
                                
                                // And perform the calculus to minimizate; is squared difference.
                                sum = [NSNumber numberWithFloat:
                                       (
                                        [sum floatValue] +
                                        [positionsDistance floatValue] -
                                        [measuresAverage floatValue]) *
                                       (
                                        [sum floatValue] +
                                        [positionsDistance floatValue] -
                                        [measuresAverage floatValue]
                                        )
                                       ];
                            }
                        }
                    }
                }
                // Evaluate feasibility
                if (positionsWithMeasures > 2) {
                    // Minimization
                    
                    if ([sum floatValue] < [minarg floatValue]) {
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
                [locatedPositions setObject:minargPosition forKey:minargUUID];
            }
        }
    }
    if ([mode isEqualToString:@"RHO_RHO_LOCATING"]) {
        
        // In a locating mode the device must be located using the measures from items. That implies that, each UUID groups the measures taken from a certain beacon and the device position must be calculed using all of them.
        
        // It is needed the whole of positions where measures were generated and its maximun value to caluculate a grid in which locate every item; save also its UUID in the same order. Retrieve that data using selected items by user.
        NSMutableArray * itemsChosenByUser = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                          andCredentialsUserDic:credentialsUserDic];
        NSMutableArray * itemsPositions = [[NSMutableArray alloc] init];
        NSMutableArray * itemsUUID = [[NSMutableArray alloc] init];
        for (NSMutableDictionary * itemDic in itemsChosenByUser) {
            
            // For every item selected by user, only get the positions of beacons
            NSString * itemUUID = itemDic[@"uuid"];
            NSString * sort = itemDic[@"sort"];
            if ([sort isEqualToString:@"beacon"]) {
                if (itemDic[@"position"]) {
                    RDPosition * itemPosition = [[RDPosition alloc] init];
                    RDPosition * newPosition = [[RDPosition alloc] init];
                    itemPosition = itemDic[@"sort"];
                    newPosition.x = itemPosition.x;
                    newPosition.y = itemPosition.y;
                    newPosition.z = itemPosition.z;
                    [itemsPositions addObject:newPosition];
                    [itemsUUID addObject:itemUUID];
                }
            }
        }
        NSNumber * maxMeasure = [sharedData fromMeasuresDataGetMaxMeasureOfSort:@"rssi" withCredentialsUserDic:credentialsUserDic];
        NSMutableArray * grid = [self generateGridUsingPositions:itemsPositions
                                                   andMaxMeasure:maxMeasure
                                                   andPrecisions:precisions];
        
        // It is also needed the info about the UUID that must be located; in this case the device's UUID.
        // TO DO: Multiuser measures. Alberto J. 2019/09/24.
        NSMutableArray * everyUUID = [[NSMutableArray alloc] initWithObjects:deviceUUID, nil];
        
        // And thus, for every device that must be located with its unique UUID, get from every item where measures were generated its measures and use them.
        for (NSString * UUIDtoLocate in everyUUID) {
            
            // Optimization search over the grid
            NSNumber * minarg = [NSNumber numberWithFloat:FLT_MAX];
            RDPosition * minargPosition;
            NSString * minargUUID = UUIDtoLocate; // In this mode it is known.
            
            // For every position in the grid,...
            for (RDPosition * gridPosition in grid) {
                
                NSNumber * sum = [NSNumber numberWithFloat:0.0];
                
                // Measures are only feasible if measures were take from at least 3 positions with measures.
                NSInteger itemsWithMeasures = 0;
                
                // ...and for every position where measures come from...
                for (RDPosition * itemPosition in itemsPositions) {
                    
                    // ...calculate the euclidean distance between them;...
                    NSNumber * positionsDistance = [itemPosition euclideanDistance3Dto:gridPosition];
                    // ...this will be used for comparing with each beacon's measures and minimization.
                    
                    // To get the measures taken from the item in that position its UUID can be used
                    NSString * itemUUID = [itemsUUID objectAtIndex:
                                           [itemsPositions indexOfObject:itemPosition]
                                           ];
                   
                    
                            
                    // Now, get only the measures taken from that item and its UUID...
                    NSMutableArray * measures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                            takenFromItemUUID:itemUUID
                                                                                        ofSort:@"rssi"
                                                                        withCredentialsUserDic:credentialsUserDic];
                    // ...and for every measure calculate its mean average.
                    // TO DO: Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                    
                    
                    if (measures.count == 0) {
                        // Not evaluate
                    } else {
                        NSNumber * measuresAcumulation = [NSNumber numberWithFloat:0.0];
                        NSInteger measureIndex = 0;
                        for (NSNumber * measure in measures) {
                            // Only evaluate if it is a RSSI measure
                            measuresAcumulation = [NSNumber numberWithFloat:
                                                   [measuresAcumulation floatValue] +
                                                   [measure floatValue]
                                                   ];
                            measureIndex++;
                        }
                        NSNumber * measureIndexFloat = [NSNumber numberWithInteger:measureIndex];
                        NSNumber * measuresAverage = [NSNumber numberWithFloat:0.0];
                        if (measureIndex != 0) { // Division by zero preventing
                            measuresAverage = [NSNumber numberWithFloat:
                                               [measuresAcumulation floatValue] / [measureIndexFloat floatValue]
                                               ];
                        }
                        // Count as valid position with measures
                        if (measureIndex > 0) {
                            itemsWithMeasures++;
                        }
                        
                        // And perform the calculus to minimizate; is squared difference.
                        sum = [NSNumber numberWithFloat:
                               (
                                [sum floatValue] +
                                [positionsDistance floatValue] -
                                [measuresAverage floatValue]) *
                               (
                                [sum floatValue] +
                                [positionsDistance floatValue] -
                                [measuresAverage floatValue]
                                )
                               ];
                    }
                }
                // Evaluate feasibility
                if (itemsWithMeasures > 2) {
                    // Minimization
                    
                    if ([sum floatValue] < [minarg floatValue]) {
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
                [locatedPositions setObject:minargPosition forKey:minargUUID];
            }
        }
    }

    // If not a rho rho type system
    if (
        [mode isEqualToString:@"THETA_THETA_MODELING"] ||
        [mode isEqualToString:@"RHO_THETA_MODELING"] ||
        [mode isEqualToString:@"THETA_THETA_LOCATING"] ||
        [mode isEqualToString:@"RHO_THETA_LOCATING"]
        ) {
        NSLog(@"[ERROR][RR] Theta type system called when in a rho rho mode.");
    }
   
    NSLog(@"[INFO][RR] Finish Radiolocating beacons");
    return locatedPositions;
}

#pragma mark - Class methods
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
