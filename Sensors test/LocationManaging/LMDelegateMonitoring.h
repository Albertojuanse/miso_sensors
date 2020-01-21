//
//  LMDelegateMonitoring.h
//  Sensors test
//
//  Created by Alberto J. on 16/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class LMDelegateMonitoring
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in Monitoring mode.
 */
@interface LMDelegateMonitoring: NSObject<CLLocationManagerDelegate>{
    
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
    
    // Variables
    RDPosition * position;  // Current position of device
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    
    // Orchestration variables
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
- (void)setPosition:(RDPosition *)givenPosition;
- (RDPosition *)getPosition;

@end
