//
//  LMDelegateHeading.h
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class LMDelegateHeading
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in calibrating mode.
 */
@interface LMDelegateHeading: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    CLLocationManager * locationManager;
    
    // Variables
    NSString * deviceUUID;
    CLHeading * lastMeasuredHeading;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;

@end
