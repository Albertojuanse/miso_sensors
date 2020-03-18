//
//  ViewControllerModellingRhoThetaModeling.m
//  Sensors test
//
//  Created by Alberto J. on 20/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerModellingRhoThetaModeling.h"

@implementation ViewControllerModellingRhoThetaModeling

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
    [self.buttonReference setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                        green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:1.0
                                         ]
                               forState:UIControlStateNormal];
    [self.buttonReference setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                        green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:0.3
                                         ]
                               forState:UIControlStateDisabled];
    [self.buttonModify setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.buttonModify setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:0.3
                                      ]
                            forState:UIControlStateDisabled];
    [self.buttonFinish setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.buttonFinish setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
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
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    
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
    
    // Components and variables error management; they must be initialized in theta theta locating view
    if (!deviceUUID) {
        NSLog(@"[ERROR][VCMRTM] Variable 'deviceUUID' not found when loading view.");
    }
    if (!thetaThetaSystem) {
        NSLog(@"[ERROR][VCMRTM] Component 'thetaThetaSystem' not found when loading view.");
    }
    if (!location) {
        NSLog(@"[ERROR][VCMRTM] Component 'location' not found when loading view.");
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Variables
    // locatedPositionUUID used for new positions located by this view and renewed every time.
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    // For reference creation routine
    flagReference = false;
    sourceItem = nil;
    targetItem = nil;
    // Load metamodels for this mode
    modeMetamodels = [[NSMutableArray alloc] init];
    modeTypes = [[NSMutableArray alloc] init];
    [self loadModeMetamodels];
    [self loadModeTypes];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic
                       andCredentialsUserDic:credentialsUserDic];
    
    // Visualization
    [self.labelStatus setText:@"Please, finish the model process."];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItemsChosen.delegate = self;
    self.tableTypes.delegate = self;
    self.tableItemsChosen.dataSource = self;
    self.tableTypes.dataSource = self;
    // Allow multiple selection
    self.tableItemsChosen.allowsMultipleSelection = true;
    self.tableTypes.allowsMultipleSelection = true;
    
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
 @method setLocationManager:
 @discussion This method sets the location manager.
 */
- (void) setLocationManager:(LMDelegateRhoThetaModelling *)givenLocation
{
    location = givenLocation;
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
 @method setDeviceUUID:
 @discussion This method sets the NSString variable 'deviceUUID'.
 */
- (void) setDeviceUUID:(NSString *)givenDeviceUUID
{
    deviceUUID = givenDeviceUUID;
}

#pragma mark - Buttons event handlers
/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromModellingRHO_THETA_MODELINGToRHO_THETA_MODELLING" sender:sender];
}

/*!
 @method handleBackFinish:
 @discussion This method dismiss this view and ask the final model to be shown; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackFinish:(id)sender
{
    // TODO: Alert user that measures will be disposed. Alberto J. 2020/01/20.
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find the mode that is not finished
            NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
            
            // Mode finished
            for (MDMode * eachMode in modes) {
                if ([eachMode isModeKey:kModeRhoThetaModelling]) {
                    [eachMode setFinished:YES];
                    break;
                }
            }
            
        }
    }
    [self performSegueWithIdentifier:@"fromModellingRHO_THETA_MODELINGToFinalModel" sender:sender];
}

/*!
 @method handleModifyButton:
 @discussion This method changes the already represented model.
 */
- (IBAction)handleModifyButton:(id)sender
{
    flagReference = false;
    sourceItem = nil;
    targetItem = nil;
    [self.labelStatus setText:@"Please, finish the model process."];
    
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        // Get the user selection
        NSMutableDictionary * itemDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                    andCredentialsUserDic:credentialsUserDic];
        MDType * type = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                    andCredentialsUserDic:credentialsUserDic];
        if (itemDic && type) {
            itemDic[@"type"] = type;
        }
        
        [self.canvas setNeedsDisplay];
        [self.tableTypes reloadData];
        [self.tableItemsChosen reloadData];
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMRTM] Shared data could not be accessed before handle the 'modify' button.");
    }
}

/*!
 @method handleReferenceButton:
 @discussion This method creates a reference between teo components in the model.
 */
- (IBAction)handleReferenceButton:(id)sender
{
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        // Get the user selection
        NSMutableDictionary * itemDic = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                    andCredentialsUserDic:credentialsUserDic];
        MDType * type = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                    andCredentialsUserDic:credentialsUserDic];
        // If is the first time tapped
        if (!flagReference) {
            if (itemDic) {
                // Save the item that will be the source item of the reference
                sourceItem = itemDic;
                flagReference = true;
                [self.labelStatus setText:@"Please, select the item for referencing to."];
            } else {
                [self.labelStatus setText:@"Error, an item for referencing from must be selected and, then, another item AND a type."];
                // Erase the item that would be the source item of the reference and the target one
                sourceItem = nil;
                targetItem = nil;
                flagReference = false;
            }
        } else { // The second
            if (itemDic && type) {
                // Save the item that will be the target item of the reference
                targetItem = itemDic;
                // And create and add the reference
                MDReference * reference = [[MDReference alloc] initWithType:type
                                                               sourceItemId:sourceItem[@"identifier"]
                                                            andTargetItemId:targetItem[@"identifier"]
                                           ];
                NSLog(@"[INFO][VCMRTM] Created reference %@", reference);
                [sharedData inSessionDataAddReference:reference toUserWithUserDic:userDic withCredentialsUserDic:credentialsUserDic];
                
                // reset
                [self.labelStatus setText:@"Reference saved."];
            } else {
                [self.labelStatus setText:@"Error, an item for referencing from must be selected and, then, another item AND a type."];
            }
            // reset
            sourceItem = nil;
            targetItem = nil;
            flagReference = false;
        }
        
        [self.canvas setNeedsDisplay];
        [self.tableTypes reloadData];
        [self.tableItemsChosen reloadData];
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMRTM] Shared data could not be accessed before handle the 'reference' button.");
    }
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
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCMRTM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromModellingRHO_THETA_MODELINGToRHO_THETA_MODELLING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModeling * viewControllerRhoThetaModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoThetaModeling setUserDic:userDic];
        [viewControllerRhoThetaModeling setSharedData:sharedData];
        [viewControllerRhoThetaModeling setLocationManager:location];
        [viewControllerRhoThetaModeling setDeviceUUID:deviceUUID];
        return;
    }
    if ([[segue identifier] isEqualToString:@"fromModellingRHO_THETA_MODELINGToFinalModel"]) {
        
        // Get destination view
        ViewControllerFinalModel * viewControllerFinalModel = [segue destinationViewController];
        // Set the variables
        [viewControllerFinalModel setCredentialsUserDic:credentialsUserDic];
        [viewControllerFinalModel setUserDic:userDic];
        [viewControllerFinalModel setSharedData:sharedData];
        [viewControllerFinalModel setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerFinalModel setItemPositionIdNumber:itemPositionIdNumber];
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
            // No item chosen by user; for reloading after using
            [sharedData inSessionDataSetItemChosenByUser:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
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
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    } else {
                        
                        RDPosition * position = itemDic[@"position"];
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               itemDic[@"uuid"],
                                               itemDic[@"major"],
                                               itemDic[@"minor"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
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
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n Position: (%.2f, %.2f, %.2f)",
                                           itemDic[@"identifier"],
                                           itemDic[@"type"],
                                           [position.x floatValue],
                                           [position.y floatValue],
                                           [position.z floatValue]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                } else {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: (%.2f, %.2f, %.2f)",
                                           itemDic[@"identifier"],
                                           [position.x floatValue],
                                           [position.y floatValue],
                                           [position.z floatValue]
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
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
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
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
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
            NSLog(@"[ERROR][VCMRTM] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    // Configure individual cells
    if (tableView == self.tableTypes) {
        // No type chosen by user; for reloading after using
        [sharedData inSessionDataSetItemChosenByUser:nil
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
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
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        if (tableView == self.tableItemsChosen) {
            
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
            
            // The table was set in 'viewDidLoad' as multiple-selecting
            // Manage multi-selection
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If not checkmark
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [sharedData inSessionDataSetItemChosenByUser:itemSelected
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
                
            } else { // If checkmark
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                [sharedData inSessionDataSetItemChosenByUser:nil
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
                
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
        }
        if (tableView == self.tableTypes) {
            
            MDType * typeSelected = [modeTypes objectAtIndex:indexPath.row];
            
            // The table was set in 'viewDidLoad' as multiple-selecting
            // Manage multi-selection
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If not checkmark
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [sharedData inSessionDataSetTypeChosenByUser:typeSelected
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
                
            } else { // If checkmark
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                [sharedData inSessionDataSetTypeChosenByUser:nil
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
                
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMRTM] Shared data could not be accessed while selecting a cell.");
    }
}

@end
