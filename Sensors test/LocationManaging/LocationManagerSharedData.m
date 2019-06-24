//
//  LocationManagerSharedData.m
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "LocationManagerSharedData.h"

@implementation LocationManagerSharedData

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        measuresDic = [[NSMutableDictionary alloc] init];
        positionIdNumber = [NSNumber numberWithInt:0];
        uuidIdNumber = [NSNumber numberWithInt:0];
        measureIdNumber = [NSNumber numberWithInt:0];
        locatedIdNumber = [NSNumber numberWithInt:0];
    }
    return self;
}

/*!
 @method getMeasuresDic
 @discussion This method returns the NSDictionary with all the measures taken
 */
- (NSMutableDictionary *) getMeasuresDic {
    return measuresDic;
}

/*!
 @method inMeasuresDicSetMeasure:ofType:withUUID:atPosition:andWithState:
 @discussion This method saves in the NSDictionary with the measures information a new one; if the state MEASURING is not true, is saved the position without any measure.
 */
- (NSMutableDictionary *) getLocatedDic {
    return locatedDic;
}

- (void) inMeasuresDicSetMeasure:(NSNumber*)measure
                          ofType:(NSString*)type
                        withUUID:(NSString*)uuid
                      atPosition:(RDPosition*)measurePosition
                    andWithState:(BOOL)measuring
{
    
    // The schema of the measuresDic object is:
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
    
    // The 'measureDic', the innermost one, is always new.
    measureDic = [[NSMutableDictionary alloc] init];
    measureDic[@"type"] = type;
    measureDic[@"measure"] = measure;
    
    if (measuresDic.count == 0) {
        // First initialization
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap measureDic with another dictionary and an unique measure's identifier key
        measureDicDic = [[NSMutableDictionary alloc] init];
        if (measuring) {
            measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
            NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
            measureDicDic[measureId] = measureDic;
        } else {
            // saves nothing
        }
        
        // Create the 'uuidDic' dictionary
        uuidDic = [[NSMutableDictionary alloc] init];
        uuidDic[@"uuid"] = uuid;
        uuidDic[@"uuidMeasures"] = measureDicDic;
        
        // Wrap uuidDic with another dictionary and an unique uuid's identifier key
        uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
        NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
        uuidDicDic = [[NSMutableDictionary alloc] init];
        uuidDicDic[uuidId] = uuidDic;
        
        // Create the 'positionDic' dictionary
        positionDic = [[NSMutableDictionary alloc] init];
        positionDic[@"measurePosition"] = measurePosition;
        positionDic[@"positionRangeMeasures"] = uuidDicDic;
        
        // Set positionDic in the main dictionary 'measuresDic' with an unique position's identifier key
        positionIdNumber = [NSNumber numberWithInt:[positionIdNumber intValue] + 1];
        NSString * positionId = [@"measurePosition" stringByAppendingString:[positionIdNumber stringValue]];
        measuresDic[positionId] = positionDic;
        
    } else {
        // Find if already exists position and uuid and create it if not.
        // If a 'parent' dictionary exists, there will exist at least one 'child' dictionary, since they are created that way; there not will be [ if(dic.count == 0) ] checks
        
        // If position and UUID already exists, the measure is allocated there; if not, they will be created later.
        BOOL positionFound = NO;
        BOOL uuidFound = NO;
        // For each position already saved...
        NSArray *positionKeys = [measuresDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position...
            positionDic = [measuresDic objectForKey:positionKey];
            // ...and checks if the current position 'measurePosition' already exists comparing it with the saved ones.
            RDPosition *dicPosition = positionDic[@"measurePosition"];
            if ([dicPosition isEqualToRDPosition:measurePosition]) {
                positionFound = YES;
                
                // For each uuid already saved...
                uuidDicDic = positionDic[@"positionRangeMeasures"];
                NSArray *uuidKeys = [uuidDicDic allKeys];
                for (id uuidKey in uuidKeys) {
                    // ...get the dictionary for this uuid...
                    uuidDic = [uuidDicDic objectForKey:uuidKey];
                    // ...and checks if the uuid already exists.
                    if ([uuidDic[@"uuid"] isEqual:uuid]) {
                        uuidFound = YES;
                        
                        // If both position and uuid are found, set the 'measureDic' into 'measureDicDic' with an unique measure's identifier key.
                        measureDicDic = uuidDic[@"uuidMeasures"];
                        if (measuring) {
                            measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                            NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                            measureDicDic[measureId] = measureDic;
                        } else {
                            // saves nothing
                        }
                    }
                }
                // If only the UUID was not found, but te positions was found, create all the inner dictionaries.
                if (uuidFound == NO) {
                    // Compose the dictionary from the innermost to the outermost
                    // Wrap measureDic with another dictionary and an unique measure's identifier key
                    measureDicDic = [[NSMutableDictionary alloc] init];
                    if (measuring) {
                        measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                        NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                        measureDicDic[measureId] = measureDic;
                    } else {
                    }
                    
                    // Create the 'uuidDic' dictionary
                    uuidDic = [[NSMutableDictionary alloc] init];
                    uuidDic[@"uuid"] = uuid;
                    uuidDic[@"uuidMeasures"] = measureDicDic;
                    
                    // Allocate 'uuidDic' into 'uuidDicDic' with an unique uuid's identifier key
                    uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
                    NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
                    uuidDicDic[uuidId] = uuidDic;
                }
            }
        }
        
        // If both position and UUID was not found create all the inner dictionaries.
        if (positionFound == NO) {
            // Compose the dictionary from the innermost to the outermost
            // Wrap measureDic with another dictionary and an unique measure's identifier key
            measureDicDic = [[NSMutableDictionary alloc] init];
            if (measuring) {
                measureIdNumber = [NSNumber numberWithInt:[measureIdNumber intValue] + 1];
                NSString * measureId = [@"measure" stringByAppendingString:[measureIdNumber stringValue]];
                measureDicDic[measureId] = measureDic;
            } else {
                // saves nothing
            }
            
            // Create the 'uuidDic' dictionary
            uuidDic = [[NSMutableDictionary alloc] init];
            uuidDic[@"uuid"] = [NSString stringWithString:uuid];
            uuidDic[@"uuidMeasures"] = measureDicDic;
            
            // Wrap uuidDic with another dictionary and an unique uuid's identifier key
            uuidIdNumber = [NSNumber numberWithInt:[uuidIdNumber intValue] + 1];
            NSString * uuidId = [@"measureUuid" stringByAppendingString:[uuidIdNumber stringValue]];
            uuidDicDic = [[NSMutableDictionary alloc] init];
            uuidDicDic[uuidId] = uuidDic;
            
            // Create the 'positionDic' dictionary
            positionDic = [[NSMutableDictionary alloc] init];
            positionDic[@"measurePosition"] = measurePosition;
            positionDic[@"positionRangeMeasures"] = uuidDicDic;
            NSLog(@"[INFO][LM] New position saved in dictionary: (%.2f, %.2f)", [measurePosition.x floatValue], [measurePosition.y floatValue]);
            
            // Set positionDic in the main dictionary 'measuresDic' with an unique position's identifier key
            positionIdNumber = [NSNumber numberWithInt:[positionIdNumber intValue] + 1];
            NSString * positionId = [@"measurePosition" stringByAppendingString:[positionIdNumber stringValue]];
            measuresDic[positionId] = positionDic;
        }
    }
}

@end
