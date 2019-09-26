//
//  ViewControllerAddBeaconMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RDPosition.h"
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerAddBeaconMenu
 @discussion This class extends UIViewController and controls the main menu for adding new beacons to the app.
 */
@interface ViewControllerAddBeaconMenu : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    
    // User selection in main manu
    NSInteger selectedSegmentIndex;
    
}


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *labelBeacon1;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconUUID;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconMajor;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconMinor;
@property (weak, nonatomic) IBOutlet UITextField *textUUID;
@property (weak, nonatomic) IBOutlet UITextField *textMajor;
@property (weak, nonatomic) IBOutlet UITextField *textMinor;
@property (weak, nonatomic) IBOutlet UILabel *labelBeacon2;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconX;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconY;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconZ;
@property (weak, nonatomic) IBOutlet UITextField *textBeaconX;
@property (weak, nonatomic) IBOutlet UITextField *textBeaconY;
@property (weak, nonatomic) IBOutlet UITextField *textBeaconZ;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconError;
@property (weak, nonatomic) IBOutlet UIButton *buttonBeaconDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonBeaconBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonBeaconAdd;

@property (weak, nonatomic) IBOutlet UILabel *labelPosition1;
@property (weak, nonatomic) IBOutlet UILabel *labelPositionX;
@property (weak, nonatomic) IBOutlet UILabel *labelPositionY;
@property (weak, nonatomic) IBOutlet UILabel *labelPositionZ;
@property (weak, nonatomic) IBOutlet UITextField *textPositionX;
@property (weak, nonatomic) IBOutlet UITextField *textPositionY;
@property (weak, nonatomic) IBOutlet UITextField *textPositionZ;
@property (weak, nonatomic) IBOutlet UILabel *labelPositionError;
@property (weak, nonatomic) IBOutlet UIButton *buttonPositionDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonPositionBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonPositionAdd;

@property (weak, nonatomic) IBOutlet UITextField *textType;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;


- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;

- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end



