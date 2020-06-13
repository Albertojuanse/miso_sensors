//
//  VCEditingDelegateRhoThetaModelling.m
//  Sensors test
//
//  Created by MISO on 13/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCEditingDelegateRhoThetaModelling.h"

@implementation VCEditingDelegateRhoThetaModelling : NSObject

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
@discussion This method returns the description for errors that ViewControllerEditing must use when in RhoThetaModelling mode.
*/
- (NSString *)getErrorDescription
{
    return ERROR_DESCRIPTION;
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in RhoThetaModelling mode.
*/
- (NSString *)getIdleStateMessage
{
    return IDLE_STATE_MESSAGE;
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in RhoThetaModelling mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return MEASURING_STATE_MESSAGE;
}

/*!
@method loadLMDelegate
@discussion This method returns the location manager with the proper location system in RhoThetaModelling mode.
*/
- (id<CLLocationManagerDelegate>)loadLMDelegate
{
    if (!rhoThetaSystem) {
        rhoThetaSystem = [[RDRhoThetaSystem alloc] initWithSharedData:sharedData
                                                              userDic:userDic
                                                           deviceUUID:deviceUUID
                                                andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        // Load the location manager and its delegate, the component which device uses to handle location events.
        location = [[LMDelegateRhoThetaModelling alloc] initWithSharedData:sharedData
                                                                    userDic:userDic
                                                            rhoThetaSystem:rhoThetaSystem
                                                                deviceUUID:deviceUUID
                                                     andCredentialsUserDic:credentialsUserDic];
    }
    NSMutableArray * itemsChosenByUser = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
    NSMutableDictionary * itemChosenByUserAsDevicePosition;
    if (itemsChosenByUser.count == 0) {
        NSLog(@"[ERROR][VCRTM] The collection with the items chosen by user is empty; no device position provided.");
    } else {
        itemChosenByUserAsDevicePosition = [itemsChosenByUser objectAtIndex:0];
        if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR][VCRTM] The collection with the items chosen by user have more than one item; the first one is set as device position.");
        }
    }
    if (itemChosenByUserAsDevicePosition) {
        RDPosition * position = itemChosenByUserAsDevicePosition[@"position"];
        if (!position) {
            NSLog(@"[ERROR][VCRTM] No position was found in the item chosen by user as device position; (0,0,0) is set.");
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
        }
        if (!deviceUUID) {
            if (!itemChosenByUserAsDevicePosition[@"uuid"]) {
                NSLog(@"[ERROR][VCRTM] No UUID was found in the item chosen by user as device position; a random one set.");
                deviceUUID = [[NSUUID UUID] UUIDString];
            } else {
                deviceUUID = itemChosenByUserAsDevicePosition[@"uuid"];
            }
        }
        [rhoThetaSystem setDeviceUUID:deviceUUID];
        [location setPosition:position];
        [location setDeviceUUID:deviceUUID];
    }
    return location;
}

/*!
@method loadMotion
@discussion This method returns the motion manager in RhoThetaModelling mode.
*/
- (MotionManager *)loadMotion
{
    if (!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                                   userDic:credentialsUserDic
                                            rhoThetaSystem:rhoThetaSystem
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

/*!
@method userDidTapButtonMeasure:whenInState:
@discussion This method returns the behaviour when user taps 'Measure' button in RhoThetaModelling mode.
*/
- (void)userDidTapButtonMeasure:(UIButton *)buttonMeasure
                    whenInState:(NSString *)state
             andWithLabelStatus:(UILabel *)labelStatus
{
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            [labelStatus setText:MEASURING_STATE_MESSAGE];
        
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/start"
                                                                object:nil];
            NSLog(@"[NOTI][VCRTM] Notification \"lmdRhoThetaModelling/start\" posted.");
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [labelStatus setText:IDLE_STATE_MESSAGE];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"lmdRhoThetaModelling/stop\" posted.");
        return;
    }
}


@end
