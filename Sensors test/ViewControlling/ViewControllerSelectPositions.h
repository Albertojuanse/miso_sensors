//
//  ViewControllerSelectPositions.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMonitoring.h"
#import "ViewControllerThetaThetaLocating.h"
#import "ViewControllerRhoRhoLocating.h"
#import "ViewControllerRhoThetaModeling.h"
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerSelectPositions
 @discussion This class extends UIViewController and controls the menu to select the beacons and positions for locating porpuses.
 */
@interface ViewControllerSelectPositions : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableItems;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
