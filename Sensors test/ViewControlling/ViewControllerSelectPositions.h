//
//  ViewControllerSelectPositions.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerThetaThetaLocating.h"
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerSelectPositions
 @discussion This class extends UIViewController and controls the menu to select the beacons and positions for locating porpuses.
 */

@interface ViewControllerSelectPositions : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // Beacons' region identifiers
    NSNumber * regionBeaconIdNumber;
    NSNumber * regionPositionIdNumber;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableItems;

- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic;
- (void) setSharedData:(SharedData *)newSharedData;
- (void) setMotionManager:(MotionManager *)newMotion;
- (void) setLocationManager:(LocationManagerDelegate *)newLocation;

- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionIdNumber;
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionIdNumber;

@end
