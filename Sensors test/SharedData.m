//
//  SharedData.m
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

//                // USER DATA //
//
// The schema of the userData collection is:
//
//  [{ "name": (NSString *)name1;                  // userDic
//     "role": (NSString *)role1;
//   },
//   { "name": (NSString *)name2;                  // userDic
//     (···)
//   },
//   (···)
//  ]
//
//              // SESSION DATA //
//
// The schema of the sessionData collection is:
//
//  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (MDType*)type1
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
//  [{ "sort": @"beacon" | @"position";                      //  itemDic
//     "identifier": (NSString *)identifier1;
//
//     "uuid": (NSString *)uuid1;
//
//     "major": (NSString *)major1;
//     "minor": (NSString *)minor1;
//
//     "position": (RDPosition *)position1;
//
//     "type": (MDType*)type1
//
//   },
//   { "sort": @"beacon" | @"position";
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
//     "positionMeasures": [                                 //  uuidArray
//         { "uuid" : (NSString *)uuid1;                     //  uuidDic
//           "uuidMeasures": [                               //  measuresArray
//             { "sort" : (NSString *)type1;                 //  measuresDic
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
//         { "position": (RDPosition *)position1;            //  componentDic
//           "type": (MDType *)type1;
//           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
//           "references": [
//               { "position": (RDPosition *)positionA;      //  componentDic
//                 "type": (MDType *)typeA;
//                 "sourceItem": (NSMutableDictionary *)itemDicA;
//               },
//           ];
//         { "position": (RDPosition *)positionB;
//           (···)
//         },
//         (···)
//     ];
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
        userData = [[NSMutableArray alloc] init];
        sessionData = [[NSMutableArray alloc] init];
        itemsData = [[NSMutableArray alloc] init];
        measuresData = [[NSMutableArray alloc] init];
        locationsData = [[NSMutableArray alloc] init];
        metamodelData = [[NSMutableArray alloc] init];
        modelData = [[NSMutableArray alloc] init];
        
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
    userData = nil;
    sessionData = nil;
    itemsData = nil;
    measuresData = nil;
    locationsData = nil;
    metamodelData = nil;
    modelData = nil;
    
    // Colections of data
    userData = [[NSMutableArray alloc] init];
    sessionData = [[NSMutableArray alloc] init];
    itemsData = [[NSMutableArray alloc] init];
    measuresData = [[NSMutableArray alloc] init];
    locationsData = [[NSMutableArray alloc] init];
    metamodelData = [[NSMutableArray alloc] init];
    modelData = [[NSMutableArray alloc] init];
    
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
    uuidDic = nil;
    uuidArray = nil;
    measureDic = nil;
    measuresArray = nil;
    locationDic = nil;
    modelDic = nil;
}

#pragma mark - General getters

/*!
 @method getUserData
 @discussion This method returns the 'NSMutableArray' object  with the user's credentials.
 */
- (NSMutableArray *)getUserData
{
    return userData;
}

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

#pragma mark - User data specific getters
//                // USER DATA //
//
// The schema of the userData collection is:
//
//  [{ "name": (NSString *)name1;                  // userDic
//     "role": (NSString *)role1;
//   },
//   { "name": (NSString *)name2;                  // userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromUserDataGetUsedDicWithName:
 @discussion This method returns the 'NSMutableDictionary' object with the user credentials of the user described with its user name; if it is not found, return null.
 */
- (NSMutableDictionary *) fromUserDataGetUsedDicWithName:(NSString*)name
{
    for (userDic in userData) {
        if ([name isEqualToString:userDic[@"name"]]) {
            return userDic;
        }
    }
    return nil;
}

/*!
 @method validateUserDic:
 @discussion This method returns YES if the given dictionary with the user credentials is compliant; is there is not users in the collection, returns null.
 */
- (BOOL) validateUserDic:(NSMutableDictionary*)givenUserDic
{
    for (userDic in userData) {
        if ([givenUserDic isEqualToDictionary:userDic]) {
            return YES;
        } else {
            return NO;
        }
    }
    return nil;
}

#pragma mark - Session data specific getters
//              // SESSION DATA //
//
// The schema of the sessionData collection is:
//
//  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (MDType*)type1
//   },
//   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromSessionDataGetSessionWithUserDic:
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary*)givenUserDic
{
    for (sessionDic in sessionData) {
        NSMutableDictionary * storedUserDic = sessionDic[@"user"];
        if ([storedUserDic isEqualToDictionary:givenUserDic]) {
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
    for (sessionDic in sessionData) {
        NSMutableDictionary * storedUserDic = sessionDic[@"user"];
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
        fromUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic];
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
    NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserName:userName];
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
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserDic:givenUserDic];
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
 @method fromSessionDataGetStateFromUserWithUserDic:
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic];
}

/*!
 @method fromSessionDataGetStateFromUserWithUserName:
 @discussion This method returns the state from the session data collection given the user's name; if is not found, return nil.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserName:(NSString*)userName
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName];
}

/*!
 @method fromSessionDataIsMeasuringUserWithUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is measuring and returns YES if so.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic];
    if ([state isEqualToString:@"MEASURING"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataIsMeasuringUserWithUserName:
 @discussion This method checks in session data collection if the given user's name is measuring and returns YES if so.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserName:(NSString*)userName
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName];
    if ([state isEqualToString:@"MEASURING"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataIsIdleUserWithUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is idle and returns YES if so.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic];
    if ([state isEqualToString:@"IDLE"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataIsIdleUserWithUserName:
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserName:(NSString*)userName
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName];
    if ([state isEqualToString:@"IDLE"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataIsTravelingUserWithUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is traveling and returns YES if so.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic];
    if ([state isEqualToString:@"TRAVELING"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataIsTravelingUserWithUserName:
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserName:(NSString*)userName
{
    NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName];
    if ([state isEqualToString:@"TRAVELING"]) {
        return YES;
    } else {
        return NO;
    }
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserDic:
 @discussion This method returns the item chosen by user from the session data collection given the user's dictionary; if is not found, return nil.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserDic:givenUserDic];
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
//             // ITEMS DATA //
//
// The schema of the itemsData collection is:
//
//  [{ "sort": @"beacon" | @"position";                      //  itemDic
//     "identifier": (NSString *)identifier1;
//
//     "uuid": (NSString *)uuid1;
//
//     "major": (NSString *)major1;
//     "minor": (NSString *)minor1;
//
//     "position": (RDPosition *)position1;
//
//     "type": (MDType*)type1
//
//   },
//   { "type": @"beacon" | @"position";
//     "identifier": (NSString *)identifier2;
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromItemDataGetItemsWithSort:
 @discussion This method returns the 'NSMutableArray' with all item objects given its sort; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([itemDic[@"sort"] isEqualToString:sort]) {
            [items addObject:itemDic];
        }
    }
    return items;
}

/*!
 @method fromItemDataGetItemsWithIdentifier:
 @discussion This method returns the 'NSMutableArray' with all item objects given its identifier; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([itemDic[@"identifier"] isEqualToString:identifier]) {
            [items addObject:itemDic];
        }
    }
    return items;
}

/*!
 @method fromItemDataGetItemsWithUUID:
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([itemDic[@"uuid"] isEqualToString:uuid]) {
            [items addObject:itemDic];
        }
    }
    return items;
}

/*!
 @method fromItemDataGetItemsWithUUID:major:andMinor
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID, major and minor values; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                        andMinor:(NSString *)minor
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([itemDic[@"uuid"] isEqualToString:uuid]) {
            if ([itemDic[@"minor"] isEqualToString:minor]) {
                if ([itemDic[@"major"] isEqualToString:major]) {
                    [items addObject:itemDic];
                }
            }
        }
    }
    return items;
}

/*!
 @method fromItemDataGetItemsWithPosition:
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([position isEqualToRDPosition:itemDic[@"position"]]) {
            [items addObject:itemDic];
        }
    }
    return items;
}

/*!
 @method fromItemDataGetItemsWithType:
 @discussion This method returns the 'NSMutableArray' with all item objects given its 'MDType'; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type
{
    NSMutableArray * items = [[NSMutableArray alloc] init];
    for (itemDic in itemsData) {
        if ([type isEqualToMDType:itemDic[@"type"]]) {
            [items addObject:itemDic];
        }
    }
    return items;
}

#pragma mark - Measures data specific getters
//            // MEASURES DATA //
//
// The schema of the measuresData collection is:
//
//  [{ "position": (RDPosition *)position1;                  //  positionDic
//     "positionMeasures": [                                 //  uuidArray
//         { "uuid" : (NSString *)uuid1;                     //  uuidDic
//           "uuidMeasures": [                               //  measuresArray
//             { "sort" : (NSString *)type1;                 //  measuresDic
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

/*!
 @method fromMeasuresDataGetPositionDics
 @discussion This method returns the 'NSMutableArray' with all positions dictionaries; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetPositionDics
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (positionDic in measuresData) {
        [positions addObject:positionDic];
    }
    return positions;
}

/*!
 @method fromMeasuresDataGetPositions
 @discussion This method returns the 'NSMutableArray' with all positions 'RDPositions'; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetPositions
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (positionDic in measuresData) {
        [positions addObject:positionDic[@"position"]];
    }
    return positions;
}

/*!
 @method fromMeasuresDataGetSourceUUIDDics
 @discussion This method returns the 'NSMutableArray' with all UUID dictionaries; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDDics
{
    // Allocate and init an array for saving the different found UUIDs
    NSMutableArray * uuids = [[NSMutableArray alloc] init];
    
    // Inspect every position dictionary...
    for (positionDic in measuresData) {
        
        // ...and get its UUIDs...
        uuidArray = positionDic[@"positionMeasures"];
        for (uuidDic in uuidArray) {
            NSString * uuid = uuidDic[@"uuid"];
            
            // ...but before save it check if it is already saved.
            BOOL uuidFound = NO;
            for (NSMutableDictionary * savedUuidDic in uuids) {
                if ([uuid isEqualToString:savedUuidDic[@"uuid"]]) {
                    uuidFound = YES;
                }
            }
            if (!uuidFound) {
                [uuids addObject:uuidDic];
            }
        }
    }
    return uuids;
}

/*!
 @method fromMeasuresDataGetSourceUUIDs
 @discussion This method returns the 'NSMutableArray' with all UUID; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDs
{
    // Allocate and init an array for saving the different found UUIDs
    NSMutableArray * uuids = [[NSMutableArray alloc] init];
    
    // Inspect every position dictionary...
    for (positionDic in measuresData) {
        
        // ...and get its UUIDs...
        uuidArray = positionDic[@"positionMeasures"];
        for (uuidDic in uuidArray) {
            NSString * uuid = uuidDic[@"uuid"];
            
            // ...but before save it check if it is already saved.
            BOOL uuidFound = NO;
            for (NSMutableDictionary * savedUuidDic in uuids) {
                if ([uuid isEqualToString:savedUuidDic[@"uuid"]]) {
                    uuidFound = YES;
                }
            }
            if (!uuidFound) {
                [uuids addObject:uuidDic[@"uuid"]];
            }
        }
    }
    return uuids;
}

/*!
 @method fromMeasuresDataGetTargetUUIDDics
 @discussion This method returns the 'NSMutableArray' with all UUID dictionaries; if it does not exist anyone returns an empty array.
 */
// Exists two different ways of name UUIDs just for semantic issues and to ease the developing.
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDDics
{
    return [self fromMeasuresDataGetSourceUUIDDics];
}

/*!
 @method fromMeasuresDataGetTargetUUIDs
 @discussion This method returns the 'NSMutableArray' with all UUID; if it does not exist anyone returns an empty array.
 */
// Exists two different ways of name UUIDs just for semantic issues and to ease the developing.
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDs
{
    return [self fromMeasuresDataGetSourceUUIDs];
}

/*!
 @method fromMeasuresDataGetMeasureDicsTakenFromPosition:fromUUIDSource:andOfSort:
 @discussion This method returns the 'NSMutableArray' with all measure dictionaries taken from a 'RDPosition' from a given UUID and of a given sort; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                     fromUUIDSource:(NSString *)uuid
                                                          andOfSort:(NSString*)sort
{
    
    // Allocate and init an array for saving the different found measures
    NSMutableArray * measures = [[NSMutableArray alloc] init];
    
    // Inspect every position dictionary...
    for (positionDic in measuresData) {
        
        // ..and find the searched one...
        if ([position isEqualToRDPosition:positionDic[@"position"]]) {
            
            // ...if found, get its UUIDs...
            uuidArray = positionDic[@"positionMeasures"];
            for (uuidDic in uuidArray) {
                
                // ...and find the seacheUUID;...
                if ([uuid isEqualToString:uuidDic[@"uuid"]]) {
                    
                    // ...if found, for every measure, check the sort, and save it.
                    measuresArray = uuidDic[@"uuidMeasures"];
                    for (measureDic in measuresArray) {
                        if ([sort isEqualToString:measureDic[@"sort"]]) {
                            [measures addObject:measureDic];
                        }
                    }
                }
            }
        }
    }
    return measures;
}

/*!
 @method fromMeasuresDataGetMeasuresTakenFromPosition:fromUUIDSource:andOfSort:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' from a given UUID and of a given sort; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                  fromUUIDSource:(NSString *)uuid
                                                       andOfSort:(NSString*)sort
{
    
    // Allocate and init an array for saving the different found measures
    NSMutableArray * measures = [[NSMutableArray alloc] init];
    
    // Inspect every position dictionary...
    for (positionDic in measuresData) {
        
        // ..and find the searched one...
        if ([position isEqualToRDPosition:positionDic[@"position"]]) {
            
            // ...if found, get its UUIDs...
            uuidArray = positionDic[@"positionMeasures"];
            for (uuidDic in uuidArray) {
                
                // ...and find the seacheUUID;...
                if ([uuid isEqualToString:uuidDic[@"uuid"]]) {
                    
                    // ...if found, for every measure, check the sort, and save it.
                    measuresArray = uuidDic[@"uuidMeasures"];
                    for (measureDic in measuresArray) {
                        if ([sort isEqualToString:measureDic[@"sort"]]) {
                            [measures addObject:measureDic[@"measure"]];
                        }
                    }
                }
            }
        }
    }
    return measures;
}

/*!
 @method fromMeasuresDataGetMeasureDicsTakenFromPosition:ofUUIDTarget:andOfSort:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' of a given UUID and of a given sort; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                       ofUUIDTarget:(NSString *)uuid
                                                          andOfSort:(NSString*)sort
{
    return [self fromMeasuresDataGetMeasureDicsTakenFromPosition:position
                                                  fromUUIDSource:uuid
                                                       andOfSort:sort];
}

/*!
 @method fromMeasuresDataGetMeasuresTakenFromPosition:ofUUIDTarget:andOfSort:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' of a given UUID and of a given sort; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                    ofUUIDTarget:(NSString *)uuid
                                                       andOfSort:(NSString*)sort
{
    return [self fromMeasuresDataGetMeasuresTakenFromPosition:position
                                               fromUUIDSource:uuid
                                                    andOfSort:sort];
}

/*!
 @method fromMeasuresDataGetMaxMeasureOfSort:
 @discussion This method returns a 'NSNumber' that contains the maximum of the measures taken.
 */
- (NSNumber *) fromMeasuresDataGetMaxMeasureOfSort:(NSString *)sort {
    NSNumber * maxMeasure = [NSNumber numberWithFloat:0.0];
    if (measuresData.count == 0) {
        // Do nothing
    } else {
        // For every position where measures were taken...
        for (positionDic in measuresData) {
            
            // ...get the UUID's dictionaries...
            uuidArray = positionDic[@"positionMeasures"];
            // ...and for every UUID...
            for (uuidDic in uuidArray) {
                
                // get the the measures dictionaries...
                measuresArray = uuidDic[@"uuidMeasures"];
                // ...and for every measure...
                for (measureDic in measuresArray) {
                    
                    // ...check it.
                    NSNumber * measure = [NSNumber numberWithFloat:[measureDic[@"measure"] floatValue]];
                    if ([sort isEqualToString:measureDic[@"sort"]]) {
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

#pragma mark - Locations data specific getters
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

/*!
 @method fromLocationsDataGetPositionDics
 @discussion This method returns the 'NSMutableArray' with all located positions dictionaries stored; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromLocationsDataGetPositionDics
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (locationDic in locationsData) {
        [positions addObject:locationDic];
    }
    return positions;
}

/*!
 @method fromLocationsDataGetPositions
 @discussion This method returns the 'NSMutableArray' with all located positions 'RDPosition' stored; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromLocationsDataGetPositions
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (locationDic in locationsData) {
        [positions addObject:locationDic[@"locatedPosition"]];
    }
    return positions;
}

/*!
 @method fromLocationsDataGetPositionDicsOfUUID:
 @discussion This method returns the 'NSMutableArray' with all located positions dictionaries stored given their UUID; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromLocationsDataGetPositionDicsOfUUID:(NSString*)uuid
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (locationDic in locationsData) {
        if ([uuid isEqualToString:locationDic[@"locatedUUID"]]){
            [positions addObject:locationDic];
        }
    }
    return positions;
}

/*!
 @method fromLocationsDataGetPositionsOfUUID:
 @discussion This method returns the 'NSMutableArray' with all located positions 'RDPosition' stored given their UUID; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromLocationsDataGetPositionsOfUUID:(NSString*)uuid
{
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (locationDic in locationsData) {
        if ([uuid isEqualToString:locationDic[@"locatedUUID"]]){
            [positions addObject:locationDic[@"locatedPosition"]];
        }
    }
    return positions;
}

#pragma mark - Metamodel data specific getters
//            // METAMODEL DATA //
//
// The schema of typesData collection is
//
//  [ (MDType *)type1,
//    (···)
//  ]
//

/*!
 @method fromMetamodelDataGetTypes
 @discussion This method returns the 'NSMutableArray' with all 'MDTypes' stored; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMetamodelDataGetTypes
{
    NSMutableArray * metamodel = [[NSMutableArray alloc] init];
    for (MDType * type in metamodelData) {
        [metamodel addObject:type];
    }
    return metamodel;
}

#pragma mark - Model data specific getters
//              // MODEL DATA //
//
// The schema of modelData collection is is
//
//  [{ "name": name1;                                        //  modelDic
//     "components": [
//         { "position": (RDPosition *)position1;            //  componentDic
//           "type": (MDType *)type1;
//           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
//           "references": [
//               { "position": (RDPosition *)positionA;      //  componentDic
//                 "type": (MDType *)typeA;
//                 "sourceItem": (NSMutableDictionary *)itemDicA;
//               },
//           ];
//         { "position": (RDPosition *)positionB;
//           (···)
//         },
//         (···)
//     ];
//   },
//   { "name": name2;                                        //  modelDic
//     (···)
//   },
//  ]
//

/*!
 @method fromMetamodelDataGetModelDics
 @discussion This method returns the 'NSMutableArray' with all models dictionaries stored; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDics
{
    NSMutableArray * models = [[NSMutableArray alloc] init];
    for (modelDic in modelData) {
        [models addObject:modelDic];
    }
    return models;
}

/*!
 @method fromMetamodelDataGetModelDicWithName:
 @discussion This method returns the 'NSMutableArray' with the models whose name is the given one; if it does not exist anyone returns an empty array.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString*)name
{
    NSMutableArray * models = [[NSMutableArray alloc] init];
    for (modelDic in modelData) {
        if ([name isEqualToString:modelDic[@"name"]]) {
            [models addObject:modelDic];
        }
    }
    return models;
}

#pragma mark - User data specific setters
//                // USER DATA //
//
// The schema of the userData collection is:
//
//  [{ "name": (NSString *)name1;                  // userDic
//     "role": (NSString *)role1;
//   },
//   { "name": (NSString *)name2;                  // userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method inUserDataSetUsedDic:
 @discussion This method sets in the user data collection a new user credentials dictionary; if its name already exists, its information is replaced.
 */
- (void) inUserDataSetUsedDic:(NSMutableDictionary*)givenUserDic
{
    [self inUserDataSetUsedDicWithName:givenUserDic[@"name"] andRole:givenUserDic[@"role"]];
}

/*!
 @method inUserDataSetUsedDicWithName:andRol:
 @discussion This method sets in the user data collection a new user credentials dictionary given its information; if its name already exists, its information is replaced.
 */
- (void) inUserDataSetUsedDicWithName:(NSString*)name
                              andRole:(NSString*)role
{
    // If name exists, user is actualized; if name does not exist, the whole dictionary is created.
    // For each user already saved...
    BOOL userFound = NO;
    for (userDic in userData) {
        
        // ...check if the current name already exists comparing it with the saved ones.
        NSString * savedName = userDic[@"name"];
        if ([name isEqualToString:savedName]) { // Name already exists
            userDic[@"role"] = role;
            userFound = YES;
        } else {
            // Do not upload the user
        }
    }
    
    // If name did not be found, create its dictionary
    if (!userFound) {
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap components collection in a dictionary with its name
        userDic = [[NSMutableDictionary alloc] init];
        userDic[@"name"] = name;
        userDic[@"role"] = role;
        
        // Set it into locatedDic
        [userData addObject:userDic];
    }
}

#pragma mark - Session data specific setters
//              // SESSION DATA //
//
// The schema of the sessionData collection is:
//
//  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (MDType*)type1
//   },
//   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:
 @discussion This method sets in session data collection the state measuring to the given user's dictionary.
 */
- (void)inSessionDataSetMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic];
    [userDic setObject:@"MEASURING" forKey:@"state"];
    return;
}

/*!
 @method inSessionDataSetMeasuringUserWithUserName:
 @discussion This method sets in session data collection the state measuring to the given user's name.
 */
- (void)inSessionDataSetMeasuringUserWithUserName:(NSString*)userName
{
    userDic = [self fromSessionDataGetSessionWithUserName:userName];
    [userDic setObject:@"MEASURING" forKey:@"state"];
    return;
    
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:
 @discussion This method sets in session data collection the state idle to the given user's dictionary.
 */
- (void)inSessionDataSetIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic];
    [userDic setObject:@"IDLE" forKey:@"state"];
    return;
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:
 @discussion This method sets in session data collection the state idle to the given user's name.
 */
- (void)inSessionDataSetIdleUserWithUserName:(NSString*)userName
{
    userDic = [self fromSessionDataGetSessionWithUserName:userName];
    [userDic setObject:@"IDLE" forKey:@"state"];
    return;
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's dictionary.
 */
- (void)inSessionDataSetTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
{
    userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic];
    [userDic setObject:@"TRAVELING" forKey:@"state"];
    return;
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's name.
 */
- (void)inSessionDataSetTravelingUserWithUserName:(NSString*)userName
{
    userDic = [self fromSessionDataGetSessionWithUserName:userName];
    [userDic setObject:@"TRAVELING" forKey:@"state"];
    return;
}

#pragma mark - Item data specific setters
//             // ITEMS DATA //
//
// The schema of the itemsData collection is:
//
//  [{ "sort": @"beacon" | @"position";                      //  itemDic
//     "identifier": (NSString *)identifier1;
//
//     "uuid": (NSString *)uuid1;
//
//     "major": (NSString *)major1;
//     "minor": (NSString *)minor1;
//
//     "position": (RDPosition *)position1;
//
//     "type": (MDType*)type1
//
//   },
//   { "type": @"beacon" | @"position";
//     "identifier": (NSString *)identifier2;
//     (···)
//   },
//   (···)
//  ]
//

#pragma mark - Measures data specific setters
//            // MEASURES DATA //
//
// The schema of the measuresData collection is:
//
//  [{ "position": (RDPosition *)position1;                  //  positionDic
//     "positionMeasures": [                                 //  uuidArray
//         { "uuid" : (NSString *)uuid1;                     //  uuidDic
//           "uuidMeasures": [                               //  measuresArray
//             { "sort" : (NSString *)type1;                 //  measuresDic
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

/*!
 @method inMeasuresDataSetMeasure:ofSort:withUUID:atPosition:andWithUserDic:
 @discussion This method saves in the measures data collection a new one; if the state MEASURING is not true for the given user credentials 'userDic', is saved only the position but no measure.
 */
- (void) inMeasuresDataSetMeasure:(NSNumber*)measure
                           ofSort:(NSString*)sort
                         withUUID:(NSString*)uuid
                       atPosition:(RDPosition*)position
                   andWithUserDic:(NSMutableDictionary*)givenUserDic
{
    
    // TO DO: Get measuring state directly from this database. Alberto J. 2019/07/31.
    
    // The 'measureDic', the innermost one, is always new.
    measureDic = [[NSMutableDictionary alloc] init];
    measureDic[@"sort"] = sort;
    measureDic[@"measure"] = measure;
    
    if (measuresData.count == 0) {
        // First initialization
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap measureDic with an array
        measuresArray = [[NSMutableArray alloc] init];
        if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic]) {
            [measuresArray addObject:measureDic];
        } else {
            // saves nothing
        }
        
        // Create the 'uuidDic' dictionary
        uuidDic = [[NSMutableDictionary alloc] init];
        uuidDic[@"uuid"] = uuid;
        uuidDic[@"uuidMeasures"] = measuresArray;
        
        // Wrap uuidDic with an array
        uuidArray = [[NSMutableArray alloc] init];
        [uuidArray addObject:uuidDic];
        
        // Create the 'positionDic' dictionary
        positionDic = [[NSMutableDictionary alloc] init];
        positionDic[@"position"] = position;
        positionDic[@"positionMeasures"] = uuidArray;
        
        // Add the position to the main collection
        [measuresData addObject:positionDic];
        
    } else {
        // Find if already exists position and uuid and create it if not.
        // If a 'parent' dictionary exists, there will exist at least one 'child' dictionary, since they are created that way; there not will be [ if(dic.count == 0) ] checks
        
        // If position and UUID already exists, the measure is allocated there; if not, they will be created later.
        BOOL positionFound = NO;
        BOOL uuidFound = NO;
        // For each position already saved...
        for (positionDic in measuresData) {
            
            // ...check if the current position 'measurePosition' already exists comparing it with the saved ones.
            if ([position isEqualToRDPosition:positionDic[@"position"]]) {
                positionFound = YES;
                
                // For each uuid already saved...
                uuidArray = positionDic[@"positionMeasures"];
                for (uuidDic in uuidArray) {
                    // ... checks if the uuid already exists.
                    if ([uuid isEqualToString:uuidDic[@"uuid"]]) {
                        uuidFound = YES;
                        
                        // If both position and uuid are found, set the 'measureDic' into 'measuresArray' with an unique measure's identifier key.
                        measuresArray = uuidDic[@"uuidMeasures"];
                        if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic]) { // Only save if in state measuring
                            [measuresArray addObject:measureDic];
                        } else {
                            // saves nothing
                        }
                    }
                }
                
                // If only the UUID was not found, but te positions was found, create all the inner dictionaries.
                if (!uuidFound) {
                    // Compose the dictionary from the innermost to the outermost
                    
                    
                    // Wrap measureDic with an array
                    measuresArray = [[NSMutableArray alloc] init];
                    if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic]) {
                        [measuresArray addObject:measureDic];
                    } else {
                        // saves nothing
                    }
                    
                    // Create the 'uuidDic' dictionary
                    uuidDic = [[NSMutableDictionary alloc] init];
                    uuidDic[@"uuid"] = uuid;
                    uuidDic[@"uuidMeasures"] = measuresArray;
                    
                    // Get the collection of UUID and add the new one
                    uuidArray = positionDic[@"positionMeasures"];
                    [uuidArray addObject:uuidDic];
                }
            }
        }
        
        // If both position and UUID was not found create all the inner dictionaries.
        if (!positionFound) {
            // Compose the dictionary from the innermost to the outermost
            
            
            // Compose the dictionary from the innermost to the outermost
            // Wrap measureDic with an array
            measuresArray = [[NSMutableArray alloc] init];
            if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic]) {
                [measuresArray addObject:measureDic];
            } else {
                // saves nothing
            }
            
            // Create the 'uuidDic' dictionary
            uuidDic = [[NSMutableDictionary alloc] init];
            uuidDic[@"uuid"] = uuid;
            uuidDic[@"uuidMeasures"] = measuresArray;
            
            // Wrap uuidDic with an array
            uuidArray = [[NSMutableArray alloc] init];
            [uuidArray addObject:uuidDic];
            
            // Create the 'positionDic' dictionary
            positionDic = [[NSMutableDictionary alloc] init];
            positionDic[@"position"] = position;
            positionDic[@"positionMeasures"] = uuidArray;
            
            // Add the position to the main collection
            [measuresData addObject:positionDic];
        }
    }
}

#pragma mark - Locations data specific setters
//            // LOCATIONS DATA //
//
// The schema of the locationsData collection is:
//
//  [{ "locatedUUID": (NSString *)locatedUUID1;              //  locationDic
//     "locatedPosition": (RDPosition *)locatedPosition1;
//   },
//   (···)
// }
//

/*!
 @method inLocationsDataSetPosition:fromUUIDSource:andWithUserDic:
 @discussion This method saves in the NSDictionary with the located positions information a new one.
 */
- (void) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                     fromUUIDSource:(NSString *)uuid
                     andWithUserDic:(NSMutableDictionary*)givenUserDic
{
    if (locationsData.count == 0) {
        // First initialization
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap locatedPosition in a dictionary with its UUID
        locationDic = [[NSMutableDictionary alloc] init];
        locationDic[@"locatedPosition"] = locatedPosition;
        locationDic[@"locatedUUID"] = uuid;
        
        // Set it into locatedDic
        [locationsData addObject:locationDic];
        
    } else {
        // A beacon only can exists in a position, hence no mobility solutions are considered
        
        // If UUID exists, position is actualized; if UUID does not exist, it will be created.
        // For each position already saved...
        BOOL UUIDfound = NO;
        for (locationDic in locationsData) {
            // ...check if the current UUID's locatedUUID already exists comparing it with the saved ones.
            
            NSString * savedUUID = positionDic[@"locatedUUID"];
            if ([uuid isEqualToString:savedUUID]) { // UUID already exists
                positionDic[@"locatedPosition"] = locatedPosition;
                UUIDfound = YES;
            } else {
                // Do not upload the position
            }
            
        }
        
        // If UUID did not be found, create its dictionary
        if (!UUIDfound) {
            
            // Compose the dictionary from the innermost to the outermost
            // Wrap locatedPosition in a dictionary with its UUID
            locationDic = [[NSMutableDictionary alloc] init];
            locationDic[@"locatedPosition"] = locatedPosition;
            locationDic[@"locatedUUID"] = uuid;
            
            // Set it into locatedDic
            [locationsData addObject:locationDic];
        }
    }
}

/*!
 @method inLocationsDataSetPosition:ofUUIDTarget:andWithUserDic:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one.
 */
- (void) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                       ofUUIDTarget:(NSString *)uuid
                     andWithUserDic:(NSMutableDictionary*)givenUserDic
{
    [self inLocationsDataSetPosition:locatedPosition
                      fromUUIDSource:uuid
                      andWithUserDic:givenUserDic];
}

#pragma mark - Metamodel data specific setters
//            // METAMODEL DATA //
//
// The schema of typesData collection is
//
//  [ (MDType *)type1,
//    (···)
//  ]
//

/*!
 @method inMetamodelDataAddType:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one.
 */
- (void) inMetamodelDataAddType:(MDType*)type
{
    [metamodelData addObject:type];
}

#pragma mark - Model data specific setters
//              // MODEL DATA //
//
// The schema of modelData collection is is
//
//  [{ "name": name1;                                        //  modelDic
//     "components": [
//         { "position": (RDPosition *)position1;            //  componentDic
//           "type": (MDType *)type1;
//           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
//           "references": [
//               { "position": (RDPosition *)positionA;      //  componentDic
//                 "type": (MDType *)typeA;
//                 "sourceItem": (NSMutableDictionary *)itemDicA;
//               },
//           ];
//         { "position": (RDPosition *)positionB;
//           (···)
//         },
//         (···)
//     ];
//   },
//   { "name": name2;                                        //  modelDic
//     (···)
//   },
//  ]
//

/*!
 @method inModelDataAddModelWithName:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one.
 */
- (void) inModelDataAddModelWithName:(NSString*)name
                       andComponents:(NSMutableArray*)components
{
    // If name exists, model is actualized; if name does not exist, the whole dictionary is created.
    // For each model already saved...
    BOOL modelFound = NO;
    for (modelDic in modelData) {
        // ...check if the current name already exists comparing it with the saved ones.
        
        NSString * savedName = modelDic[@"name"];
        if ([name isEqualToString:savedName]) { // Name already exists
            modelDic[@"components"] = components;
            modelFound = YES;
        } else {
            // Do not upload the model
        }
        
    }
    
    // If name did not be found, create its dictionary
    if (!modelFound) {
        
        // Compose the dictionary from the innermost to the outermost
        // Wrap components collection in a dictionary with its name
        modelDic = [[NSMutableDictionary alloc] init];
        modelDic[@"name"] = name;
        modelDic[@"components"] = components;
        
        // Set it into locatedDic
        [modelData addObject:modelDic];
    }
}

@end
