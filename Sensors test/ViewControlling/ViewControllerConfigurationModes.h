//
//  ViewControllerConfigurationModes.h
//  Sensors test
//
//  Created by Alberto J. on 23/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDMode.h"
#import "MDMetamodel.h"
#import "MDRoutine.h"
#import "VCToolbar.h"

/*!
 @class ViewControllerConfigurationModes
 @discussion This class extends UIViewController and controls the modes configuration interface.
 */
@interface ViewControllerConfigurationModes : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Tab controller
    UITabBarController * tabBar;
    
    NSMutableArray * metamodels;
    
    // Creation and removing of models and metamodels
    BOOL removingFirstCell;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableModes;
@property (weak, nonatomic) IBOutlet UITableView *tableMetamodels;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setTabBar:(UITabBarController *)givenTabBar;

@end
