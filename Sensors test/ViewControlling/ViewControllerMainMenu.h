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
#import "ViewControllerRhoRhoModelling.h"

/*!
 @class ViewControllerMainMenu
 @discussion This class extends UIViewController and controls the main menu interface.
 */
@interface ViewControllerMainMenu : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Modes
    NSMutableArray * modes;
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSMutableArray * beaconsRegistered;
    NSNumber * regionIdNumber;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableBeacons;

- (void) setBeaconsRegistered:(NSMutableArray *)newBeaconsRegistered;
- (void) setRegionIdNumber:(NSNumber *)newRegionIdNumber;

@end


