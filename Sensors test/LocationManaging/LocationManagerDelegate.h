//
//  LocationManagerDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLHeading.h>
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "RDRhoThetaSystem.h"
#import "RDThetaThetaSystem.h"
#import "SharedData.h"

/*!
 @class LocationManagerDelegate
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    RDThetaThetaSystem * thetaThetaSystem;
    
    // Variables
    RDPosition * position;
    NSNumber * lastHeadingPosition;
    BOOL measuring;
    BOOL idle;
    NSString * mode;
    NSString * uuidChosenByUser;
    NSString * locatedPositionUUID;
    RDPosition * positionChosenByUser;
    BOOL isUuidChosenByUserRanged;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * monitoredPositions;
    NSMutableArray * rangedRegions;
    CLLocationManager * locationManager;
    NSMutableArray * rangedBeacons;
    
    // Orchestration variables
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData;
- (instancetype)initWithSharedData:(SharedData *)sharedData
             andCredentialsUserDic:(NSMutableDictionary *)credentialsUserDic;

- (RDPosition *) getPosition;
- (void) setPosition:(RDPosition *)newPosition;
- (void) setSharedData:(SharedData *)newSharedData;

@end

