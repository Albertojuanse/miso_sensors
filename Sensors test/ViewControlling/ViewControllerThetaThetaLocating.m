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
                                             selector:@selector(presentEditComponentView:)
                                                 name:@"presentEditComponentView"
                                               object:nil];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItemsChosen.delegate = self;
    self.tableTypes.delegate = self;
    self.tableItemsChosen.dataSource = self;
    self.tableTypes.dataSource = self;
    
    [self.tableItemsChosen reloadData];
    [self.tableTypes reloadData];
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
 @method presentEditComponentView:
 @discussion This method is called when user taps over and component on canvas and presents modally the pop up view to edit that component.
 */
- (void) presentEditComponentView:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"presentEditComponentView"]){
        NSLog(@"[NOTI][VC] Notification \"presentEditComponentView\" recived.");
        
        // User did choose an item; get it...
        VCPosition * sourceViewChosenByUser = [notification object];
        if (!sourceViewChosenByUser) {
            NSLog(@"[ERROR][VCTTL] Object VCPosition not found in notification.");
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
                                                                      loadNibNamed:@"ViewControllerEditComponent"
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
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"startCompassHeadingMeasuring" object:nil];
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
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"stopCompassHeadingMeasuring" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopes" object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopGyroscopes\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopGyroscopeHeadingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopGyroscopeHeadingMeasuring\" posted.");
        // For showing the located items
        [self.tableItemsChosen reloadData];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLocationAndMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"resetLocationAndMeasures\" posted.");
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

#pragma mark - UItableView delegate methods
/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableItemsChosen) {
        NSInteger itemsChosenCount = [[sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                   andCredentialsUserDic:credentialsUserDic] count];
        NSInteger itemsLocatedCount = [[sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                               andCredentialsUserDic:credentialsUserDic] count];
        NSInteger itemsCount = itemsChosenCount + itemsLocatedCount;
        return itemsCount;
    }
    if (tableView == self.tableTypes) {
        return [modeTypes count];
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableItemsChosen) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // No item chosen by user
            [sharedData inSessionDataSetItemChosenByUser:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
            
            // Select the source of items; both chosen and located items are shown
            NSInteger itemsChosenCount = [[sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                       andCredentialsUserDic:credentialsUserDic] count];
            NSInteger itemsLocatedCount = [[sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                   andCredentialsUserDic:credentialsUserDic] count];
            
            // Load the item depending of the source
            NSMutableDictionary * itemDic = nil;
            if (indexPath.row < itemsChosenCount) {
                itemDic = [
                           [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row
                           ];
            }
            if (indexPath.row >= itemsChosenCount && indexPath.row < itemsChosenCount + itemsLocatedCount) {
                itemDic = [
                           [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                   andCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row - itemsChosenCount
                           ];
            }
            cell.textLabel.numberOfLines = 0; // Means any number
            
            // If it is a beacon
            if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                
                // It representation depends on if exist its position or its type
                if (itemDic[@"position"]) {
                    if (itemDic[@"type"]) {
                        
                        RDPosition * position = itemDic[@"position"];
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: %@",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"],
                                               position
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    } else {
                        
                        RDPosition * position = itemDic[@"position"];
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: %@",
                                               itemDic[@"identifier"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"],
                                               position
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    }
                } else {
                    if (itemDic[@"type"]) {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nmajor: %@ ; minor: %@",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    } else  {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nmajor: %@ ; minor: %@",
                                               itemDic[@"identifier"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    }
                }
            }
            
            // And if it is a position
            if ([@"position" isEqualToString:itemDic[@"sort"]] && ([@"NO" isEqualToString:itemDic[@"located"]] || !itemDic[@"located"])) {
                // If its type is set
                RDPosition * position = itemDic[@"position"];
                if (itemDic[@"type"]) {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n Position: %@",
                                           itemDic[@"identifier"],
                                           itemDic[@"type"],
                                           position
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                } else {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: %@",
                                           itemDic[@"identifier"],
                                           position
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                }
                
            }
            
            // And if it is a location
            if ([@"position" isEqualToString:itemDic[@"sort"]] && [@"YES" isEqualToString:itemDic[@"located"]]) {
                // If its type is set
                RDPosition * position = itemDic[@"position"];
                if (itemDic[@"type"]) {
                    
                    if (position) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n Position: %@",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               position
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    } else {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    }
                    
                } else {
                    
                     if (position) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: %@",
                                               itemDic[@"identifier"],
                                               position
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                     } else {
                         cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n",
                                                itemDic[@"identifier"],
                                                itemDic[@"type"]
                                                ];
                         cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                     }
                }
                
            }
        } else { // Database not acessible
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCTTL] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    // Configure individual cells
    if (tableView == self.tableTypes) {
        MDType * type = [modeTypes objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [type getName]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    
    return cell;
}

/*!
 @method tableView:didSelectRowAtIndexPath:
 @discussion Handles the upload of tables; handles the 'select a cell' action.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableItemsChosen) {
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // No item chosen by user
            [sharedData inSessionDataSetItemChosenByUser:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
            
            // Select the source of items; both chosen and located items are shown
            NSInteger itemsChosenCount = [[sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                       andCredentialsUserDic:credentialsUserDic] count];
            NSInteger itemsLocatedCount = [[sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                                   andCredentialsUserDic:credentialsUserDic] count];
            
            // Load the item depending of the source
            NSMutableDictionary * itemSelected = nil;
            if (indexPath.row < itemsChosenCount) {
                itemSelected = [
                           [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row
                           ];
            }
            if (indexPath.row >= itemsChosenCount && indexPath.row < itemsChosenCount + itemsLocatedCount) {
                itemSelected = [
                           [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                   andCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row - itemsChosenCount
                           ];
            }
            
            // Only not located positions can be aimed, positions were marked
            if ([@"position" isEqualToString:itemSelected[@"sort"]] && ([@"NO" isEqualToString:itemSelected[@"located"]] || !itemSelected[@"located"]))
            {
                [sharedData inSessionDataSetItemChosenByUser:itemSelected
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            
        } else {
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCTTL] Shared data could not be accessed while selecting a cell.");
        }
    }
    if (tableView == self.tableTypes) {
        MDType * typeSelected = [modeTypes objectAtIndex:indexPath.row];
        [sharedData inSessionDataSetTypeChosenByUser:typeSelected
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
    }
}

@end
