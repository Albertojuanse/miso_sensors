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
#import "SharedData.h"

/*!
 @class LocationManagerDelegate
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    // Components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    
    // Variables
    RDPosition * position;
    NSNumber * lastHeadingPosition;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * rangedRegions;
    CLLocationManager * locationManager;
    NSMutableArray * rangedBeacons;
    
    // Orchestration variables
    BOOL measuring;
    BOOL idle;
    NSString * mode;
    NSString * uuidChosenByUser;
    BOOL save;
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData;
- (RDPosition *) getPosition;
- (void) setPosition:(RDPosition *)newPosition;

@end

