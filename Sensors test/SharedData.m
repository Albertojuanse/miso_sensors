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
//     "pass": (NSString *)pass1;
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
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "itemsChosenByUser": (NSMutableArray *)items1;
//     "typeChosenByUser": (MDType *)type1
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
//     "located": @"YES" | @"NO";
//
//     "type": (MDType *)type1
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
//  [{ "user": { "name": (NSString *)name1;                  // measureDic; userDic
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "position": (RDPosition *)position1;
//     "itemUUID": (NSString *)itemUUID1;
//     "deviceUUID": (NSString *)deviceUUID1;
//     "sort" : (NSString *)type1;
//     "measure": (NSNumber *)measure1
//   },
//   { "user": { "name": (NSString *)name2;                  // measureDic; userDic
//               "pass": (NSString *)pass2;
//               "role": (NSString *)role2;
//             }
//     "position": (RDPosition *)position2;
//     (···)
//   },
//   (···)
//  ]
//
//            // METAMODEL DATA //
//
// The schema of typesData collection is
//
//  [ (MDType *)type1,
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
        metamodelData = [[NSMutableArray alloc] init];
        modelData = [[NSMutableArray alloc] init];
        
    }
    return self;
}

/*!
 @method initWithCredentialsUserDic:
 @discussion Constructor given it first user as the credential user dictionary.
 */
- (instancetype)initWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    self = [self init];
    
    // Add first user
    [userData addObject:credentialsUserDic];
    
    return self;
}

/*!
 @method initWithName:andRole:
 @discussion Constructor given it first user as its name and role.
 */
- (instancetype)initWithName:(NSString *)name
                     andRole:(NSString *)role
{
    self = [self init];
    
    // Add first user
    // Compose the dictionary from the innermost to the outermost
    // Wrap components collection in a dictionary with its name
    NSMutableDictionary * userDic = [[NSMutableDictionary alloc] init];
    userDic[@"name"] = name;
    userDic[@"role"] = role;
    
    // Set it into locatedDic
    [userData addObject:userDic];
    
    return self;
}

#pragma mark - General methods

/*!
 @method resetWithCredentialsUserDic:
 @discussion Set every instance variable to null for ARC disposing and reallocate and init them;
 */
- (void) resetWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic {
    
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        // Colections of data
        userData = nil;
        sessionData = nil;
        itemsData = nil;
        measuresData = nil;
        metamodelData = nil;
        modelData = nil;
        
        // Colections of data
        userData = [[NSMutableArray alloc] init];
        sessionData = [[NSMutableArray alloc] init];
        itemsData = [[NSMutableArray alloc] init];
        measuresData = [[NSMutableArray alloc] init];
        metamodelData = [[NSMutableArray alloc] init];
        modelData = [[NSMutableArray alloc] init];
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
    }
    return;
}

/*!
 @method resetInnerDictionaries
 @discussion Set every inner dictionary variable to null for ARC disposing.
 */
- (void) resetInnerDictionaries {
    sessionDic = nil;
    itemDic = nil;
    measureDic = nil;
    modelDic = nil;
}

#pragma mark - General getters

/*!
 @method getUserDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object  with the user's credentials; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getUserDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
- (NSMutableArray *)getSessionDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
- (NSMutableArray *)getItemsDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
- (NSMutableArray *)getMeasuresDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return measuresData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method getMetamodelDataWithCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' object with the the metamodeling types use; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)getMetamodelDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
- (NSMutableArray *)getModelDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        return modelData;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method isUserDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'User data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isUserDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (userData.count == 0) {
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
 @method isSessionDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Session data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isSessionDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (sessionData.count == 0) {
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
 @method isItemsDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Items data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isItemsDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (itemsData.count == 0) {
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
 @method isMeasuresDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Measures data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isMeasuresDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (measuresData.count == 0) {
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
 @method isLocationsDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Locations data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isLocationsDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (userData.count == 0) {
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
 @method isMetamodelDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Metamodel data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isMetamodelDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (metamodelData.count == 0) {
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
 @method isModelDataEmptyWithCredentialsUserDic:
 @discussion This method returns YES if the collection 'Model data' is empty; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)isModelDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        if (modelData.count == 0) {
            return YES;
        } else {
            return NO;
        }
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
//     "pass": (NSString *)pass1;
//     "role": (NSString *)role1;
//   },
//   { "name": (NSString *)name2;                  // userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromUserDataGetUserDicWithName:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableDictionary' object with the user credentials of the user described with its user name; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *) fromUserDataGetUserDicWithName:(NSString *)name
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]){
        for (NSMutableDictionary * userDic in userData) {
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
- (BOOL) validateCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    for (NSMutableDictionary * userDic in userData) {
        if ([credentialsUserDic isEqualToDictionary:userDic]) {
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
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (MDType *)type1
//   },
//   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromSessionDataGetSessionWithUserDic:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary *)givenUserDic
                                        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataGetSessionWithUserName:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableDictionary' object with the sessions information of the user described with its user dictionary; if it is not found, return null; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString *)userName
                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataGetKey:fromUserWithUserDic:andCredentialsUserDic:
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (id)fromSessionDataGetKey:(NSString *)key
        fromUserWithUserDic:(NSMutableDictionary *)givenUserDic
      andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataGetKey:fromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the object with the info determined by the dictionary key from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (id)fromSessionDataGetKey:(NSString *)key
       fromUserWithUserName:(NSString *)userName
      andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataGetModeFromUserWithUserDic:andCredentialsUserDic:
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary *)givenUserDic
                                  andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeFromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the mode from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString *)userName
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetStateFromUserWithUserDic:
 @discussion This method returns the mode from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserDic:(NSMutableDictionary *)givenUserDic
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetStateFromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the state from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetStateFromUserWithUserName:(NSString *)userName
                                    andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"state" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataIsMeasuringUserWithUserDic:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is measuring and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserDic:(NSMutableDictionary *)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataIsMeasuringUserWithUserName:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's name is measuring and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsMeasuringUserWithUserName:(NSString *)userName
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataIsIdleUserWithUserDic:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataIsIdleUserWithUserName:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsIdleUserWithUserName:(NSString *)userName
                        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataIsTravelingUserWithUserDic:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's dictionary is traveling and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserDic:(NSMutableDictionary *)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataIsTravelingUserWithUserName:andCredentialsUserDic:
 @discussion This method checks in session data collection if the given user's name is idle and returns YES if so; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromSessionDataIsTravelingUserWithUserName:(NSString *)userName
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromSessionDataGetItemChosenByUserFromUserWithUserDic:andCredentialsUserDic:
 @discussion This method returns the item chosen by user from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary *)givenUserDic
                                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetItemChosenByUserFromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the item chosen by user from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString *)userName
                                                          andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"itemChosenByUser" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserDic:andCredentialsUserDic:
 @discussion This method returns the mode chosen by user from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary *)userDic
                                              andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetModeChosenByUserFromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the mode chosen by user from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSString *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString *)userName
                                               andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"mode" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetTypeChosenByUserFromUserWithUserDic:andCredentialsUserDic:
 @discussion This method returns the type chosen by user from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (MDType *)fromSessionDataGetTypeChosenByUserFromUserWithUserDic:(NSMutableDictionary *)userDic
                                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"typeChosenByUser" fromUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetTypeChosenByUserFromUserWithUserName:andCredentialsUserDic:
 @discussion This method returns the type chosen by user from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (MDType *)fromSessionDataGetTypeChosenByUserFromUserWithUserName:(NSString *)userName
                                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self fromSessionDataGetKey:@"typeChosenByUser" fromUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method fromSessionDataGetItemsChosenByUserDic:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' collection with the items chosen by the user given its user dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromSessionDataGetItemsChosenByUserDic:(NSMutableDictionary *)givenUserDic
                                     andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * itemsChosenByUser;
        
        // Search for the user in session data...
        for (sessionDic in sessionData) {
            NSMutableDictionary * userDic = sessionDic[@"user"];
            if ([userDic isEqualToDictionary:givenUserDic]) {
                
                // ...and get the items array.
                itemsChosenByUser = sessionDic[@"itemsChosenByUser"];
            }
        }
        
        if (itemsChosenByUser) {
            return itemsChosenByUser;
        } else {
            return nil;
        }
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromSessionDataGetItemsChosenByUser:andCredentialsUserName:
 @discussion This method returns the 'NSMutableArray' collection with the items chosen by the user given its user name; if is not found, NO is return; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromSessionDataGetItemsChosenByUserName:(NSString *)givenUserName
                                      andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * itemsChosenByUser;
        
        // Search for the user in session data...
        for (sessionDic in sessionData) {
            NSMutableDictionary * userDic = sessionDic[@"user"];
            NSString * userName = userDic[@"name"];
            if ([userName isEqualToString:givenUserName]) {
                
                // ...and get the items array.
                itemsChosenByUser = sessionDic[@"itemsChosenByUser"];
            }
        }
        
        if (itemsChosenByUser) {
            return itemsChosenByUser;
        } else {
            return nil;
        }
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromSessionDataGetPositionsOfItemsChosenByUserDic:withCredentialsUserName:
 @discussion This method returns the 'NSMutableArray' collection with the positions of items chosen by the user given its user dictionary; if is not found, NO is return; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromSessionDataGetPositionsOfItemsChosenByUserDic:(NSMutableDictionary *)givenUserDic
                                              withCredentialsUserName:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Get the chosen items by the given user...
        NSMutableArray * itemsChosenByUser = [self fromSessionDataGetItemsChosenByUserDic:givenUserDic
                                                                    andCredentialsUserDic:credentialsUserDic];
        
        // ...and get its positions
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        for (itemDic in itemsChosenByUser) {
            RDPosition * itemPosition = itemDic[@"position"];
            if (itemDic) {
                RDPosition * newPosition = [[RDPosition alloc] init];
                newPosition.x = itemPosition.x;
                newPosition.y = itemPosition.y;
                newPosition.z = itemPosition.z;
                [positions addObject:newPosition];
            }
        }
        
        return positions;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromSessionDataGetPositionsOfItemsChosenByUserName:withCredentialsUserName:
 @discussion This method returns the 'NSMutableArray' collection with the positions of items chosen by the user given its user name; if is not found, NO is return; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromSessionDataGetPositionsOfItemsChosenByUserName:(NSString *)givenUserName
                                            withCredentialsUserName:(NSMutableDictionary *)credentialsUserDic
{
    // Get the chosen items by the given user...
    NSMutableArray * itemsChosenByUser = [self fromSessionDataGetItemsChosenByUserName:givenUserName
                                                                 andCredentialsUserDic:credentialsUserDic];
    
    // ...and get its positions
    NSMutableArray * positions = [[NSMutableArray alloc] init];
    for (itemDic in itemsChosenByUser) {
        RDPosition * itemPosition = itemDic[@"position"];
        if (itemDic) {
            RDPosition * newPosition = [[RDPosition alloc] init];
            newPosition.x = itemPosition.x;
            newPosition.y = itemPosition.y;
            newPosition.z = itemPosition.z;
            [positions addObject:newPosition];
        }
    }
    
    return positions;
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
//     "located": @"YES" | @"NO";
//
//     "type": (MDType *)type1
//   },
//   { "sort": @"beacon" | @"position";
//     "identifier": (NSString *)identifier2;
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromItemDataGetItemsWithSort:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its sort; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromItemDataGetItemsWithIdentifier:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its identifier; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier
                                 andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromItemDataGetItemsWithUUID:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromItemDataGetItemsWithUUID:major:andMinor:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID, major and minor values; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                           minor:(NSString *)minor
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromItemDataGetItemsWithPosition:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its UUID; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position
                               andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @method fromItemDataGetItemsWithType:andCredentialsUserDic:
 @discussion This method returns the 'NSMutableArray' with all item objects given its 'MDType'; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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

/*!
 @method fromItemDataGetItemsWithType:andCredentialsUserDic:
 @discussion This method returns an 'NSMutableArray' collection with every item whose values are the same that in a given 'infoDic' dictionary ("uuid" key and value is required); if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromItemDataGetItemWithInfoDic:(NSMutableDictionary *)infoDic
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * itemsFound = [[NSMutableArray alloc] init];
        // The info dictionary must describe the item enough to find it; for that, uuid key is required
        // Validate the keys
        NSArray * infoDicKeys = [infoDic allKeys];
        BOOL uuidFound = NO;
        for (NSString * key in infoDicKeys) {
            if ([key isEqualToString:@"uuid"]) {
                uuidFound = YES;
            }
        }
        if (uuidFound) {
            // Do nothing
        } else {
            NSLog(@"[ERROR][SD] Information provided for deleting an item had not \"uuid\" key.");
            return itemsFound;
        }
        
        // Search for the item
        BOOL itemFound = NO;
        NSMutableDictionary * itemToAdd = nil;
        
        // Search for it and delete it
        for (NSMutableDictionary * itemDic in itemsData) {
            
            // Search for the same UUID.
            NSString * givenUuid = infoDic[@"uuid"];
            if ([givenUuid isEqualToString:itemDic[@"uuid"]]) {
                
                itemFound = YES;
                itemToAdd = itemDic;
                // Verify that searched values are not different to this one...
                for (NSString * key in infoDicKeys) {
                    // ...if they exist.
                    if (itemDic[key]) {
                        
                        id givenValue = infoDic[key];
                        if ([givenValue isEqual:itemDic[key]]) {
                            // Do nothing
                        } else {
                            itemFound = NO;
                        }
                    }
                    
                    // If not found, do nothing; if found, add it
                    if (itemFound) {
                        [itemsFound addObject:itemToAdd];
                    } else {
                        // Do nothing
                    }
                }
            }
        }
        
        return itemsFound;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetItemsWithType:andCredentialsUserDic:
 @discussion This method returns YES if any item whose values are the same that in a given 'infoDic' dictionary is found; if is not found, NO is return; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)fromItemDataIsItemWithInfoDic:(NSMutableDictionary *)infoDic
                andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * itemsFound = [self fromItemDataGetItemWithInfoDic:infoDic andCredentialsUserDic:credentialsUserDic];
        if (itemsFound.count > 0) {
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
 @method fromItemDataGetLocatedItemsByUser:andCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' collection with all the items that had been located and flaged as so in its dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray* )fromItemDataGetLocatedItemsByUser:(NSMutableDictionary *)userDic
                                andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * itemsFound = [[NSMutableArray alloc] init];
        
        for (NSMutableDictionary * itemDic in itemsData) {
            
            if ([@"yes" isEqualToString:itemDic[@"located"]]) {
                [itemsFound addObject:itemDic];
            }
        }
        
        return itemsFound;
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromItemDataGetPositionsOfLocatedItemsByUser:andCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' collection with all the positions of items that had been located and flaged as so in its dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray* )fromItemDataGetPositionsOfLocatedItemsByUser:(NSMutableDictionary *)userDic
                                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * positionsFound = [[NSMutableArray alloc] init];
        
        NSMutableArray * locatedItems = [self fromItemDataGetLocatedItemsByUser:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        
        for (NSMutableDictionary * itemDic in locatedItems) {
            
            RDPosition * position = itemDic[@"position"];
            if (position) {
                [positionsFound addObject:position];
            }
        }
        
        return positionsFound;
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
//  [{ "user": { "name": (NSString *)name1;                  // measureDic; userDic
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "position": (RDPosition *)position1;
//     "itemUUID": (NSString *)itemUUID1;
//     "deviceUUID": (NSString *)deviceUUID1;
//     "sort" : (NSString *)type1;
//     "measure": (NSNumber *)measure1
//   },
//   { "user": { "name": (NSString *)name2;                  // measureDic; userDic
//               "pass": (NSString *)pass2;
//               "role": (NSString *)role2;
//             }
//     "position": (RDPosition *)position2;
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method fromMeasuresDataGetPositionsWithCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every position taken; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and copy and save the position
        for (measureDic in measuresData) {
            RDPosition * newPosition = [[RDPosition alloc] init];
            RDPosition * storedPosition = measureDic[@"position"];
            storedPosition.x = newPosition.x;
            storedPosition.y = newPosition.y;
            storedPosition.z = newPosition.z;
            [positions addObject:newPosition];
        }
        
        return positions;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetPositionsOfUserDic:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every position taken from a given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetPositionsOfUserDic:(NSMutableDictionary *)givenUserDic
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and copy and save the position if it's from the user
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                RDPosition * newPosition = [[RDPosition alloc] init];
                RDPosition * storedPosition = measureDic[@"position"];
                storedPosition.x = newPosition.x;
                storedPosition.y = newPosition.y;
                storedPosition.z = newPosition.z;
                [positions addObject:newPosition];
            }
        }
        
        return positions;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetPositionsWithMeasuresOfUserDic:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure from the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */

- (NSMutableArray *)fromMeasuresDataGetPositionsWithMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * positions = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and copy and save the position if it's from the user and measure is saved
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                if (measureDic[@"measure"]) {
                    RDPosition * newPosition = [[RDPosition alloc] init];
                    RDPosition * storedPosition = measureDic[@"position"];
                    storedPosition.x = newPosition.x;
                    storedPosition.y = newPosition.y;
                    storedPosition.z = newPosition.z;
                    [positions addObject:newPosition];
                }
            }
        }
        
        return positions;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetItemUUIDsOfUserDic:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every different item UUID measured; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */

- (NSMutableArray *)fromMeasuresDataGetItemUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * uuid = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and copy and save the UUID if it's from the user
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                if (measureDic[@"itemUUID"]) {
                    
                    // Search for different UUID
                    if(uuid.count == 0) {
                        [uuid addObject:measureDic[@"itemUUID"]];
                    } else {
                        BOOL foundUUID = NO;
                        for (NSString * existingUUID in uuid) {
                            if ([existingUUID isEqualToString:measureDic[@"itemUUID"]]) {
                                foundUUID = YES;
                            } else {
                                
                            }
                        }
                        if (!foundUUID) {
                            [uuid addObject:measureDic[@"itemUUID"]];
                        }
                    }
                }
            }
        }
        
        return uuid;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetDeviceUUIDsOfUserDic:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every different device UUID; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetDeviceUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                     withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * uuid = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and copy and save the UUID if it's from the user
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                if (measureDic[@"deviceUUID"]) {
                    
                    // Search for different UUID
                    if(uuid.count == 0) {
                        [uuid addObject:measureDic[@"deviceUUID"]];
                    } else {
                        BOOL foundUUID = NO;
                        for (NSString * existingUUID in uuid) {
                            if ([existingUUID isEqualToString:measureDic[@"deviceUUID"]]) {
                                foundUUID = YES;
                            } else {
                                
                            }
                        }
                        if (!foundUUID) {
                            [uuid addObject:measureDic[@"deviceUUID"]];
                        }
                    }
                }
            }
        }
        
        return uuid;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetItemUUIDsOfUserDic:takenFromPosition:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every item UUID measured from the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */

- (NSMutableArray *)fromMeasuresDataGetItemUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                        takenFromPosition:(RDPosition *)givenPosition
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * uuid = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures if it's from the user and from given position.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    if (measureDic[@"itemUUID"]) {
                        [uuid addObject:measureDic[@"itemUUID"]];
                    }
                }
            }
        }
        
        return uuid;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetDeviceUUIDsOfUserDic:takenFromPosition:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every device UUID measured from the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetDeviceUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                          takenFromPosition:(RDPosition *)givenPosition
                                     withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * uuid = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures if it's from the user and from given position.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    if (measureDic[@"deviceUUID"]) {
                        [uuid addObject:measureDic[@"deviceUUID"]];
                    }
                }
            }
        }
        
        return uuid;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return nil;
    }
}

/*!
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromItemUUID:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken from a given item UUID by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromItemUUID:(NSString *)itemUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                NSString * storedItemUUID = measureDic[@"itemUUID"];
                if ([storedItemUUID isEqualToString:itemUUID]) {
                    
                    if (measureDic[@"measure"]) {
                        [measures addObject:measureDic[@"measure"]];
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
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromItemUUID:ofSort:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken from a given item UUID and sort by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromItemUUID:(NSString *)itemUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                NSString * storedItemUUID = measureDic[@"itemUUID"];
                if ([storedItemUUID isEqualToString:itemUUID]) {
                    
                    NSString * storedMeasureSort = measureDic[@"sort"];
                    if ([storedMeasureSort isEqualToString:sort]) {
                        
                        if (measureDic[@"measure"]) {
                            [measures addObject:measureDic[@"measure"]];
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
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromPosition:fromItemUUID:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken from a given item UUID, the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            fromItemUUID:(NSString *)itemUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    
                    NSString * storedItemUUID = measureDic[@"itemUUID"];
                    if ([storedItemUUID isEqualToString:itemUUID]) {
                        
                        if (measureDic[@"measure"]) {
                            [measures addObject:measureDic[@"measure"]];
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
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromPosition:fromDeviceUUID:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken of a given device UUID, the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            ofDeviceUUID:(NSString *)deviceUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    
                    NSString * storedDeviceUUID = measureDic[@"deviceUUID"];
                    if ([storedDeviceUUID isEqualToString:deviceUUID]) {
                        
                        if (measureDic[@"measure"]) {
                            [measures addObject:measureDic[@"measure"]];
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
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromPosition:fromItemUUID:ofSort:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken from a given item UUID, the given sort, the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            fromItemUUID:(NSString *)itemUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    
                    NSString * storedItemUUID = measureDic[@"itemUUID"];
                    if ([storedItemUUID isEqualToString:itemUUID]) {
                        
                        NSString * storedSort = measureDic[@"sort"];
                        if ([storedSort isEqualToString:sort]) {
                            if (measureDic[@"measure"]) {
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
 @method fromMeasuresDataGetMeasuresOfUserDic:takenFromPosition:fromDeviceUUID:ofSort:withCredentialsUserDic:
 @discussion This method returns a 'NSMutableArray' with every measure taken of a given device UUID, the given sort, the given position by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            ofDeviceUUID:(NSString *)deviceUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        NSMutableArray * measures = [[NSMutableArray alloc] init];
        
        // Get every dictionary with measures and save the measures.
        for (measureDic in measuresData) {
            NSMutableDictionary * storedUserDic = measureDic[@"user"];
            if ([storedUserDic isEqualToDictionary:givenUserDic]) {
                
                RDPosition * storedPosition = measureDic[@"position"];
                if ([storedPosition isEqualToRDPosition:givenPosition]) {
                    
                    NSString * storedDeviceUUID = measureDic[@"deviceUUID"];
                    if ([storedDeviceUUID isEqualToString:deviceUUID]) {
                        
                        NSString * storedSort = measureDic[@"sort"];
                        if ([storedSort isEqualToString:sort]) {
                            if (measureDic[@"measure"]) {
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
 @method fromMeasuresDataGetPositionDicsWithCredentialsUserDic:
 @discussion This method returns the maximum 'NSNumber' value of the measures taken; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */

- (NSNumber *) fromMeasuresDataGetMaxMeasureOfSort:(NSString *)sort
                            withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableArray * measuresTaken = [self getMeasuresDataWithCredentialsUserDic:credentialsUserDic];
        NSNumber * max = [NSNumber numberWithFloat:FLT_MIN];
        for (NSNumber * measure in measuresTaken) {
            if ([measure floatValue] > [max floatValue]) {
                max = nil;
                max = [NSNumber numberWithFloat:[measure floatValue]];
            }
        }
        return max;        
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
 @discussion This method returns the 'NSMutableArray' with all 'MDTypes' stored; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetTypesWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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

/*!
 @method fromMetamodelDataIsTypeWithName:andWithCredentialsUserDic:
 @discussion This method returns YES if there is stored a type with the given name; if is not found, NO is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL) fromMetamodelDataIsTypeWithName:(NSString *)givenName
               andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        // Search the type
        for (MDType * eachType in metamodelData) {
            NSString * name = [eachType getName];
            if ([name isEqualToString:givenName]) {
                return YES;
            } else {
                // Do nothing
            }
        }
        // This code is reached if the type is not found
        return NO;
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
 @discussion This method returns the 'NSMutableArray' with all models dictionaries stored; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDicsWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
 @discussion This method returns the 'NSMutableArray' with the models whose name is the given one; if is not found, an empty array is returned; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString *)name
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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
//     "pass": (NSString *)pass1;
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
- (BOOL) inUserDataSetUsedDic:(NSMutableDictionary *)givenUserDic
       withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inUserDataSetUsedDicWithName:givenUserDic[@"name"] role:givenUserDic[@"role"] andWithCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inUserDataSetUsedDicWithName:rol:andWithCredentialsUserDic:
 @discussion This method sets in the user data collection a new user credentials dictionary given its information; if its name already exists, its information is replaced; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inUserDataSetUsedDicWithName:(NSString *)name
                                 role:(NSString *)role
            andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        // If name exists, user is actualized; if name does not exist, the whole dictionary is created.
        // For each user already saved...
        BOOL userFound = NO;
        for (NSMutableDictionary * userDic in userData) {
            
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
            NSMutableDictionary * userDic = [[NSMutableDictionary alloc] init];
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
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "mode": (NSString *)mode1;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "typeChosenByUser": (MDType *)type1
//   },
//   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method inSessionDataSetObject:forKey:toUserWithUserDic:andCredentialsUserDic:
 @discussion This method sets the object as the info determined by the dictionary key from the session data collection given the user's dictionary; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)inSessionDataSetObject:(id)object
                        forKey:(NSString *)key
             toUserWithUserDic:(NSMutableDictionary *)givenUserDic
         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
        // Can be null
        if (sessionDic) {
            // Nil is ot an object
            if (object == nil) {
                [sessionDic setValue:nil forKey:key];
            } else {
                [sessionDic setObject:object forKey:key];
            }
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
 @method inSessionDataSetObject:forKey:toUserWithUserName:andCredentialsUserDic:
 @discussion This method sets the object as the info determined by the dictionary key from the session data collection given the user's name; if is not found, return nil; it is necesary to give a valid user credentials user dictionary for grant the acces and null is returned if not.
 */
- (BOOL)inSessionDataSetObject:(id)object
                        forKey:(NSString *)key
            toUserWithUserName:(NSString *)userName
         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        NSMutableDictionary * sessionDic = [self fromSessionDataGetSessionWithUserName:userName andCredentialsUserDic:credentialsUserDic];
        // Can be null
        if (sessionDic) {
            if (object == nil) {
                [sessionDic setValue:nil forKey:key];
            } else {
                [sessionDic setObject:object forKey:key];
            }
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
 @method inSessionDataSetMode:toUserWithUserDic:andCredentialsUserDic:
 @discussion This method sets in session data collection the user's mode given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMode:(NSString *)givenMode
           toUserWithUserDic:(NSMutableDictionary *)userDic
       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:givenMode forKey:@"mode" toUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetMode:toUserWithUserName:andCredentialsUserDic:
 @discussion This method sets in session data collection the user's mode given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMode:(NSString *)givenMode
          toUserWithUserName:(NSString *)userName
       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
        return [self inSessionDataSetObject:givenMode forKey:@"mode" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetState:toUserWithUserDic:andCredentialsUserDic:
 @discussion This method sets in session data collection the given state to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetState:(NSString *)givenState
            toUserWithUserDic:(NSMutableDictionary *)givenUserDic
        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:givenState forKey:@"state" toUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetState:toUserWithUserName:andCredentialsUserDic:
 @discussion This method sets in session data collection the given state to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetState:(NSString *)givenState
           toUserWithUserName:(NSString *)givenUserName
        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:givenState forKey:@"state" toUserWithUserName:givenUserName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetMeasuringUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state measuring to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMeasuringUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"MEASURING" forKey:@"state" toUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetMeasuringUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state measuring to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetMeasuringUserWithUserName:(NSString *)userName
                        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"MEASURING" forKey:@"state" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetIdleUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state idle to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetIdleUserWithUserDic:(NSMutableDictionary *)givenUserDic
                  andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"IDLE" forKey:@"state" toUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetIdleUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state idle to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetIdleUserWithUserName:(NSString *)userName
                   andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"IDLE" forKey:@"state" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetTravelingUserWithUserDic:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTravelingUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"TRAVELING" forKey:@"state" toUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetTravelingUserWithUserName:andWithCredentialsUserDic:
 @discussion This method sets in session data collection the state traveling to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTravelingUserWithUserName:(NSString *)userName
                        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:@"TRAVELING" forKey:@"state" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetItemChosenByUser:toUserWithUserDic:andCredentialsUserDic:
 @discussion This method sets in session data collection the parameter 'itemChosenByUser' state to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary *)itemChosenByUser
                       toUserWithUserDic:(NSMutableDictionary *)userDic
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:itemChosenByUser forKey:@"itemChosenByUser" toUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetItemChosenByUser:toUserWithUserName:andCredentialsUserDic:
 @discussion This method sets in session data collection the parameter 'itemChosenByUser' state to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary *)itemChosenByUser
                      toUserWithUserName:(NSString *)userName
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:itemChosenByUser forKey:@"itemChosenByUser" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetTypeChosenByUser:toUserWithUserDic:andCredentialsUserDic:
 @discussion This method sets in session data collection the parameter 'typeChosenByUser' state to the given user's dictionary; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType *)typeChosenByUser
                       toUserWithUserDic:(NSMutableDictionary *)userDic
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:typeChosenByUser forKey:@"typeChosenByUser" toUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetTypeChosenByUser:toUserWithUserName:andCredentialsUserDic:
 @discussion This method sets in session data collection the parameter 'typeChosenByUser' state to the given user's name; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType *)typeChosenByUser
                      toUserWithUserName:(NSString *)userName
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    return [self inSessionDataSetObject:typeChosenByUser forKey:@"typeChosenByUser" toUserWithUserName:userName andCredentialsUserDic:credentialsUserDic];
}

/*!
 @method inSessionDataSetAsChosenItem:toUserWithUserDic:withCredentialsUserDic:
 @discussion This method set an item as a chosen one for use it in the modeling process by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inSessionDataSetAsChosenItem:(NSMutableDictionary *)givenItemDic
                    toUserWithUserDic:(NSMutableDictionary *)givenUserDic
               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic

{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Search for the item...
        BOOL isItemDicFound = NO;
        NSMutableDictionary * itemDicFound;
        for (itemDic in itemsData) {
            if ([itemDic isEqualToDictionary:givenItemDic]) {
                itemDicFound = itemDic;
                isItemDicFound = YES;
            }
        }
        
        // ...and for the user in session...
        BOOL isUserDicFound = NO;
        NSMutableDictionary * userDicFound;
        NSMutableDictionary * sessionDicFound;
        for (sessionDic in sessionData) {
            NSMutableDictionary * userDic = sessionDic[@"user"];
            if ([userDic isEqualToDictionary:givenUserDic]) {
                userDicFound = userDic;
                sessionDicFound = sessionDic;
                isUserDicFound = YES;
            }
        }
        if (!isUserDicFound) {
            NSLog(@"[ERROR][SD] User did not found when triying to set an item as chosen to it.");
            return NO;
        }
        
        // Initializate the collection in the user if it does not exist
        if (!sessionDicFound[@"itemsChosenByUser"]) {
            sessionDicFound[@"itemsChosenByUser"] = [[NSMutableArray alloc] init];
        }
        
        // ...and update it
        if (isItemDicFound) {
            NSMutableArray * itemsChosenByUser = sessionDicFound[@"itemsChosenByUser"];
            [itemsChosenByUser addObject:itemDicFound];
        } else {
            NSLog(@"[ERROR][SD] Item did not found when triying to set it item as chosen by user.");
            return NO;
        }
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetAsChosenItem:toUserWithUserName:withCredentialsUserDic:
 @discussion This method set an item as a chosen one for use it in the modeling process by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inSessionDataSetAsChosenItem:(NSMutableDictionary *)givenItemDic
                   toUserWithUserName:(NSString *)givenUserName
               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Search for the item...
        BOOL isItemDicFound = NO;
        NSMutableDictionary * itemDicFound;
        for (itemDic in itemsData) {
            if ([itemDic isEqualToDictionary:givenItemDic]) {
                itemDicFound = itemDic;
                isItemDicFound = YES;
            }
        }
        
        // ...and for the user in session...
        BOOL isUserDicFound = NO;
        NSMutableDictionary * userDicFound;
        NSMutableDictionary * sessionDicFound;
        sessionDicFound = sessionDic;
        for (sessionDic in sessionData) {
            NSString * userName = sessionDic[@"user"][@"name"];
            if ([userName isEqualToString:givenUserName]) {
                userDicFound = sessionDic[@"user"];
                sessionDicFound = sessionDic;
                isUserDicFound = YES;
            }
        }
        if (!isUserDicFound) {
            NSLog(@"[ERROR][SD] User did not found when triying to set an item as chosen to it.");
            return NO;
        }
        
        // Initializate the collection in the user if it does not exist
        if (!sessionDicFound[@"itemsChosenByUser"]) {
            sessionDicFound[@"itemsChosenByUser"] = [[NSMutableArray alloc] init];
        }
        
        // ...and update it
        if (isItemDicFound) {
            NSMutableArray * itemsChosenByUser = sessionDicFound[@"itemsChosenByUser"];
            [itemsChosenByUser addObject:itemDicFound];
        } else {
            NSLog(@"[ERROR][SD] Item did not found when triying to set it item as chosen by user.");
            return NO;
        }
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetAsNotChosenItem:toUserWithUserDic:withCredentialsUserDic:
 @discussion This method set an item as a non chosen one for use it in the modeling process by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inSessionDataSetAsNotChosenItem:(NSMutableDictionary *)givenItemDic
                       toUserWithUserDic:(NSMutableDictionary *)givenUserDic
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Search for the user in session data...
        BOOL isUserDicFound = NO;
        NSMutableDictionary * userDicFound;
        NSMutableDictionary * sessionDicFound;
        for (sessionDic in sessionData) {
            NSMutableDictionary * userDic = sessionDic[@"user"];
            
            if ([userDic isEqualToDictionary:givenUserDic]) {
                userDicFound = userDic;
                sessionDicFound = sessionDic;
                isUserDicFound = YES;
            }
        }
        if (!isUserDicFound) {
            NSLog(@"[ERROR][SD] User did not found when triying to set an item as not chosen by user.");
            return NO;
        }
        
        // ...and search for the item in the user's array of chosen items by it...
        BOOL isItemDicFound = NO;
        NSMutableDictionary * itemDicFound;
        for (itemDic in sessionDicFound[@"itemsChosenByUser"]) {
            
            if ([itemDic isEqualToDictionary:givenItemDic]) {
                itemDicFound = itemDic;
                isItemDicFound = YES;
            }
        }
        
        // ...and delete it if found
        if (isItemDicFound) {
            NSMutableArray * itemsChosenByUser = sessionDicFound[@"itemsChosenByUser"];
            [itemsChosenByUser removeObject:itemDicFound];
        } else {
            NSLog(@"[ERROR][SD] Item did not found when triying to set it item as not chosen by user.");
            return NO;
        }
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

/*!
 @method inSessionDataSetAsNotChosenItem:toUserWithUserName:withCredentialsUserDic:
 @discussion This method set an item as a non chosen one for use it in the modeling process by the given user; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inSessionDataSetAsNotChosenItem:(NSMutableDictionary *)givenItemDic
                      toUserWithUserName:(NSString *)givenUserName
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Search for the user in session data...
        BOOL isUserDicFound = NO;
        NSMutableDictionary * userDicFound;
        NSMutableDictionary * sessionDicFound;
        for (sessionDic in sessionData) {
            NSString * userName = sessionDic[@"user"][@"name"];
            
            if ([userName isEqualToString:givenUserName]) {
                userDicFound = sessionDic[@"user"];
                sessionDicFound = sessionDic;
                isUserDicFound = YES;
            }
        }
        if (!isUserDicFound) {
            NSLog(@"[ERROR][SD] User did not found when triying to set an item as not chosen by user.");
            return NO;
        }
        
        // ...and search for the item in the user's array of chosen items by it...
        BOOL isItemDicFound = NO;
        NSMutableDictionary * itemDicFound;
        for (itemDic in sessionDicFound[@"itemsChosenByUser"]) {
            
            if ([itemDic isEqualToDictionary:givenItemDic]) {
                itemDicFound = itemDic;
                isItemDicFound = YES;
            }
        }
        
        // ...and delete it if found
        if (isItemDicFound) {
            NSMutableArray * itemsChosenByUser = sessionDicFound[@"itemsChosenByUser"];
            [itemsChosenByUser removeObject:itemDicFound];
        } else {
            NSLog(@"[ERROR][SD] Item did not found when triying to set it item as not chosen by user.");
            return NO;
        }
        
        // Everything OK
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
//     "located": @"YES" | @"NO";
//
//     "type": (MDType *)type1
//   },
//   { "sort": @"beacon" | @"position";
//     "identifier": (NSString *)identifier2;
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method inItemDataAddItemOfSort:withIdentifier:withInfoDic:andWithCredentialsUserDic:
 @discussion This method saves in the items collection data an item with the provided information in the information dictionary, its sort and its identifier; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inItemDataAddItemOfSort:(NSString *)sort
                  withIdentifier:(NSString *)identifier
                     withInfoDic:(NSMutableDictionary *)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // If identifier exists, item is updated; if identifier does not exist, the whole dictionary is created.
        // For each item already saved...
        BOOL identifierFound = NO;
        for (itemDic in itemsData) {
            // ...check if the current identifier already exists comparing it with the saved ones.
            
            NSString * savedIdentifier = itemDic[@"identifier"];
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

/*!
 @method inItemDataAddItemOfSort:withUUID:withInfoDic:andWithCredentialsUserDic:
 @discussion This method saves in the items collection data an item with the provided information in the information dictionary, its sort and its UUID; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inItemDataAddItemOfSort:(NSString *)sort
                        withUUID:(NSString *)uuid
                     withInfoDic:(NSMutableDictionary *)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // If UUID exists, item is updated; if UUID does not exist, the whole dictionary is created.
        // For each item already saved...
        BOOL uuidFound = NO;
        for (itemDic in itemsData) {
            // ...check if the current uuid already exists comparing it with the saved ones.
            
            NSString * savedUUID = itemDic[@"uuid"];
            if ([uuid isEqualToString:savedUUID]) { // Identifier already exists
                uuidFound = YES;
                
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
        if (!uuidFound) {
            
            // Compose the dictionary from the innermost to the outermost
            // Generate a new dictionary with the information od the provided one and add sort and UUID
            
            itemDic = [[NSMutableDictionary alloc] init];
            itemDic[@"sort"] = sort;
            itemDic[@"uuid"] = uuid;
            
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
//  [{ "user": { "name": (NSString *)name1;                  // measureDic; userDic
//               "pass": (NSString *)pass1;
//               "role": (NSString *)role1;
//             }
//     "position": (RDPosition *)position1;
//     "itemUUID": (NSString *)itemUUID1;
//     "deviceUUID": (NSString *)deviceUUID1;
//     "sort" : (NSString *)type1;
//     "measure": (NSNumber *)measure1
//   },
//   { "user": { "name": (NSString *)name2;                  // measureDic; userDic
//               "pass": (NSString *)pass2;
//               "role": (NSString *)role2;
//             }
//     "position": (RDPosition *)position2;
//     (···)
//   },
//   (···)
//  ]
//

/*!
 @method inMeasuresDataSetMeasure:ofSort:withItemUUID:withDeviceUUID:atPosition:takenByUserDic:andWithCredentialsUserDic:
 @discussion This method saves in the measures data collection a new one from a given item UUID and device UUID; if the state MEASURING is not true for the given user credentials 'userDic', is saved only the position but no measure; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inMeasuresDataSetMeasure:(NSNumber *)measure
                           ofSort:(NSString *)sort
                     withItemUUID:(NSString *)itemUUID
                   withDeviceUUID:(NSString *)deviceUUID
                       atPosition:(RDPosition *)position
                   takenByUserDic:(NSMutableDictionary *)givenUserDic
        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    // TO DO: Get measuring state directly from this database. Alberto J. 2019/07/31.
    
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // The 'measureDic', the innermost one, is always new.
        measureDic = [[NSMutableDictionary alloc] init];
        measureDic[@"user"] = givenUserDic;
        measureDic[@"position"] = position;
        if ([self fromSessionDataIsMeasuringUserWithUserDic:givenUserDic andCredentialsUserDic:credentialsUserDic]) {
            measureDic[@"itemUUID"] = itemUUID;
            measureDic[@"deviceUUID"] = deviceUUID;
            measureDic[@"measure"] = measure;
        }
        
        [measuresData addObject:measureDic];
        
        // Everything OK
        return YES;
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
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
 @discussion This method saves in the metamodel collection data a new MDType type if it does not exist; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inMetamodelDataAddType:(MDType *)type
         withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Check if it exists
        BOOL typeFound = NO;
        for (MDType * savedType in metamodelData) {
            
            if ([savedType isEqualToMDType:type]) {
                typeFound = YES;
            } else {
                // Do nothing
            }
        }
        
        // If type did not be found, add it
        if (!typeFound) {
            [metamodelData addObject:type];
        }
        
        
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
 @discussion This method saves in the model collection data a new one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inModelDataAddModelWithName:(NSString *)name
                          components:(NSMutableArray *)components
           andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
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

#pragma mark - User data specific removers

#pragma mark - Session data specific removers

#pragma mark - Items data specific removers
/*!
 @method inItemDataRemoveItemWithInfoDic:withCredentialsUserDic:
 @discussion This method removes in the items collection data the one whose data is equals to the information dictionary provided (sort and uuid keys are required); it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inItemDataRemoveItemWithInfoDic:(NSMutableDictionary *)infoDic
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {

        // The info dictionary must describe the item enough to delete it; for that, sort and uuid keys are required
        // Validate the keys
        NSArray * infoDicKeys = [infoDic allKeys];
        BOOL sortFound = NO;
        BOOL uuidFound = NO;
        for (NSString * key in infoDicKeys) {
            if ([key isEqualToString:@"sort"]) {
                sortFound = YES;
            }
            if ([key isEqualToString:@"uuid"]) {
                uuidFound = YES;
            }
        }
        if (sortFound && uuidFound) {
            // Do nothing
        } else {
            NSLog(@"[ERROR][SD] Information provided for deleting an item had not \"sort\" or \"uuid\" keys.");
            return NO;
        }
        
        // Search for the item
        BOOL itemFound = NO;
        NSMutableDictionary * itemToRemove = nil;
        
        // Search for it and delete it
        for (NSMutableDictionary * itemDic in itemsData) {
            
            NSString * givenSort = infoDic[@"sort"];
            if ([givenSort isEqualToString:itemDic[@"sort"]]) {
                
                NSString * givenUuid = infoDic[@"uuid"];
                if ([givenUuid isEqualToString:itemDic[@"uuid"]]) {
                    
                    itemFound = YES;
                    itemToRemove = itemDic;
                    // Verify that searched values are not different to this one...
                    for (NSString * key in infoDicKeys) {
                        // ...if they exist.
                        if (itemDic[key]) {
                            
                            id givenValue = infoDic[key];
                            if ([givenValue isEqual:itemDic[key]]) {
                                // Do nothing
                            } else {
                                itemFound = NO;
                            }
                        }
                    }
                }
            }
        }
        // If not found, return; if found, remove it
        if (itemFound) {
            [itemsData removeObject:itemToRemove];
            return YES;
        } else {
            return NO;
        }
        
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}

#pragma mark - Measures data specific removers

#pragma mark - Locations data specific removers

#pragma mark - Metamodel data specific removers
/*!
 @method inMetamodelDataRemoveItemWithName:andCredentialsUserDic:
 @discussion This method removes the MDType stored whose name is equals to the given one; it is necesary to give a valid user credentials user dictionary for grant the acces and NO is returned if not.
 */
- (BOOL) inMetamodelDataRemoveItemWithName:(NSString *)givenName
                     andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic
{
    if([self validateCredentialsUserDic:credentialsUserDic]) {
        
        // Search for the type called as the given name
        MDType * typeToRemove;
        BOOL typeToRemoveFound = NO;
        for (MDType * eachType in metamodelData) {
            NSString * eachTypeName = [eachType getName];
            if ([eachTypeName isEqualToString:givenName]) {
                typeToRemove = eachType;
                typeToRemoveFound = YES;
            }
        }
        
        // If found, remove it; if not, return NO;
        if (typeToRemoveFound) {
            [metamodelData removeObject:typeToRemove];
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"[ALARM][SD] User tried to acess with no valid user credentials.");
        return NO;
    }
}
    
#pragma mark - Model data specific removers

@end
