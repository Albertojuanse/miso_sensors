//
//  ViewControllerConfiguration.h
//  Sensors test
//
//  Created by Alberto J. on 23/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerLogin.h"

/*!
 @class ViewControllerConfiguration
 @discussion This class extends UIViewController and controls the configuration interface.
 */
@interface ViewControllerConfiguration : UIViewController {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    BOOL userDidAskLogOut;
    BOOL userDidAskSignOut;
    
}

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;

@end
