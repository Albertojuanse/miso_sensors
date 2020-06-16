//
//  VCEditingDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <CoreLocation/CoreLocation.h>
#import "MotionManager.h"
#import "SharedData.h"

static NSString * ERROR_DESCRIPTION = @"[VCETTL]";
static NSString * IDLE_STATE_MESSAGE = @"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing.";
static NSString * MEASURING_STATE_MESSAGE = @"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure.";

/*!
 @protocol VCEditingDelegate
 @discussion Abstract definition of the delegate to define the behaviour of the editing view controller in each mode.
 */
@protocol VCEditingDelegate

@required
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (NSString *)getErrorDescription;
- (NSString *)getIdleStateMessage;
- (NSString *)getMeasuringStateMessage;
- (id<CLLocationManagerDelegate>)loadLMDelegate;
- (MotionManager *)loadMotion;
- (void)userDidTapButtonMeasure:(UIButton *)buttonMeasure
                    whenInState:(NSString *)state
             andWithLabelStatus:(UILabel *)labelStatus;
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
