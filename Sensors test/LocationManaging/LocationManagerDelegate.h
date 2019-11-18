//
//  LocationManagerDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "RDRhoThetaSystem.h"
#import "RDThetaThetaSystem.h"
#import "SharedData.h"
#import <math.h>

/*!
 @class LocationManagerDelegate
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    RDThetaThetaSystem * thetaThetaSystem;
    CLLocationManager * locationManager;
    
    // Variables
    RDPosition * position;  // Current position of device
    NSNumber * lastHeadingPosition;
    BOOL isItemChosenByUserRanged;
    BOOL calibrating;
    NSInteger calibrationStep;
    NSNumber * calibrationYvalue;
    NSNumber * calibrationYvalueAccumulation;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    
    // Orchestration variables
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;
- (void)setPosition:(RDPosition *)givenPosition;
- (RDPosition *)getPosition;

@end

