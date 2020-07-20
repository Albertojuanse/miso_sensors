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
    
    // Visualization
    [self loadLayout];
    
    // Variables
    calibrating = NO;
    
    // Load event listeners
    [self loadEventListeners];
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

/*!
 @method loadLayout
 @discussion This method loads the layout configurations.
 */
- (void)loadLayout
{
    // Toolbar layout
    UIColor * normalThemeColor = [VCDrawings getNormalThemeColor];
    UIColor * disabledThemeColor = [VCDrawings getDisabledThemeColor];
    
    [self.cancelButton setTitleColor:normalThemeColor
                            forState:UIControlStateNormal];
    [self.editButton setTitleColor:normalThemeColor
                          forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:normalThemeColor
                               forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:disabledThemeColor
                               forState:UIControlStateDisabled];
    [self.calibrateButton setEnabled:YES];
    [self.firstButton setTitleColor:normalThemeColor
                           forState:UIControlStateNormal];
    [self.firstButton setTitleColor:disabledThemeColor
                           forState:UIControlStateDisabled];
    [self.firstButton setEnabled:NO];
    [self.secondButton setTitleColor:normalThemeColor
                            forState:UIControlStateNormal];
    [self.secondButton setTitleColor:disabledThemeColor
                            forState:UIControlStateDisabled];
    [self.secondButton setEnabled:NO];
    
    [[self secondDistanceText] setText:@"2.0"];
}

/*!
@method loadEventListeners
@discussion This method loads the event listeners for this class.
*/
- (void)loadEventListeners
{
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
 @method setItemChosenByUser:
 @discussion This method sets the NSMutableDictionary variable 'itemChosenByUser'.
 */
- (void) setItemChosenByUser:(NSMutableDictionary *)givenItemChosenByUser
{
    itemChosenByUser = givenItemChosenByUser;
}

#pragma mark - Notification event handles
/*!
 @method firstStepFinished:
 @discussion This method handles the event that notifies that the first calibration step is done.
 */
- (void)firstStepFinished:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"vcItemSettings/firstStepFinished"]){
        NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/firstStepFinished\" recived.");
        
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
        NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/firstStepFinishedWithErrors\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                             andWithCredentialsUserDic:credentialsUserDic];
        
        // Retrieve its information
        NSDictionary * data = notification.userInfo;
        NSString * consecutiveInvalidMeasuresError = data[@"consecutiveInvalidMeasures"];
        if (consecutiveInvalidMeasuresError) {
            if ([consecutiveInvalidMeasuresError isEqualToString:@"consecutiveInvalidMeasures"]) {
                // Alert the user
                [self alertUserWithTitle:@"Calibration error"
                                 message:@"Calibration process failed in its first step due to too many measures were invalid. Please, try again."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }];
            }
        } else {
            // Alert the user
            [self alertUserWithTitle:@"Calibration error"
                             message:@"Calibration process failed in its first step due an unknown error. Please, try again."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }];
        }
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/stop\" posted.");
        // Remove all measures
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
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
        NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/secondStepFinished\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Get variables and update
        NSDictionary * data = notification.userInfo;
        NSMutableDictionary * itemToCalibrate = data[@"itemToCalibrate"];
        itemChosenByUser[@"refRSSI"] = itemToCalibrate[@"refRSSI"];
        itemChosenByUser[@"refDistance"] = itemToCalibrate[@"refDistance"];
        itemChosenByUser[@"attenuationFactor"] = itemToCalibrate[@"attenuationFactor"];
        itemChosenByUser[@"attenuationDistance"] = itemToCalibrate[@"attenuationDistance"];
        [self updatePersistentItemsWithItem:itemChosenByUser];
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/stop\" posted.");
        // Remove all measures
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
        location = nil;
        ranger = nil;
        
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
        NSLog(@"[NOTI][LMR] Notification \"vcItemSettings/secondStepFinishedWithErrors\" recived.");
        
        // Orchestrate and set user idle
        calibrating = NO;
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                             andWithCredentialsUserDic:credentialsUserDic];
        
        // Retrieve its information
        NSDictionary * data = notification.userInfo;
        NSString * consecutiveInvalidMeasuresError = data[@"consecutiveInvalidMeasures"];
        if (consecutiveInvalidMeasuresError) {
            if ([consecutiveInvalidMeasuresError isEqualToString:@"consecutiveInvalidMeasures"]) {
                // Alert the user
                [self alertUserWithTitle:@"Calibration error"
                                 message:@"Calibration process failed in its first step due to too many measures were invalid. Please, try again."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }];
            }
        } else {
            // Alert the user
            [self alertUserWithTitle:@"Calibration error"
                             message:@"Calibration process failed in its first step due an unknown error. Please, try again."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }];
        }
        
        // Deallocate location manager; ARC disposal.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                            object:nil];
        NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/stop\" posted.");
        // Remove all measures
        [sharedData resetMeasuresWithCredentialsUserDic:credentialsUserDic];
        location = nil;
        ranger = nil;
        
        // Layout
        [self.calibrateButton setEnabled:YES];
    }
}

/*!
 @method updatePersistentItemsWithItem:
 @discussion This method is called when creates a new item to upload it.
 */
- (BOOL)updatePersistentItemsWithItem:(NSMutableDictionary *)itemDic
{
    // Set the variable areItems as YES
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
    NSData * areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
    
    // Remove the item; warning, THIS is not done in other copies of the method
    NSString * itemToRemoveIdentifier = itemDic[@"identifier"];
    NSString * itemKeyToRemove = [@"es.uam.miso/data/items/items/"
                                  stringByAppendingString:itemToRemoveIdentifier];
    [userDefaults removeObjectForKey:itemKeyToRemove];
    
    // Get the index and upload it
    NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
    NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
    if (!itemsIndex) {
        itemsIndex = [[NSMutableArray alloc] init];
    }
    NSString * itemIdentifier = itemDic[@"identifier"];
    [itemsIndex addObject:itemIdentifier];
    itemsIndexData = nil; // ARC disposal
    itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
    [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
    
    // Save the item itself
    NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:itemDic];
    NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
    [userDefaults setObject:itemData forKey:itemKey];
    
    return YES;
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonCancel:
 @discussion This method handles the 'cancel' button action and segues back.
 */
- (IBAction)handleButtonCancel:(id)sender
{
    // Dismiss the popover view
    // Deallocate location manager; ARC disposal.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                        object:nil];
    NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/stop\" posted.");
    location = nil;
    ranger = nil;
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonCancel:
@discussion This method handles the 'edit' button action, save the changes, and segues back.
*/
- (IBAction)handleButtonEdit:(id)sender
{
    // Dismiss the popover view
    // Deallocate location manager; ARC disposal.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/stop"
                                                        object:nil];
    NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/stop\" posted.");
    location = nil;
    ranger = nil;
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
                                           andCredentialsUserDic:credentialsUserDic];
    ranger = [[LMRanging alloc] initWithSharedData:sharedData
                                           userDic:userDic
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
    [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Layout
    [self.firstButton setEnabled:NO];
    
    // Save calibration parameters
    NSString * refDistanceString = [[self secondDistanceText] text];
    NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
    NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
    if ([floatTest evaluateWithObject:refDistanceString]){
        //Matches
    } else {
        return;
    }
    itemChosenByUser[@"attenuationDistance"] = [NSNumber numberWithFloat:[refDistanceString floatValue]];
    itemChosenByUser[@"refDistance"] = [NSNumber numberWithFloat:1.0];
    
    // Ask Location manager to calibrate the beacon
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    // Create a copy of the current position for sending it; concurrence issues prevented
    NSString * uuidToCalibrate = itemChosenByUser[@"uuid"];
    NSLog(@"[INFO][VCIS] User asked to start first calibration step with UUID: %@", uuidToCalibrate);
    [data setObject:uuidToCalibrate forKey:@"calibrationUUID"];
    [data setObject:[[NSUUID UUID] UUIDString] forKey:@"deviceUUID"]; // Random device UUID, not used
    // And send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/startFirstStep"
                                                        object:nil
                                                      userInfo:data];
    NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/startFirstStep\" posted.");
    
}

/*!
@method handleButtonSecond:
@discussion This method handles the 'second' button action, handleling the second step of calibration pocess.
*/
- (IBAction)handleButtonSecond:(id)sender
{
    // Orchestrate and set user measuring
    [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
    
    // Layout
    [self.secondButton setEnabled:NO];
    
    // Notify to location manager
    NSLog(@"[INFO][VCIS] User asked to start second calibration step.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdCalibrating/startSecondStep"
                                                        object:nil];
    NSLog(@"[NOTI][VCIS] Notification \"lmdCalibrating/startSecondStep\" posted.");
    
}

/*!
 @method alertUserWithTitle:message:andHandler:
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
