//
//  ViewControllerFinalModel.h
//  Sensors test
//
//  Created by Alberto J. on 8/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MotionManager.h"
#import "SharedData.h"
#import "ViewControllerMainMenu.h"
#import "NSMutableArray+Printable.h"

/*!
 @class ViewControllerFinalModel
 @discussion This class extends UIViewController and shows the final model.
 */
@interface ViewControllerFinalModel : UIViewController {
    
    // Other components
    SharedData * sharedData;
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Naming concurrency
    BOOL userDidTrySubmit;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UITextView *modelText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;

@end
