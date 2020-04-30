//
//  ViewControllerItemSettings.m
//  Sensors test
//
//  Created by Alberto J. on 30/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerItemSettings.h"

@implementation ViewControllerItemSettings

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"itemDic viewDidLoad: %@", itemChosenByUser);
    
    // Visualization
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                        green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:1.0
                                         ]
                               forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                        green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:0.3
                                    ]
                               forState:UIControlStateDisabled];
    [self.calibrateButton setEnabled:YES];
    [self.firstButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                     ]
                           forState:UIControlStateNormal];
    [self.firstButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:0.3
                                     ]
                           forState:UIControlStateDisabled];
    [self.firstButton setEnabled:NO];
    [self.secondButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.secondButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:0.3
                                      ]
                            forState:UIControlStateDisabled];
    [self.secondButton setEnabled:NO];
    
    // Variables
    calibrating = NO;
}

/*!
@method viewDidLoad
@discussion This method is called when the view is going to be shown.
*/
- (void)viewWillAppear:(BOOL)animated
{
    // Retrieve and show information from item
    if (itemChosenByUser) {
        
        // General information
        NSString * sort = itemChosenByUser[@"sort"];
        NSString * itemUUID = itemChosenByUser[@"uuid"];
        NSString * major = itemChosenByUser[@"major"];
        NSString * minor = itemChosenByUser[@"minor"];
        if (sort) {
            [self.sortLabel setText:sort];
        } else {
            [self.sortLabel setText:@"(null)"];
        }
        if (itemUUID) {
            [self.uuidLabel setText:itemUUID];
        } else {
            [self.uuidLabel setText:@"(null)"];
        }
        
        if (major) {
            [self.majorLabel setText:major];
        } else {
            [self.majorLabel setText:@"(null)"];
        }
        
        if (minor) {
            [self.minorLabel setText:minor];
        } else {
            [self.minorLabel setText:@"(null)"];
        }
        
        // Calibration information
        
    } else {
        NSLog(@"[ERROR][VCIS] View will appear without itemChosenByUser variable.");
    }
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firstStepFinished:)
                                                 name:@"vcItemSettings/firstStepFinished"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firstStepFinishedWithErrors:)
                                                 name:@"vcItemSettings/firstStepFinishedWithErrors"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(secondStepFinished:)
                                                 name:@"vcItemSettings/secondStepFinished"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(secondStepFinishedWithErrors:)
                                                 name:@"vcItemSettings/secondStepFinishedWithErrors"
                                               object:nil];
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance methods
/*!
 @method setCredentialsUserDic:
 @discussion This method sets the NSMutableDictionary with the security purposes user credentials.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
}

/*!
 @method setUserDic:
 @discussion This method sets the NSMutableDictionary with the identifying purposes user credentials.
 */
- (void) setUserDic:(NSMutableDictionary *)givenUserDic
{
    userDic = givenUserDic;
}

/*!
 @method setSharedData:
 @discussion This method sets the shared data collection.
 */
- (void) setSharedData:(SharedData *)givenSharedData
{
    sharedData = givenSharedData;
}

/*!
 @method setItemBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setItemBeaconIdNumber:(NSNumber *)givenItemBeaconIdNumber
{
    itemBeaconIdNumber = givenItemBeaconIdNumber;
}

/*!
 @method setItemPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setItemPositionIdNumber:(NSNumber *)givenItemPositionIdNumber
{
    itemPositionIdNumber = givenItemPositionIdNumber;
}

/*!
 @method setItemChosenByUser:
 @discussion This method sets the NSMutableDictionary variable 'itemChosenByUser'.
 */
- (void) setItemChosenByUser:(NSMutableDictionary *)givenItemChosenByUser
{
    itemChosenByUser = givenItemChosenByUser;
}

/*!
 @method setDeviceUUID:
 @discussion This method sets the NSString variable 'deviceUUID'.
 */
- (void) setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
}

#pragma mark - Notification event handles
/*!
 @method firstStepFinished:
 @discussion This method handles the event that notifies that the first calibration step is done.
 */
- (void)firstStepFinished:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"vcItemSettings/firstStepFinished"]){
        NSLog(@"[NOTI][LMR] Notification \"vcMainMenu/firstStepFinished\" recived.");
        
        // Orchestrate and set user idle
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Layout
        [self.secondButton setEnabled:YES];
    }
}

/*!
 @method firstStepFinishedWithErrors:
 @discussion This method handles the event that notifies that the first calibration step failed.
 */
- (void)firstStepFinishedWithErrors:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"vcItemSettings/firstStepFinishedWithErrors"]){
        NSLog(@"[NOTI][LMR] Notification \"vcMainMenu/firstStepFinishedWithErrors\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Alert the user
        [self alertUserWithTitle:@"Calibration error"
                         message:@"Calibration process failed in its first step due an unknown error. Please, try again."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }];
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCMM] Notification \"lmdCalibrating/stop\" posted.");
        location = nil;
        
        // Layout
        [self.calibrateButton setEnabled:YES];
    }
}

/*!
 @method secondStepFinished:
 @discussion This method handles the event that notifies that the second calibration step is done.
 */
- (void)secondStepFinished:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"vcItemSettings/secondStepFinished"]){
        NSLog(@"[NOTI][LMR] Notification \"vcMainMenu/secondStepFinished\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCMM] Notification \"lmdCalibrating/stop\" posted.");
        location = nil;
        
        // Layout
        [self.calibrateButton setEnabled:YES];
    }
}

/*!
 @method secondStepFinishedWithErrors:
 @discussion This method handles the event that notifies that the second calibration step failed.
 */
- (void)secondStepFinishedWithErrors:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"vcItemSettings/secondStepFinishedWithErrors"]){
        NSLog(@"[NOTI][LMR] Notification \"vcMainMenu/secondStepFinishedWithErrors\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Alert the user
        [self alertUserWithTitle:@"Calibration error"
                         message:@"Calibration process failed in its second step due an unknown error. Please, try again."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }];
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCMM] Notification \"lmdCalibrating/stop\" posted.");
        location = nil;
        
        // Layout
        [self.calibrateButton setEnabled:YES];
    }
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonCancel:
 @discussion This method handles the 'cancel' button action and segues back.
 */
- (IBAction)handleButtonCancel:(id)sender
{
    // Dismiss the popover view
    // TODO: Notify cancel event to location manager. Alberto J. 2020/04/30.
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonCancel:
@discussion This method handles the 'edit' button action, save the changes, and segues back.
*/
- (IBAction)handleButtonEdit:(id)sender
{
    // Dismiss the popover view
    // TODO: Notify cancel event to location manager if process is not finished. Alberto J. 2020/04/30.
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonCalibrate:
@discussion This method handles the 'calibrate' button action, instantiating the location manager and enabling the process.
*/
- (IBAction)handleButtonCalibrate:(id)sender
{
    // Layout
    [self.calibrateButton setEnabled:NO];
    [self.firstButton setEnabled:YES];
    
    // Components
    location = [[LMDelegateCalibrating alloc] initWithSharedData:sharedData
                                                         userDic:userDic
                                                      deviceUUID:deviceUUID
                                           andCredentialsUserDic:credentialsUserDic];
    
    // Variables
    calibrating = YES;
}

/*!
@method handleButtonFirst:
@discussion This method handles the 'first' button action, handleling the first step of calibration pocess.
*/
- (IBAction)handleButtonFirst:(id)sender
{
    // Orchestrate and set user measuring
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Layout
    [self.firstButton setEnabled:NO];
    
    // Ask Location manager to calibrate the beacon
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    // Create a copy of the current position for sending it; concurrence issues prevented
    NSString * uuidToCalibrate = itemChosenByUser[@"uuid"];
    [data setObject:uuidToCalibrate forKey:@"calibrationUUID"];
    // And send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/startFirstStep"
                                                        object:nil
                                                      userInfo:data];
    NSLog(@"[NOTI][VCMM] Notification \"lmdCalibrating/startFirstStep\" posted.");
    
}

/*!
@method handleButtonSecond:
@discussion This method handles the 'second' button action, handleling the second step of calibration pocess.
*/
- (IBAction)handleButtonSecond:(id)sender
{
    // Orchestrate and set user measuring
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Layout
    [self.secondButton setEnabled:NO];
    
    // Notify to location manager
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/startSecondStep"
                                                        object:nil];
    NSLog(@"[NOTI][VCMM] Notification \"lmdCalibrating/startSecondStep\" posted.");
    
}

/*!
 @method alertUserWithTitle:andMessage:
 @discussion This method alerts the user with a pop up window with a single "Ok" button given its message and title and lambda funcion handler.
 */
- (void) alertUserWithTitle:(NSString *)title
                    message:(NSString *)message
                 andHandler:(void (^)(UIAlertAction *action))handler;
{
    UIAlertController * alertUsersNotFound = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:handler
                                ];
    
    [alertUsersNotFound addAction:okButton];
    [self presentViewController:alertUsersNotFound animated:YES completion:nil];
    return;
}

#pragma mark - UIPopoverPresentationControllerDelegate methods
/*!
@method adaptivePresentationStyleForPresentationController:
@discussion This method is called by the UIPopoverPresentationControllerDelegate protocol.
*/
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

@end
