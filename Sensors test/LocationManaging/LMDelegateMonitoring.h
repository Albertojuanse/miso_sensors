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
    
    // Components
    SharedData * sharedData;
    CLLocationManager * locationManager;
    
    // Variables
    RDPosition * position;
    NSString * deviceUUID;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    
    // Orchestration variables
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;
- (void)setPosition:(RDPosition *)givenPosition;
- (RDPosition *)getPosition;

@end
