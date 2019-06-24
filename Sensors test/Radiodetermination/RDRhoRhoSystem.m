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
 @method getLocationsUsingGridAproximationWithMeasures:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions; it uses a simple grid search of the minimum of the least square of distances from positions were the measures were taken to the grid and the measures and the same point in the grid.
 */
- (NSMutableArray *) getLocationsUsingGridAproximationWithMeasures:(SharedData*)sharedData
                                                      andPrecision:(NSNumber*)precision
{
    
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
    NSMutableArray * xGrid = [self generateGridUsingPosition:measurePositions
                                            itsIthDimension:0
                                               andPrecision:precision];
    
    
    NSInteger positionIndex = 0;
    NSArray * positionKeys = [measuresDic allKeys];
    // For every (canvas) position where measures were taken
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [measuresDic objectForKey:positionKey];
        // ...but also get the transformed position.
        RDPosition * realPosition = positionDic[@"measurePosition"];
        
        // Get the the dictionary with the UUID's dictionaries...
        uuidDicDic = positionDic[@"positionRangeMeasures"];
        // ...and for every UUID...
        NSArray * uuidKeys = [uuidDicDic allKeys];
        // Color for every UUID
        NSInteger UUIDindex = 0;
        for (id uuidKey in uuidKeys) {
            
            // ...get the dictionary...
            uuidDic = [uuidDicDic objectForKey:uuidKey];
            // ...and get the uuid.
            NSString * uuid = [NSString stringWithString:uuidDic[@"uuid"]];
            
            // Get the the dictionary with the measures dictionaries...
            measureDicDic = uuidDic[@"uuidMeasures"];
            // ...and for every measure...
            NSArray * measuresKeys = [measureDicDic allKeys];
            for (id measureKey in measuresKeys) {
                // ...get the dictionary for this measure...
                measureDic = [measureDicDic objectForKey:measureKey];
                // ...and the measure.
                NSNumber * measure = [NSNumber numberWithFloat:[measureDic[@"measure"] floatValue]];
            }
            UUIDindex++;
        }
        positionIndex++;
    }
    
    
    
}

/*!
 @method generateGridUsingPositions:itsIthDimension:andPrecision:
 @discussion This method generates the i-th axis of a grid using maximum and minimum coordinate values of a set of positions and a given precision for this coordinate; if 3D is used, dimensions are 0, 1, 2.
 */
- (NSNumber *) generateGridUsingPosition:(NSMutableArray*)measurePositions
                         itsIthDimension:(NSInteger *)dimension
                            andPrecision:(NSNumber *)precision
{
    
    // Search for the maximum and minimum values for the i-th coordinate.
    float minPositionValue = FLT_MAX];
    float maxPositionValue = -FLT_MAX];
    
    for (RDPosition * position in measurePositions) {
        switch (dimension) {
            case 0:
                if ([position.x floatValue] < minPositionValue) {
                    minPositionValue = [position.x floatValue];
                }
                if ([position.x floatValue] > maxPositionValue) {
                    maxPositionValue = [position.x floatValue];
                }
                break;
                
            case 1:
                if ([position.y floatValue] < minPositionValue) {
                    minPositionValue = [position.y floatValue];
                }
                if ([position.y floatValue] > maxPositionValue) {
                    maxPositionValue = [position.y floatValue];
                }
                break;
                
            case 2:
                if ([position.z floatValue] < minPositionValue) {
                    minPositionValue = [position.y floatValue];
                }
                if ([position.z floatValue] > maxPositionValue) {
                    maxPositionValue = [position.y floatValue];
                }
                break;
            default:
                NSLog(@"[ERROR][RR] i-th dimension higher than 2; 3D -> 0, 1, 2");
                break;
        }
    }
    
    // Compose the grid
    // Get the coordinate values for the grid's positions
    NSMutableArray * xValues = [[NSMutableArray alloc] init];
    NSMutableArray * yValues = [[NSMutableArray alloc] init];
    NSMutableArray * zValues = [[NSMutableArray alloc] init];
    
}

/*!
 @method divideSegmentStartingAt:finishingAt:andWithPrecision:
 @discussion This method divides a segment until reach an equally spaced precision grid axis and compose an 'NSMutableArray' with the values.
 */
- (float) divideSegmentStartingAt:(float)minValue
                      finishingAt:(float)maxValue
                    withPrecision:(float)precision
                          inArray:(NSMutableArray*)values
{
    
    // If equals
    if (minValue == maxValue) {
        values = [NSMutableArray arrayWithObject:minValue];
        return values;
    }
    // If absolute value minor than the precision
    if (powf( powf(maxValue - minValue , 2) , 0.5) < precision) {
        return nil;
    }
    
    // Search for middle and append it
    float middleValue = minValue + powf( powf(maxValue - minValue , 2) , 0.5) / 2;
    values = [NSMutableArray arrayWithObject:middleValue];
    // Repeat for both sides of middle
    id lowMiddle = [self divideSegmentStartingAt:minValue finishingAt:middleValue andWithPrecision:precision];
    id highMiddle = [self divideSegmentStartingAt:minValue finishingAt:middleValue andWithPrecision:precision];
    
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
