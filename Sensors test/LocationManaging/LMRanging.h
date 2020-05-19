//
//  LMRanging.h
//  Sensors test
//
//  Created by Alberto J. on 15/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <math.h>
#import "MDMode.h"
#import "RDPosition.h"
#import "SharedData.h"

/*!
 @class LMRanging
 @discussion This class gets the measures taken by Location manager from measures collection and creates new calibrated measures.
 */
@interface LMRanging: NSObject {
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    
    // Variables
    NSString * calibrationUUID;
    NSMutableDictionary * itemToCalibrate;
    NSInteger minNumberOfIterations;
    NSInteger minNumberOfIterationsOfFirstStep;
    NSInteger minNumberOfIterationsOfSecondStep;
    BOOL firstStepFinished;
    float gaussThreshold;
    
    // Orchestration variables
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void)setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

@end
