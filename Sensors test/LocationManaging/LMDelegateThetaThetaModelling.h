//
//  LMDelegateThetaThetaModelling.h
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "RDThetaThetaSystem.h"
#import "SharedData.h"

/*!
 @class LMDelegateThetaThetaModelling
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in kModeThetaThetaModelling mode.
 */
@interface LMDelegateThetaThetaModelling: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    RDThetaThetaSystem * thetaThetaSystem;
    CLLocationManager * locationManager;
    
    // Variables
    RDPosition * position;  // Current position of device
    CLHeading * currentCompassHeading;
    CLHeading * lastMeasuredHeading;
    BOOL needMeasureHeading;
    NSString * deviceUUID;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;
- (void)setPosition:(RDPosition *)givenPosition;
- (RDPosition *)getPosition;

@end