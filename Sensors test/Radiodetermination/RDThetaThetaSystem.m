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
    RDPosition * barycenter;
    if ([points count] > 0) {
        barycenter = [[RDPosition alloc] init];
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
    }
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
 @discussion This method ocates a point given the heading measures from different points aiming it and calculates the barycenter of the solutions; it uses direct angles measures, such as the compass ones, to locate the position with the efect of the North.
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
        NSLog(@"[INFO][TT] Locating mode");
    
        // In a locating mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the adding menu, and
        // - as the 'itemUUID' the UUID of the item chosen in the canvas.
        // A location will be found for each 'deviceUUID'
        
        // Also, in this system, the measures for each tuple (itemUUID, deviceUUID) will be found, averaged and saved as single new measures for doing the final calculus with all of them at the same time; ordering them is needed.
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSNumber * north = [sharedData fromSessionDataGetCurrentModelNorthWithUserDic:userDic withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * deviceUUID in allDeviceUUID) {
            NSLog(@"[INFO][TT] Evaluating device %@", deviceUUID);
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            
            // Create a collection for saving this new single new measures
            NSMutableArray * itemsDicWithMeasures = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * itemUUID in allItemUUID) {
                NSLog(@"[INFO][TT] ->Evaluating item %@", itemUUID);
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                NSLog(@"[INFO][TT] ->%tu measures found for both", [headingMeasures count]);
                
                // ...and for every measure compose a new measure with the mean value; the calculus will be done when every item has its own measure because they have to be ordered.
                if ([headingMeasures count] > 0) {

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
            }
                        
            NSMutableArray * deviceUUIDPositions = [[NSMutableArray alloc] init];
            
            // Evaluate feasibility
            //if (itemsDicWithMeasures.count > 2) { // 3D
            if (itemsDicWithMeasures.count > 1) { // 2D
                
                // Perform the calculus.
                NSLog(@"[INFO][TT] Final calculus.");
                // In this aproximate calculus, one of the trigonometrical equation got from the measures is solved with another one, this second with aother third, etc., in pairs, and then calculated the barycenter of the results. The selection criteria of this first, second, third... equations is to order from the lowest to the higest, and thus the dilution of precision is minimized; convergence problems appears if not.
                // Also, before solving the equations, the model is rotated to substract the North.
                // Angles measured by the compass are clockwise, while the cosine and sine definitions and usage are counter-clockwise; all measured angles must be inverted.
                
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
                
                // Clockwise angles to counter-clockwise angles reversion
                // and rotation from the north to the model 'north'
                
                NSMutableArray * rotatedItemsDic = [[NSMutableArray alloc] init];
                for (NSMutableDictionary * eachItemDic in sortedItemsDic) {
                    
                    NSMutableDictionary * newItemDic = [[NSMutableDictionary alloc] init];
                    
                    // Inversion
                    NSNumber * eachMeasure = eachItemDic[@"measure"];
                    newItemDic[@"measure"] = [NSNumber numberWithFloat:-[eachMeasure floatValue]];
                    
                    // Rotation
                    RDPosition * eachPosition = eachItemDic[@"postion"];
                    RDPosition * newPosition = [[RDPosition alloc] init];
                    newPosition.x = [NSNumber numberWithFloat:
                                     (cos([north floatValue])*[eachPosition.x floatValue] +
                                      sin([north floatValue])*[eachPosition.y floatValue])];
                    newPosition.y = [NSNumber numberWithFloat:
                                     (cos([north floatValue])*[eachPosition.y floatValue] -
                                      sin([north floatValue])*[eachPosition.x floatValue])];
                    newPosition.z = [NSNumber numberWithFloat:[newPosition.z floatValue]];
                    newItemDic[@"measure"] = newPosition;
                    
                    [rotatedItemsDic addObject:newItemDic];
                }
                
                NSNumber * lastHeading = nil;
                RDPosition * lastPosition = nil;
                
                for (NSUInteger m = 0; m < [sortedItemsDic count]; m++) {
                    
                    NSString * indexKey = [NSString stringWithFormat:@"%tu", m];
                    NSDictionary * eachItemDic = sortedItemsDic[indexKey];
                    
                    NSNumber * eachHeading = eachItemDic[@"measure"];
                    RDPosition * eachPosition = eachItemDic[@"position"];
                    
                    // The first one is saved.
                    if (m == 0) {
                        lastHeading = eachHeading;
                        lastPosition = eachPosition;
                        NSLog(@"[INFO][TT] First heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] First position %@", lastPosition);
                    } else {
                        
                        // The rest of iterations, the code executed is the following

                        
                        RDPosition * solution = [[RDPosition alloc] init];
                        solution.x = [NSNumber numberWithFloat:
                                      (
                                       ([lastPosition.y floatValue]-[lastPosition.x floatValue]*tan([lastHeading floatValue]))
                                       -
                                       ([eachPosition.y floatValue]-[eachPosition.x floatValue]*tan([eachHeading floatValue]))
                                       )
                                       /
                                       (-tan([lastHeading floatValue]) + -tan([eachHeading floatValue]))
                                      ];
                        solution.y = [NSNumber numberWithFloat:
                                      (
                                       ([lastPosition.y floatValue]-[lastPosition.x floatValue]*tan([lastHeading floatValue]))
                                       * tan([eachHeading floatValue])
                                       -
                                       ([eachPosition.y floatValue]-[eachPosition.x floatValue]*tan([eachHeading floatValue]))
                                       * tan([lastHeading floatValue])
                                       )
                                      /
                                      (-tan([lastHeading floatValue]) + -tan([eachHeading floatValue]))
                                      ];
                        // ARC disposing
                        lastPosition = nil;
                        lastPosition = eachPosition;
                        lastHeading = nil;
                        lastHeading = eachHeading;
                        
                        // TODO: Z coordinate. Alberto J. 2019/09/24.
                        solution.z = [NSNumber numberWithFloat:0.0];
                        
                        // Counter rotation
                        solution.x = [NSNumber numberWithFloat:
                                         (cos([north floatValue])*[solution.x floatValue] -
                                          sin([north floatValue])*[solution.y floatValue])];
                        solution.y = [NSNumber numberWithFloat:
                                         (cos([north floatValue])*[solution.y floatValue] +
                                          sin([north floatValue])*[solution.x floatValue])];
                        
                        NSLog(@"[INFO][TT] Solution %@", solution);
                        [deviceUUIDPositions addObject:solution];
                    }
                }
                
            }
            
            // Get the barycenter as an aproximation and save the result for this deviceUUID.
            RDPosition * deviceUUIDPosition = [self getBarycenterOf:deviceUUIDPositions];
            if (deviceUUIDPosition) {
                [locatedPositions setObject:deviceUUIDPosition forKey:deviceUUID];
            }
            
        }
    
    } else if ([mode isModeKey:kModeRhoThetaModelling]) {
        NSLog(@"[INFO][TT] Modelling mode");
        
        // In a modelling mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the canvas, and
        // - as the 'itemUUID' the UUID of the item chosen in the adding menu.
        // A location will be found for each 'itemUUID'
        
        // Also, in this system, the measures for each tuple (itemUUID, deviceUUID) will be found, averaged and saved as single new measures for doing the final calculus with all of them at the same time; ordering them is needed.
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSNumber * north = [sharedData fromSessionDataGetCurrentModelNorthWithUserDic:userDic withCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * itemUUID in allItemUUID) {
            NSLog(@"[INFO][TT] ->Evaluating item %@", itemUUID);
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            
            // Create a collection for saving this new single new measures
            NSMutableArray * itemsDicWithMeasures = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * deviceUUID in allDeviceUUID) {
                NSLog(@"[INFO][TT] Evaluating device %@", deviceUUID);
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                NSLog(@"[INFO][TT] ->%tu measures found for both", [headingMeasures count]);
                
                // ...and for every measure compose a new measure with the mean value; the calculus will be done when every item has its own measure because they have to be ordered.
                if ([headingMeasures count] > 0) {

                    NSNumber * measuresHeadingAverage = [self getMeanOf:headingMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:deviceUUID
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
            }
                        
            NSMutableArray * itemUUIDPositions = [[NSMutableArray alloc] init];
            
            // Evaluate feasibility
            //if (itemsDicWithMeasures.count > 2) { // 3D
            if (itemsDicWithMeasures.count > 1) { // 2D
                
                // Perform the calculus.
                NSLog(@"[INFO][TT] Final calculus.");
                // In this aproximate calculus, one of the trigonometrical equation got from the measures is solved with another one, this second with aother third, etc., in pairs, and then calculated the barycenter of the results. The selection criteria of this first, second, third... equations is to order from the lowest to the higest, and thus the dilution of precision is minimized; convergence problems appears if not.
                // Also, before solving the equations, the model is rotated to substract the North.
                // Angles measured by the compass are clockwise, while the cosine and sine definitions and usage are counter-clockwise; all measured angles must be inverted.
                
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
                
                // Clockwise angles to counter-clockwise angles reversion
                // and rotation from the north to the model 'north'
                
                NSMutableArray * rotatedItemsDic = [[NSMutableArray alloc] init];
                for (NSMutableDictionary * eachItemDic in sortedItemsDic) {
                    
                    NSMutableDictionary * newItemDic = [[NSMutableDictionary alloc] init];
                    
                    // Inversion
                    NSNumber * eachMeasure = eachItemDic[@"measure"];
                    newItemDic[@"measure"] = [NSNumber numberWithFloat:-[eachMeasure floatValue]];
                    
                    // Rotation
                    RDPosition * eachPosition = eachItemDic[@"postion"];
                    RDPosition * newPosition = [[RDPosition alloc] init];
                    newPosition.x = [NSNumber numberWithFloat:
                                     (cos([north floatValue])*[eachPosition.x floatValue] +
                                      sin([north floatValue])*[eachPosition.y floatValue])];
                    newPosition.y = [NSNumber numberWithFloat:
                                     (cos([north floatValue])*[eachPosition.y floatValue] -
                                      sin([north floatValue])*[eachPosition.x floatValue])];
                    newPosition.z = [NSNumber numberWithFloat:[newPosition.z floatValue]];
                    newItemDic[@"measure"] = newPosition;
                    
                    [rotatedItemsDic addObject:newItemDic];
                }
                
                NSNumber * lastHeading = nil;
                RDPosition * lastPosition = nil;
                
                for (NSUInteger m = 0; m < [sortedItemsDic count]; m++) {
                    
                    NSString * indexKey = [NSString stringWithFormat:@"%tu", m];
                    NSDictionary * eachItemDic = sortedItemsDic[indexKey];
                    
                    NSNumber * eachHeading = eachItemDic[@"measure"];
                    RDPosition * eachPosition = eachItemDic[@"position"];
                    
                    // The first one is saved.
                    if (m == 0) {
                        lastHeading = eachHeading;
                        lastPosition = eachPosition;
                        NSLog(@"[INFO][TT] First heading %.2f ", [eachHeading floatValue]);
                        NSLog(@"[INFO][TT] First position %@", lastPosition);
                    } else {
                        
                        // The rest of iterations, the code executed is the following

                        
                        RDPosition * solution = [[RDPosition alloc] init];
                        solution.x = [NSNumber numberWithFloat:
                                      (
                                       ([lastPosition.y floatValue]-[lastPosition.x floatValue]*tan([lastHeading floatValue]))
                                       -
                                       ([eachPosition.y floatValue]-[eachPosition.x floatValue]*tan([eachHeading floatValue]))
                                       )
                                       /
                                       (-tan([lastHeading floatValue]) + -tan([eachHeading floatValue]))
                                      ];
                        solution.y = [NSNumber numberWithFloat:
                                      (
                                       ([lastPosition.y floatValue]-[lastPosition.x floatValue]*tan([lastHeading floatValue]))
                                       * tan([eachHeading floatValue])
                                       -
                                       ([eachPosition.y floatValue]-[eachPosition.x floatValue]*tan([eachHeading floatValue]))
                                       * tan([lastHeading floatValue])
                                       )
                                      /
                                      (-tan([lastHeading floatValue]) + -tan([eachHeading floatValue]))
                                      ];
                        // ARC disposing
                        lastPosition = nil;
                        lastPosition = eachPosition;
                        lastHeading = nil;
                        lastHeading = eachHeading;
                        
                        // TODO: Z coordinate. Alberto J. 2019/09/24.
                        solution.z = [NSNumber numberWithFloat:0.0];
                        
                        // Counter rotation
                        solution.x = [NSNumber numberWithFloat:
                                         (cos([north floatValue])*[solution.x floatValue] -
                                          sin([north floatValue])*[solution.y floatValue])];
                        solution.y = [NSNumber numberWithFloat:
                                         (cos([north floatValue])*[solution.y floatValue] +
                                          sin([north floatValue])*[solution.x floatValue])];
                        
                        NSLog(@"[INFO][TT] Solution %@", solution);
                        [itemUUIDPositions addObject:solution];
                    }
                }
                
            }
            
            // Get the barycenter as an aproximation and save the result for this deviceUUID.
            RDPosition * itemUUIDPosition = [self getBarycenterOf:itemUUIDPositions];
            if (itemUUIDPosition) {
                [locatedPositions setObject:itemUUIDPosition forKey:itemUUID];
            }
            
        }
        
    } else {
        NSLog(@"[ERROR][TT] Instantiated theta-theta type system  when using %@ mode.", mode);
    }
    
    NSLog(@"[INFO][TT] Finish Radiolocating beacons.");
    
    return locatedPositions;
}

/*!
 @method getRelativeLocationsUsingBarycenterAproximationWithPrecisions:
 @discussion This method locates a point given the heading measures from different points aiming it and calculates the barycenter of the solutions; it uses swept angles measures, such as the gyroscope ones, to locate the position without the efect of the North.
 */
- (NSMutableDictionary *) getRelativeLocationsUsingBarycenterAproximationWithPrecisions:(NSDictionary *)precisions
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
        NSLog(@"[INFO][TT] Locating mode");
        
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
            NSLog(@"[INFO][TT] Evaluating device %@", deviceUUID);
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            
            // Create a collection for saving this new single new measures
            NSMutableArray * itemsDicWithMeasures = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * itemUUID in allItemUUID) {
                NSLog(@"[INFO][TT] ->Evaluating item %@", itemUUID);
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                NSLog(@"[INFO][TT] ->%tu measures found for both", [headingMeasures count]);
                
                // ...and for every measure compose a new measure with the mean value; the calculus will be done when every item has its own measure because they have to be ordered.
                if ([headingMeasures count] > 0) {

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
            if (deviceUUIDPosition) {
                [locatedPositions setObject:deviceUUIDPosition forKey:deviceUUID];
            }
            
        }
    
    } else if ([mode isModeKey:kModeRhoThetaModelling]) {
        NSLog(@"[INFO][TT] Modelling mode");
        
        // In a modelling mode the measures use
        // - as the 'deviceUUID' the UUID of the item chosen in the canvas, and
        // - as the 'itemUUID' the UUID of the item chosen in the adding menu.
        // A location will be found for each 'itemUUID'
        
                // Also, in this system, the measures for each tuple (itemUUID, deviceUUID) will be found, averaged and saved as single new measures for doing the final calculus with all of them at the same time; ordering them is needed.
        
        // Get all UUID from the measures
        NSMutableArray * allDeviceUUID = [sharedData fromMeasuresDataGetDeviceUUIDsWithCredentialsUserDic:credentialsUserDic];
        NSMutableArray * allItemUUID = [sharedData fromMeasuresDataGetItemUUIDsWithCredentialsUserDic:credentialsUserDic];
        
        // And thus, for every item that must be located...
        for (NSString * itemUUID in allItemUUID) {
            NSLog(@"[INFO][TT] ->Evaluating item %@", itemUUID);
            
            // Measures are only possible if measures were take from at least 3 positions with measures, what means, 3 tuples (itemUUID, deviceUUID) with the same 'deviceUUID' but different 'itemUUID'.
            
            // Create a collection for saving this new single new measures
            NSMutableArray * itemsDicWithMeasures = [[NSMutableArray alloc] init];
            
            // ...evaluate the diferent items that are measured...
            for (NSString * deviceUUID in allDeviceUUID) {
                NSLog(@"[INFO][TT] Evaluating device %@", deviceUUID);
                
                // ...and get every measure of the tuple (itemUUID, deviceUUID)
                NSMutableArray * headingMeasures = [sharedData fromMeasuresDataGetMeasuresOfDeviceUUID:deviceUUID
                                                                                          fromItemUUID:itemUUID
                                                                                                ofSort:@"heading"
                                                                                withCredentialsUserDic:credentialsUserDic];
                NSLog(@"[INFO][TT] ->%tu measures found for both", [headingMeasures count]);
                
                // ...and for every measure compose a new measure with the mean value; the calculus will be done when every item has its own measure because they have to be ordered.
                if ([headingMeasures count] > 0) {

                    NSNumber * measuresHeadingAverage = [self getMeanOf:headingMeasures];
                    
                    // Get the item position using its UUID
                    NSMutableArray * itemsMeasured = [sharedData fromItemDataGetItemsWithUUID:deviceUUID
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
            }
                        
            NSMutableArray * itemUUIDPositions = [[NSMutableArray alloc] init];
            
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
                        [itemUUIDPositions addObject:solution];
                    }
                }
                
            }
            
            // Get the barycenter as an aproximation and save the result for this deviceUUID.
            RDPosition * itemUUIDPosition = [self getBarycenterOf:itemUUIDPositions];
            if (itemUUIDPosition) {
                [locatedPositions setObject:itemUUIDPosition forKey:itemUUID];
            }
            
        }
        
    } else {
        NSLog(@"[ERROR][TT] Instantiated theta-theta type system  when using %@ mode.", mode);
    }
    
    NSLog(@"[INFO][TT] Finish Radiolocating beacons.");
    
    return locatedPositions;
}

@end
