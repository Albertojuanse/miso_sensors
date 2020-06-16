//
//  VCEditingDelegateRhoThetaModelling.h
//  Sensors test
//
//  Created by MISO on 13/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "VCEditingDelegate.h"
#import "RDPosition.h"
#import "RDRhoThetaSystem.h"
#import "LMDelegateRhoThetaModelling.h"
#import "MotionManager.h"

/*!
 @class VCEditingDelegateRhoThetaModelling
 @discussion This class implements the protocol VCEditingDelegate to define the behaviour of the editing view controller in RhoThetaModelling mode.
 */
@interface VCEditingDelegateRhoThetaModelling: NSObject<VCEditingDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    LMDelegateRhoThetaModelling * location;
    RDRhoThetaSystem * rhoThetaSystem;
    MotionManager * motion;
    
    // Constants
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (NSString *)getErrorDescription;
- (NSString *)getIdleStateMessage;
- (NSString *)getMeasuringStateMessage;
- (id<CLLocationManagerDelegate>)loadLMDelegate;
- (MotionManager *)loadMotion;

@end
