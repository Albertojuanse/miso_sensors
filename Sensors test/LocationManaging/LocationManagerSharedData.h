//
//  LocationManagerSharedData.h
//  Sensors test
//
//  Created by Alberto J. on 24/6/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDPosition.h"

/*!
 @class LocationManagerSharedData
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerSharedData: NSObject {
    
    // Measures tajen at certain positions
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
- (void) inMeasuresDicSetMeasure:(NSNumber*)measure
                          ofType:(NSString*)type
                        withUUID:(NSString*)uuid
                      atPosition:(RDPosition*)measurePosition
                    andWithState:(BOOL)measuring;
- (void) inLocatedDicSetLocation;

@end
