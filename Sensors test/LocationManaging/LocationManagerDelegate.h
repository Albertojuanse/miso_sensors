//
//  LocationManagerDelegate.h
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Canvas.h"

@interface LocationManagerDelegate: NSObject<CLLocationManagerDelegate>{
    
    NSMutableArray * monitoredRegions;
    NSMutableArray * rangedRegions;
    CLLocationManager * locationManager;
    
    // Radiolocator
    NSMutableArray *rssiMeasures;
}

- (void) configure;

@property NSMutableArray * rangedBeacons;

@end

