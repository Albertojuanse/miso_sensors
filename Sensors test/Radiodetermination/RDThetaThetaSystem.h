//
//  RDThetaThetaSystem.h
//  Sensors test
//
//  Created by Alberto J. on 18/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import <float.h>
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class RDThetaThetaSystem
 @discussion This class creates a system capable of locate a position in space given other positions and values related to its heading.
 */
@interface RDThetaThetaSystem : NSObject {
    NSMutableArray * headingMeasures;
}

- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithMeasures:(SharedData*)sharedData
                                                                andPrecisions:(NSDictionary*)precisions;
+ (NSNumber *) calculateDistanceWithRssi:(NSInteger) rssi;

@end