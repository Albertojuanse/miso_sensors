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
#import "SharedData.h"

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
- (id<CLLocationManagerDelegate>)loadLMDelegate;
@end
