//
//  VCModeDelegateThetaThetaLocating.m
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCModeDelegateThetaThetaLocating.h"

@implementation VCModeDelegateThetaThetaLocating : NSObject

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

#pragma mark - General VCModeDelegate methods
/*!
@method getErrorDescription
@discussion This method returns the description for errors that ViewControllerEditing must use when in ThetaThetaLocating mode.
*/
- (NSString *)getErrorDescription
{
    return ERROR_DESCRIPTION_VCETTL;
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in ThetaThetaLocating mode.
*/
- (NSString *)getIdleStateMessage
{
    return IDLE_STATE_MESSAGE_VCETTL;
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in ThetaThetaLocating mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return MEASURING_STATE_MESSAGE_VCETTL;
}

#pragma mark - Location VCModeDelegate methods
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

#pragma mark - Motion VCModeDelegate methods
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

#pragma mark - Selecting VCModeDelegate methods

#pragma mark - Editing VCModeDelegate methods    
/*!
@method whileEditingUserDidTapButtonMeasure:whenInState:andWithLabelStatus:
@discussion This method returns the behaviour when user taps 'Measure' button in ThetaThetaLocating mode.
*/
- (void)whileEditingUserDidTapButtonMeasure:(UIButton *)buttonMeasure
                                whenInState:(NSString *)state
                         andWithLabelStatus:(UILabel *)labelStatus
{
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        // If user did chose a position to aim
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            
            [labelStatus setText:MEASURING_STATE_MESSAGE_VCETTL];
            
            // And send the notification
            // TODO: Decide if use this or not. Combined? Alberto J. 2020/01/21.
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdThetaThetaLocating/start" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopes" object:nil];
            NSLog(@"[NOTI]%@ Notification \"startGyroscopes\" posted.", ERROR_DESCRIPTION_VCETTL);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopeHeadingMeasuring"
                                                                object:nil];
            NSLog(@"[NOTI]%@ Notification \"startGyroscopeHeadingMeasuring\" posted.", ERROR_DESCRIPTION_VCETTL);
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If 'Measuring' is tapped, ask stop measuring.
        [buttonMeasure setEnabled:YES];
        // This next line have been moved into "stopGyroscopesHeadingMeasuring" method, because the measure is generated in this case after stop measuring
        // [sharedData inSessionDataSetIdleUserWithUserDic:userDic andWithCredentialsUserDic:credentialsUserDic];
        [labelStatus setText:IDLE_STATE_MESSAGE_VCETTL];
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdThetaThetaLocating/stop" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopes" object:nil];
        NSLog(@"[NOTI]%@ Notification \"stopGyroscopes\" posted.", ERROR_DESCRIPTION_VCETTL);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopeHeadingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"stopGyroscopeHeadingMeasuring\" posted.", ERROR_DESCRIPTION_VCETTL);
        return;
    }
}

/*!
 @method whileEditingNumberOfSectionsInTableItems:inViewController:
 @discussion Handles the upload of table items; returns the number of sections in them.
 */
- (NSInteger)whileEditingNumberOfSectionsInTableItems:(UITableView *)tableView
                            inViewController:(UIViewController *)viewController
{
    // Return the number of sections.
    return 0;
}

/*!
 @method whileEditingTableItems:inViewController:numberOfRowsInSection:
 @discussion Handles the upload of table items; returns the number of items in them.
 */
- (NSInteger)whileEditingTableItems:(UITableView *)tableView
                   inViewController:(UIViewController *)viewController
    numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

/*!
 @method whileEditingTableItems:inViewController:cell:forRowAtIndexPath:
 @discussion Handles the upload of table items; returns each cell.
 */
- (UITableViewCell *)whileEditingTableItems:(UITableView *)tableView
                           inViewController:(UIViewController *)viewController
                                       cell:(UITableViewCell *)cell
                          forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cell;
}

/*!
 @method whileEditingTtableItems:inViewController:didSelectRowAtIndexPath:
 @discussion Handles the upload of table items; handles the 'select a cell' action.
 */
- (void)whileEditingTableItems:(UITableView *)tableView
              inViewController:(UIViewController *)viewController
       didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return;
}
@end
