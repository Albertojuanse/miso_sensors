//
//  ViewControllerAddComponent.m
//  Sensors test
//
//  Created by Alberto J. on 15/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerAddComponent.h"

@implementation ViewControllerAddComponent

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Picker delegates
    self.tableItems.dataSource = self;
    self.tableItems.delegate = self;
}

/*!
@method viewDidLoad
@discussion This method is called when the view is going to be shown.
*/
- (void)viewWillAppear:(BOOL)animated
{
    
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

#pragma mark - Buttons event handlers

/*!
 @method handleButtonCancel:
 @discussion This method handles the 'cancel' button action and segues back.
 */
- (IBAction)handleButtonCancel:(id)sender
{
    // Dismiss the popover view
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonEdit:
@discussion This method handles the 'edit' button action, save the changes, and segues back.
*/
- (IBAction)handleButtonEdit:(id)sender
{
    // Dismiss the popover view
    NSLog(@"[NOTI][VCAC] Notification \"canvas/refresh\" posted.");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"canvas/refresh"
     object:nil];
    [self dismissViewControllerAnimated:YES completion:Nil];
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
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAC] Shared data could not be accessed while loading items.");
        }
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
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAC] Shared data could not be accessed while loading cells' item.");
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
                              // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAC] Shared data could not be accessed while selecting a cell.");
        }
    }
}
@end
