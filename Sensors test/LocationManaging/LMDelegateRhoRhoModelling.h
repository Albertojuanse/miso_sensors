//
//  LMDelegateRhoRhoModelling.h
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "SharedData.h"

/*!
 @class LMDelegateRhoRhoModelling
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in kModeRhoRhoModelling mode.
 */
@interface LMDelegateRhoRhoModelling: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    CLLocationManager * locationManager;
    
    // Variables (modelling mode)
    RDPosition * devicePosition;
    NSString * deviceUUID;
    NSString * itemToMeasureUUID;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

@end
