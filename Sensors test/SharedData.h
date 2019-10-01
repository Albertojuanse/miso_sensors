//
//  SharedData.h
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDPosition.h"
#import "MDType.h"

/*!
 @class SharedData
 @discussion This class works as a monitor for all the aplication shared data such as items or measures.
 */
@interface SharedData: NSObject {
    
    // Colections of data
    NSMutableArray * userData;       // Set of dictionaries with the user's credentials
    NSMutableArray * sessionData;    // Set of dictionaries with the information generated by the user in each use
    NSMutableArray * itemsData;      // Set of dictionaries with the information of every position, beacon... submitted by the user
    NSMutableArray * measuresData;   // Set of dictionaries with the measures taken
    NSMutableArray * metamodelData;  // Set of dictionaries with the metamodeling types
    NSMutableArray * modelData;      // Set of dictionaries with the models generated or imported
    
    // Declare the inner dictionaries; they will be created or gotten if they already exists each use
    NSMutableDictionary * sessionDic;
    NSMutableDictionary * itemDic;
    NSMutableDictionary * measureDic;
    NSMutableDictionary * modelDic;
    
}

// General methods
- (instancetype)initWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (instancetype)initWithName:(NSString *)name
                     andRole:(NSString *)role;
- (void)resetWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// General getters
- (NSMutableArray *)getUserDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)getSessionDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)getItemsDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)getMeasuresDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)getMetamodelDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)getModelDataWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (BOOL)isUserDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)isSessionDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)isItemsDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)isMeasuresDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)isMetamodelDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)isModelDataEmptyWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific user data getters
- (NSMutableDictionary *) fromUserDataGetUserDicWithName:(NSString *)name
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) validateCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific session data getters
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary *)userDic
                                        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString *)userName
                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary *)givenUserDic
                                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString *)userName
                                                          andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary *)userDic
                                  andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString *)userName
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetStateFromUserWithUserDic:(NSMutableDictionary *)givenUserDic
                                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetStateFromUserWithUserName:(NSString *)userName
                                    andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsMeasuringUserWithUserDic:(NSMutableDictionary *)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsMeasuringUserWithUserName:(NSString *)userName
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsIdleUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsIdleUserWithUserName:(NSString *)userName
                        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsTravelingUserWithUserDic:(NSMutableDictionary *)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromSessionDataIsTravelingUserWithUserName:(NSString *)userName
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary *)userDic
                                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString *)userName
                                                          andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary *)userDic
                                                         andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSString *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString *)userName
                                                          andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (MDType *)fromSessionDataGetTypeChosenByUserFromUserWithUserDic:(NSMutableDictionary *)userDic
                                            andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (MDType *)fromSessionDataGetTypeChosenByUserFromUserWithUserName:(NSString *)userName
                                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromSessionDataGetItemsChosenByUserDic:(NSMutableDictionary *)givenUserDic
                                     andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromSessionDataGetItemsChosenByUserName:(NSString *)givenUserName
                                      andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromSessionDataGetPositionsOfItemsChosenByUserDic:(NSMutableDictionary *)givenUserDic
                                              withCredentialsUserName:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromSessionDataGetPositionsOfItemsChosenByUserName:(NSString *)givenUserName
                                               withCredentialsUserName:(NSMutableDictionary *)credentialsUserDic;

// Specific items data getters
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier
                                 andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                           minor:(NSString *)minor
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position
                               andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type
                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemWithInfoDic:(NSMutableDictionary *)infoDic
                             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)fromItemDataIsItemWithInfoDic:(NSMutableDictionary *)infoDic
                andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray* )fromItemDataGetLocatedItemsByUser:(NSMutableDictionary *)userDic
                                andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray* )fromItemDataGetPositionsOfLocatedItemsByUser:(NSMutableDictionary *)userDic
                                           andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific measures measure getters
- (NSMutableArray *)fromMeasuresDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetPositionsOfUserDic:(NSMutableDictionary *)givenUserDic
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetPositionsWithMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetItemUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetDeviceUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                     withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetItemUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                        takenFromPosition:(RDPosition *)givenPosition
                                   withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetDeviceUUIDsOfUserDic:(NSMutableDictionary *)givenUserDic
                                          takenFromPosition:(RDPosition *)givenPosition
                                     withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromItemUUID:(NSString *)itemUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromItemUUID:(NSString *)itemUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            fromItemUUID:(NSString *)itemUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            ofDeviceUUID:(NSString *)deviceUUID
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            fromItemUUID:(NSString *)itemUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasuresOfUserDic:(NSMutableDictionary *)givenUserDic
                                       takenFromPosition:(RDPosition *)givenPosition
                                            ofDeviceUUID:(NSString *)deviceUUID
                                                  ofSort:(NSString *)sort
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (NSNumber *) fromMeasuresDataGetMaxMeasureOfSort:(NSString *)sort
                            withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific metamodel data specific getters
- (NSMutableArray *)fromMetamodelDataGetTypesWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) fromMetamodelDataIsTypeWithName:(NSString *)givenName
               andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific model data specific getters
- (NSMutableArray *)fromMetamodelDataGetModelDicsWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString *)name
                                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific user data setters
- (BOOL) inUserDataSetUsedDic:(NSMutableDictionary *)givenUserDic
       withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inUserDataSetUsedDicWithName:(NSString *)name
                                 role:(NSString *)role
            andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific session data setters
- (BOOL)inSessionDataSetMode:(NSString *)givenMode
           toUserWithUserDic:(NSMutableDictionary *)userDic
       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetMode:(NSString *)givenMode
          toUserWithUserName:(NSString *)userName
       andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetState:(NSString *)givenState
            toUserWithUserDic:(NSMutableDictionary *)givenUserDic
        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetState:(NSString *)givenState
           toUserWithUserName:(NSString *)givenUserName
        andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetMeasuringUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetMeasuringUserWithUserName:(NSString *)userName
                        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetIdleUserWithUserDic:(NSMutableDictionary *)givenUserDic
                  andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetIdleUserWithUserName:(NSString *)userName
                   andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetTravelingUserWithUserDic:(NSMutableDictionary *)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetTravelingUserWithUserName:(NSString *)userName
                        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary *)itemChosenByUser
                       toUserWithUserDic:(NSMutableDictionary *)userDic
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary *)itemChosenByUser
                      toUserWithUserName:(NSString *)userName
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType *)typeChosenByUser
                       toUserWithUserDic:(NSMutableDictionary *)userDic
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType *)typeChosenByUser
                      toUserWithUserName:(NSString *)userName
                   andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inSessionDataSetAsChosenItem:(NSMutableDictionary *)givenItemDic
                    toUserWithUserDic:(NSMutableDictionary *)userDic
               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inSessionDataSetAsChosenItem:(NSMutableDictionary *)givenItemDic
                   toUserWithUserName:(NSString *)userName
               withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inSessionDataSetAsNotChosenItem:(NSMutableDictionary *)givenItemDic
                       toUserWithUserDic:(NSMutableDictionary *)userDic
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inSessionDataSetAsNotChosenItem:(NSMutableDictionary *)givenItemDic
                      toUserWithUserName:(NSString *)userName
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific items data setters
- (BOOL) inItemDataAddItemOfSort:(NSString *)sort
                  withIdentifier:(NSString *)identifier
                     withInfoDic:(NSMutableDictionary *)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;
- (BOOL) inItemDataAddItemOfSort:(NSString *)sort
                        withUUID:(NSString *)uuid
                     withInfoDic:(NSMutableDictionary *)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific measures data setters
- (BOOL) inMeasuresDataSetMeasure:(NSNumber *)measure
                           ofSort:(NSString *)sort
                     withItemUUID:(NSString *)itemUUID
                   withDeviceUUID:(NSString *)deviceUUID
                       atPosition:(RDPosition *)position
                   takenByUserDic:(NSMutableDictionary *)givenUserDic
        andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific metamodel data specific setters
- (BOOL) inMetamodelDataAddType:(MDType *)type
         withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific model data specific setters
- (BOOL) inModelDataAddModelWithName:(NSString *)name
                          components:(NSMutableArray *)components
           andWithCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific user data specific removers

// Specific session data specific removers

// Specific items data specific removers
- (BOOL) inItemDataRemoveItemWithInfoDic:(NSMutableDictionary *)infoDic
                  withCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific measures data specific removers

// Specific metamodel data specific removers
- (BOOL) inMetamodelDataRemoveItemWithName:(NSString *)givenName
                     andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

// Specific model data specific removers

@end
