//
//  VCEditingDelegateThetaThetaLocating.m
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCEditingDelegateThetaThetaLocating.h"

@implementation VCEditingDelegateThetaThetaLocating : NSObject

/*!
 @method initWithSharedData:userDic:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [super init];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = initDeviceUUID;
    }
    
    return self;
}

#pragma mark - VCEditingDelegate methods
/*!
@method getErrorDescription
@discussion This method returns the description for errors that ViewControllerEditing must use when in ThetaThetaLocating mode.
*/
- (NSString *)getErrorDescription
{
    return @"[VCETTL]";
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in ThetaThetaLocating mode.
*/
- (NSString *)getIdleStateMessage
{
    return @"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing.";
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in ThetaThetaLocating mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";
}

/*!
@method loadLMDelegate
@discussion This method returns the location manager with the proper location system in ThetaThetaLocating mode.
*/
- (id<CLLocationManagerDelegate>)loadLMDelegate
{
    if (!thetaThetaSystem) {
        thetaThetaSystem = [[RDThetaThetaSystem alloc] initWithSharedData:sharedData
                                                                  userDic:userDic
                                                               deviceUUID:deviceUUID
                                                    andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        // Load the location manager and its delegate, the component which device uses to handle location events.
        location = [[LMDelegateThetaThetaLocating alloc] initWithSharedData:sharedData
                                                                    userDic:userDic
                                                           thetaThetaSystem:thetaThetaSystem
                                                                 deviceUUID:deviceUUID
                                                      andCredentialsUserDic:credentialsUserDic];
    }
    return location;
}

/*!
@method loadMotion
@discussion This method returns the motion manager in ThetaThetaLocating mode.
*/
- (MotionManager *)loadMotion
{
    if (!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                                   userDic:credentialsUserDic
                                          thetaThetaSystem:thetaThetaSystem
                                                deviceUUID:deviceUUID
                                     andCredentialsUserDic:credentialsUserDic];
        
        // TODO: make this configurable or properties. Alberto J. 2019/09/13.
        motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
    }
    return motion;
}

@end
