//
//  RDRhoRhoSystem.h
//  Sensors test
//
//  Created by Alberto J. on 14/5/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import <float.h>
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class RDRhoRhoSystem
 @discussion This class creates a system capable of locate a position in space given other positions and a value related to the distance within them.
 */
@interface RDRhoRhoSystem: NSObject {
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
- (NSMutableDictionary *) getLocationsUsingGridAproximationWithPrecisions:(NSDictionary *)precisions;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

+ (NSNumber *) calculateDistanceWithRssi:(NSInteger) rssi;

@end
