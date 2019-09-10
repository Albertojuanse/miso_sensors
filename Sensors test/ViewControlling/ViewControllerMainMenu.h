//
//  ViewControllerMainMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MotionManager.h"
#import "LocationManagerDelegate.h"
#import "SharedData.h"
#import "ViewControllerAddBeaconMenu.h"
#import "ViewControllerSelectPositions.h"
#import "ViewControllerRhoRhoModeling.h"
#import "ViewControllerRhoThetaModeling.h"

/*!
 @class ViewControllerMainMenu
 @discussion This class extends UIViewController and controls the main menu interface.
 */
@interface ViewControllerMainMenu : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // Modes
    NSMutableArray * modes;
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSNumber * regionBeaconIdNumber;
    NSNumber * regionPositionIdNumber;
    

    
}

@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;


- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic;
- (void) setSharedData:(SharedData *)newSharedData;
- (void) setMotionManager:(MotionManager *)newMotion;
- (void) setLocationManager:(LocationManagerDelegate *)newLocation;


- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionIdNumber;
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionIdNumber;

@end


