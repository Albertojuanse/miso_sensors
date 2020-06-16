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
#import "MotionManager.h"

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
