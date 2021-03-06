//
//  VCModeDelegateThetaThetaModelling.h
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "VCModeDelegate.h"
#import "VCDrawings.h"
#import "RDThetaThetaSystem.h"
#import "LMDelegateThetaThetaModelling.h"
#import "MotionManager.h"

static NSString * ERROR_DESCRIPTION_VCETTM = @"[VCETTM]";
static NSString * IDLE_STATE_MESSAGE_VCETTM = @"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing.";
static NSString * MEASURING_STATE_MESSAGE_VCETTM = @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";

/*!
 @class VCModeDelegateThetaThetaModelling
 @discussion This class implements the protocol VCModeDelegate to define the behaviour of the editing view controller in ThetaThetaLocating mode.
 */
@interface VCModeDelegateThetaThetaModelling: NSObject<VCModeDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    LMDelegateThetaThetaModelling * location;
    RDThetaThetaSystem * thetaThetaSystem;
    MotionManager * motion;
    
    // Constants
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
#pragma mark - General VCModeDelegate methods
- (NSString *)getErrorDescription;
- (NSString *)getIdleStateMessage;
- (NSString *)getMeasuringStateMessage;
#pragma mark - Location VCModeDelegate methods
- (id<CLLocationManagerDelegate>)loadLMDelegate;
- (LMRanging *)loadLMRanging;
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
#pragma mark - Adding VCModeDelegate methods
- (UIImage *)imageForMeasureIcon;
- (void)whileAddingUserDidTapMeasure:(UIButton *)buttonMeasure
                    toMeasureItemDic:(NSMutableDictionary *)itemDic;
- (void)whileAddingRangingMeasureFinishedInViewController:(UIViewController *)viewController
                                        withMeasureButton:(UIButton *)measureButton;
- (void)whileAddingRangingMeasureFinishedWithErrorsInViewController:(UIViewController *)viewController
                                                       notification:(NSNotification *)notification
                                                  withMeasureButton:(UIButton *)measureButton;
@end
