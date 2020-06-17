//
//  VCModeDelegateThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "VCModeDelegate.h"
#import "RDThetaThetaSystem.h"
#import "LMDelegateThetaThetaLocating.h"
#import "MotionManager.h"

static NSString * ERROR_DESCRIPTION_VCETTL = @"[VCETTL]";
static NSString * IDLE_STATE_MESSAGE_VCETTL = @"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing.";
static NSString * MEASURING_STATE_MESSAGE_VCETTL = @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";

/*!
 @class VCModeDelegateThetaThetaLocating
 @discussion This class implements the protocol VCModeDelegate to define the behaviour of the editing view controller in ThetaThetaLocating mode.
 */
@interface VCModeDelegateThetaThetaLocating: NSObject<VCModeDelegate>{
    
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
- (NSInteger)numberOfSectionsInTableItems:(UITableView *)tableView
                         inViewController:(UIViewController *)viewController;
- (NSInteger)tableItems:(UITableView *)tableView
       inViewController:(UIViewController *)viewController
  numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableItems:(UITableView *)tableView
               inViewController:(UIViewController *)viewController
                           cell:(UITableViewCell *)cell
              forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableItems:(UITableView *)tableView
  inViewController:(UIViewController *)viewController
didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
