//
//  LMDelegateRhoRhoLocating.h
//  Sensors test
//
//  Created by Alberto J. on 21/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "SharedData.h"

/*!
 @class LMDelegateRhoRhoLocating
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in kModeRhoRhoLocating mode.
 */
@interface LMDelegateRhoRhoLocating: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    CLLocationManager * locationManager;
    
    // Variables (locating mode)
    NSString * deviceUUID;
    RDPosition * itemToMeasurePosition;
    NSString * itemToMeasureUUID;
    
    // Data store
    NSMutableArray * monitoredRegions;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;

@end
