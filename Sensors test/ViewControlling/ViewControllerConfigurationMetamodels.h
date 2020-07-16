//
//  ViewControllerConfigurationMetamodels.h
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCDrawings.h"
#import "VCToolbar.h"
#import "MDType.h"
#import "MDRoutine.h"

/*!
 @class ViewControllerConfigurationMetamodels
 @discussion This class extends UIViewController and controls the metamodels configuration interface.
 */
@interface ViewControllerConfigurationMetamodels : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Tab controller
    UITabBarController * tabBar;
    
    // Varibles
    NSMutableArray * types;
    NSMutableArray * metamodels;
    
    // Creation and removing of types and metamodels
    UITextField * typeTextField;
    UITextField * metamodelTextField;
    BOOL removingFirstCell;
    NSString * nameTypeToRemove;
    // Creation routine
    BOOL userWantsToSetRoutine;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UITableView *tableMetamodels;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setTabBar:(UITabBarController *)givenTabBar;

@end
