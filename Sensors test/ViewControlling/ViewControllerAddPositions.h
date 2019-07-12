//
//  ViewControllerAddPositions.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerThetaThetaLocating.h"
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerAddPositions
 @discussion This class extends UIViewController and controls the menu to add the beacons positions for locating porpuses.
 */

@interface ViewControllerAddPositions : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSMutableArray * beaconsAndPositionsRegistered;
    NSString * uuidChosenByUser;    
    
}

@property (weak, nonatomic) IBOutlet UITextField *textX;
@property (weak, nonatomic) IBOutlet UITextField *textY;
@property (weak, nonatomic) IBOutlet UITextField *textZ;
@property (weak, nonatomic) IBOutlet UITableView *tableBeacons;
@property (weak, nonatomic) IBOutlet UIButton *buttonSet;

- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered;
- (void) setChosenMode:(NSString *)chosenMode;

@end
