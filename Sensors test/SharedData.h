//
//  SharedData.h
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDPosition.h"

/*!
 @class SharedData
 @discussion This class works as a monitor for all the aplication shared data such as locations or measures.
 */
@interface SharedData: NSObject {
    
    // Measures taken at certain positions
    NSMutableDictionary * measuresDic;
    NSNumber * positionIdNumber;
    NSNumber * uuidIdNumber;
    NSNumber * measureIdNumber;
    
    // Located positions using measures
    NSMutableDictionary * locatedDic;
    NSNumber * locatedIdNumber;
    
    // Declare the inner dictionaries; they will be created or gotten if they already exists each actualization.
    NSMutableDictionary * measureDic;
    NSMutableDictionary * measureDicDic;
    NSMutableDictionary * uuidDic;
    NSMutableDictionary * uuidDicDic;
    NSMutableDictionary * positionDic;
}

- (NSMutableDictionary *) getMeasuresDic;
- (NSMutableDictionary *) getLocatedDic;
- (NSMutableArray *) fromMeasuresDicGetPositions;
- (NSNumber *) fromMeasuresDicGetMaxMeasureOfType:(NSString *)type;
- (NSMutableArray *) fromLocatedDicGetPositions;

- (void) inMeasuresDicSetMeasure:(NSNumber*)measure
                          ofType:(NSString*)type
                        withUUID:(NSString*)uuid
                      atPosition:(RDPosition*)measurePosition
                    andWithState:(BOOL)measuring;
- (void) inLocatedDicSetPosition:(RDPosition*)locatedPosition
                        fromUUID:(NSString*)locatedUUID;
- (void) reset;

@end
