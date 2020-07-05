//
//  ViewControllerEditing.h
//  Sensors test
//
//  Created by Alberto J. on 12/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ViewControllerSelectPositions.h"
#import "ViewControllerAddComponent.h"
#import "ViewControllerEditComponent.h"
#import "ViewControllerMeasure.h"
#import "VCDrawings.h"

#import "VCModeDelegate.h"
#import "VCModeDelegateThetaThetaLocating.h"
#import "VCModeDelegateRhoThetaModelling.h"

#import "LMRanging.h"
#import "LMDelegateRhoRhoLocating.h"
#import "LMDelegateRhoRhoModelling.h"
#import "LMDelegateRhoThetaModelling.h"
#import "LMDelegateThetaThetaLocating.h"

#import "RDRhoRhoSystem.h"
#import "RDRhoThetaSystem.h"
#import "RDThetaThetaSystem.h"

#import "MotionManager.h"
#import "Canvas.h"

/*!
 @class ViewControllerEditing
 @discussion This class extends UIViewController and controls the interface for editing a model using a location system in any mode.
 */
@interface ViewControllerEditing : UIViewController {
    
    // Other components
    SharedData * sharedData;
    RDRhoRhoSystem * rhoRhoSystem;
    RDRhoThetaSystem * rhoThetaSystem;
    RDThetaThetaSystem * thetaThetaSystem;
    id<CLLocationManagerDelegate> location;
    LMRanging * ranger;
    MotionManager * motion;
    // Delegate class with the methods to define the behaviour of this view in each mode
    id<VCModeDelegate> delegate;
    
    // Session and user context
    // The first credentials dictionary is for security issues and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    NSMutableDictionary * credentialsUserDic;
    NSMutableDictionary * userDic;
    
    // Context variables
    NSString * locatedPositionUUID; // This one changes when the user measures and generates a new position for the device.
    NSString * deviceUUID;
    MDMode * mode;
    NSMutableArray * modeMetamodels;
    NSMutableArray * modeTypes;
    
    // Adding alert view's variables
    UITextField * xValueTextField;
    UITextField * yValueTextField;
    UITextField * zValueTextField;
    
    // Delegate variables
    NSString * errorDescription;
    NSString * idleStateMessage;
    NSString * measuringStateMessage;
}

@property (weak, nonatomic) IBOutlet VCToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *loginText;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet Canvas *canvas;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddManual;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddMeasure;

// Methods for passing volatile variables that disappear when segue between views
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic;
- (void) setUserDic:(NSMutableDictionary *)givenUserDic;
- (void) setSharedData:(SharedData *)givenSharedData;
- (void) setMotionManager:(MotionManager *)givenMotion;
- (void) setLocationManager:(CLLocationManager *)givenLocationManager;
- (void) setDeviceUUID:(NSString *)givenDeviceUUID;

@end
