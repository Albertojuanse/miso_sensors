//
//  LMDelegteRhoThetaModelling.h
//  Sensors test
//
//  Created by Alberto J. on 20/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "RDRhoThetaSystem.h"
#import "SharedData.h"

/*!
 @class LMDelegateRhoThetaModelling
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in kModeRhoThetaModelling mode.
 */
@interface LMDelegateRhoThetaModelling: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    RDRhoThetaSystem * rhoThetaSystem;
    CLLocationManager * locationManager;
    
    // Variables (modelling mode)
    RDPosition * devicePosition;
    NSString * deviceUUID;
    NSString * itemToMeasureUUID;
    BOOL isItemToMeasureRanged;
    NSNumber * lastHeadingPosition;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;

@end
