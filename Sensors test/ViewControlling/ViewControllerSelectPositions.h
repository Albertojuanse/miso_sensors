//
//  ViewControllerSelectPositions.h
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
 @class ViewControllerSelectPositions
 @discussion This class extends UIViewController and controls the menu to select the beacons and positions for locating porpuses.
 */

@interface ViewControllerSelectPositions : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSString * chosenMode;
    
    // Beacons' region identifiers
    NSMutableArray * beaconsAndPositionsRegistered;
    NSMutableArray * typesRegistered;
    NSMutableArray * beaconsAndPositionsChosen;
    NSMutableArray * beaconsAndPositionsChosenIndexes;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableBeaconsAndPositions;

- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered;
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered;
- (void) setChosenMode:(NSString *)chosenMode;

@end
