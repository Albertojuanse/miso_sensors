//
//  LMDelegateGPS.h
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
 @class LMDelegateGPS
 @discussion This class implements the protocol CLLocationManagerDelegate to handle the events of location manager in calibrating mode.
 */
@interface LMDelegateGPS: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Components
    SharedData * sharedData;
    CLLocationManager * locationManager;
    
    // Variables
    NSString * deviceUUID;
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
@end
