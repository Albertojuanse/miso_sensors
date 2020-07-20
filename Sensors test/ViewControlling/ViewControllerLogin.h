//
//  ViewControllerLogin.h
//  Sensors test
//
//  Created by Alberto J. on 5/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VCDrawings.h"
#import "ViewControllerMainMenu.h"
#import "TabBarControllerConfiguration.h"

/*!
 @class ViewControllerLogin
 @discussion This class extends UIViewController and controls the log in interface.
 */
@interface ViewControllerLogin : UIViewController {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    NSMutableArray * credentialsUserDicArray;
    
    BOOL userDidAskLogOut;
    BOOL userDidAskSignOut;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextField *passText;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignin;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfiguration;
@property (weak, nonatomic) IBOutlet UIButton *buttonReset;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setUserDidAskLogOut:(BOOL)givenUserDidAskLogOut;
- (void) setUserDidAskSignOut:(BOOL)givenUserDidAskSignOut;

@end
