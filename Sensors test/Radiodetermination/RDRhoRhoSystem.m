//
//  RhoRhoSystem.m
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "RDRhoRhoSystem.h"

/*!
 @class RDRhoRhoSystem
 @discussion This class creates a system capable of locate a position in space given other positions and a value related to the distance within them.
 */
@implementation RDRhoRhoSystem : NSObject

- (instancetype)init
{
    self = [super init];
    return self;
}

/*!
 @method get2DPositionWithRssi1:andRssi2:andReference1:andReference2:andPrediction:
 @discussion This method calculates the position in 2D space given other two reference positions and two measured RSSI values.
 */
- (RDPosition *) get2DPositionWithRssi1:(NSInteger) rssi1
                               andRssi2:(NSInteger) rssi2
                          andReference1:(RDPosition *) ref1
                          andReference2:(RDPosition *) ref2
                          andPrediction:(RDPosition *) pred
{
    // Retrieve coordinates from the reference positions
    NSNumber * x1 = ref1.x;
    NSNumber * y1 = ref1.y;
    NSNumber * x2 = ref2.x;
    NSNumber * y2 = ref2.y;
    // Estimate the distance given the RSSI values
    NSNumber * dis1 = [self calculateDistanceWithRssi:rssi1];
    NSNumber * dis2 = [self calculateDistanceWithRssi:rssi2];
    
    RDPosition * pos = [[RDPosition alloc] init];
    pos.x = x1;
    return pos;
}

/*!
 @method calculateDistanceWithRssi:
 @discussion This method calculates the distance from a signal was transmited using reception's RSSI value.
 */
- (NSNumber *) calculateDistanceWithRssi: (NSUInteger) rssi
{
    // Absolute values of speed of light, frecuency, and antenna's join gain
    NSNumber * C = [[NSNumber alloc]initWithDouble:299792458.0];
    NSNumber * F = [[NSNumber alloc]initWithDouble:2440000000.0]; // 2400 - 2480 MHz
    NSNumber * G = [[NSNumber alloc]initWithDouble:1.0]; // typically 2.16 dBi
    // RSSI value to double
    NSNumber * RSSIvalue = [[NSNumber alloc]initWithInteger:rssi];
    // Calculate the distance
    NSNumber * distance = [[NSNumber alloc] initWithDouble:([C doubleValue] / (4.0 * M_PI * [F doubleValue])) * sqrt([G doubleValue] * pow(10.0, [RSSIvalue doubleValue] / 10.0))];
    return distance;
}

@end
