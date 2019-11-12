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
#import "RDRhoRhoSystem.h"
#import "RDRhoThetaSystem.h"
#import "RDThetaThetaSystem.h"
#import "SharedData.h"
#import "ViewControllerLogin.h"
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
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    RDThetaThetaSystem * thetaThetaSystem;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Modes
    NSMutableArray * modes;
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    
    // Login
    BOOL userDidAskLogOut;
    BOOL userDidAskSignOut;
}

@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet UILabel *loginText;


- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;


- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
