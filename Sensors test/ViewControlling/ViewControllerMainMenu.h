//
//  ViewControllerMainMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "MDRoutine.h"
#import "MDMetamodel.h"
#import "MDType.h"
#import "MDMode.h"
#import "LMDelegateGPS.h"
#import "LMDelegateHeading.h"
#import "LMDelegateCalibrating.h"
#import "VCToolbar.h"
#import "ViewControllerLogin.h"
#import "ViewControllerSelectPositions.h"
#import "ViewControllerItemSettings.h"

/*!
 @class ViewControllerMainMenu
 @discussion This class extends UIViewController and controls the main menu interface.
 */
@interface ViewControllerMainMenu : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    LMDelegateGPS * locationGPS;
    LMDelegateHeading * locationHeading;
    LMDelegateCalibrating * locationCalibrating;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Modes
    MDMode * chosenMode;
    
    // Variables
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * deviceUUID;
    
    // Login
    BOOL userDidAskLogOut;
    BOOL userDidAskSignOut;
    BOOL userDidLogIn;
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
