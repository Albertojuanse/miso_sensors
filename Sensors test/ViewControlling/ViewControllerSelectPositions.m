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
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed while loading cells' item.");
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
- (void) setLocationManager:(LocationManagerDelegate *)givenLocation
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

#pragma mark - Buttons event handles

/*!
 @method handleButtonBack:
 @discussion This method handles the Back button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromSelectPositionsToMain" sender:sender];
}

/*!
 @method handleButtonGo:
 @discussion This method handles the 'Go' button action and segue to theta theta system locating view; 'prepareForSegue:sender:' method is called before.
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
        NSString * mode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
        
        // This button can segue with different views depending on the mode chosen by the user in the main menu
        if ([mode isEqualToString:@"RHO_RHO_LOCATING"]) {
            // NSLog(@"[INFO][VCSP] Chosen mode is RHO_RHO_LOCATING.");
            // [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_RHO_LOCATING" sender:sender];
            return;
        }
        if ([mode isEqualToString:@"RHO_THETA_LOCATING"]) {
            // NSLog(@"[INFO][VCSP] Chosen mode is RHO_THETA_LOCATING.");
            // [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_THETA_LOCATING" sender:sender];
            return;
        }
        if ([mode isEqualToString:@"RHO_THETA_MODELING"]) {
            NSLog(@"[INFO][VCSP] Chosen mode is RHO_THETA_MODELING.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToRHO_THETA_MODELING" sender:sender];
            return;
        }
        if ([mode isEqualToString:@"THETA_THETA_LOCATING"]) {
            // Go is only allowed if the user did choose at least one position in the table
            NSLog(@"[INFO][VCSP] Chosen mode is THETA_THETA_LOCATING.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToTHETA_THETA_LOCATING" sender:sender];
        }
        
    } else {
        [self alertUserWithTitle:@"Mode won't load."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCSP] Shared data could not be accessed while loading cells' item.");
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
    NSLog(@"[INFO][VCSP] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu
        
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerThetaThetaLocating * viewControllerThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerThetaThetaLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerThetaThetaLocating setUserDic:userDic];
        [viewControllerThetaThetaLocating setSharedData:sharedData];
        [viewControllerThetaThetaLocating setMotionManager:motion];
        [viewControllerThetaThetaLocating setLocationManager:location];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToRHO_THETA_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModeling * viewControllerRhoThetaModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoThetaModeling setUserDic:userDic];
        [viewControllerRhoThetaModeling setSharedData:sharedData];
        [viewControllerRhoThetaModeling setMotionManager:motion];
        [viewControllerRhoThetaModeling setLocationManager:location];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
    }
    return;
}

#pragma mark - UItableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableItems) {
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        return itemsCount + modelCount;
    }
    return 0;
}

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
                cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
                            // TO DO: Assign items by user. Alberto J. 15/11/2019.
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
                                NSLog(@"[ERROR][VCSP] Saved item %@ could not be retieved from shared data.", eachComponent[@"identifier"]);
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

@end

