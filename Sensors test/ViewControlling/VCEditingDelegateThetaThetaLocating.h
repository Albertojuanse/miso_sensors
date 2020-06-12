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
    
    // Variables
    NSString * errorDescription;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (NSString *)getErrorDescription;
- (id<CLLocationManagerDelegate>)loadLMDelegate;

@end
