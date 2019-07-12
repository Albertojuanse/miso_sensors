//
//  ViewControllerAddBeaconMenu.h
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerAddBeaconMenu
 @discussion This class extends UIViewController and controls the main menu for adding new beacons to the app.
 */
@interface ViewControllerAddBeaconMenu : UIViewController{
    
    NSMutableArray * beaconsAndPositionsRegistered;
    NSNumber * regionIdNumber;
    NSString * uuidChosenByUser;
}

@property (weak, nonatomic) IBOutlet UITextField *textUUID;
@property (weak, nonatomic) IBOutlet UITextField *textMajor;
@property (weak, nonatomic) IBOutlet UITextField *textMinor;
@property (weak, nonatomic) IBOutlet UILabel *textError;
@property (weak, nonatomic) IBOutlet UITextField *textX;
@property (weak, nonatomic) IBOutlet UITextField *textY;
@property (weak, nonatomic) IBOutlet UITextField *textZ;

- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered;
- (void) setRegionIdNumber:(NSNumber *)newRegionIdNumber;
- (void) setUuidChosenByUser:(NSString *)uuidChosenByUser;

@end



