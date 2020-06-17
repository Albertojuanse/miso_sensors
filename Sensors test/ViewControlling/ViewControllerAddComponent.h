//
//  ViewControllerAddComponent.h
//  Sensors test
//
//  Created by Alberto J. on 15/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "MDAttribute.h"
#import "MDType.h"
#import "VCModeDelegate.h"
#import "VCComponent.h"
#import "VCComponentInfo.h"

/*!
 @class ViewControllerAddComponent
 @discussion This class extends UIViewController and controls the menu to add a positioned component to the model.
 */
@interface ViewControllerAddComponent : UIViewController <UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    // Other components
    SharedData * sharedData;
    // Delegate class with the methods to define the behaviour of this view in each mode
    id<VCModeDelegate> delegate;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Variables
    
}

@property (weak, nonatomic) IBOutlet UIButton * cancelButton;
@property (weak, nonatomic) IBOutlet UIButton * editButton;
@property (weak, nonatomic) IBOutlet UITableView * tableItems;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setVCEditingDelegate:(id<VCModeDelegate>)givenDelegate;

@end
