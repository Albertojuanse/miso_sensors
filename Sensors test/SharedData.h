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
 @discussion This class works as a monitor for all the aplication shared data such as locations or measures.
 */
@interface SharedData: NSObject {
    
    // Colections of data
    NSMutableArray * userData;       // Set of dictionaries with the user's credentials
    NSMutableArray * sessionData;    // Set of dictionaries with the information generated by the user in each use
    NSMutableArray * itemsData;      // Set of dictionaries with the information of every position, beacon... submitted by the user
    NSMutableArray * measuresData;   // Set of dictionaries with the measures taken
    NSMutableArray * locationsData;  // Set of dictionaries with the positions locted in space using location methods
    NSMutableArray * metamodelData;  // Set of dictionaries with the metamodeling types
    NSMutableArray * modelData;      // Set of dictionaries with the models generated or imported
    
    // Declare the inner dictionaries; they will be created or gotten if they already exists each use
    NSMutableDictionary * sessionDic;
    NSMutableDictionary * userDic;
    NSMutableDictionary * itemDic;
    NSMutableDictionary * positionDic;
    NSMutableDictionary * uuidDic;
    NSMutableArray * uuidArray;
    NSMutableDictionary * measureDic;
    NSMutableArray * measuresArray;
    NSMutableDictionary * locationDic;
    NSMutableDictionary * modelDic;
    
}

// General methods
- (instancetype)initWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (instancetype)initWithName:(NSString*)name
                     andRole:(NSString*)role;
- (void)resetWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// General getters
- (NSMutableArray *)getUserDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getSessionDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getItemsDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getMeasuresDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getLocationsDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getMetamodelDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)getModelDataWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

- (BOOL)isUserDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isSessionDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isItemsDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isMeasuresDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isLocationsDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isMetamodelDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)isModelDataEmptyWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific user data getters
- (NSMutableDictionary *) fromUserDataGetUserDicWithName:(NSString*)name
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL) validateCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific session data getters
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary*)userDic
                                        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString*)userName
                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary*)userDic
                                  andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString*)userName
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSString *)fromSessionDataGetStateFromUserWithUserDic:(NSMutableDictionary*)givenUserDic
                                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSString *)fromSessionDataGetStateFromUserWithUserName:(NSString*)userName
                                    andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsMeasuringUserWithUserName:(NSString*)userName
                             andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsIdleUserWithUserName:(NSString*)userName
                        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
                            andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)fromSessionDataIsTravelingUserWithUserName:(NSString*)userName
                             andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic
                                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString*)userName
                                                          andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic
                                                         andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString*)userName
                                                          andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific items data getters
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier
                                 andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                           minor:(NSString *)minor
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position
                               andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type
                           andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
// Specific measures data getters
- (NSMutableArray *)fromMeasuresDataGetPositionDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                     fromUUIDSource:(NSString *)uuid
                                                             ofSort:(NSString*)sort
                                          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                  fromUUIDSource:(NSString *)uuid
                                                          ofSort:(NSString*)sort
                                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                       ofUUIDTarget:(NSString *)uuid
                                                             ofSort:(NSString*)sort
                                          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                    ofUUIDTarget:(NSString *)uuid
                                                          ofSort:(NSString*)sort
                                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSNumber *) fromMeasuresDataGetMaxMeasureOfSort:(NSString *)sort
                            withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific locations data specific getters
- (NSMutableArray *)fromLocationsDataGetPositionDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromLocationsDataGetPositionsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromLocationsDataGetPositionDicsOfUUID:(NSString*)uuid
                                    withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromLocationsDataGetPositionsOfUUID:(NSString*)uuid
                                 withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific metamodel data specific getters
- (NSMutableArray *)fromMetamodelDataGetTypesWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific model data specific getters
- (NSMutableArray *)fromMetamodelDataGetModelDicsWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString*)name
                                  withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific user data setters
- (BOOL) inUserDataSetUsedDic:(NSMutableDictionary*)givenUserDic
       withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL) inUserDataSetUsedDicWithName:(NSString*)name
                                 role:(NSString*)role
            andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific session data setters
- (BOOL)inSessionDataSetMode:(NSString*)givenMode
           toUserWithUserDic:(NSMutableDictionary*)userDic
       andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetMode:(NSString*)givenMode
          toUserWithUserName:(NSString*)userName
       andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetState:(NSString*)givenState
            toUserWithUserDic:(NSMutableDictionary*)givenUserDic
        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetState:(NSString*)givenState
           toUserWithUserName:(NSString*)givenUserName
        andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetMeasuringUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetMeasuringUserWithUserName:(NSString*)userName
                        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetIdleUserWithUserDic:(NSMutableDictionary*)givenUserDic
                  andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetIdleUserWithUserName:(NSString*)userName
                   andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetTravelingUserWithUserDic:(NSMutableDictionary*)givenUserDic
                       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetTravelingUserWithUserName:(NSString*)userName
                        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary*)itemChosenByUser
                       toUserWithUserDic:(NSMutableDictionary*)userDic
                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetItemChosenByUser:(NSMutableDictionary*)itemChosenByUser
                      toUserWithUserName:(NSString*)userName
                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType*)typeChosenByUser
                       toUserWithUserDic:(NSMutableDictionary*)userDic
                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL)inSessionDataSetTypeChosenByUser:(MDType*)typeChosenByUser
                      toUserWithUserName:(NSString*)userName
                   andCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific items data setters
- (BOOL) inItemDataAddItemOfSort:(NSString*)sort
                  withIdentifier:(NSString*)identifier
                     withInfoDic:(NSMutableDictionary*)infoDic
       andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific measures data setters
- (BOOL) inMeasuresDataSetMeasure:(NSNumber*)measure
                           ofSort:(NSString*)sort
                         withUUID:(NSString*)uuid
                       atPosition:(RDPosition*)position
                      withUserDic:(NSMutableDictionary*)givenUserDic
        andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific locations data specific setters
- (BOOL) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                     fromUUIDSource:(NSString *)uuid
                        withUserDic:(NSMutableDictionary*)givenUserDic
          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;
- (BOOL) inLocationsDataSetPosition:(RDPosition*)locatedPosition
                       ofUUIDTarget:(NSString *)uuid
                        withUserDic:(NSMutableDictionary*)givenUserDic
          andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific metamodel data specific setters
- (BOOL) inMetamodelDataAddType:(MDType*)type
         withCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

// Specific model data specific setters
- (BOOL) inModelDataAddModelWithName:(NSString*)name
                          components:(NSMutableArray*)components
           andWithCredentialsUserDic:(NSMutableDictionary*)credentialsUserDic;

@end
