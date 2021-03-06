//
//  ViewControllerConfigurationTypes.h
//  Sensors test
//
//  Created by Alberto J. on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "VCDrawings.h"
#import "VCToolbar.h"
#import "MDType.h"
#import "MDAttribute.h"
#import "MDRoutine.h"

/*!
 @class ViewControllerConfigurationTypes
 @discussion This class extends UIViewController and controls the modes configuration interface.
 */
@interface ViewControllerConfigurationTypes : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Tab controller
    UITabBarController * tabBar;
    
    // Varibles
    NSMutableArray * types;
    MDType * chosenType;
    UIImagePickerController * imagePicker;
    // Creation routine
    BOOL userWantsToSetRoutine;
    
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UITableView *tableTypes;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textAttributes;
@property (weak, nonatomic) IBOutlet UITextField *textIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonCam;
@property (weak, nonatomic) IBOutlet UITextView *textModel;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setTabBar:(UITabBarController *)givenTabBar;

@end
