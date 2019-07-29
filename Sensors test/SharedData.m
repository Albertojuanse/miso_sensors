//
//  SharedData.m
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

//              // SESSION DATA //
//
// The schema of the sessionData collection is:
//
//  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (NSMutableDictionary *)type1;     //  metamodelDic
//   },
//   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
//     (···)
//   },
//   (···)
//  ]
//
//             // ITEMS DATA //
//
// The schema of the itemsData collection is:
//
//  [{ "type": @"beacon" | @"position";                      //  itemDic
//     "identifier": (NSString *)identifier1;
//
//     "uuid": (NSString *)uuid1;
//
//     "major": (NSString *)major1;
//     "minor": (NSString *)minor1;
//
//     "position": (RDPosition *)position1;
//
//     "type": (NSMutableDictionary *)metamodelDic1;       //  metamodelDic
//
//   },
//   { "type": @"beacon" | @"position";
//     "identifier": (NSString *)identifier2;
//     (···)
//   },
//   (···)
//  ]
//
//            // MEASURES DATA //
//
// The schema of the measuresData collection is:
//
//  [{ "position": (RDPosition *)position1;                  //  positionDic
//     "positionMeasures": [
//         { "uuid" : (NSString *)uuid1;                     //  uuidDic
//           "uuidMeasures": [
//             { "type" : (NSString *)type1;                 //  measuresDic
//               "measure": (NSNumber *)measure1;
//             },
//             (···)
//           ]
//         },
//         (···)
//     ]
//   },
//   { "position": (RDPosition *)position2;                  // positionDic
//     (···)
//   },
//   (···)
//  ]
//
//            // LOCATIONS DATA //
//
//
// The schema of the locationsData collection is:
//
//  [{ "locatedUUID": (NSString *)locatedUUID1;              //  locationDic
//     "locatedPosition": (RDPosition *)locatedPosition1;
//   },
//   (···)
// }
//
//            // METAMODEL DATA //
//
// The schema of typesData collection is
//
//  [ (MDType*)type1,
//    (···)
//  ]
//
//              // MODEL DATA //
//
// The schema of modelData collection is is
//
//  [{ "name": name1;                                        //  modelDic
//     "components": [
//         { "position": (RDPosition *)position1;
//           "type": (MDType *)type1;
//           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
//         },
//         { "position": (RDPosition *)position2;
//           (···)
//         },
//         (···)
//     ]
//   },
//   { "name": name2;                                        //  modelDic
//     (···)
//   },
//  ]
//

/*!
 @method init
 @discussion Constructor
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Colections of data
        sessionData = [[NSMutableArray alloc] init];
        itemsData = [[NSMutableArray alloc] init];
        measuresData = [[NSMutableArray alloc] init];
        locationsData = [[NSMutableArray alloc] init];
        metamodelData = [[NSMutableArray alloc] init];
        modelData = [[NSMutableArray alloc] init];
        
        // Identifiers generation variables
        sessionIdNumber = [NSNumber numberWithInt:0];
        itemsIdNumber = [NSNumber numberWithInt:0];
        measureIdNumber = [NSNumber numberWithInt:0];
        locationsIdNumber = [NSNumber numberWithInt:0];
        metamodelIdNumber = [NSNumber numberWithInt:0];
        modelIdNumber = [NSNumber numberWithInt:0];
        
    }
    return self;
}

#pragma mark - General methods

/*!
 @method reset
 @discussion Set every instance variable to null for ARC disposing and reallocate and init them.
 */
- (void) reset {
    
    // Colections of data
    sessionData = nil;
    itemsData = nil;
    measuresData = nil;
    locationsData = nil;
    metamodelData = nil;
    modelData = nil;
    
    // Identifiers generation variables
    sessionIdNumber = nil;
    itemsIdNumber = nil;
    measureIdNumber = nil;
    locationsIdNumber = nil;
    metamodelIdNumber = nil;
    modelIdNumber = nil;
    
    // Colections of data
    sessionData = [[NSMutableArray alloc] init];
    itemsData = [[NSMutableArray alloc] init];
    measuresData = [[NSMutableArray alloc] init];
    locationsData = [[NSMutableArray alloc] init];
    metamodelData = [[NSMutableArray alloc] init];
    modelData = [[NSMutableArray alloc] init];
    
    // Identifiers generation variables
    sessionIdNumber = [NSNumber numberWithInt:0];
    itemsIdNumber = [NSNumber numberWithInt:0];
    measureIdNumber = [NSNumber numberWithInt:0];
    locationsIdNumber = [NSNumber numberWithInt:0];
    metamodelIdNumber = [NSNumber numberWithInt:0];
    modelIdNumber = [NSNumber numberWithInt:0];
    
}

/*!
 @method resetInnerDictionaries
 @discussion Set every inner dictionary variable to null for ARC disposing.
 */
- (void) resetInnerDictionaries {
    sessionDic = nil;
    userDic = nil;
    itemDic = nil;
    positionDic = nil;
    measureDic = nil;
    locationDic = nil;
    metamodelDic = nil;
    modelDic = nil;
}

#pragma mark - General getters

/*!
 @method getSessionData
 @discussion This method returns the 'NSMutableArray' object with the information generated by the user in each use.
 */
- (NSMutableArray *)getSessionData
{
    return sessionData;
}

/*!
 @method getItemsData
 @discussion This method returns the 'NSMutableArray' object with the information of every position, beacon... submitted by the user.
 */
- (NSMutableArray *)getItemsData
{
    return itemsData;
}

/*!
 @method getMeasuresData
 @discussion This method returns the 'NSMutableArray' object with the measures taken.
 */
- (NSMutableArray *)getMeasuresData
{
    return measuresData;
}

/*!
 @method getLocationsData
 @discussion This method returns the 'NSMutableArray' object with the positions locted in space using location methods.
 */
- (NSMutableArray *)getLocationsData
{
    return locationsData;
}

/*!
 @method getMetamodelData
 @discussion This method returns the 'NSMutableArray' object with the the metamodeling types use.
 */
- (NSMutableArray *)getMetamodelData
{
    return metamodelData;
}

/*!
 @method getModelData
 @discussion This method returns the 'NSMutableArray' object with the models generated or imported.
 */
- (NSMutableArray *)getModelData
{
    return modelData;
}

#pragma mark - Session data specific getters
/*!
 @method fromSessionDataGetSessionWithUserDic:
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary*)userDic
{
    for (NSMutableDictionary * sessionDic in sessionData) {
        NSMutableDictionary * storedUserDic = dic[@"user"];
        if ([storedUserDic isEqualToDictionary:userDic]) {
            return sessionDic;
        }
    }
    return nil;
}

/*!
 @method fromSessionDataGetSessionWithUserName:
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString*)userName {
    for (NSMutableDictionary * sessionDic in sessionData) {
        NSMutableDictionary * storedUserDic = dic[@"user"];
        if ([storedUserDic[@"name"] isEqualToString:userName]) {
            return sessionDic;
        }
    }
    return nil;
}

/*!
 @method fromSessionDataGetKey:fromUserWithUserDic:
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (id)fromSessionDataGetKey:(NSString *)key
        fromUserWithUserDic:(NSMutableDictionary*)userDic
{
    NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserDic:userDic];
    // Can be null
    if (sessionDic) {
        return sessionDic[key];
    } else {
        return nil;
    }
}

/*!
 @method fromSessionDataGetKey:fromUserWithUserName:
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's name; if is not found, return nil.
 */
- (id)fromSessionDataGetKey:(NSString *)key
       fromUserWithUserName:(NSString*)userName
{
    NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUsername:userName];
    // Can be null
    if (sessionDic) {
        return sessionDic[key];
    } else {
        return nil;
    }
}

/*!
 @method fromSessionDataGetModeFromUserWithUserDic:
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary*)userDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserDic:userDic];
}

/*!
 @method fromSessionDataGetModeFromUserWithUserName:
 @discussion This method returns the mode from the session data collection given the user's name; if is not found, return nil.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString*)userName
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserName:userName];
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserDic:
 @discussion This method returns the item chosen by user from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserDic:userDic];
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserName:
 @discussion This method returns the item chosen by user from the session data collection given the user's name; if is not found, return nil.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString*)userName
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserName:userName];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserDic:
 @discussion This method returns the mode chosen by user from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic
{
    return [self fromSessionDataGetKey:@"modeChosenByUser" fromUserWithUserDic:userDic];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserName:
 @discussion This method returns the mode chosen by user from the session data collection given the user's name; if is not found, return nil.
 */
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString*)userName
{
    return [self fromSessionDataGetKey:@"modeChosenByUser" fromUserWithUserName:userName];
}

#pragma mark - Item data specific getters

- (NSMutableArray *)fromItemDataGetItems;

- (NSMutableArray *)fromMeasuresDataGetMeasures;
- (NSMutableArray *)fromMeasuresDataGetPositions;
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDs;
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDs;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromSourceUUID:(NSString*)uuid;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromTargetUUID:(NSString*)uuid;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                   andSourceUUID:(NSString*)uuid;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                   andTargetUUID:(NSString*)uuid;
- (NSNumber *)fromMeasuresDataGetMaxMeasureOfType:(NSString *)type;

- (NSMutableArray *)fromLocationsDataGetPositions;

- (NSMutableArray *)fromMetamodelDataGetTypes;

- (NSMutableArray *)fromModelDataGetModels;

// Specific setters
- (void) inSessionDataSetVariable:(id)variable;

- (void) inItemDataSetItem:(NSMutableDictionary*)item;

- (void) inMeasuresDataSetMeasure:(NSNumber*)measure
                           ofType:(NSString*)type
                   withSourceUUID:(NSString*)uuid
                       atPosition:(RDPosition*)positionp;
- (void) inMeasuresDataSetMeasure:(NSNumber*)measure
                           ofType:(NSString*)type
                   withTargetUUID:(NSString*)uuid
                       atPosition:(RDPosition*)positionp;

- (void) inLocationsDataSetPosition:(RDPosition*)position
                           fromUUID:(NSString*)locatedUUID;
- (void) inLocationsDataSetPosition:(RDPosition*)position
                             ofUUID:(NSString*)locatedUUID;

- (void) inMetamodelDataSetType:(MDType*)type;

- (void) inModelDataSetModel:(NSMutableDictionary*)model;

#pragma mark Measures getters

/*!
 @method getMeasuresDic
 @discussion This method returns the NSDictionary with all the measures taken
 */
- (NSMutableDictionary *) getMeasuresDic {
    return measuresDic;
}

/*!
 @method fromMeasuresDicGetPositions
 @discussion This method returns a 'NSMutableArray' object with all the positions where the measures were taken.
 */
- (NSMutableArray *) fromMeasuresDicGetPositions {
    NSArray * positionKeys = [measuresDic allKeys];
    NSMutableArray * measurePositions = [[NSMutableArray alloc] init];
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [measuresDic objectForKey:positionKey];
        // ...and the position.
        RDPosition * dicPosition = positionDic[@"measurePosition"];
        RDPosition * position = [[RDPosition alloc] init];
        position.x = dicPosition.x;
        position.y = dicPosition.y;
        position.z = dicPosition.z;
        [measurePositions addObject:position];
    }
    return measurePositions;
}

/*!
 @method fromMeasuresDicGetMaxMeasureOfType:
 @discussion This method returns a 'NSNumber' that contains the maximum of the measures taken.
 */
- (NSNumber *) fromMeasuresDicGetMaxMeasureOfType:(NSString *)type {
    NSNumber * maxMeasure = [NSNumber numberWithFloat:0.0];
    if (measuresDic.count == 0) {
        // Do nothing
    } else {
        // For every position where measures were taken...
        NSArray * positionKeys = [measuresDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position.
            positionDic = [measuresDic objectForKey:positionKey];
            
            // Get the the dictionary with the UUID's dictionaries...
            uuidDicDic = positionDic[@"positionMeasures"];
            // ...and for every UUID...
            NSArray * uuidKeys = [uuidDicDic allKeys];
            for (id uuidKey in uuidKeys) {
                // ...get the dictionary.
                uuidDic = [uuidDicDic objectForKey:uuidKey];
                
                // Get the the dictionary with the measures dictionaries...
                measureDicDic = uuidDic[@"uuidMeasures"];
                // ...and for every measure...
                NSArray * measuresKeys = [measureDicDic allKeys];
                for (id measureKey in measuresKeys) {
                    // ...get the dictionary for this measure...
                    measureDic = [measureDicDic objectForKey:measureKey];
                    // ...and the measure.
                    NSNumber * measure = [NSNumber numberWithFloat:[measureDic[@"measure"] floatValue]];
                    if ([measureDic[@"type"] isEqualToString:type]) {
                        if ([measure floatValue] > [maxMeasure floatValue]) {
                            maxMeasure = measure;
                        }
                    }
                }
            }
        }
    }
    return maxMeasure;
}

#pragma mark Measures setters

/*!
 @method inMeasuresDicSetMeasure:ofType:withUUID:atPosition:andWithState:
 @discussion This method saves in the NSDictionary with the measures information a new one; if the state MEASURING is not true, is saved the position without any measure.
 */
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
        positionDic[@"positionMeasures"] = uuidDicDic;
        
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
                uuidDicDic = positionDic[@"positionMeasures"];
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
            positionDic[@"positionMeasures"] = uuidDicDic;
            NSLog(@"[INFO][LM] New position saved in dictionary: (%.2f, %.2f)", [measurePosition.x floatValue], [measurePosition.y floatValue]);
            
            // Set positionDic in the main dictionary 'measuresDic' with an unique position's identifier key
            positionIdNumber = [NSNumber numberWithInt:[positionIdNumber intValue] + 1];
            NSString * positionId = [@"measurePosition" stringByAppendingString:[positionIdNumber stringValue]];
            measuresDic[positionId] = positionDic;
        }
    }
}

#pragma mark Located getters

/*!
 @method inMeasuresDicSetMeasure:ofType:withUUID:atPosition:andWithState:
 @discussion This method saves in the NSDictionary with the measures information a new one; if the state MEASURING is not true, is saved the position without any measure.
 */
- (NSMutableDictionary *) getLocatedDic {
    return locatedDic;
}

/*!
 @method fromLocatedDicGetPositions
 @discussion This method returns a 'NSMutableArray' object with all the positions where the measures were taken
 */
- (NSMutableArray *) fromLocatedDicGetPositions {
    NSArray * positionKeys = [locatedDic allKeys];
    NSMutableArray * locatedPositions = [[NSMutableArray alloc] init];
    for (id positionKey in positionKeys) {
        // ...get the dictionary for this position...
        positionDic = [measuresDic objectForKey:positionKey];
        // ...and the position.
        RDPosition * dicPosition = positionDic[@"locatedPosition"];
        RDPosition * position = [[RDPosition alloc] init];
        position.x = dicPosition.x;
        position.y = dicPosition.y;
        position.z = dicPosition.z;
        [locatedPositions addObject:position];
    }
    return locatedPositions;
}

#pragma mark Located setters

/*!
 @method inLocatedDicSetPosition:fromUUID:
 @discussion This method saves in the NSDictionary with the located positions information a new one.
 */
- (void) inLocatedDicSetPosition:(RDPosition*)locatedPosition
                        fromUUID:(NSString*)locatedUUID
{
    NSLog(@"[INFO][SD] Located positions to save:");
    NSLog(@"[INFO][SD]  -> Position %@", locatedPosition);
    NSLog(@"[INFO][SD]  -> from %@", locatedUUID);
    // The schema of the locatedDic object is:
    //
    // { "locatedPosition1":                              //  locatedDic
    //     { "locatedUUID": locatedUUID;                  //  positionDic
    //       "locatedPosition": locatedPosition;
    //     };
    //   "locatedPosition2": { (···) }
    // }
    //
    
    if (locatedDic.count == 0) {
        NSLog(@"[INFO][SD] locatedDic.count == 0 => YES");
        // First initialization
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap locatedPosition in a dictionary with its UUID
        positionDic = [[NSMutableDictionary alloc] init];
        positionDic[@"locatedPosition"] = locatedPosition;
        positionDic[@"locatedUUID"] = locatedUUID;
        
        // Set it into locatedDic
        locatedIdNumber = [NSNumber numberWithInt:[locatedIdNumber intValue] + 1];
        NSString * locatedId = [@"locatedPosition" stringByAppendingString:[measureIdNumber stringValue]];
        locatedDic[locatedId] = positionDic;
        
    } else {
        NSLog(@"[INFO][SD] locatedDic.count == 0 => NO");
        // A beacon only can exists in a position, hence no mobility solutions are considered
        
        // If UUID exists, position is actualized; if UUID does not exist, it will be created.
        // For each position already saved...
        BOOL UUIDfound = NO;
        NSArray *positionKeys = [locatedDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position...
            positionDic = [locatedDic objectForKey:positionKey];
            // ...and checks if the current UUID's locatedUUID already exists comparing it with the saved ones.
            NSString * savedUUID = positionDic[@"locatedUUID"];
            NSLog(@"[INFO][SD] UUID saved in %@ is %@", positionDic[@"locatedPosition"], savedUUID);
            if ([savedUUID isEqualToString:locatedUUID]) { // UUID already exists
                NSLog(@"[INFO][SD] UUID saved is equals to %@; upload to %@", locatedUUID, locatedPosition);
                positionDic[@"locatedPosition"] = locatedPosition;
                UUIDfound = YES;
            } else {
                
            }
        }
        
        // If UUID did not be found, create its dictionary
        if (!UUIDfound) {
            NSLog(@"[INFO][SD] UUID saved are not equals to %@; creating new dic", locatedUUID);
            // Wrap locatedPosition in a dictionary with its UUID
            NSMutableDictionary * newPositionDic = [[NSMutableDictionary alloc] init];
            newPositionDic[@"locatedPosition"] = locatedPosition;
            newPositionDic[@"locatedUUID"] = locatedUUID;
            
            // Set it into locatedDic
            locatedIdNumber = [NSNumber numberWithInt:[locatedIdNumber intValue] + 1];
            NSString * locatedId = [@"locatedPosition" stringByAppendingString:[measureIdNumber stringValue]];
            locatedDic[locatedId] = newPositionDic;
        }
    }
}

@end
