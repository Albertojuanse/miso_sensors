//
//  ViewControllerThetaThetaLocating.m
//  Sensors test
//
//  Created by MISO on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerThetaThetaLocating.h"

@implementation ViewControllerThetaThetaLocating

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    [self showUser];
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ];
    [self.buttonMeasure setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                      green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                       blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                      alpha:1.0
                                       ]
                             forState:UIControlStateNormal];
    [self.buttonMeasure setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                      green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                       blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                      alpha:0.3
                                       ]
                             forState:UIControlStateDisabled];
    [self.buttonModel setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                     ]
                           forState:UIControlStateNormal];
    [self.buttonModel setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:0.3
                                     ]
                           forState:UIControlStateDisabled];
    [self.buttonNext setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.buttonNext setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.buttonBack setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.buttonBack setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    // Other components
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing."];
    
    // Register the current mode
    mode = [[MDMode alloc] initWithModeKey:kModeThetaThetaLocating];
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:mode
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Components
    // TODO: Use UUID from component 'device'. Alberto J. 2020/01/20.
    if (!deviceUUID) {
        deviceUUID = [[NSUUID UUID] UUIDString];
    }
    if (!thetaThetaSystem) {
        thetaThetaSystem = [[RDThetaThetaSystem alloc] initWithSharedData:sharedData
                                                                  userDic:userDic
                                                               deviceUUID:deviceUUID
                                                    andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        location = [[LMDelegateThetaThetaLocating alloc] initWithSharedData:sharedData
                                                                    userDic:userDic
                                                           thetaThetaSystem:thetaThetaSystem
                                                                 deviceUUID:deviceUUID
                                                      andCredentialsUserDic:credentialsUserDic];
        [location setItemBeaconIdNumber:itemBeaconIdNumber];
        [location setItemPositionIdNumber:itemPositionIdNumber];
    }
    if (!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                                   userDic:credentialsUserDic
                                          thetaThetaSystem:thetaThetaSystem
                                                deviceUUID:deviceUUID
                                     andCredentialsUserDic:credentialsUserDic];
        
        // TODO: make this configurable or properties. Alberto J. 2019/09/13.
        motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Variables; used for new positions located by this view and renewed every time.
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    // Load metamodels for this mode
    modeMetamodels = [[NSMutableArray alloc] init];
    modeTypes = [[NSMutableArray alloc] init];
    [self loadModeMetamodels];
    [self loadModeTypes];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic
                       andCredentialsUserDic:credentialsUserDic];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chooseItem:)
                                                 name:@"chooseItem"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentEditComponentView:)
                                                 name:@"presentEditComponentView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createReference:)
                                                 name:@"createReference"
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

/*!
 @method showUser
 @discussion This method defines how user name is shown once logged.
 */
- (void)showUser
{
    self.loginText.text = [self.loginText.text stringByAppendingString:@" "];
    self.loginText.text = [self.loginText.text stringByAppendingString:userDic[@"name"]];
}

/*!
@method loadModeMetamodels
@discussion This method loads the metamodels for this mode.
*/
- (void)loadModeMetamodels
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Get all metamodels
            NSMutableArray * metamodels = [sharedData fromMetamodelsDataGetMetamodelsWithCredentialsUserDic:credentialsUserDic];
            
            // Find the metamodels used in this mode
            for (MDMetamodel * eachMetamodel in metamodels) {
                
                NSMutableArray * eachMetamodelModes = [eachMetamodel getModes];
                
                // Modes are saved as NSNumbers with each key
                for (NSNumber * eachModeKey in eachMetamodelModes){
                    
                    MDMode * eachMode = [[MDMode alloc] initWithModeKey:[eachModeKey intValue]];
                    
                    if ([eachMode isEqualToMDMode:mode]) {
                        [modeMetamodels addObject:eachMetamodel];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO][VCTTL] Loaded %tu metamodels for this mode.", modeMetamodels.count);
}

/*!
@method loadModeTypes
@discussion This method loads the types for this mode from the metamodels.
*/
- (void)loadModeTypes
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find in the metamodels the types used
            for (MDMetamodel * eachMetamodel in modeMetamodels) {
                
                NSMutableArray * eachMetamodelTypes = [eachMetamodel getTypes];
                
                // Get the types of the metamodel and check if they are already got.
                for (MDType * eachMetamodelType in eachMetamodelTypes){
                    
                    BOOL typeFound = NO;
                    for (MDType * eachType in modeTypes){
                        if ([eachType isEqualToMDType:eachMetamodelType]) {
                            typeFound = YES;
                        }
                    }
                    if (!typeFound) {
                        [modeTypes addObject:eachMetamodelType];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO][VCTTL] Loaded %tu ontologycal types for this mode.", modeTypes.count);
}

#pragma mark - Notifications events handlers
/*!
 @method chooseItem:
 @discussion This method is called when user taps over and sets a component as chosen item.
 */
- (void) chooseItem:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"chooseItem"]){
        NSLog(@"[NOTI][VC] Notification \"chooseItem\" recived.");
        
        // User did choose an item; get it...
        VCComponent * sourceViewChosenByUser = [notification object];
        if (!sourceViewChosenByUser) {
            NSLog(@"[ERROR][VCTTL] Object VCComponent not found in notification.");
            return;
        }
        NSString * chosenItemUUID = [sourceViewChosenByUser getUUID];
        NSMutableArray * itemsChosenByUser = [sharedData fromItemDataGetItemsWithUUID:chosenItemUUID
                                                                andCredentialsUserDic:credentialsUserDic];
        if (itemsChosenByUser.count == 0) {
            NSLog(@"[ERROR][VCTTL] User did choose an unknown item: %@", chosenItemUUID);
            return;
        }
        else if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR][VCTTL] User did choose an item whose UUID is repeated: %@", chosenItemUUID);
        }
        NSMutableDictionary * itemChosenByUser = [itemsChosenByUser objectAtIndex:0];

        NSLog(@"[INFO][VCTTL] The user did choose the item %@", itemChosenByUser[@"uuid"]);
        
        // ...and set it as item chosen by user in shared data.
        [sharedData inSessionDataSetItemChosenByUser:itemChosenByUser
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
    }
    return;
}

/*!
 @method presentEditComponentView:
 @discussion This method is called when user double taps over and component on canvas and presents modally the pop up view to edit that component.
 */
- (void) presentEditComponentView:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"presentEditComponentView"]){
        NSLog(@"[NOTI][VC] Notification \"presentEditComponentView\" recived.");
        
        // User did choose an item; get it...
        VCComponent * sourceViewChosenByUser = [notification object];
        if (!sourceViewChosenByUser) {
            NSLog(@"[ERROR][VCTTL] Object VCComponent not found in notification.");
            return;
        }
        NSString * chosenItemUUID = [sourceViewChosenByUser getUUID];
        NSMutableArray * itemsChosenByUser = [sharedData fromItemDataGetItemsWithUUID:chosenItemUUID
                                                                andCredentialsUserDic:credentialsUserDic];
        if (itemsChosenByUser.count == 0) {
            NSLog(@"[ERROR][VCTTL] User did choose an unknown item: %@", chosenItemUUID);
            return;
        }
        else if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR][VCTTL] User did choose an item whose UUID is repeated: %@", chosenItemUUID);
        }
        NSMutableDictionary * itemChosenByUser = [itemsChosenByUser objectAtIndex:0];

        NSLog(@"[INFO][VCTTL] The user asked pop up view to edit %@", itemChosenByUser[@"uuid"]);
        
        // ...and set it as item chosen by user in shared data.
        [sharedData inSessionDataSetItemChosenByUser:itemChosenByUser
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
        // Present the view as a pop up
        //[self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToEditComponent" sender:nil];
        ViewControllerEditComponent * viewControllerEditComponent = [[[NSBundle mainBundle]
                                                                      loadNibNamed:@"ViewEditComponent"
                                                                      owner:self
                                                                      options:nil]
                                                                     objectAtIndex:0];
        [viewControllerEditComponent setModalPresentationStyle:UIModalPresentationPopover];
        // Set the variables
        [viewControllerEditComponent setCredentialsUserDic:credentialsUserDic];
        [viewControllerEditComponent setUserDic:userDic];
        [viewControllerEditComponent setSharedData:sharedData];
        [viewControllerEditComponent setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerEditComponent setItemPositionIdNumber:itemPositionIdNumber];
        [viewControllerEditComponent setModeTypes:modeTypes];
        // Configure popover layout
        NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
        NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
        NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
        NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
        UIPopoverPresentationController * popoverEditComponent =  viewControllerEditComponent.popoverPresentationController;
        [popoverEditComponent setDelegate:viewControllerEditComponent];
        [popoverEditComponent setSourceView:sourceViewChosenByUser];
        [popoverEditComponent setSourceRect:CGRectMake([positionWidth floatValue]/2.0,
                                                       [positionHeight floatValue],
                                                       1,
                                                       1)];
        [popoverEditComponent setPermittedArrowDirections:UIPopoverArrowDirectionAny];
        // Show the view
        [self presentViewController:viewControllerEditComponent animated:YES completion:nil];
    }
    return;
}

/*!
 @method handleReferenceButton:
 @discussion This method creates a reference between teo components in the model.
 */
- (void)createReference:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"createReference"]){
        NSLog(@"[NOTI][VCTTL] Notification \"createReference\" recived.");
    
        // Retrieve notification data
        NSDictionary * dataDic = [notification userInfo];
        VCComponent * sourceView = dataDic[@"sourceView"];
        VCComponent * targetView = dataDic[@"targetView"];
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // Get both items from shared data
            if (!sourceView) {
                NSLog(@"[ERROR][VCTTL] Source VCComponent not found in notification.");
                return;
            }
            if (!targetView) {
                NSLog(@"[ERROR][VCTTL] Target VCComponent not found in notification.");
                return;
            }
            NSString * sourceItemUUID = [sourceView getUUID];
            NSString * targetItemUUID = [targetView getUUID];
            NSMutableArray * sourceItems = [sharedData fromItemDataGetItemsWithUUID:sourceItemUUID
                                                              andCredentialsUserDic:credentialsUserDic];
            
            NSMutableArray * targetItems = [sharedData fromItemDataGetItemsWithUUID:targetItemUUID
                                                              andCredentialsUserDic:credentialsUserDic];
            if (sourceItems.count == 0) {
                NSLog(@"[ERROR][VCTTL] User did choose an unknown source item: %@", sourceItemUUID);
                return;
            }
            if (targetItems.count == 0) {
                NSLog(@"[ERROR][VCTTL] User did choose an unknown target item: %@", targetItemUUID);
                return;
            }
            else if (sourceItems.count > 1) {
                NSLog(@"[ERROR][VCTTL] User did choose a source item whose UUID is repeated: %@", sourceItemUUID);
            }
            else if (targetItems.count > 1) {
                NSLog(@"[ERROR][VCTTL] User did choose a target item whose UUID is repeated: %@", targetItemUUID);
            }
            NSMutableDictionary * sourceItem = [sourceItems objectAtIndex:0];
            NSMutableDictionary * targetItem = [targetItems objectAtIndex:0];

            NSLog(@"[INFO][VCTTL] The user asked to crate a reference between %@ and %@", sourceItem[@"uuid"], targetItem[@"uuid"]);

            // And create and add the reference
            MDReference * reference = [[MDReference alloc] initWithsourceItemId:sourceItem[@"identifier"]
                                                                andTargetItemId:targetItem[@"identifier"]];
            NSLog(@"[INFO][VCMTTL] Created reference %@", reference);
            [sharedData inSessionDataAddReference:reference toUserWithUserDic:userDic withCredentialsUserDic:credentialsUserDic];
                    
            
            [self.canvas setNeedsDisplay];
            
        } else {
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCMTTL] Shared data could not be accessed before handle the 'reference' button.");
        }
    }
    return;
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
 @method setMotionManager:
 @discussion This method sets the motion manager.
 */
- (void) setMotionManager:(MotionManager *)givenMotion
{
    motion = givenMotion;
}

/*!
 @method setLocationManager:
 @discussion This method sets the location manager.
 */
- (void) setLocationManager:(LMDelegateThetaThetaLocating *)givenLocation
{
    location = givenLocation;
}

/*!
 @method setItemBeaconIdNumber:
 @discussion This method sets the NSNumber variable 'itemBeaconIdNumber'.
 */
- (void) setItemBeaconIdNumber:(NSNumber *)givenItemBeaconIdNumber
{
    itemBeaconIdNumber = givenItemBeaconIdNumber;
}

/*!
 @method setItemPositionIdNumber:
 @discussion This method sets the NSNumber variable 'itemPositionIdNumber'.
 */
- (void) setItemPositionIdNumber:(NSNumber *)givenItemPositionIdNumber
{
    itemPositionIdNumber = givenItemPositionIdNumber;
}

/*!
 @method setDeviceUUID:
 @discussion This method sets the NSString variable 'deviceUUID'.
 */
- (void) setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
}

#pragma mark - Buttons event handlers
/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must disable 'Travel' control buttons and ask location manager delegate to start measuring.
 */
- (IBAction)handleButtonMeasure:(id)sender
{
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Measure won't be started."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCTTL] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        // If user did chose a position to aim
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [self.buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure."];
            
            // And send the notification
            // TODO: Decide if use this or not. Combined? Alberto J. 2020/01/21.
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdThetaThetaLocating/start" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopes" object:nil];
            NSLog(@"[NOTI][VCTTL] Notification \"startGyroscopes\" posted.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startGyroscopeHeadingMeasuring"
                                                                object:nil];
            NSLog(@"[NOTI][VCTTL] Notification \"startGyroscopeHeadingMeasuring\" posted.");
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If 'Measuring' is tapped, ask stop measuring.
        [self.buttonMeasure setEnabled:YES];
        // This next line have been moved into "stopGyroscopesHeadingMeasuring" method, because the measure is generated in this case after stop measuring
        // [sharedData inSessionDataSetIdleUserWithUserDic:userDic andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing."];
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdThetaThetaLocating/stop" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopes" object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopGyroscopes\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopeHeadingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopGyroscopeHeadingMeasuring\" posted.");
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToSelectPosition" sender:sender];
}

/*!
 @method handleButtonNext:
 @discussion This method is called one the user wnats to locate a new position and thus a new UUID is generated for it.
 */
- (IBAction)handleButtonNext:(id)sender
{
    // New UUID
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    [location setDeviceUUID:locatedPositionUUID];
    [motion setDeviceUUID:locatedPositionUUID];
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

/*!
 @method handleButtonModel:
 @discussion This method is called when user is prepared for modeling.
 */
- (IBAction)handleButtonModel:(id)sender {
    [self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToModelingTHETA_THETA_LOCATING" sender:sender];
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCTTL] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromTHETA_THETA_LOCATINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerSelectPositions setItemPositionIdNumber:itemPositionIdNumber];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopeHeadingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopGyroscopeHeadingMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"lmd/reset\" posted.");
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"fromTHETA_THETA_LOCATINGToModelingTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerModelingThetaThetaLocating * viewControllerModelingThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerModelingThetaThetaLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerModelingThetaThetaLocating setUserDic:userDic];
        [viewControllerModelingThetaThetaLocating setSharedData:sharedData];
        [viewControllerModelingThetaThetaLocating setMotionManager:motion];
        [viewControllerModelingThetaThetaLocating setLocationManager:location];
        [viewControllerModelingThetaThetaLocating setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerModelingThetaThetaLocating setItemPositionIdNumber:itemPositionIdNumber];
        [viewControllerModelingThetaThetaLocating setDeviceUUID:deviceUUID];
        return;
    }
    
}

@end
