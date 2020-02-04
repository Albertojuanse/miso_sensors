//
//  TabBarControllerConfiguration.h
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MDType.h"
#import "MDMetamodel.h"
#import "VCToolbar.h"
#import "ViewControllerLogin.h"
#import "ViewControllerConfigurationTypes.h"
#import "ViewControllerConfigurationMetamodels.h"
#import "ViewControllerConfigurationModes.h"
#import "ViewControllerConfigurationBeacons.h"

/*!
 @class TabBarConfiguration
 @discussion This class extends UITabBarController and controls the tab-conmmutation of configuration interfaces.
 */
@interface TabBarConfiguration : UITabBarController <UITabBarControllerDelegate> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Tab views
    ViewControllerConfigurationTypes * viewControllerConfigurationTypes;
    ViewControllerConfigurationMetamodels * viewControllerConfigurationMetamodels;
    ViewControllerConfigurationModes * viewControllerConfigurationModes;
    ViewControllerConfigurationBeacons * viewControllerConfigurationBeacons;
    
}

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;

@end
