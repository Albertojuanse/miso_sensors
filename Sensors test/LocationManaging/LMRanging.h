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
#import "RDRhoRhoSystem.h"
#import "RDRhoThetaSystem.h"
#import "RDThetaThetaSystem.h"
#import "SharedData.h"

/*!
 @class LMRanging
 @discussion This class gets the measures taken by Location manager from measures collection and creates new calibrated measures.
 */
@interface LMRanging: NSObject {
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    NSString * deviceUUID;
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    RDThetaThetaSystem * thetaThetaSystem;
    
    // Variables
    NSString * calibrationUUID;
    NSMutableDictionary * itemToCalibrate;
    // Calibration variables
    NSInteger minIterations;
    NSInteger maxIterations;
    NSInteger minIterationsStep1;
    NSInteger maxIterationsStep1;
    NSInteger minIterationsStep2;
    NSInteger maxIterationsStep2;
    NSInteger minMeasuresAfterGauss;
    NSInteger consecutiveInvalidIterations;
    NSInteger maxConsecutiveInvalidIterations;
    BOOL firstStepFinished;
    float gaussThreshold;
    // Ranging variables
    NSInteger minMeasures;
    NSInteger maxMeasures;
    NSInteger validMeasures;
    NSInteger consecutiveInvalidMeasures;
    NSInteger maxConsecutiveInvalidMeasures;
    
    
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                      rhoRhoSystem:(RDRhoRhoSystem *)initRhoRhoSystem
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                    rhoThetaSystem:(RDRhoThetaSystem *)initRhoThetaSystem
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                  thetaThetaSystem:(RDThetaThetaSystem *)initThetaThetaSystem
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic;
- (void)setCredentialUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void)setUserDic:(NSMutableDictionary *)givenUserDic;
- (void)setDeviceUUID:(NSString *)givenDeviceUUID;

@end
