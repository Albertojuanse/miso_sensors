//
//  ViewControllerRhoThetaModeling.m
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMainMenu.h"

@implementation ViewControllerRhoThetaModeling

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
        [sharedData inSessionDataSetMode:@"RHO_THETA_MODELING"
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Get chosen item and set as device position
    NSMutableArray * itemsChosenByUser = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                           andCredentialsUserDic:credentialsUserDic];
    NSMutableDictionary * itemChosenByUserAsDevicePosition;
    if (itemsChosenByUser.count == 0) {
        NSLog(@"[ERROR][VCRTM] The collection with the items chosen by user is empty; no device position provided");
    } else {
        itemChosenByUserAsDevicePosition = [itemsChosenByUser objectAtIndex:0];
        if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR][VCRTM] The collection with the items chosen by user have more than one item; the first one is set as device position");
        }
    }
    if (itemChosenByUserAsDevicePosition) {
        RDPosition * position = itemChosenByUserAsDevicePosition[@"position"];
        if (!position) {
            NSLog(@"[ERROR][VCRTM] No position was found in the item chosen by user as device position; (0,0,0) is set");
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
        }
        [motion setPosition:position];
        [location setPosition:position];
    }
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
    // Visualization
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, aim the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
    
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
        NSLog(@"[ERROR][VCRTM] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [self.buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure."];
        
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startLocationMeasuring"
                                                                object:nil];
            NSLog(@"[NOTI][VCRTM] Notification \"startLocationMeasuring\" posted.");
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, aim the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"stopLocationMeasuring\" posted.");
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromRHO_THETA_MODELINGToSelectPosition" sender:sender];
}

/*!
 @method handleButtonModel:
 @discussion This method is called when user is prepared for modeling.
 */
- (IBAction)handleModelButton:(id)sender {
    [self performSegueWithIdentifier:@"fromRHO_THETA_MODELINGToModelingTHETA_THETA_LOCATING" sender:sender];
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
    NSLog(@"[INFO][VCRTM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromRHO_THETA_MODELINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setMotionManager:motion];
        [viewControllerSelectPositions setLocationManager:location];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"stopLocationMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"reset\" posted.");
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
            NSLog(@"[ERROR][VCRTM] Shared data could not be accessed while loading items.");
        }
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
            NSLog(@"[ERROR][VCRTM] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    // Configure individual cells
    if (tableView == self.tableTypes) {
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
    if (tableView == self.tableItems) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            // Load the item depending of the source
            NSMutableDictionary * itemSelected = nil;
            itemSelected = [
                                                  [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                                  objectAtIndex:indexPath.row
                                                  ];
            
            // Only beacons can be aimed, positions were marked
            if ([@"position" isEqualToString:itemSelected[@"sort"]] && ([@"NO" isEqualToString:itemSelected[@"located"]] || !itemSelected[@"located"]))
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                [sharedData inSessionDataSetItemChosenByUser:itemSelected
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
            }
            
        } else {
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCRTM] Shared data could not be accessed while loading cells' item.");
        }
    }
    if (tableView == self.tableTypes) {
        MDType * typeSelected = [
                                 [sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic]
                                 objectAtIndex:indexPath.row
                                 ];
        [sharedData inSessionDataSetTypeChosenByUser:typeSelected
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
    }
}

@end
