//
//  VCModeDelegateRhoThetaModelling.h
//  Sensors test
//
//  Created by MISO on 13/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MDType.h"
#import "VCModeDelegate.h"
#import "VCDrawings.h"
#import "RDPosition.h"
#import "RDRhoThetaSystem.h"
#import "LMDelegateRhoThetaModelling.h"
#import "MotionManager.h"

static NSString * ERROR_DESCRIPTION_VCERTM = @"[VCERTM]";
static NSString * IDLE_STATE_MESSAGE_VCERTM = @"IDLE; please, aim the iBeacon device and tap 'Measure' for starting. Tap back for finishing.";
static NSString * MEASURING_STATE_MESSAGE_VCERTM = @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";

/*!
 @class VCModeDelegateRhoThetaModelling
 @discussion This class implements the protocol VCModeDelegate to define the behaviour of the editing view controller in RhoThetaModelling mode.
 */
@interface VCModeDelegateRhoThetaModelling: NSObject<VCModeDelegate>{
    
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
#pragma mark - General VCModeDelegate methods
- (NSString *)getErrorDescription;
- (NSString *)getIdleStateMessage;
- (NSString *)getMeasuringStateMessage;
#pragma mark - Location VCModeDelegate methods
- (id<CLLocationManagerDelegate>)loadLMDelegate;
#pragma mark - Motion VCModeDelegate methods
- (MotionManager *)loadMotion;
#pragma mark - Selecting VCModeDelegate methods
- (void)whileSelectingHandleButtonGo:(id)sender
                  fromViewController:(UIViewController *)viewController;
- (NSInteger)whileSelectingNumberOfSectionsInTableItems:(UITableView *)tableView
                                       inViewController:(UIViewController *)viewController;
- (NSInteger)whileSelectingTableItems:(UITableView *)tableView
                     inViewController:(UIViewController *)viewController
                numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)whileSelectingTableItems:(UITableView *)tableView
                             inViewController:(UIViewController *)viewController
                                         cell:(UITableViewCell *)cell
                            forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)whileSelectingTableItems:(UITableView *)tableView
                inViewController:(UIViewController *)viewController
         didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
#pragma mark - Editing VCModeDelegate methods
- (void)whileEditingUserDidTapButtonMeasure:(UIButton *)buttonMeasure
                                whenInState:(NSString *)state
                         andWithLabelStatus:(UILabel *)labelStatus;
- (NSInteger)whileEditingNumberOfSectionsInTableItems:(UITableView *)tableView
                                     inViewController:(UIViewController *)viewController;
- (NSInteger)whileEditingTableItems:(UITableView *)tableView
                   inViewController:(UIViewController *)viewController
              numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)whileEditingTableItems:(UITableView *)tableView
                           inViewController:(UIViewController *)viewController
                                       cell:(UITableViewCell *)cell
                          forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)whileEditingTableItems:(UITableView *)tableView
              inViewController:(UIViewController *)viewController
       didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end