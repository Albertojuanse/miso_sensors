//
//  LMDelegateGPS.h
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class LMDelegateGPS
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in calibrating mode.
 */
@interface LMDelegateGPS: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    CLLocationManager * locationManager;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void)setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

@end
