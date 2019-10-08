//
//  ViewControllerFinalModel.h
//  Sensors test
//
//  Created by Alberto J. on 8/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MotionManager.h"
#import "LocationManagerDelegate.h"
#import "SharedData.h"
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerFinalModel
 @discussion This class extends UIViewController and shows the final model.
 */
@interface ViewControllerFinalModel : UIViewController {
    
    // Other components
    SharedData * sharedData;
    MotionManager * motion;
    LocationManagerDelegate * location;
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    
}

@property (weak, nonatomic) IBOutlet UITextView *modelText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;

- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation;

- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;


@end
