//
//  ViewControllingRhoRhoLocating.m
//  Sensors test
//
//  Created by Alberto J. on 21/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerRhoRhoLocating.h"

@implementation ViewControllerRhoRhoLocating

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
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    
    // Register the current mode
    mode = [[MDMode alloc] initWithModeKey:kModeRhoRhoLocating];
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:mode
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Components
    // In this mode, the device UUID is used to generate every located component; thus, it changes when user wants to locate another component.
    if (!deviceUUID) {
        deviceUUID = [[NSUUID UUID] UUIDString];
    }
    if (!rhoRhoSystem) {
        rhoRhoSystem = [[RDRhoRhoSystem alloc] initWithSharedData:sharedData
                                                          userDic:userDic
                                                       deviceUUID:deviceUUID
                                            andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        location = [[LMDelegateRhoRhoLocating alloc] initWithSharedData:sharedData
                                                                userDic:userDic
                                                           rhoRhoSystem:rhoRhoSystem
                                                             deviceUUID:deviceUUID
                                                  andCredentialsUserDic:credentialsUserDic];
        [location setItemBeaconIdNumber:itemBeaconIdNumber];
        [location setItemPositionIdNumber:itemPositionIdNumber];
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
    // Visualization
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, move to any position and tap 'Measure' to start. Tap 'Next' to add another component. Tap back to finish."];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItems.delegate = self;
    self.tableTypes.delegate = self;
    self.tableItems.dataSource = self;
    self.tableTypes.dataSource = self;
    
    [self.tableItems reloadData];
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
- (void) setLocationManager:(LMDelegateRhoRhoLocating *)givenLocation
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
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRL] Shared data could not be accessed before start measuring.");
        return;
    }
    
    // In every state the button performs different behaviours
    if ([sharedData fromSessionDataIsIdleUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) { // If idle, user can measuring; if 'Measuring' is tapped, user asks start measuring.
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [self.buttonMeasure setEnabled:NO];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again to finish the measure."];
            
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startBeaconRangingMeasuring"
                                                                object:nil];
            NSLog(@"[NOTI][VCRRL] Notification \"startBeaconRangingMeasuring\" posted.");
        } else {
        }
        return;
    }
    if ([sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic andCredentialsUserDic:credentialsUserDic]) { // If measuring, user can go idle; if 'Measuring' is tapped, user asks stop measuring.
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, tap 'Next' to add another component, move to any position and tap 'Measure' to start. Tap back to finish."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopBeaconRangingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRL] Notification \"stopBeaconRangingMeasuring\" posted.");
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method handles the 'next' button renewing the UUID for a new component and setting it in components.
 */
- (IBAction)handleNextButton:(id)sender {
    [self alertUserWithTitle:@"Component added to the model."
                     message:[NSString stringWithFormat:@"Please, move to a new location. UUID: %@.", deviceUUID]
                  andHandler:^(UIAlertAction * action) {
                      // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                  }
     ];
    deviceUUID = [[NSUUID UUID] UUIDString];
    [location setDeviceUUID:deviceUUID];
    [rhoRhoSystem setDeviceUUID:deviceUUID];
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromRHO_RHO_LOCATINGToSelectPosition" sender:sender];
}

/*!
 @method handleButtonModel:
 @discussion This method is called when user is prepared for modeling.
 */
- (IBAction)handleModelButton:(id)sender {
    [self performSegueWithIdentifier:@"fromRHO_RHO_LOCATINGToModellingRHO_RHO_LOCATING" sender:sender];
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
    NSLog(@"[INFO][VCRRL] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromRHO_RHO_LOCATINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerSelectPositions setItemPositionIdNumber:itemPositionIdNumber];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopBeaconRangingMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRL] Notification \"stopBeaconRangingMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLocationAndMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRL] Notification \"resetLocationAndMeasures\" posted.");
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"fromRHO_RHO_LOCATINGToModellingRHO_RHO_LOCATING"]) {
        
        // Get destination view
        ViewControllerModellingRhoRhoLocating * viewControllerModellingRhoRhoLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerModellingRhoRhoLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerModellingRhoRhoLocating setUserDic:userDic];
        [viewControllerModellingRhoRhoLocating setSharedData:sharedData];
        [viewControllerModellingRhoRhoLocating setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerModellingRhoRhoLocating setItemPositionIdNumber:itemPositionIdNumber];
        [viewControllerModellingRhoRhoLocating setDeviceUUID:deviceUUID];
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
    if (tableView == self.tableItems) {
        // Get the number of metamodel elements; if access the database is imposible, warn the user.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            return [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        } else { // Type not found
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCRRL] Shared data could not be accessed while loading items.");
        }
    }
    if (tableView == self.tableTypes) {
        return [[sharedData fromTypesDataGetTypesWithCredentialsUserDic:credentialsUserDic] count];
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
    if (tableView == self.tableItems) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // No item chosen by user
            [sharedData inSessionDataSetItemChosenByUser:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
            
            // Select the source of items
            NSMutableDictionary * itemDic = [
                                             [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                             objectAtIndex:indexPath.row
                                             ];
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
                
                // In this mode, only beacons can be aimed, and so, positions are marked
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [cell setTintColor:[UIColor redColor]];
                
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
                
                // In this mode, only beacons can be aimed, and so, positions are marked
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [cell setTintColor:[UIColor redColor]];
                
            }
            
        } else { // Type not found
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCRRL] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    // Configure individual cells
    if (tableView == self.tableTypes) {
        MDType * type = [
                         [sharedData fromTypesDataGetTypesWithCredentialsUserDic:credentialsUserDic]
                         objectAtIndex:indexPath.row
                         ];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [type getName]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    
    return cell;
}

@end
