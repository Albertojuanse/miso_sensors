//
//  ViewControllerThetaThetaLocating.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"
#import "Canvas.h"

/*!
 @class ViewControllerThetaThetaLocating
 @discussion This class extends UIViewController and controls the interface for locating the device with the theta theta location system.
 */
@interface ViewControllerThetaThetaLocating : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // Beacons' region identifiers
    NSNumber * regionBeaconIdNumber;
    NSNumber * regionPositionIdNumber;
    
    // For update canvas
    NSMutableDictionary * measuresDic;
    NSMutableDictionary * locatedDic;
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableItemsChosen;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;

- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;

- (void) setRegionBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setRegionPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
