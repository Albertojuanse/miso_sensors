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
    return ERROR_DESCRIPTION_VCERTM;
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in RhoThetaModelling mode.
*/
- (NSString *)getIdleStateMessage
{
    return IDLE_STATE_MESSAGE_VCERTM;
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in RhoThetaModelling mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return MEASURING_STATE_MESSAGE_VCERTM;
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
        NSLog(@"[ERROR]%@ The collection with the items chosen by user is empty; no device position provided.", ERROR_DESCRIPTION_VCERTM);
    } else {
        itemChosenByUserAsDevicePosition = [itemsChosenByUser objectAtIndex:0];
        if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR]%@ The collection with the items chosen by user have more than one item; the first one is set as device position.", ERROR_DESCRIPTION_VCERTM);
        }
    }
    if (itemChosenByUserAsDevicePosition) {
        RDPosition * position = itemChosenByUserAsDevicePosition[@"position"];
        if (!position) {
            NSLog(@"[ERROR]%@ No position was found in the item chosen by user as device position; (0,0,0) is set.", ERROR_DESCRIPTION_VCERTM);
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
        }
        if (!deviceUUID) {
            if (!itemChosenByUserAsDevicePosition[@"uuid"]) {
                NSLog(@"[ERROR]%@ No UUID was found in the item chosen by user as device position; a random one set.", ERROR_DESCRIPTION_VCERTM);
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
            [labelStatus setText:MEASURING_STATE_MESSAGE_VCERTM];
        
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/start"
                                                                object:nil];
            NSLog(@"[NOTI]%@ Notification \"lmdRhoThetaModelling/start\" posted.", ERROR_DESCRIPTION_VCERTM);
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [labelStatus setText:IDLE_STATE_MESSAGE_VCERTM];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/stop"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmdRhoThetaModelling/stop\" posted.", ERROR_DESCRIPTION_VCERTM);
        return;
    }
}

/*!
 @method numberOfSectionsInTableItems:inViewController:
 @discussion Handles the upload of table items; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableItems:(UITableView *)tableView
                         inViewController:(UIViewController *)viewController
{
    // Return the number of sections.
    return 1;
}

/*!
 @method tableItems:inViewController:numberOfRowsInSection:
 @discussion Handles the upload of table items; returns the number of items in them.
 */
- (NSInteger)tableItems:(UITableView *)tableView
       inViewController:(UIViewController *)viewController
  numberOfRowsInSection:(NSInteger)section
{
    // In this mode, only iBeacon devices can be positioned; if one of these items have already got a position assigned, that position must be transferred to another item
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        return [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                                   andCredentialsUserDic:credentialsUserDic] count];
    } else { // Type not found
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading items.", ERROR_DESCRIPTION_VCERTM);
    }
    
    return 0;
}

/*!
 @method tableItems:inViewController:cell:forRowAtIndexPath:
 @discussion Handles the upload of table items; returns each cell.
 */
- (UITableViewCell *)tableItems:(UITableView *)tableView
               inViewController:(UIViewController *)viewController
                           cell:(UITableViewCell *)cell
              forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In this mode, only iBeacon devices can be positioned; if one of these items have already got a position assigned, that position must be transferred to another item
    
    // Configure individual cells
    // Database could be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // No item chosen by user
        [sharedData inSessionDataSetItemChosenByUser:nil
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
        // Select the source of items
        NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                                                            andCredentialsUserDic:credentialsUserDic]
                                         objectAtIndex:indexPath.row
                                         ];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // If it is a beacon
        if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
            
            // It representation depends on if exist its position or its type
            if (itemDic[@"position"]) {
                if (itemDic[@"type"]) {
                    
                    RDPosition * position = itemDic[@"position"];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: %@",
                                           itemDic[@"identifier"],
                                           itemDic[@"type"],
                                           itemDic[@"uuid"],
                                           itemDic[@"major"],
                                           itemDic[@"minor"],
                                           position
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    
                } else {
                    
                    RDPosition * position = itemDic[@"position"];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: %@",
                                           itemDic[@"identifier"],
                                           itemDic[@"uuid"],
                                           itemDic[@"major"],
                                           itemDic[@"minor"],
                                           position
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    
                }
            } else {
                if (itemDic[@"type"]) {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nmajor: %@ ; minor: %@",
                                           itemDic[@"identifier"],
                                           itemDic[@"type"],
                                           itemDic[@"uuid"],
                                           itemDic[@"major"],
                                           itemDic[@"minor"]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    
                } else  {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nmajor: %@ ; minor: %@",
                                           itemDic[@"identifier"],
                                           itemDic[@"uuid"],
                                           itemDic[@"major"],
                                           itemDic[@"minor"]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    
                }
            }
        } else {
            NSLog(@"[ERROR]%@ An item of sort %@ loaded as a beacon.",
                  ERROR_DESCRIPTION_VCERTM,
                  itemDic[@"sort"]);
        }
        
    } else { // Type not found
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading cells' item.", ERROR_DESCRIPTION_VCERTM);
    }
    
    return cell;
}

/*!
 @method tableItems:inViewController:didSelectRowAtIndexPath:
 @discussion Handles the upload of table items; handles the 'select a cell' action.
 */
- (void)tableItems:(UITableView *)tableView
  inViewController:(UIViewController *)viewController
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // Load the item depending and set as selected
        NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                           andCredentialsUserDic:credentialsUserDic]
        objectAtIndex:indexPath.row
        ];
        
        [sharedData inSessionDataSetItemChosenByUser:itemDic
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while selecting a cell.", ERROR_DESCRIPTION_VCERTM);
    }
}

/*!
 @method alertUserWithTitle:message:andHandler:inViewController:
 @discussion This method alerts the user with a pop up window with a single "Ok" button given its message and title and lambda funcion handler.
 */
- (void) alertUserWithTitle:(NSString *)title
                    message:(NSString *)message
                 andHandler:(void (^)(UIAlertAction *action))handler
           inViewController:(UIViewController *)viewController
{
    UIAlertController * alertUsersNotFound = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:handler
                                ];
    
    [alertUsersNotFound addAction:okButton];
    [viewController presentViewController:alertUsersNotFound animated:YES completion:nil];
    return;
}
@end
