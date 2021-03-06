//
//  LMDelegateRhoThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "RDRhoThetaSystem.h"
#import "SharedData.h"

/*!
 @class LMDelegateRhoThetaLocating
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in kModeRhoThetaLocating mode.
 */
@interface LMDelegateRhoThetaLocating: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    RDRhoThetaSystem * rhoThetaSystem;
    CLLocationManager * locationManager;
    
    // Variables (locating mode)
    NSString * deviceUUID;
    RDPosition * itemToMeasurePosition;
    NSString * itemToMeasureUUID;
    BOOL isItemToMeasureRanged;
    NSNumber * lastHeadingPosition;
    
    // Data store
    NSMutableArray * monitoredRegions;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;

@end
