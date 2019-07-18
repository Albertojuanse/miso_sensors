//
//  RDRhoThetaSystem.h
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import <float.h>
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class RDRhoThetaSystem
 @discussion This class creates a system capable of locate a position in space given other positions and both a value related to the distance within them and a value related to its heading.
 */
@interface RDRhoThetaSystem: NSObject {
    NSMutableArray * rssiMeasures;
    NSMutableArray * headingMeasures;
}

- (NSMutableDictionary *) getLocationsWithMeasures:(SharedData*)sharedData
                                     andPrecisions:(NSDictionary*)precisions;
+ (NSNumber *) calculateDistanceWithRssi:(NSInteger) rssi;

@end
