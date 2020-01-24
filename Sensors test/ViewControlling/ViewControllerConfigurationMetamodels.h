//
//  ViewControllerConfigurationMetamodels.h
//  Sensors test
//
//  Created by MISO on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCToolbar.h"

/*!
 @class ViewControllerConfigurationMetamodels
 @discussion This class extends UIViewController and controls the metamodels configuration interface.
 */
@interface ViewControllerConfigurationMetamodels : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Varibles
    NSMutableArray * types;
    NSMutableArray * metamodels;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITableView *tableMetamodels;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;

@end
