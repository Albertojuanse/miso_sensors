//
//  LocationManagerDelegate.m
//  Sensors test
//
//  Created by Alberto J. on 23/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "LocationManagerDelegate.h"

@implementation LocationManagerDelegate : NSObject

/*!
 @method configure
 @discussion This method is called when the app is loaded and manage some initializations and permission askings.
 */
- (void) configure{
    
    // Initialize location manager and set this class as the delegate which implement the event response's methods
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    //[locationManager startUpdatingLocation];
    
    // It seems is only for background modes
    //locationManager.allowsBackgroundLocationUpdates = YES;
    //locationManager.pausesLocationUpdatesAutomatically = false;
    
    // Ask for authorization for location services
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            // Request when-in-use authorization initially
            [locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            [locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            [locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            break;
            
        default:
            break;
    }
    NSLog(@"[INFO][LM] LocationManager prepared");
}

/*!
 @method locationManager:didChangeAuthorizationStatus:
 @discussion This method is called when the device's location permission change because user's desire or automatic rutines; depending on the current permission status this delegate will start searching for beacon's regions or not.
 */
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            // Request authorization initially
             NSLog(@"[ERROR][LM] Authorization is not known");
            
        case kCLAuthorizationStatusRestricted:
            // Disable location features
            NSLog(@"[ERROR][LM] User restricts localization services");
            break;
            
        case kCLAuthorizationStatusDenied:
            // Disable location features
            NSLog(@"[ERROR][LM] User doesn't allow localization services");
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'always' localization services");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            // Enable location features
            NSLog(@"[INFO][LM] User allows 'when-in-use' localization services");
            break;
            
        default:
            break;
    }
    
    // Error managment
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO][LM] Location services enabled.");
    }else{
        NSLog(@"[ERROR][LM] Location services not enabled.");
    }
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"[INFO][LM] Monitoring avalible for class CLBeaconRegion.");
    }else{
        NSLog(@"[ERROR][LM] Monitoring not avalible for class CLBeaconRegion.");
    }
    
    if ([CLLocationManager isRangingAvailable]) {
        NSLog(@"[INFO][LM] Ranging avalible.");
    }else{
        NSLog(@"[ERROR][LM] Ranging not avalible.");
    }
    
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // Create a NSUUID with proximity UUID of the broadcasting beacons
        NSUUID *uuidRaspi = [[NSUUID alloc] initWithUUIDString:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7"];
        NSUUID *uuidBeacon1 = [[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
        
        // Setup searching region with proximity UUID as the broadcasting beacon
        monitoredRegions = [[NSMutableArray alloc] init];
        CLBeaconRegion * RaspiRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuidRaspi major:1 minor:0 identifier:@"raspi@miso.uam.es"];
        [monitoredRegions addObject:RaspiRegion];
        CLBeaconRegion * Beacon1Region = [[CLBeaconRegion alloc] initWithProximityUUID:uuidBeacon1 major:1 minor:1 identifier:@"beacon1@miso.uam.es"];
        [monitoredRegions addObject:Beacon1Region];
        
        // Info to radiolocator
        NSMutableArray *rssiMeasures = [[NSMutableArray alloc] init];
        // In first element of each row it will be refereced each region UUID, and then the measuresNSMutableArray *first = [[NSMutableArray alloc] init];
        for(CLBeacon *region in monitoredRegions) {
            NSArray *rssiValues = [[NSArray alloc] initWithObjects:[region proximityUUID], nil];
            [rssiMeasures addObject:rssiValues];
        }
        
        // Configurate the region
        
        // If entry or exit must be notify; the default values are YES
        //RaspiRegion.notifyOnEntry = YES;
        //RaspiRegion.notifyOnExit = YES;
        //RaspiRegion.notifyEntryStateOnDisplay = YES;
        
        //  For normal use ob beacon regions use startMonitoringForRegion:  ...
        //[locationManager startMonitoringForRegion:RaspiRegion];
        // ...but for in-region initialization this one is needed
        rangedRegions = [[NSMutableArray alloc] init];
        [rangedRegions addObject:RaspiRegion];
        [locationManager startRangingBeaconsInRegion:RaspiRegion];
        [rangedRegions addObject:Beacon1Region];
        [locationManager startRangingBeaconsInRegion:Beacon1Region];
        
        
        NSLog(@"[INFO][LM] Device monitorizes a region:");
        NSLog(@"[INFO][LM] -> %@", [[RaspiRegion proximityUUID] UUIDString]);
        NSLog(@"[INFO][LM] Device monitorizes a region:");
        NSLog(@"[INFO][LM] -> %@", [[Beacon1Region proximityUUID] UUIDString]);
        
        NSLog(@"[INFO][LM] Start monitoring regions.");
    }else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied || CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted){
        for(CLBeaconRegion * region in  locationManager.monitoredRegions){
            [locationManager stopMonitoringForRegion:region];
        }
    }
}

/*!
 @method locationManager:didEnterRegion:
 @discussion This method is called when the device cross the border line and enters one of the monitor's monitorized regions (areas); ask the monitor to start searching for specific devices in the region.
 */
- (void)locationManager:(CLLocationManager*)manager
         didEnterRegion:(CLBeaconRegion*)region
{
    // Changed definition of method for (CLBeaconRegion*) instead of (CLRegion*)!!!!
    
    // Start ranging
    rangedRegions = [[NSMutableArray alloc] init];
    [rangedRegions addObject:region];
    [manager startRangingBeaconsInRegion:region];
    
    NSLog(@"[INFO][LM] Device ranged a region:");
    NSLog(@"[INFO][LM] -> %@", [[region proximityUUID] UUIDString]);
    //NSLog([NSString stringWithFormat:@"[INFO] Device ranged a region:", [[region proximityUUID] UUIDString]]);
}

/*!
 @method locationManager:rangingBeaconsDidFailForRegion:inRegion:
 @discussion This method is called when the device fails in detect some other device in a ranged region.
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error {
    NSLog(@"[ERROR][LM] Device failed in raging a region:");
    NSLog(@"[ERROR][LM] -> %@", [[region proximityUUID] UUIDString]);
}

/*!
 @method locationManager:didRangeBeacons:inRegion:
 @discussion This method is called when the device detects some other device in a ranged region; it saves it and ask view to show its information.
 */
-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    if (beacons.count > 0) {
        if(self.rangedBeacons.count > 0) {
            NSInteger index = 0;
            for(CLBeacon *oldBeacon in self.rangedBeacons){
                for(CLBeacon *newBeacon in beacons){
                    if([[[oldBeacon proximityUUID] UUIDString] isEqual:[[newBeacon proximityUUID] UUIDString]]){
                        [self.rangedBeacons replaceObjectAtIndex:index withObject:newBeacon];
                        NSLog(@"[INFO][LM] Beacon ranged:");
                        NSLog(@"[INFO][LM] -> %@", [[newBeacon proximityUUID] UUIDString]);
                    } else {
                        [self.rangedBeacons addObject:newBeacon];
                        NSLog(@"[INFO] Beacon ranged:");
                        NSLog(@"[INFO][LM] -> %@", [[newBeacon proximityUUID] UUIDString]);
                    }
                    
                    // Save measures
                    NSInteger indexData = 0;
                    for (CLBeacon *monitoredRegion in monitoredRegions) {
                        if ([[newBeacon proximityUUID] isEqual:[monitoredRegion proximityUUID]]){
                            NSNumber * rssi = [NSNumber numberWithInteger:[newBeacon rssi]];                            
                            [rssiMeasures[indexData] addObject:rssi];
                        }
                    }
                }
                index ++;
            }
        } else {
            self.rangedBeacons = [[NSMutableArray alloc] init];
            for (CLBeacon *beacon in beacons) {
                // Save ranged Beacons
                [self.rangedBeacons addObject:beacon];
                NSLog(@"[INFO] Beacon ranged:");
                NSLog(@"[INFO][LM] -> %@",  [[beacon proximityUUID] UUIDString]);
            }
        }
        
        // Ask view controller to refresh the canvas
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:self.rangedBeacons forKey:@"rangedBeacons"];        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshCanvas"
         object:nil
         userInfo:data];
    } else {
        NSLog(@"[INFO][LM] No beacons ranged.");
    }
    
}

- (void) radiolocator {
    
}

@end
