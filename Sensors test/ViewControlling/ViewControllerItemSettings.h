//
//  ViewControllerItemSettings.h
//  Sensors test
//
//  Created by Alberto J. on 30/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "LMDelegateCalibrating.h"

/*!
 @class ViewControllerItemSettings
 @discussion This class extends UIViewController and controls the menu to edit any positioned component of the model.
 */
@interface ViewControllerItemSettings : UIViewController <UIPopoverPresentationControllerDelegate> {
    
    // Other components
    SharedData * sharedData;
    LMDelegateCalibrating * location;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Beacons' region identifiers
    NSNumber * itemBeaconIdNumber;
    NSNumber * itemPositionIdNumber;
    
    // Variables
    NSString * deviceUUID;
    NSMutableDictionary * itemChosenByUser;
    BOOL calibrating;
}

@property (weak, nonatomic) IBOutlet UIButton * cancelButton;
@property (weak, nonatomic) IBOutlet UIButton * editButton;
@property (weak, nonatomic) IBOutlet UILabel * sortLabel;
@property (weak, nonatomic) IBOutlet UILabel * uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel * majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UIButton * calibrateButton;
@property (weak, nonatomic) IBOutlet UIButton * firstButton;
@property (weak, nonatomic) IBOutlet UIButton * secondButton;
@property (weak, nonatomic) IBOutlet UILabel *firstDistanceLabel;
@property (weak, nonatomic) IBOutlet UITextField *secondDistanceText;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setItemBeaconIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemPositionIdNumber:(NSNumber *)givenRegionIdNumber;
- (void) setItemChosenByUser:(NSMutableDictionary *)itemChosenByUser;
- (void) setDeviceUUID:(NSString *)givenDeviceUUID;

@end
