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
 @method getLocationsUsingGridAproximationWithPrecisions:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions; it uses a simple grid search of the minimum of the least square of distances from positions were the measures were taken to the grid and the measures and the same point in the grid. In the '('NSDictionary' object 'precisions' must be defined the minimum requirement of precision for each axe, with floats in objects 'NSNumbers' set in the keys "xPrecision", "yPrecision" and "zPrecision".
 */
- (NSMutableDictionary *) getLocationsUsingGridAproximationWithPrecisions:(NSDictionary *)precisions
{
    NSLog(@"[INFO][RR] Start radiolocating items.");
    
    // Check the access to data shared collections
    if (
        ![sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][RR] Shared data could not be accessed before use grid aproximation.");
    }
    
    // Declare collections
    NSMutableDictionary * locatedPositions = [[NSMutableDictionary alloc] init];
    
    // Different behaviour depending on location mode
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    
    if ([mode isModeKey:kModeRhoRhoLocating]) {
        
        // In a locating mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the adding menu, and
        // - as the 'itemUUID' the UUID of the item chosen in the canvas.
        // A location will be found for each 'deviceUUID'
        
        // This method uses a grid search, and the grid is calculated with the maximum value of measures.
        NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithCredentialsUserDic:credentialsUserDic];
        NSNumber * maxMeasure = [sharedData fromMeasuresDataGetMaxMeasureOfSort:@"correctedDistance"
                                                         withCredentialsUserDic:credentialsUserDic];
        NSMutableArray * grid = [self generateGridUsingPositions:measurePositions
                                                   andMaxMeasure:maxMeasure
                                                   andPrecisions:precisions];
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * deviceUUID in allDeviceUUID) {
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            NSInteger itemsWithMeasures = 0;
            
            // Perform the calculus searching over the grid the optimum solution
            NSNumber * minarg = [NSNumber numberWithFloat:FLT_MAX];
            RDPosition * minargPosition;
        
            // For every position in the grid,...
            for (RDPosition * gridPosition in grid) {
                
                NSNumber * sum = [NSNumber numberWithFloat:0.0];
            
                // ...evaluate the diferent items that are measured...
                for (NSString * itemUUID in allItemUUID) {
                    
                    // ...and get every measure of the tuple (itemUUID, deviceUUID)
                    NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                           fromItemUUID:itemUUID
                                                                                                 ofSort:@"correctedDistance"
                                                                                 withCredentialsUserDic:credentialsUserDic];
                    // ...and for every measure do the calculations:
                    // - calculate its mean average and
                    // - calculate the location.
                    // minarg_{gridPosition} of { SUM{
                    //      (|| itemPosition - gridPosition || - measure)^2
                    //  } }
                
                    NSNumber * measuresRSSIAverage = [self getMeanOf:rssiMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:itemUUID
                                                                        andCredentialsUserDic:credentialsUserDic];
                    if (itemsMeasured.count == 0) {
                        NSLog(@"[ERROR][RR] No items found with the itemUUID in measures.");
                        break;
                    }
                    if (itemsMeasured.count > 1) {
                        NSLog(@"[ERROR][RR] More than one items stored with the same UUID: using first one.");
                    }
                    NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                    RDPosition * itemPosition = itemMeasured[@"position"];
                    
                    if (itemPosition) {
                        itemsWithMeasures++; // valid item
                        
                        // Perform the calculus to minimizate; is squared difference.
                        NSNumber * positionsDistance = [itemPosition euclideanDistance3Dto:gridPosition];
                        sum = [NSNumber numberWithFloat: [sum floatValue] +
                               ([positionsDistance floatValue]-[measuresRSSIAverage floatValue]) *
                               ([positionsDistance floatValue]-[measuresRSSIAverage floatValue])
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
                }
            }
            
            // Save the result for this deviceUUID.
            if (minargPosition) {
                [locatedPositions setObject:minargPosition forKey:deviceUUID];
            }
        }
        
    } else if ([mode isModeKey:kModeRhoRhoModelling]) {
        
        // In a modelling mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the canvas, and
        // - as the 'itemUUID' the UUID of the item chosen in the adding menu.
        // A location will be found for each 'itemUUID'
        
        // This method uses a grid search, and the grid is calculated with the maximum value of measures.
        NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithCredentialsUserDic:credentialsUserDic];
        NSNumber * maxMeasure = [sharedData fromMeasuresDataGetMaxMeasureOfSort:@"correctedDistance"
                                                         withCredentialsUserDic:credentialsUserDic];
        NSMutableArray * grid = [self generateGridUsingPositions:measurePositions
                                                   andMaxMeasure:maxMeasure
                                                   andPrecisions:precisions];
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * itemUUID in allItemUUID) {
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'itemUUID' but different 'deviceUUID'.
            NSInteger itemsWithMeasures = 0;
            
            // Perform the calculus searching over the grid the optimum solution
            NSNumber * minarg = [NSNumber numberWithFloat:FLT_MAX];
            RDPosition * minargPosition;
        
            // For every position in the grid,...
            for (RDPosition * gridPosition in grid) {
                
                NSNumber * sum = [NSNumber numberWithFloat:0.0];
            
                // ...evaluate the diferent items that are measured...
                for (NSString * deviceUUID in allDeviceUUID) {
                    
                    // ...and get every measure of the tuple (itemUUID, deviceUUID)
                    NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                           fromItemUUID:itemUUID
                                                                                                 ofSort:@"correctedDistance"
                                                                                 withCredentialsUserDic:credentialsUserDic];
                    // ...and for every measure do the calculations:
                    // - calculate its mean average and
                    // - calculate the location.
                    // minarg_{gridPosition} of { SUM{
                    //      (|| itemPosition - gridPosition || - measure)^2
                    //  } }
                    NSNumber * measuresRSSIAverage = [self getMeanOf:rssiMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:deviceUUID
                                                                        andCredentialsUserDic:credentialsUserDic];
                    if (itemsMeasured.count == 0) {
                        NSLog(@"[ERROR][RR] No items found with the itemUUID in measures.");
                        break;
                    }
                    if (itemsMeasured.count > 1) {
                        NSLog(@"[ERROR][RR] More than one items stored with the same UUID: using first one.");
                    }
                    NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                    RDPosition * itemPosition = itemMeasured[@"position"];
                    
                    if (itemPosition) {
                        itemsWithMeasures++; // valid item
                        
                        // Perform the calculus to minimizate; is squared difference.
                        NSNumber * positionsDistance = [itemPosition euclideanDistance3Dto:gridPosition];
                        sum = [NSNumber numberWithFloat: [sum floatValue] +
                               ([positionsDistance floatValue]-[measuresRSSIAverage floatValue]) *
                               ([positionsDistance floatValue]-[measuresRSSIAverage floatValue])
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
                }
            }
            
            // Save the result for this deviceUUID.
            if (minargPosition) {
                [locatedPositions setObject:minargPosition forKey:itemUUID];
            }
        }
        
    } else {
       NSLog(@"[ERROR][RR] Instantiated rho-rho type system  when using %@ mode.", mode);
    }
   
    NSLog(@"[INFO][RR] Finish Radiolocating beacons.");
    return locatedPositions;
}

@end
