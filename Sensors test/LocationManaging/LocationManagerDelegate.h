//
//  LocationManagerDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RDPosition.h"
#import "RDRhoRhoSystem.h"
#import "MotionManager.h"

/*!
 @class LocationManagerDelegate
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    // Variables
    RDPosition * position;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * rangedRegions;
    CLLocationManager * locationManager;
    NSMutableArray * rangedBeacons;
    
    // Data shared
    NSMutableDictionary * rangedBeaconsDic;
    NSNumber * positionIdNumber;
    NSNumber * uuidIdNumber;
    NSNumber * measureIdNumber;
    
}

- (void) configure;

@end

