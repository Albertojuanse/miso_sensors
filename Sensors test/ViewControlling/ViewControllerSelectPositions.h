//
//  ViewControllerSelectPositions.h
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCDrawings.h"
#import "ViewControllerMonitoring.h"
#import "ViewControllerMainMenu.h"
#import "ViewControllerEditing.h"
#import "VCModeDelegate.h"

/*!
 @class ViewControllerSelectPositions
 @discussion This class extends UIViewController and controls the menu to select the beacons and positions for locating porpuses.
 */
@interface ViewControllerSelectPositions : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Other components
    SharedData * sharedData;
    // Delegate class with the methods to define the behaviour of this view in each mode
    id<VCModeDelegate> delegate;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UITableView *tableItems;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;

@end
