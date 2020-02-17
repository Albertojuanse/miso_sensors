//
//  ViewControllerConfigurationBeacons.h
//  Sensors test
//
//  Created by Alberto J. on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RDPosition.h"
#import "VCToolbar.h"
#import "MDRoutine.h"

/*!
 @class ViewControllerConfigurationBeacons
 @discussion This class extends UIViewController and controls the beacons configuration interface.
 */
@interface ViewControllerConfigurationBeacons : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Tab controller
    UITabBarController * tabBar;
    
    // Varibles
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSMutableArray * items;
    NSMutableDictionary * chosenItem;    
    // User selection in main manu
    NSInteger selectedSegmentIndex;
    // Creation routine
    BOOL userWantsToSetRoutine;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UITextField *textX;
@property (weak, nonatomic) IBOutlet UITextField *textY;
@property (weak, nonatomic) IBOutlet UITextField *textZ;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *textUUID;
@property (weak, nonatomic) IBOutlet UITextField *textMajor;
@property (weak, nonatomic) IBOutlet UITextField *textMinor;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconUUID;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconMajor;
@property (weak, nonatomic) IBOutlet UILabel *labelBeaconMinor;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setTabBar:(UITabBarController *)givenTabBar;

@end
