//
//  VCModeDelegateRhoRhoModelling.h
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MDType.h"
#import "VCModeDelegate.h"
#import "VCDrawings.h"
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "LMDelegateRhoRhoModelling.h"
#import "LMRanging.h"
#import "MotionManager.h"

static NSString * ERROR_DESCRIPTION_VCERRM = @"[VCERRM]";
static NSString * IDLE_STATE_MESSAGE_VCERRM = @"IDLE; please, move to any position and tap 'Measure' to start. Tap 'Next' to add another component. Tap back to finish.";
static NSString * MEASURING_STATE_MESSAGE_VCERRM = @"MEASURING; please, do not move the device. Tap 'Measure' again to finish the measure.";

/*!
 @class VCModeDelegateRhoRhoModelling
 @discussion This class implements the protocol VCModeDelegate to define the behaviour of the editing view controller in RhoRhoModelling mode.
 */
@interface VCModeDelegateRhoRhoModelling: NSObject<VCModeDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    LMDelegateRhoRhoModelling * location;
    RDRhoRhoSystem * rhoRhoSystem;
    MotionManager * motion;
    LMRanging * ranger;
    
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
- (void)whileAddingUserDidTapMeasure:(UIButton *)buttonMeasure
                    toMeasureItemDic:(NSMutableDictionary *)itemDic;
- (void)whileAddingRangingMeasureFinishedInViewController:(UIViewController *)viewController
                                        withMeasureButton:(UIButton *)measureButton;
- (void)whileAddingRangingMeasureFinishedWithErrorsInViewController:(UIViewController *)viewController
                                                       notification:(NSNotification *)notification
                                                  withMeasureButton:(UIButton *)measureButton;

@end
