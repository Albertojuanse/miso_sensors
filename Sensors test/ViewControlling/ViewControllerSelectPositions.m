//
//  ViewControllerSelectPositions.m
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerSelectPositions.h"

@implementation ViewControllerSelectPositions

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
    [self loadLayout];
    
    // All items must be set as not chosen by user everytime
    [self uncheckAllItemsAsChosenByUser];
    
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Get temporal model
            NSMutableDictionary * routineModelDic = [sharedData fromSessionDataGetRoutineModelFromUserWithUserDic:userDic
                                                                                       andCredentialsUserDic:credentialsUserDic
                                           ];
            
            // Set each component as chosen one
            if (routineModelDic) {
                NSMutableArray * components = routineModelDic[@"components"];
                for (NSMutableDictionary * eachComponent in components) {
                    [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                            toUserWithUserDic:userDic
                                       withCredentialsUserDic:credentialsUserDic];
                }
            }
            
        }
        
        // USE CASE PAPER
        NSMutableArray * itemData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
        for (NSMutableDictionary * itemDic in itemData) {
            NSString * itemIdentifier = itemDic[@"identifier"];
            if ([itemIdentifier isEqualToString:@"position95_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position95_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position85_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position85_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position35_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position35_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position2_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position2_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position05_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position05_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_5@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_3@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_2@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"position0_0@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column75_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column75_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column59_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column59_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column35_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column35_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column19_33@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"column19_16@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance95_25@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance9_08@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance9_42@miso.uam.es"] ||
                [itemIdentifier isEqualToString:@"entrance0_25@miso.uam.es"]
                )
            {
                [sharedData  inSessionDataSetAsChosenItem:itemDic
                                        toUserWithUserDic:userDic
                                   withCredentialsUserDic:credentialsUserDic];
            }
            
        }
        // END USE CASE PAPER
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItems.delegate = self;
    self.tableItems.dataSource = self;
    // Allow multiple selection
    self.tableItems.allowsMultipleSelection = true;
    
    [self.tableItems reloadData];
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
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ];
    [self.backButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.goButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.goButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
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
@method uncheckAllItemsAsChosenByUser
@discussion This method sets as not chosen by user every item.
*/
- (void)uncheckAllItemsAsChosenByUser
{
    // Everytime that this view is loaded every item must be set as 'not chosen'
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        NSMutableDictionary * sessionDic = [sharedData fromSessionDataGetSessionWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
        if (sessionDic[@"itemsChosenByUser"]) {
            sessionDic[@"itemsChosenByUser"] = nil;
        }
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed while loading select position view.");
    }
    
    // Uncheck as Chosen all the items
    NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * eachItemChosenByUser in items) {
        [sharedData inSessionDataSetAsNotChosenItem:eachItemChosenByUser
                                  toUserWithUserDic:userDic
                             withCredentialsUserDic:credentialsUserDic];
    }
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

#pragma mark - Buttons event handlers

/*!
 @method handleButtonBack:
 @discussion This method handles the 'back' button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromSelectPositionsToMain" sender:sender];
}

/*!
 @method handleButtonGo:
 @discussion This method handles the 'go' button action and segues to mode's locating view; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonGo:(id)sender
{
    
    NSLog(@"[INFO][VCSP] Button GO tapped.");
    
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // Get the current mode
        MDMode * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        // TODO: Different behavior depending on mode. Alberto J. 2020/01/20.
        // This button can segue with different views depending on the mode chosen by the user in the main menu
        if ([mode isModeKey:kModeMonitoring]) {
            NSLog(@"[INFO][VCSP] Chosen mode is kModeMonitoring.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToMONITORING" sender:sender];
            return;
        }
        if ([mode isModeKey:kModeRhoRhoLocating]) {
            NSLog(@"[INFO][VCSP] Chosen mode is kModeRhoRhoLocating.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_RHO_LOCATING" sender:sender];
            return;
        }
        if ([mode isModeKey:kModeRhoThetaLocating]) {
            // NSLog(@"[INFO][VCSP] Chosen mode is kModeRhoThetaLocating.");
            // [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_THETA_LOCATING" sender:sender];
            return;
        }
        if ([mode isModeKey:kModeRhoThetaModelling]) {
            NSLog(@"[INFO][VCSP] Chosen mode is kModeRhoThetaModelling.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_THETA_MODELING" sender:sender];
            return;
        }
        if ([mode isModeKey:kModeThetaThetaLocating]) {
            // TODO: Go is only allowed if the user did choose at least one position in the table. Alberto J. 2020/01/20.
            NSLog(@"[INFO][VCSP] Chosen mode is kModeThetaThetaLocating.");
            // [self performSegueWithIdentifier:@"fromSelectPositionsToTHETA_THETA_LOCATING" sender:sender];
            [self performSegueWithIdentifier:@"fromSelectPositionsToEDITING" sender:sender];
        }
        
    } else {
        [self alertUserWithTitle:@"Mode won't load."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed when tapped 'go' button item.");
    }
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

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCSP] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu
    
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToMONITORING"]) {
        
        // Get destination view
        ViewControllerMonitoring * viewControllerMonitoring = [segue destinationViewController];
        // Set the variables
        [viewControllerMonitoring setCredentialsUserDic:credentialsUserDic];
        [viewControllerMonitoring setUserDic:userDic];
        [viewControllerMonitoring setSharedData:sharedData];
        [viewControllerMonitoring setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerMonitoring setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToRHO_RHO_LOCATING"]) {
        
        // Get destination view
        ViewControllerRhoRhoLocating * viewControllerRhoRhoLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoRhoLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoRhoLocating setUserDic:userDic];
        [viewControllerRhoRhoLocating setSharedData:sharedData];
        [viewControllerRhoRhoLocating setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerRhoRhoLocating setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToEDITING"]) {
        
        // Get destination view
        ViewControllerEditing * viewControllerEditing = [segue destinationViewController];
        // Set the variables
        [viewControllerEditing setCredentialsUserDic:credentialsUserDic];
        [viewControllerEditing setUserDic:userDic];
        [viewControllerEditing setSharedData:sharedData];
        [viewControllerEditing setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerEditing setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    return;
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
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        return itemsCount + modelCount;
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = [@"Cell" stringByAppendingString:[indexPath description]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableItems) {
        
        // Select the source of items; both items and models are shown
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        
        // Load the item depending of the source
        NSMutableDictionary * itemDic = nil;
        if (indexPath.row < itemsCount) {
            itemDic = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                       objectAtIndex:indexPath.row];
        }
        if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
            itemDic = [
                       [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                       objectAtIndex:indexPath.row - itemsCount
                       ];
        }
        
        // The itemDic variable can be null or NO if access is not granted or there are not items stored.
        if (itemDic) {
            cell.textLabel.numberOfLines = 0; // Means any number
            
            // Check if the item is already selected; when in a routine it happens
            BOOL selected = [sharedData fromSessionDataIsChosenItemByUser:itemDic
                                                        byUserWithUserDic:userDic
                                                    andCredentialsUserDic:userDic];
            if (selected) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            
            // Only if the item have a position can be selected; not prevent selecting models
            if (!itemDic[@"position"]) {
                if (![@"model" isEqualToString:itemDic[@"sort"]]) {
                    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                    [cell setTintColor:[UIColor redColor]];
                }
            }
            
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
            
            // If it is a position
            if ([@"position" isEqualToString:itemDic[@"sort"]]) {
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
            
            // If it is a model
            if ([@"model" isEqualToString:itemDic[@"sort"]]) {
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@",
                                       itemDic[@"name"]
                                       ];
                cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            }

            
        } else {
            // The itemDic variable is null or NO
            NSLog(@"[VCMM][ERROR] No items found for showing.");
            if (indexPath.row == 0) {
                cell.textLabel.text = @"No items found.";
                cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            } else {
                cell.textLabel.text = @"Error loading item";
                cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            }
        }
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
    NSLog(@"[INFO][VCSP] User did select the row %tu", indexPath.row);
    if (tableView == self.tableItems) {
        
        // The table was set in 'viewDidLoad' as multiple-selecting
        // Manage multi-selection
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Select the source of items; both items are models shown
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        
        // Load the item depending of the source
        NSMutableDictionary * itemDic = nil;
        if (indexPath.row < itemsCount) {
            itemDic = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                objectAtIndex:indexPath.row
                                ];
        }
        if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
            itemDic = [
                                [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                                objectAtIndex:indexPath.row - itemsCount
                                ];
        }
        
        if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If not checkmark
            
            // Only models and items with position can be selected
            if (![@"model" isEqualToString:itemDic[@"sort"]]) {
                if (itemDic[@"position"]) {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    [sharedData  inSessionDataSetAsChosenItem:itemDic
                                            toUserWithUserDic:userDic
                                       withCredentialsUserDic:credentialsUserDic];
                } else {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                    [selectedCell setTintColor:[UIColor redColor]];
                }
                
            } else { // if model
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                // Retrieve the components, verify if they exists as items, and if not, add them
                NSMutableArray * components = itemDic[@"components"];
                for (NSMutableDictionary * eachComponent in components) {
                    if ([sharedData fromItemDataIsItemWithInfoDic:eachComponent andCredentialsUserDic:credentialsUserDic]) {
                        [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                                toUserWithUserDic:userDic
                                           withCredentialsUserDic:credentialsUserDic];
                    } else { // If it does not exist, just add it and set as chosen
                        BOOL savedItem = [sharedData inItemDataAddItemDic:eachComponent withCredentialsUserDic:credentialsUserDic];
                        [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                                toUserWithUserDic:userDic
                                           withCredentialsUserDic:credentialsUserDic];
                        if (savedItem) {
                            // PERSISTENT: SAVE ITEM
                            // Save them in persistent memory
                            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                            // TODO: Assign items by user. Alberto J. 15/11/2019.
                            // Now there are items
                            NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
                            if (areItemsData) {
                                [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
                            }
                            areItemsData = nil; // ARC disposing
                            areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
                            [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
                            
                            // Get the index in which names of items are saved for retrieve them later
                            NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
                            NSMutableArray * itemsIndex;
                            if (itemsIndexData) {
                                itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
                                [userDefaults removeObjectForKey:@"es.uam.miso/data/items/index"];
                            } else {
                                itemsIndex = [[NSMutableArray alloc] init];
                            }
                            
                            // Get the item as it was saved in shared data
                            NSMutableArray * itemDics = [sharedData fromItemDataGetItemsWithIdentifier:eachComponent[@"identifier"]
                                                                                 andCredentialsUserDic:credentialsUserDic];
                            if (itemDics.count == 0) {
                                NSLog(@"[ERROR][VCSP] Saved item %@ could not be retrieved from shared data.", eachComponent[@"identifier"]);
                                break;
                            } else {
                                if (itemDics.count > 1) {
                                    NSLog(@"[ERROR][VCSP] More than one saved item with identifier %@.", eachComponent[@"identifier"]);
                                    break;
                                }
                            }
                            NSMutableDictionary * itemDic = [itemDics objectAtIndex:0];
                            
                            // Create a NSData for the item and save it using its name
                            // Item's name
                            NSString * itemIdentifier = itemDic[@"identifier"];
                            // Save the name in the index
                            [itemsIndex addObject:itemIdentifier];
                            // Create the item's data and archive it
                            NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:itemDic];
                            NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
                            [userDefaults setObject:itemData forKey:itemKey];
                            // And save the new index
                            itemsIndexData = nil; // ARC disposing
                            itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
                            [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
                            NSLog(@"[INFO][VCAB] Item saved in device memory.");
                            // END PERSISTENT: SAVE ITEM
                        } else {
                            NSLog(@"[ERROR][VCSP] Item from model %@ could not be stored as an item.", eachComponent[@"position"]);
                        }
                    }
                }
                
            }
            
        } else { // If checkmark or detail mark
            
            // Only models and items with position can be selected
            if (![@"model" isEqualToString:itemDic[@"sort"]]) {
                if (itemDic[@"position"]) {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                    [sharedData  inSessionDataSetAsNotChosenItem:itemDic
                                               toUserWithUserDic:userDic
                                          withCredentialsUserDic:credentialsUserDic];
                } else {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                    [selectedCell setTintColor:[UIColor redColor]];
                }
            
            } else { // if model
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                // Retrieve the components, verify if they exists as items, and if not, add them
                NSMutableArray * components = itemDic[@"components"];
                for (NSMutableDictionary * eachComponent in components) {
                    [sharedData  inSessionDataSetAsNotChosenItem:eachComponent
                                               toUserWithUserDic:userDic
                                          withCredentialsUserDic:credentialsUserDic];
                }
                
            }
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    return;
}

#pragma mark - Other methods
/*!
@method imageForPositionInNormalThemeColor
@discussion This method draws the position icon for table cells.
*/
- (UIImage *)imageForPositionInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    CGPoint arrowPoint = CGPointMake(rectWidth/2, rectHeight);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                   alpha:1.0
    ];
    [normalThemeColor setStroke];
    [normalThemeColor setFill];
    
    UIBezierPath * outterRightBezierPath = [UIBezierPath bezierPath];
    [outterRightBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:5.0*M_PI/6.0 clockwise:NO];
    [outterRightBezierPath addLineToPoint:arrowPoint];
    [outterRightBezierPath fill];
    CGContextAddPath(context, outterRightBezierPath.CGPath);
    
    UIBezierPath * outterLeftBezierPath = [UIBezierPath bezierPath];
    [outterLeftBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:3.0*M_PI/2.0 endAngle:M_PI/6.0 clockwise:YES];
    [outterLeftBezierPath addLineToPoint:arrowPoint];
    [outterLeftBezierPath fill];
    CGContextAddPath(context, outterLeftBezierPath.CGPath);
    
    [[UIColor whiteColor] setFill]; // Clear
    
    UIBezierPath * innerCircleBezierPath = [UIBezierPath bezierPath];
    [innerCircleBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:0 endAngle:2.0*M_PI clockwise:YES];
    [innerCircleBezierPath stroke];
    [innerCircleBezierPath fill];
    CGContextAddPath(context, innerCircleBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForBeaconInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
- (UIImage *)imageForBeaconInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    
    // Points for Bezier path
    CGFloat circlesCenterX = rectOrigin.x + rectWidth/2;
    CGFloat circlesCenterY = rectOrigin.y + rectHeight/3;
    CGPoint circlesCenter = CGPointMake(circlesCenterX, circlesCenterY);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterRightArcBezierPath = [UIBezierPath bezierPath];
    [outterRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [outterRightArcBezierPath stroke];
    CGContextAddPath(context, outterRightArcBezierPath.CGPath);
    
    UIBezierPath * outterLeftArcBezierPath = [UIBezierPath bezierPath];
    [outterLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/3 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [outterLeftArcBezierPath stroke];
    CGContextAddPath(context, outterLeftArcBezierPath.CGPath);
    
    UIBezierPath * middleRightArcBezierPath = [UIBezierPath bezierPath];
    [middleRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [middleRightArcBezierPath stroke];
    CGContextAddPath(context, middleRightArcBezierPath.CGPath);
    
    UIBezierPath * middleLeftArcBezierPath = [UIBezierPath bezierPath];
    [middleLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/4 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [middleLeftArcBezierPath stroke];
    CGContextAddPath(context, middleLeftArcBezierPath.CGPath);
    
    UIBezierPath * innerRightArcBezierPath = [UIBezierPath bezierPath];
    [innerRightArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:2.0*M_PI/3.0 endAngle:4.0*M_PI/3.0 clockwise:YES];
    [innerRightArcBezierPath stroke];
    CGContextAddPath(context, innerRightArcBezierPath.CGPath);
    
    UIBezierPath * innerLeftArcBezierPath = [UIBezierPath bezierPath];
    [innerLeftArcBezierPath addArcWithCenter:circlesCenter radius:rectWidth/6 startAngle:M_PI/3.0 endAngle:5.0*M_PI/3.0 clockwise:NO];
    [innerLeftArcBezierPath stroke];
    CGContextAddPath(context, innerLeftArcBezierPath.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
@method imageForModelInNormalThemeColor
@discussion This method draws the beacon icon for table cells.
*/
- (UIImage *)imageForModelInNormalThemeColor
{
    // Create a frame for the image
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber * positionWidth = layoutDic[@"canvas/position/width"];
    NSNumber * positionHeight = layoutDic[@"canvas/position/height"];
    CGRect rect = CGRectMake(0,
                             0,
                             [positionWidth integerValue],
                             [positionHeight integerValue]);

    // Create a view to embed the image using the frame
    UIView * view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Get the rect in which the drawn must be embebed its dimensions
    CGSize rectSize = rect.size;
    CGFloat rectHeight = rectSize.height;
    CGFloat rectWidth = rectSize.width;
    CGPoint rectOrigin = rect.origin;
    CGFloat margin = rectWidth * 0.1;
    CGFloat splitLineHeith = rectHeight * 0.2;
    CGFloat minusHeith = rectHeight * 0.3;
    CGFloat minusX = rectHeight * 0.15;
    CGFloat minusLength = rectHeight * 0.15;
    
    // Points for Bezier path
    CGPoint upperLeftCorner = CGPointMake(rectOrigin.x + margin,
                                          rectOrigin.y + margin);
    CGPoint upperRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                           rectOrigin.y + margin);
    CGPoint bottomRightCorner = CGPointMake(rectOrigin.x + rectWidth - margin,
                                            rectOrigin.y + rectHeight - margin);
    CGPoint bottomLeftCorner = CGPointMake(rectOrigin.x + margin,
                                           rectOrigin.y + rectHeight - margin);
    CGPoint leftSplitLine = CGPointMake(rectOrigin.x + margin,
                                        rectOrigin.y + margin + splitLineHeith);
    CGPoint rightSplitLine = CGPointMake(rectOrigin.x + rectWidth - margin,
                                         rectOrigin.y + margin + splitLineHeith);
    CGPoint leftMinusLine = CGPointMake(rectOrigin.x + minusX,
                                        rectOrigin.y + margin + minusHeith);
    CGPoint rightMinusLine = CGPointMake(rectOrigin.x + minusX + minusLength,
                                         rectOrigin.y + margin + minusHeith);
    
    // Draw the path
    UIColor * normalThemeColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                 green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                  blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                 alpha:1.0
                                  ];
    [normalThemeColor setStroke];
    
    UIBezierPath * outterSquare = [UIBezierPath bezierPath];
    [outterSquare moveToPoint:upperLeftCorner];
    [outterSquare addLineToPoint:upperRightCorner];
    [outterSquare addLineToPoint:bottomRightCorner];
    [outterSquare addLineToPoint:bottomLeftCorner];
    [outterSquare addLineToPoint:upperLeftCorner];
    [outterSquare moveToPoint:leftSplitLine];
    [outterSquare addLineToPoint:rightSplitLine];
    [outterSquare moveToPoint:leftMinusLine];
    [outterSquare addLineToPoint:rightMinusLine];
    [outterSquare stroke];
    CGContextAddPath(context, outterSquare.CGPath);
    
    // Render the image
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

