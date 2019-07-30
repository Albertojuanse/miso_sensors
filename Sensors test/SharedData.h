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
- (void) reset;

// General getters
- (NSMutableArray *)getSessionData;
- (NSMutableArray *)getItemsData;
- (NSMutableArray *)getMeasuresData;
- (NSMutableArray *)getLocationsData;
- (NSMutableArray *)getMetamodelData;
- (NSMutableArray *)getModelData;

// Specific session data getters
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserDic:(NSMutableDictionary*)userDic;
- (NSMutableDictionary *)fromSessionDataGetSessionWithUserName:(NSString*)userName;
- (NSString *)fromSessionDataGetModeFromUserWithUserDic:(NSMutableDictionary*)userDic;
- (NSString *)fromSessionDataGetModeFromUserWithUserName:(NSString*)userName;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic;
- (NSMutableDictionary *)fromSessionDataGetItemChosenByUserFromUserWithUserName:(NSString*)userName;
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserDic:(NSMutableDictionary*)userDic;
- (NSMutableDictionary *)fromSessionDataGetModeChosenByUserFromUserWithUserName:(NSString*)userName;

// Specific items data getters
- (NSMutableArray *)fromItemDataGetItemsWithSort:(NSString *)sort;
- (NSMutableArray *)fromItemDataGetItemsWithIdentifier:(NSString *)identifier;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid;
- (NSMutableArray *)fromItemDataGetItemsWithUUID:(NSString *)uuid
                                           major:(NSString *)major
                                        andMinor:(NSString *)minor;
- (NSMutableArray *)fromItemDataGetItemsWithPosition:(RDPosition *)position;
- (NSMutableArray *)fromItemDataGetItemsWithType:(MDType *)type;
// Specific measures data getters
- (NSMutableArray *)fromMeasuresDataGetPositionDics;
- (NSMutableArray *)fromMeasuresDataGetPositions;
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDDics;
- (NSMutableArray *)fromMeasuresDataGetSourceUUIDs;
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDDics;
- (NSMutableArray *)fromMeasuresDataGetTargetUUIDs;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                  fromUUIDSource:(NSString *)uuid
                                                       andOfSort:(NSString*)sort;
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                     fromUUIDSource:(NSString *)uuid
                                                          andOfSort:(NSString*)sort;
- (NSMutableArray *)fromMeasuresDataGetMeasuresTakenFromPosition:(RDPosition*)position
                                                    ofUUIDTarget:(NSString *)uuid
                                                       andOfSort:(NSString*)sort;
- (NSMutableArray *)fromMeasuresDataGetMeasureDicsTakenFromPosition:(RDPosition*)position
                                                       ofUUIDTarget:(NSString *)uuid
                                                          andOfSort:(NSString*)sort;

// Specific locations data specific getters
- (NSMutableArray *)fromLocationsDataGetPositionDics;
- (NSMutableArray *)fromLocationsDataGetPositions;
- (NSMutableArray *)fromLocationsDataGetPositionDicsOfUUID:(NSString*)uuid;
- (NSMutableArray *)fromLocationsDataGetPositionsOfUUID:(NSString*)uuid;

// Specific metamodel data specific getters
- (NSMutableArray *)fromMetamodelDataGetTypes;

// Specific model data specific getters
- (NSMutableArray *)fromMetamodelDataGetModelDics;
- (NSMutableArray *)fromMetamodelDataGetModelDicWithName:(NSString*)name;

// Specific session data setters

// Specific items data setters

// Specific measures data setters
- (void) inMeasuresDicSetMeasure:(NSNumber*)measure
                          ofSort:(NSString*)sort
                        withUUID:(NSString*)uuid
                      atPosition:(RDPosition*)measurePosition
                    andWithState:(BOOL)measuring;

// Specific locations data specific setters

// Specific metamodel data specific setters

// Specific model data specific setters

@end
