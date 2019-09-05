//
//  ViewControllerLogin.h
//  Sensors test
//
//  Created by Alberto J. on 5/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerMainMenu.h"

/*!
 @class ViewControllerLogin
 @discussion This class extends UIViewController and controls the log in interface.
 */
@interface ViewControllerLogin : UIViewController {
    
    // When the user logs in a credentials dictionary is created if access is granted.
    NSMutableDictionary * credentialsUserDic;
    NSMutableArray * credentialsUserDicArray;
    
}

@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextField *passText;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignin;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;

- (void) setCredentialsUserDic:(NSMutableDictionary*)newCredentialsUserDic;

@end



