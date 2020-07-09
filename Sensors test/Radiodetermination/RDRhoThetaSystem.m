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
    
    if ([mode isModeKey:kModeRhoThetaLocating]) {
        
        // In a locating mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the adding menu, and
        // - as the 'itemUUID' the UUID of the item chosen in the canvas.
        // A location will be found for each 'deviceUUID'
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * deviceUUID in allDeviceUUID) {
            
            NSMutableArray * deviceUUIDPositions = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * itemUUID in allItemUUID) {
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                       fromItemUUID:itemUUID
                                                                                             ofSort:@"correctedDistance"
                                                                             withCredentialsUserDic:credentialsUserDic];
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                
                // Measures are only possible if measures have both heading and rssi types.
                BOOL isHeadingMeasure = NO;
                BOOL isRSSIMeasure = NO;
                if (rssiMeasures.count > 0) {
                    isRSSIMeasure = YES;
                } else {
                    break;
                }
                if (headingMeasures.count > 0) {
                    isHeadingMeasure = YES;
                } else {
                    break;
                }
                //NSLog(isRSSIMeasure ? @"[INFO][RT] isRSSIMeasure = YES" : @"[INFO][RT] isRSSIMeasure = NO.");
                //NSLog(isHeadingMeasure ? @"[INFO][RT] isHeadingMeasure = YES" : @"[INFO][RT] isHeadingMeasure = NO.");
                
                // ...and for every measure do the calculations:
                // - calculate its mean average and
                // - calculate the location.
                // (x_device, y_device) = (x_item, y_item) - (RSSI * cos(heading), RSSI * sen(heading)) in radians and meters
                if (isRSSIMeasure && isHeadingMeasure) {
                    
                    NSNumber * measuresRSSIAverage = [self getMeanOf:rssiMeasures];
                    NSNumber * measuresHeadingAverage = [self getMeanOf:headingMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:itemUUID
                                                                        andCredentialsUserDic:credentialsUserDic];
                    if (itemsMeasured.count == 0) {
                        NSLog(@"[ERROR][RT] No items found with the itemUUID in measures.");
                        break;
                    }
                    if (itemsMeasured.count > 1) {
                        NSLog(@"[ERROR][RT] More than one items stored with the same UUID: using first one.");
                    }
                    NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                    RDPosition * itemPosition = itemMeasured[@"position"];
                    
                    if (itemPosition) {
                        // Perform the calculus
                        RDPosition * locatedPosition = [[RDPosition alloc] init];
                        locatedPosition.x = [NSNumber numberWithFloat:[itemPosition.x floatValue] -
                                             [measuresRSSIAverage floatValue] *
                                             cos([measuresHeadingAverage doubleValue])
                                             ];
                        locatedPosition.y = [NSNumber numberWithFloat:[itemPosition.y floatValue] -
                                             [measuresRSSIAverage floatValue] *
                                             sin([measuresHeadingAverage doubleValue])
                                             ];
                        // TODO: Z coordinate. Alberto J. 2019/09/24.
                        locatedPosition.z = itemPosition.z;
                    
                        // NSLog(@"[INFO][RT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                        // NSLog(@"[INFO][RT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                        // NSLog(@"[INFO][RT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                    
                        [deviceUUIDPositions addObject:locatedPosition];
                    } else {
                        NSLog(@"[ERROR][RT] The item measured has not got position estored.");
                    }
                }
                
                // Get the barycenter as an aproximation and save the result for this deviceUUID.
                RDPosition * deviceUUIDPosition = [self getBarycenterOf:deviceUUIDPositions];
                [locatedPositions setObject:deviceUUIDPosition forKey:deviceUUID];
                
            }
        }
        
    } else  if ([mode isModeKey:kModeRhoThetaModelling]) {
        
        // In a modelling mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the canvas, and
        // - as the 'itemUUID' the UUID of the item chosen in the adding menu.
        // A location will be found for each 'itemUUID'
        
        // Get all UUID from the measures
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * itemUUID in allItemUUID) {
            
            NSMutableArray * itemUUIDPositions = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * deviceUUID in allDeviceUUID) {
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * rssiMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                       fromItemUUID:itemUUID
                                                                                             ofSort:@"correctedDistance"
                                                                             withCredentialsUserDic:credentialsUserDic];
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                
                // Measures are only possible if measures have both heading and rssi types.
                BOOL isHeadingMeasure = NO;
                BOOL isRSSIMeasure = NO;
                if (rssiMeasures.count > 0) {
                    isRSSIMeasure = YES;
                } else {
                    break;
                }
                if (headingMeasures.count > 0) {
                    isHeadingMeasure = YES;
                } else {
                    break;
                }
                //NSLog(isRSSIMeasure ? @"[INFO][RT] isRSSIMeasure = YES" : @"[INFO][RT] isRSSIMeasure = NO.");
                //NSLog(isHeadingMeasure ? @"[INFO][RT] isHeadingMeasure = YES" : @"[INFO][RT] isHeadingMeasure = NO.");
                
                // ...and for every measure do the calculations:
                // - calculate its mean average and
                // - calculate the location.
                // (x_device, y_device) = (x_item, y_item) - (RSSI * cos(heading), RSSI * sen(heading)) in radians and meters
                if (isRSSIMeasure && isHeadingMeasure) {
                    
                    NSNumber * measuresRSSIAverage = [self getMeanOf:rssiMeasures];
                    NSNumber * measuresHeadingAverage = [self getMeanOf:headingMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:deviceUUID
                                                                        andCredentialsUserDic:credentialsUserDic];
                    if (itemsMeasured.count == 0) {
                        NSLog(@"[ERROR][RT] No items found with the deviceUUID in measures.");
                        break;
                    }
                    if (itemsMeasured.count > 1) {
                        NSLog(@"[ERROR][RT] More than one items stored with the same UUID: using first one.");
                    }
                    NSMutableDictionary * itemMeasured = [itemsMeasured objectAtIndex:0];
                    RDPosition * itemPosition = itemMeasured[@"position"];
                    
                    if (itemPosition) {
                        // Perform the calculus
                        RDPosition * locatedPosition = [[RDPosition alloc] init];
                        locatedPosition.x = [NSNumber numberWithFloat:[itemPosition.x floatValue] -
                                             [measuresRSSIAverage floatValue] *
                                             cos([measuresHeadingAverage doubleValue])
                                             ];
                        locatedPosition.y = [NSNumber numberWithFloat:[itemPosition.y floatValue] -
                                             [measuresRSSIAverage floatValue] *
                                             sin([measuresHeadingAverage doubleValue])
                                             ];
                        // TODO: Z coordinate. Alberto J. 2019/09/24.
                        locatedPosition.z = itemPosition.z;
                    
                        // NSLog(@"[INFO][RT] locatedPosition.x: %.2f", [locatedPosition.x floatValue]);
                        // NSLog(@"[INFO][RT] locatedPosition.y: %.2f", [locatedPosition.y floatValue]);
                        // NSLog(@"[INFO][RT] locatedPosition.z: %.2f", [locatedPosition.z floatValue]);
                    
                        [itemUUIDPositions addObject:locatedPosition];
                    } else {
                        NSLog(@"[ERROR][RT] The item measured has not got position estored.");
                    }
                }
                
                // Get the barycenter as an aproximation and save the result for this deviceUUID.
                RDPosition * itemUUIDPosition = [self getBarycenterOf:itemUUIDPositions];
                [locatedPositions setObject:itemUUIDPosition forKey:itemUUID];
                
            }
        }
         
    } else {
        NSLog(@"[ERROR][RT] Instantiated rho-theta type system  when using %@ mode.", mode);
    }
    
    NSLog(@"[INFO][RT] Finish Radiolocating beacons.");
    
    return locatedPositions;
}

@end
