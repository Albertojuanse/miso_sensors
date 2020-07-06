//
//  RDRhoThetaSystem.m
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoThetaSystem.h"

@implementation RDRhoThetaSystem : NSObject

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
 @method getLocationsUsingBarycenterAproximationWithPrecisions:
 precision:
 @discussion This method calculates any posible location with the measures taken from each beacon at different positions. In the NSDictionary object 'precisions' must be defined the minimum requirement of precision for each axe, with floats in objects 'NSNumbers' set in the keys "xPrecision", "yPrecision" and "zPrecision".
 */
- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithPrecisions:(NSDictionary *)precisions
{
    NSLog(@"[INFO][RT] Start Radiolocating beacons.");
    
    // Check the access to data shared collections
    if (
        ![sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
        NSLog(@"[ERROR][RT] Shared data could not be accessed before use barycenter aproximation.");
    }
    
    // Declare collections
    NSMutableDictionary * locatedPositions = [[NSMutableDictionary alloc] init];
    
    // Different behaviour depending on location mode
    MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                    andCredentialsUserDic:credentialsUserDic];
    /*
    if ([mode isModeKey:kModeRhoThetaLocating]) {
        
        // In a locating mode the device must be located using the measures from items and the headings aginst them. That implies that, each UUID groups the measures taken from a certain beacon and the device position must be calculed using all of them.
        
        // It is also needed the info about the UUID that must be located; in this case the beacons.
        // TODO: Multiuser measures. Alberto J. 2019/09/24.
        NSMutableArray * everyUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every beacon that is used to location with its unique UUID, get the measures that come from every item or that aim it; the measure position is unknown, but the items positions are so. The located item is the device.
        // TODO: Multiuser measures. Alberto J. 2019/09/24.
        NSString * uuid = deviceUUID; // In this mode it is known.
        
        // And thus, for every item used for locating with it unique UUID.
        for (NSString * UUIDusedToLocate in everyUUID) {
            
            
            // Measures are only feasible if measures have both heading and rssi types.
            BOOL isHeadingMeasure = NO;
            BOOL isRSSIMeasure = NO;
            
            // Get the measures taken from the UUID that must be located.
            // TODO: Multiuser measures. Alberto J. 2019/09/24.
            NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                           takenFromItemUUID:UUIDusedToLocate
                                                                                      ofSort:@"correctedDistance"
                                                                      withCredentialsUserDic:credentialsUserDic];
            NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                              takenFromItemUUID:UUIDusedToLocate
                                                                                         ofSort:@"heading"
                                                                         withCredentialsUserDic:credentialsUserDic];
            
            // ...and for every measure calculate its mean average.
            // TODO: Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
            
            NSNumber * measuresRSSIAcumulation = [NSNumber numberWithFloat:0.0];
            NSInteger measureRSSIIndex = 0;
            if (rssiMeasures.count == 0) {
                // Not evaluate
            } else {
                isRSSIMeasure = YES;
                for (NSNumber * measure in rssiMeasures) {
                    measuresRSSIAcumulation = [NSNumber numberWithFloat:
                                               [measuresRSSIAcumulation floatValue] +
                                               [measure floatValue]
                                               ];
                    measureRSSIIndex++;
                }
            }
            
            NSNumber * measuresHeadingAcumulation = [NSNumber numberWithFloat:0.0];
            NSInteger measureHeadingIndex = 0;
            if (headingMeasures.count == 0) {
                // Not evaluate
            } else {
                isHeadingMeasure = YES;
                for (NSNumber * measure in headingMeasures) {
                    measuresHeadingAcumulation = [NSNumber numberWithFloat:
                                                  [measuresHeadingAcumulation floatValue] +
                                                  [measure floatValue]
                                                  ];
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
            // (x_device, y_device) = (x_item, y_item) - (RSSI * cos(heading), RSSI * sen(heading)) in radians and meters
            // NSLog(isRSSIMeasure ? @"[INFO][RT] isRSSIMeasure = YES" : @"[INFO][RT] isRSSIMeasure = NO.");
            // NSLog(isHeadingMeasure ? @"[INFO][RT] isHeadingMeasure = YES" : @"[INFO][RT] isHeadingMeasure = NO.");
            if (isRSSIMeasure && isHeadingMeasure) {
                // Get the item position using its UUID
                NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:UUIDusedToLocate
                                                                    andCredentialsUserDic:credentialsUserDic];
                if (itemsMeasured.count == 0) {
                    NSLog(@"[ERROR][RT] No items found with the UUID in measures.");
                    break;
                }
                if (itemsMeasured.count > 1) {
                    NSLog(@"[ERROR][RT] More than one items stored with the same UUID. Using first one.");
                }
                NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                RDPosition * itemPosition = itemMeasured[@"position"];
                
                if (itemPosition) {
                    // Perform the calculus
                    // TODO: Z coordinate. Alberto J. 2019/09/24.
                    RDPosition * locatedPosition = [[RDPosition alloc] init];
                    locatedPosition.x = [NSNumber numberWithFloat:[itemPosition.x floatValue] -
                                         [measuresRSSIAverage floatValue] *
                                         cos([measuresHeadingAverage doubleValue])
                                         ];
                    locatedPosition.y = [NSNumber numberWithFloat:[itemPosition.y floatValue] -
                                         [measuresRSSIAverage floatValue] *
                                         sin([measuresHeadingAverage doubleValue])
                                         ];
                    locatedPosition.z = itemPosition.z;
                
                    // NSLog(@"[INFO][RT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                    // NSLog(@"[INFO][RT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                    // NSLog(@"[INFO][RT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                
                    [locatedPositions setObject:locatedPosition forKey:uuid];
                } else {
                    NSLog(@"[ERROR][RT] The item measured has not got position estored.");
                }
            }
        }
    }
     */
    
    if ([mode isModeKey:kModeRhoThetaModelling]) {
        
        // In a modeling mode the items must be located using the measures taken by the device or devices from items and the headings aginst them. That implies that, each UUID groups the measures taken of a certain beacon and so, for every one of them a RDPosition would be found.
        // TODO: Multiuser measures. Alberto J. 2019/09/24.
        
        // It is also needed the info about the UUID that must be located; in this case the beacons.
        NSMutableArray * allUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                              withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every beacon that must be located with its unique UUID, get the measures of this UUID or that aim it.
        for (NSString * uuid in allUUID) {
            
            // Measures are only feasible if measures have both heading and rssi types.
            BOOL isHeadingMeasure = NO;
            BOOL isRSSIMeasure = NO;
            
            // For every position where measures were taken, which is usually only one,...
            NSMutableArray * measurePositions = [sharedData fromMeasuresDataGetPositionsWithMeasuresOfUserDic:userDic
                                                                                       withCredentialsUserDic:credentialsUserDic];
            for (RDPosition * measurePosition in measurePositions) {
                        
                // ...get only the measures taken from that position and from that UUID...
                NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                               takenFromPosition:measurePosition
                                                                                    fromItemUUID:uuid
                                                                                          ofSort:@"correctedDistance"
                                                                          withCredentialsUserDic:credentialsUserDic];
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfUserDic:userDic
                                                                                  takenFromPosition:measurePosition
                                                                                       fromItemUUID:uuid
                                                                                             ofSort:@"heading"
                                                                             withCredentialsUserDic:credentialsUserDic];
                // ...and for every measure calculate its mean average.
                // TODO: Other statistical such as a deviation ponderate average. Alberto J. 2019/06/25.
                NSLog(@"[INFO]][RT] rssiMeasures.count %.2f", [[NSNumber numberWithInteger:rssiMeasures.count] floatValue]);
                NSLog(@"[INFO]][RT] headingMeasures.count %.2f", [[NSNumber numberWithInteger:headingMeasures.count] floatValue]);
                if (!(rssiMeasures.count == 0) && !(headingMeasures.count == 0)) {
                    NSNumber * measuresRSSIAcumulation = [NSNumber numberWithFloat:0.0];
                    NSInteger measureRSSIIndex = 0;
                    if (rssiMeasures.count == 0) {
                        // Not evaluate
                    } else {
                        isRSSIMeasure = YES;
                        for (NSNumber * measure in rssiMeasures) {
                            measuresRSSIAcumulation = [NSNumber numberWithFloat:
                                                       [measuresRSSIAcumulation floatValue] +
                                                       [measure floatValue]
                                                       ];
                            measureRSSIIndex++;
                        }
                    }
                        
                    NSNumber * measuresHeadingAcumulation = [NSNumber numberWithFloat:0.0];
                    NSInteger measureHeadingIndex = 0;
                    if (headingMeasures.count == 0) {
                        // Not evaluate
                    } else {
                        isHeadingMeasure = YES;
                        for (NSNumber * measure in headingMeasures) {
                            measuresHeadingAcumulation = [NSNumber numberWithFloat:
                                                          [measuresHeadingAcumulation floatValue] +
                                                          [measure floatValue]
                                                          ];
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
                    // (x_item, y_item) = (x_device, y_device) + (RSSI * cos(heading), RSSI * sen(heading)) in radians and meters
                    NSLog(isRSSIMeasure ? @"[INFO][RT] isRSSIMeasure = YES" : @"[INFO][RT] isRSSIMeasure = NO.");
                    NSLog(isHeadingMeasure ? @"[INFO][RT] isHeadingMeasure = YES" : @"[INFO][RT] isHeadingMeasure = NO.");
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
                        
                        NSLog(@"[INFO][RT] measurePosition.x: %.2f", [measurePosition.x floatValue]);
                        NSLog(@"[INFO][RT] measuresRSSIAverage.x: %.2f", [measuresRSSIAverage floatValue]);
                        NSLog(@"[INFO][RT] measuresHeadingAverage.x: %.2f", [measuresHeadingAverage floatValue]);
                        NSLog(@"[INFO][RT] cos(measuresHeadingAverage): %.2f", cos([measuresHeadingAverage doubleValue]));
                        
                        NSLog(@"[INFO][RT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                        NSLog(@"[INFO][RT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                        NSLog(@"[INFO][RT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                        
                        NSLog(@"[INFO][RT] locatedPosition: %@", locatedPosition);
                        NSLog(@"[INFO][RT] uuid: %@", uuid);
                        [locatedPositions setObject:locatedPosition forKey:uuid];
                    }
                    
                } else {
                    // No measures taken in that position; do nothing.
                }
            }
        }
        
    }
    
    // Aks canvas to refresh if positions were located
    if (locatedPositions.count > 0) {
        NSLog(@"[NOTI][LMR] Notification \"canvas/refresh\" posted.");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"canvas/refresh"
         object:nil];
    }
    
    // If not a rho theta type system
    if (
        [mode isModeKey:kModeRhoRhoLocating] ||
        [mode isModeKey:kModeRhoRhoModelling] ||
        [mode isModeKey:kModeThetaThetaModelling] ||
        [mode isModeKey:kModeThetaThetaLocating]
        
        ) {
        NSLog(@"[ERROR][RT] Rho theta type system called when in %@ mode.", [mode description]);
    }
    
    NSLog(@"[INFO][RT] Finish Radiolocating beacons.");
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
