//
//  VCEditingDelegateThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "VCEditingDelegate.h"
#import "RDThetaThetaSystem.h"
#import "LMDelegateThetaThetaLocating.h"
#import "MotionManager.h"

static NSString * ERROR_DESCRIPTION = @"[VCETTL]";
static NSString * IDLE_STATE_MESSAGE = @"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing.";
static NSString * MEASURING_STATE_MESSAGE = @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";

/*!
 @class VCEditingDelegateThetaThetaLocating
 @discussion This class implements the protocol VCEditingDelegate to define the behaviour of the editing view controller in ThetaThetaLocating mode.
 */
@interface VCEditingDelegateThetaThetaLocating: NSObject<VCEditingDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    LMDelegateThetaThetaLocating * location;
    RDThetaThetaSystem * thetaThetaSystem;
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
