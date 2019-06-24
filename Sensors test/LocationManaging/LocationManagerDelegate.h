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
#import "SharedData.h"

/*!
 @class LocationManagerDelegate
 @discussion This class implements the protocol CLLocationManagerDelegate and so implements the methods for attend the events of location manager.
 */
@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    // Components
    SharedData * sharedData;
    
    // Variables
    RDPosition * position;
    
    // Data store
    NSMutableArray * monitoredRegions;
    NSMutableArray * rangedRegions;
    CLLocationManager * locationManager;
    NSMutableArray * rangedBeacons;
    
    // Orchestration variables
    BOOL measuring;
    BOOL located;
    NSNumber * currentNumberOfMeasures;
}

- (instancetype)initWithSharedData:(SharedData *)initSharedData;
- (void) setLocated:(BOOL)newLocated;
- (BOOL) isLocated;
- (void) startMeasuring;
- (void) stopMeasuring;
- (BOOL) isMeasuredWith:(NSNumber *)numberOfMeasures;
- (RDPosition *) getPosition;
- (void) setPosition:(RDPosition *)newPosition;

@end

