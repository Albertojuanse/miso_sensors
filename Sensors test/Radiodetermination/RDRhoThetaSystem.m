//
//  RDRhoThetaSystem.m
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoThetaSystem.h"

@implementation RDRhoThetaSystem : NSObject

- (instancetype)init
{
    self = [super init];
    return self;
}

- (NSMutableDictionary *) getLocationsUsingGridAproximationWithMeasures:(SharedData*)sharedData
                                                          andPrecisions:(NSDictionary*)precisions
{
 NSLog(@"[INFO][RT] Start Radiolocating beacons");
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
    
    // Each UUID groups the measures taken from a certain beacon and so, for every one of them a RDPosition would be found. It is needed the info about how many beacons there are.
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
    NSLog(@"[INFO][RT] Found %.2f different UUID", [[NSNumber numberWithInteger:diferentUUID.count] floatValue]);
    
    // And thus, for every beacon that must be located with it unique UUID.
    for (NSString * UUIDtoLocate in diferentUUID) {
        
        NSString * uuid;
        
        // Measures are only feasible if measures have both heading and rssi types.
        BOOL isHeadingMeasure = NO;
        BOOL isRSSIMeasure = NO;
        
        // For every position where measures were taken, which is usually only one,
        NSArray * positionKeys = [measuresDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position, and also get the position,...
            positionDic = [measuresDic objectForKey:positionKey];
            RDPosition * measurePosition = positionDic[@"measurePosition"];
            
            // Get the the dictionary with the UUID's dictionaries...
            uuidDicDic = positionDic[@"positionMeasures"];
            NSArray * uuidKeys = [uuidDicDic allKeys];
            for (id uuidKey in uuidKeys) {
                // ...get the dictionary and the UUID...
                uuidDic = [uuidDicDic objectForKey:uuidKey];
                uuid = uuidDic[@"uuid"];
                
                // ...and only perform the calculus if is the current searched UUID...
                NSLog(@"[INFO][RT] UUIDtoLocate %@", UUIDtoLocate);
                NSLog(@"[INFO][RT] uuid %@", uuid);
                if ([UUIDtoLocate isEqualToString:uuid]) {
                    
                    // Get the the dictionary with the measures dictionaries...
                    measureDicDic = uuidDic[@"uuidMeasures"];
                    
                    // ...and for every measure calculate its mean average.
                    // TO DO Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                    
                    // But only do this if the 'measureDicDic' exists
                    if (measureDicDic.count == 0) {
                        NSLog(@"[INFO][RT] measureDicDic.count == 0 => YES");
                        // Not evaluate
                    } else {
                        NSLog(@"[INFO][RT] measureDicDic.count == 0 => NO");
                        NSNumber * measuresRSSIAcumulation = [NSNumber numberWithFloat:0.0];
                        NSNumber * measuresHeadingAcumulation = [NSNumber numberWithFloat:0.0];
                        NSInteger measureRSSIIndex = 0;
                        NSInteger measureHeadingIndex = 0;
                        NSArray * measuresKeys = [measureDicDic allKeys];
                        for (id measureKey in measuresKeys) {
                            measureDic = [measureDicDic objectForKey:measureKey];
                            
                            // Get the data and acumulate it
                            if ([measureDic[@"type"] isEqualToString:@"rssi"]) {
                                measuresRSSIAcumulation = [NSNumber numberWithFloat:
                                                           [measuresRSSIAcumulation floatValue] +
                                                           [measureDic[@"measure"] floatValue]
                                                           ];
                                measureRSSIIndex++;
                                isRSSIMeasure = YES;
                            }
                            if ([measureDic[@"type"] isEqualToString:@"heading"]) {
                                measuresHeadingAcumulation = [NSNumber numberWithFloat:
                                                              [measuresHeadingAcumulation floatValue] +
                                                              [measureDic[@"measure"] floatValue]
                                                              ];
                                isHeadingMeasure = YES;
                                measureHeadingIndex++;
                            }
                        }
                            
                        // Calculate the mean averages
                        NSNumber * measureRSSIIndexFloat = [NSNumber numberWithInteger:measureRSSIIndex];
                        NSNumber * measuresRSSIAverage = [NSNumber numberWithFloat:0.0];
                        if (measureRSSIIndex != 0) { // Division by zero preventing
                            measuresRSSIAverage = [NSNumber numberWithFloat:
                                                   [measuresRSSIAcumulation floatValue] /
                                                   [measureRSSIIndexFloat floatValue]
                                                   ];
                        }
                        
                        NSNumber * measureHeadingIndexFloat = [NSNumber numberWithInteger:measureHeadingIndex];
                        NSNumber * measuresHeadingAverage = [NSNumber numberWithFloat:0.0];
                        if (measureHeadingIndex != 0) { // Division by zero preventing
                            measuresHeadingAverage = [NSNumber numberWithFloat:
                                                      [measuresHeadingAcumulation floatValue] /
                                                      [measureHeadingIndexFloat floatValue]
                                                      ];
                        }
                            
                        // Final calculus is only performed if there are both RSSI and heading measures
                        // (x, y) = (x0, y0) + (RSSI * cos(heading), RSSI * sen(heading)) in radians and meters
                        NSLog(isRSSIMeasure ? @"[INFO][RT] isRSSIMeasure = YES" : @"[INFO][RT] isRSSIMeasure = NO");
                        NSLog(isHeadingMeasure ? @"[INFO][RT] isHeadingMeasure = YES" : @"[INFO][RT] isHeadingMeasure = NO");
                        if (isRSSIMeasure && isHeadingMeasure) {
                            RDPosition * locatedPosition = [[RDPosition alloc] init];
                            locatedPosition.x = [NSNumber numberWithFloat:[measurePosition.x floatValue] +
                                                 [measuresRSSIAverage floatValue] *
                                                 cos([measuresHeadingAverage doubleValue])
                                                 ];
                            locatedPosition.y = [NSNumber numberWithFloat:[measurePosition.y floatValue] +
                                                 [measuresRSSIAverage floatValue] *
                                                 sin([measuresHeadingAverage doubleValue])
                                                 ];
                            locatedPosition.z = measurePosition.z;
                            
                            NSLog(@"[INFO][RT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                            NSLog(@"[INFO][RT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                            NSLog(@"[INFO][RT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                            
                            [locatedPositions setObject:locatedPosition forKey:uuid];
                        }
                    }
                }
            }
        }
    }
    NSLog(@"[INFO][RT] Finish Radiolocating beacons");
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
