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
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    
    // Variables
    NSMutableArray * rssiMeasures;
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (NSMutableDictionary *) getLocationsUsingBarycenterAproximationWithPrecisions:(NSDictionary *)precisions;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

+ (NSNumber *) calculateDistanceWithRssi:(NSInteger) rssi;

@end
