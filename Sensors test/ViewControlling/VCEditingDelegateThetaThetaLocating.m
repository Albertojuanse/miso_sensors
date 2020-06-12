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
        
        // Description for errors that View Controller Editing must use when in ThetaThetaLocating mode.
        errorDescription = @"[VCETTL]";
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
    return errorDescription;
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

@end
