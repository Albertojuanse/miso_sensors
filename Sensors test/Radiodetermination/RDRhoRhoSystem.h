//
//  RDRhoRhoSystem.h
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class RDRhoRhoSystem
 @discussion This class creates a system capable of locate a position in space given other positions and a value related to the distance within them.
 */
@interface RDRhoRhoSystem: NSObject {
    NSMutableArray * rssiMeasures;
}

- (RDPosition *) get2DPositionWithRssi1:(NSInteger) rssi1
                               andRssi2:(NSInteger) rssi1
                          andReference1:(RDPosition *) ref1
                          andReference2:(RDPosition *) ref2
                          andPrediction:(RDPosition *) pred;

- (NSMutableArray *) getLocationsUsingGridAproximationWithMeasures:(NSMutableDictionary*)measuresDic
                                                      andPrecision:(NSNumber*)precision;

+ (NSNumber *) calculateDistanceWithRssi:(NSInteger) rssi;

@end
