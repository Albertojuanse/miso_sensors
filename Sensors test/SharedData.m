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
 @method getUserDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object  with the user's credentials; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getUserDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return userData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getSessionDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the information generated by the user in each use; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getSessionDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return sessionData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getItemsDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the information of every position, beacon... submitted by the user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getItemsDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return itemsData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getMeasuresDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the measures taken; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getMeasuresDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return measuresData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getLocationsDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the positions locted in space using location methods; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getLocationsDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return locationsData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getMetamodelDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the the metamodeling types use; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getMetamodelDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return metamodelData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getModelDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the models generated or imported; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getModelDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return modelData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method fromUserDataGetUserDicWithName:andCredentialsUserDic
 @discussion This method returns the 'NSMutableDictionary' object with the user credentials of the user described with its user name; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *) fromUserDataGetUserDicWithName:(NSString*)name
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]){
        for (userDic in userData) {
            if ([name isEqualToString:userDic[@"name"]]) {
                return userDic;
            }
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method validatecredentialsUserDic:
 @discussion This method returns YES if the given dictionary with the user credentials is compliant; is there is not users in the collection, returns null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL) validateCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        for (userDic in userData) {
            if ([credentialsUserDic isEqualToDictionary:userDic]) {
                return YES;
            } else {
                return NO;
            }
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
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
 @method fromSessionDataGetSessionWithUserDic:andCredentialsUserDic
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary*)givenUserDic
                                        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        for (sessionDic in sessionData) {
            NSMutableDictionary * storedUserDic = sessionDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                return sessionDic;
            }
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataGetSessionWithUserName:andCredentialsUserDic
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString*)userName
                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        for (sessionDic in sessionData) {
            NSMutableDictionary * storedUserDic = sessionDic[@"user"];
            if ([storedUserDic[@"name"] isEqualToString:userName]) {
                return sessionDic;
            }
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataGetKey:fromUserWithUserDic:andCredentialsUserDic
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (id)fromSessionDataGetKey:(NSString *)key
        fromUserWithUserDic:(NSMutableDictionary*)givenUserDic
      andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{

    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        // Can be null
        if (sessionDic) {
            return sessionDic[key];
        } else {
            return nil;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataGetKey:fromUserWithUserName:andCredentialsUserDic
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (id)fromSessionDataGetKey:(NSString *)key
       fromUserWithUserName:(NSString*)userName
      andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        // Can be null
        if (sessionDic) {
            return sessionDic[key];
        } else {
            return nil;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataGetModeFromUserWithUserDic:andCredentialsUserDic
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
                                  andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeFromUserWithUserName:andCredentialsUserDic
 @discussion This method returns the mode from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString*)userName
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetStateFromUserWithUserDic:
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetStateFromUserWithUserName:andCredentialsUserDic
 @discussion This method returns the state from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserName:(NSString*)userName
                                    andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataIsMeasuringUserWithUserDic:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's dictionary is measuring and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"MEASURING"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataIsMeasuringUserWithUserName:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's name is measuring and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserName:(NSString*)userName
                             andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"MEASURING"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataIsIdleUserWithUserDic:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's dictionary is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"IDLE"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
    return nil;
}

/*!
 @method fromSessionDataIsIdleUserWithUserName:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserName:(NSString*)userName
                        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"IDLE"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromSessionDataIsTravelingUserWithUserDic:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's dictionary is traveling and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"TRAVELING"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }

}

/*!
 @method fromSessionDataIsTravelingUserWithUserName:andCredentialsUserDic
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserName:(NSString*)userName
                             andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSString * state = [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName
                                 andCredentialsUserDic:credentialsUserDic];
        if ([state isEqualToString:@"TRAVELING"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserDic:andCredentialsUserDic
 @discussion This method returns the item chosen by user from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
                                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserName:andCredentialsUserDic
 @discussion This method returns the item chosen by user from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString*)userName
                                                          andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserDic:andCredentialsUserDic
 @discussion This method returns the mode chosen by user from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic
                                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"modeChosenByUser" fromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserName:andCredentialsUserDic
 @discussion This method returns the mode chosen by user from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString*)userName
                                                          andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"modeChosenByUser" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
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
 @method fromItemDataGetItemsWithSort:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its sort; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * items = [[NSMutableArray alloc] init];
        for (itemDic in itemsData) {
            if ([itemDic[@"sort"] isEqualToString:sort]) {
                [items addObject:itemDic];
            }
        }
        return items;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithIdentifier:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its identifier; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier
                                 andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * items = [[NSMutableArray alloc] init];
        for (itemDic in itemsData) {
            if ([itemDic[@"identifier"] isEqualToString:identifier]) {
                [items addObject:itemDic];
            }
        }
        return items;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithUUID:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * items = [[NSMutableArray alloc] init];
        for (itemDic in itemsData) {
            if ([itemDic[@"uuid"] isEqualToString:uuid]) {
                [items addObject:itemDic];
            }
        }
        return items;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithUUID:major:andMinor:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID, major and minor values; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                           minor:(NSString *)minor
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithPosition:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position
                               andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * items = [[NSMutableArray alloc] init];
        for (itemDic in itemsData) {
            if ([position isEqualToRDPosition:itemDic[@"position"]]) {
                [items addObject:itemDic];
            }
        }
        return items;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithType:andCredentialsUserDic
 @discussion This method returns the 'NSMutableArray' with all item objects given its 'MDType'; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * items = [[NSMutableArray alloc] init];
        for (itemDic in itemsData) {
            if ([type isEqualToMDType:itemDic[@"type"]]) {
                [items addObject:itemDic];
            }
        }
        return items;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method fromMeasuresDataGetPositionDicsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all positions dictionaries; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetPositionDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (positionDic in measuresData) {
            [positions addObject:positionDic];
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetPositionsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all positions 'RDPositions'; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (positionDic in measuresData) {
            [positions addObject:positionDic[@"position"]];
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetSourceUUIDDicsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all UUID dictionaries; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetSourceUUIDsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetTargetUUIDDicsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all UUID dictionaries; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
// Exists two different ways of name UUIDs just for semantic issues and to ease the developing.
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromMeasuresDataGetSourceUUIDDicsWithCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromMeasuresDataGetTargetUUIDsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
// Exists two different ways of name UUIDs just for semantic issues and to ease the developing.
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromMeasuresDataGetSourceUUIDsWithCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromMeasuresDataGetMeasureDicsTakenFromPosition:fromUUIDSource:ofSort:andWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all measure dictionaries taken from a 'RDPosition' from a given UUID and of a given sort; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                     fromUUIDSource:(NSString *)uuid
                                                             ofSort:(NSString*)sort
                                          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetMeasuresTakenFromPosition:fromUUIDSource:ofSort:andWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' from a given UUID and of a given sort; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                  fromUUIDSource:(NSString *)uuid
                                                          ofSort:(NSString*)sort
                                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetMeasureDicsTakenFromPosition:ofUUIDTarget:ofSort:andWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' of a given UUID and of a given sort; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                       ofUUIDTarget:(NSString *)uuid
                                                             ofSort:(NSString*)sort
                                          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromMeasuresDataGetMeasureDicsTakenFromPosition:position
                                                  fromUUIDSource:uuid
                                                          ofSort:sort
                                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic];
}

/*!
 @method fromMeasuresDataGetMeasuresTakenFromPosition:ofUUIDTarget:ofSort:andWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all measures taken from a 'RDPosition' of a given UUID and of a given sort; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                    ofUUIDTarget:(NSString *)uuid
                                                          ofSort:(NSString*)sort
                                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self fromMeasuresDataGetMeasuresTakenFromPosition:position
                                               fromUUIDSource:uuid
                                                       ofSort:sort
                                    andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic];
}

/*!
 @method fromMeasuresDataGetMaxMeasureOfSort:withCredentialsUserDic:
 @discussion This method returns a 'NSNumber' that contains the maximum of the measures taken; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSNumber *) fromMeasuresDataGetMaxMeasureOfSort:(NSString *)sort
                            withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method fromLocationsDataGetPositionDicsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all located positions dictionaries stored; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromLocationsDataGetPositionDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (locationDic in locationsData) {
            [positions addObject:locationDic];
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromLocationsDataGetPositionsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all located positions 'RDPosition' stored; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromLocationsDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (locationDic in locationsData) {
            [positions addObject:locationDic[@"locatedPosition"]];
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromLocationsDataGetPositionDicsOfUUID:withCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all located positions dictionaries stored given their UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromLocationsDataGetPositionDicsOfUUID:(NSString*)uuid
                                    withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (locationDic in locationsData) {
            if ([uuid isEqualToString:locationDic[@"locatedUUID"]]){
                [positions addObject:locationDic];
            }
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromLocationsDataGetPositionsOfUUID:withCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all located positions 'RDPosition' stored given their UUID; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromLocationsDataGetPositionsOfUUID:(NSString*)uuid
                                 withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (locationDic in locationsData) {
            if ([uuid isEqualToString:locationDic[@"locatedUUID"]]){
                [positions addObject:locationDic[@"locatedPosition"]];
            }
        }
        return positions;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method fromMetamodelDataGetTypesWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all 'MDTypes' stored; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetTypesWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * metamodel = [[NSMutableArray alloc] init];
        for (MDType * type in metamodelData) {
            [metamodel addObject:type];
        }
        return metamodel;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method fromMetamodelDataGetModelDicsWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all models dictionaries stored; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * models = [[NSMutableArray alloc] init];
        for (modelDic in modelData) {
            [models addObject:modelDic];
        }
        return models;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMetamodelDataGetModelDicWithName:withCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with the models whose name is the given one; if it does not exist anyone returns an empty array; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString*)name
                                  withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * models = [[NSMutableArray alloc] init];
        for (modelDic in modelData) {
            if ([name isEqualToString:modelDic[@"name"]]) {
                [models addObject:modelDic];
            }
        }
        return models;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
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
 @method inUserDataSetUsedDic:withCredentialsUserDic:
 @discussion This method sets in the user data collection a new user credentials dictionary; if its name already exists, its information is replaced; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inUserDataSetUsedDic:(NSMutableDictionary*)givenUserDic
       withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self inUserDataSetUsedDicWithName:givenUserDic[@"name"] role:givenUserDic[@"role"] andWithCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inUserDataSetUsedDicWithName:rol:andWithCredentialsUserDic:
 @discussion This method sets in the user data collection a new user credentials dictionary given its information; if its name already exists, its information is replaced; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inUserDataSetUsedDicWithName:(NSString*)name
                                 role:(NSString*)role
            andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
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
 @method inSessionDataSetMeasuringUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state measuring to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"MEASURING" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetMeasuringUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state measuring to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMeasuringUserWithUserName:(NSString*)userName
                        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"MEASURING" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state idle to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
                  andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"IDLE" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetMeasuringUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state idle to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetIdleUserWithUserName:(NSString*)userName
                   andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"IDLE" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"TRAVELING" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetMeasuringUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTravelingUserWithUserName:(NSString*)userName
                        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        userDic = [self fromSessionDataGetSessionWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        [userDic setObject:@"TRAVELING" forKey:@"state"];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
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

/*!
 @method inModelDataAddModelWithName:components:andWithCredentialsUserDic:
 @discussion This method saves in the items collection data an item with the provided information in the information dictionary, its sort and its identifier; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inItemDataAddItemOfSort:(NSString*)sort
                  withIdentifier:(NSString*)identifier
                     withInfoDic:(NSMutableDictionary*)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // If identifier exists, model is actualized; if identifier does not exist, the whole dictionary is created.
        // For each item already saved...
        BOOL identifierFound = NO;
        for (itemDic in itemsData) {
            // ...check if the current identifier already exists comparing it with the saved ones.
            
            NSString * savedIdentifier =itemDic[@"identifier"];
            if ([identifier isEqualToString:savedIdentifier]) { // Identifier already exists
                identifierFound = YES;
                
                // Retrieve the information
                NSArray * infoDicKeys = [infoDic allKeys];
                for (id key in infoDicKeys) {
                    itemDic[key] = infoDic[key];
                }
                
            } else {
                // Do nothing
            }
            
        }
        
        // If identifier did not be found, create its dictionary
        if (!identifierFound) {
            
            // Compose the dictionary from the innermost to the outermost
            // Generate a new dictionary with the information od the provided one and add sort and identifier
            
            itemDic = [[NSMutableDictionary alloc] init];
            itemDic[@"sort"] = sort;
            itemDic[@"identifier"] = identifier;
            
            // Retrieve the information
            NSArray * infoDicKeys = [infoDic allKeys];
            for (id key in infoDicKeys) {
                itemDic[key] = infoDic[key];
            }
             
            [itemsData addObject:itemDic];
            
        }
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

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
 @method inMeasuresDataSetMeasure:ofSort:withUUID:atPosition:withUserDic:andWithCredentialsUserDic:
 @discussion This method saves in the measures data collection a new one; if the state MEASURING is not true for the given user credentials 'userDic', is saved only the position but no measure; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inMeasuresDataSetMeasure:(NSNumber*)measure
                           ofSort:(NSString*)sort
                         withUUID:(NSString*)uuid
                       atPosition:(RDPosition*)position
                      withUserDic:(NSMutableDictionary*)givenUserDic
        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    
    // TO DO: Get measuring state directly from this database. Alberto J. 2019/07/31.
    
    if([self validateCredentialsUserDic:credentialsUserDic]) {

        // The 'measureDic', the innermost one, is always new.
        measureDic = [[NSMutableDictionary alloc] init];
        measureDic[@"sort"] = sort;
        measureDic[@"measure"] = measure;
        
        if (measuresData.count == 0) {
            // First initialization
            
            // Compose the dictionary from the innermost to the outermost
            // Wrap measureDic with an array
            measuresArray = [[NSMutableArray alloc] init];
            if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic]) {
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
                            if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic]) { // Only save if in state measuring
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
                        if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic]) {
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
                if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic]) {
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
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
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
 @method inLocationsDataSetPosition:fromUUIDSource:withUserDic:andWithCredentialsUserDic:
 @discussion This method saves in the NSDictionary with the located positions information a new one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                     fromUUIDSource:(NSString *)uuid
                        withUserDic:(NSMutableDictionary*)givenUserDic
          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
        // Everythong OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inLocationsDataSetPosition:ofUUIDTarget:withUserDic:andWithCredentialsUserDic:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                       ofUUIDTarget:(NSString *)uuid
                        withUserDic:(NSMutableDictionary*)givenUserDic
          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    return [self inLocationsDataSetPosition:locatedPosition
                             fromUUIDSource:uuid
                                withUserDic:givenUserDic
                  andWithCredentialsUserDic:credentialsUserDic];
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
 @method inMetamodelDataAddType:withCredentialsUserDic:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inMetamodelDataAddType:(MDType*)type
         withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        [metamodelData addObject:type];
        return YES;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
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
 @method inModelDataAddModelWithName:components:andWithCredentialsUserDic:
 @discussion This method saves in the locatios collection data a located position  with the located positions information a new one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inModelDataAddModelWithName:(NSString*)name
                          components:(NSMutableArray*)components
           andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
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
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

@end
