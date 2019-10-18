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
#import "Canvas.h"
#import "SDPrintableMutableArray.h

/*!
 @class ViewControllerModelingThetaThetaLocating
 @discussion This class extends UIViewController and controls the interface for locating the device with the theta theta location system.
 */
@interface ViewControllerModelingThetaThetaLocating : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Reference; this flag is set 'true' when the user has chosen the item from refenrece from.
    NSMutableDictionary * itemFrom;
    NSMutableDictionary * itemTo;
    BOOL flagReference;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    NSString * locatedPositionUUID; // This one changes when the user measures and generates a new position for the device.
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableItemsChosen;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet Canvas *canvas;

- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;

- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
