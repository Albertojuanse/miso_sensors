//
//  ViewControllerMonitoring.h
//  Sensors test
//
//  Created by Alberto J. on 18/12/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDMode.h"
#import "VCDrawings.h"
#import "ViewControllerMainMenu.h"
#import "ViewControllerFinalModel.h"
#import "Canvas.h"
#import "LMDelegateMonitoring.h"

/*!
 @class ViewControllerMonitoring
 @discussion This class extends UIViewController and controls the interface for locating the device with the theta theta location system.
 */
@interface ViewControllerMonitoring : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    LMDelegateMonitoring * location;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Variables
    NSString * locatedPositionUUID; // This one changes when the user measures and generates a new position for the device.
    NSMutableDictionary * itemChosenByUserAsDevicePosition;
    MDMode * mode;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UITableView *tableRegister;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;

@end


