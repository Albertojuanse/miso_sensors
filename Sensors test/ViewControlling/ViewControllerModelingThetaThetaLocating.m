//
//  ViewControllerModelingThetaThetaLocating.m
//  Sensors test
//
//  Created by Alberto J. on 2/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerModelingThetaThetaLocating.h"

@implementation ViewControllerModelingThetaThetaLocating

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:@"THETA_THETA_LOCATING"
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Variables
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
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
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromModelingTHETA_THETA_LOCATINGToTHETA_THETA_LOCATING" sender:sender];
}

/*!
 @method handleModifyButton:
 @discussion This method changes the already represented model.
 */
- (IBAction)handleModifyButton:(id)sender
{
    // Database could not be acessed.
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
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMTTL] Shared data could not be accessed while loading cells' item.");
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
    NSLog(@"[INFO][VCMTTL] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromModelingTHETA_THETA_LOCATINGToTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerThetaThetaLocating * viewControllerThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerThetaThetaLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerThetaThetaLocating setUserDic:userDic];
        [viewControllerThetaThetaLocating setSharedData:sharedData];
        [viewControllerThetaThetaLocating setMotionManager:motion];
        [viewControllerThetaThetaLocating setLocationManager:location];
        return;
    }
}

#pragma mark - UItableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

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
        return [[sharedData fromMetamodelDataGetTypesWithCredentialsUserDic:credentialsUserDic] count];
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
    if (tableView == self.tableItemsChosen) {
        
        // Database could not be acessed.
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
                             message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCMTTL] Shared data could not be accessed while loading cells' item.");
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
        
        MDType * type = [
                         [sharedData fromMetamodelDataGetTypesWithCredentialsUserDic:credentialsUserDic]
                         objectAtIndex:indexPath.row
                         ];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [type getName]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Database could not be acessed.
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
            
            MDType * typeSelected = [
                                     [sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic]
                                     objectAtIndex:indexPath.row
                                     ];
            
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
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMTTL] Shared data could not be accessed while loading cells' item.");
    }
}

@end

