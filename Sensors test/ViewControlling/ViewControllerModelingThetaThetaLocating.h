//
//  ViewControllerModelingThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. 2/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerThetaThetaLocating.h"
#import "ViewControllerFinalModel.h"
#import "LMDelegateThetaThetaLocating.h"
#import "RDThetaThetaSystem.h"
#import "MotionManager.h"
#import "Canvas.h"

/*!
 @class ViewControllerModelingThetaThetaLocating
 @discussion This class extends UIViewController and controls the interface for locating the device with the theta theta location system.
 */
@interface ViewControllerModelingThetaThetaLocating : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    RDThetaThetaSystem * thetaThetaSystem;
    MotionManager * motion;
    LMDelegateThetaThetaLocating * location;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Reference; this flag is set 'true' when the user has chosen the item from refenrece from.
    NSMutableDictionary * sourceItem;
    NSMutableDictionary * targetItem;
    BOOL flagReference;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * locatedPositionUUID; // This one changes when the user measures and generates a new position for the device.
    NSString * deviceUUID;
    MDMode * mode;
    
}
@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableItemsChosen;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonReference;
@property (weak, nonatomic) IBOutlet UIButton *buttonModify;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LMDelegateThetaThetaLocating *)givenLocation;
- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setDeviceUUID:(NSString *)givenDeviceUUID;

@end
