//
//  ViewControllerRhoThetaModeling.h
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"
#import "ViewControllerModellingRhoThetaModeling.h"
#import "LMDelegateRhoThetaModelling.h"
#import "RDRhoThetaSystem.h"
#import "Canvas.h"

/*!
 @class ViewControllerRhoThetaModeling
 @discussion This class extends UIViewController and controls the interface for modeling with the rho theta location system.
 */
@interface ViewControllerRhoThetaModeling : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    RDRhoThetaSystem * thetaThetaSystem;
    LMDelegateRhoThetaModelling * location;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Variables
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * deviceUUID;
    MDMode * mode;
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setLocationManager:(LMDelegateRhoThetaModelling *)givenLocation;
- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setDeviceUUID:(NSString *)givenDeviceUUID;

@end
