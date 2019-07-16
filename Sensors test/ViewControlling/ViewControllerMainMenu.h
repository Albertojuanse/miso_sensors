//
//  ViewControllerMainMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerAddBeaconMenu.h"
#import "ViewControllerSelectPositions.h"
#import "ViewControllerRhoRhoModeling.h"
#import "ViewControllerRhoThetaModeling.h"

/*!
 @class ViewControllerMainMenu
 @discussion This class extends UIViewController and controls the main menu interface.
 */
@interface ViewControllerMainMenu : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Modes
    NSMutableArray * modes;
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSMutableArray * beaconsAndPositionsRegistered;
    NSMutableArray * entitiesRegistered;
    NSNumber * regionBeaconIdNumber;
    NSNumber * regionPositionIdNumber;
    
    // user choose to pass to add beacon and positions view controller; one of both must be alwais nil
    NSString * uuidChosenByUser;
    RDPosition * positionChosenByUser;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableBeaconsAndPositions;

- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered;
- (void) setEntitiesRegistered:(NSMutableArray *)newEntitiesRegistered;
- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionIdNumber;
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionIdNumber;

@end


