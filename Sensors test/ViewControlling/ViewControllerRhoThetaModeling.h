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
#import "Canvas.h"

/*!
 @class ViewControllerRhoThetaModeling
 @discussion This class extends UIViewController and controls the interface for modeling with the rho theta location system.
 */
@interface ViewControllerRhoThetaModeling : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // Session and user context
    NSMutableDictionary * credentialsUserDic;
    
    // Beacons' region identifiers
    NSNumber * regionBeaconIdNumber;
    NSNumber * regionPositionIdNumber;
    
}

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonMeasure;

- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;

- (void) setRegionBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setRegionPositionIdNumber:(NSNumber *)givenRegionIdNumber;

@end
