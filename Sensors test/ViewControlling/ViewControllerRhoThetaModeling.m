//
//  ViewControllerRhoThetaModeling.m
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerRhoThetaModeling.h"

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
                       toUserWithUserDic:credentialsUserDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithMode:@"RHO_THETA_MODELING"];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
    // Visualization
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, aim the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItems.delegate = self;
    self.tableItems.dataSource = self;
    
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
 @method setCredentialsUserDic
 @discussion This method sets the credentials of the user for accessing data shared.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic
{
    credentialsUserDic = newCredentialsUserDic;
}

/*!
 @method setSharedData:
 @discussion This method sets the shared data collection.
 */
- (void) setSharedData:(SharedData *)newSharedData
{
    sharedData = newSharedData;
}

/*!
 @method setMotionManager:
 @discussion This method sets the motion manager.
 */
- (void) setMotionManager:(MotionManager *)newMotion
{
    motion = newMotion;
}

/*!
 @method setLocationManager:
 @discussion This method sets the location manager.
 */
- (void) setLocationManager:(LocationManagerDelegate *)newLocation
{
    location = newLocation;
}

/*!
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionBeaconIdNumber
{
    regionBeaconIdNumber = newRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionPositionIdNumber
{
    regionPositionIdNumber = newRegionPositionIdNumber;
}

#pragma mark - Notification event handles

/*!
 @method refreshCanvas:
 @discussion This method gets the beacons that must be represented in canvas and ask it to upload; this method is called when someone submits the 'refreshCanvas' notification.
 */
- (void) refreshCanvas:(NSNotification *) notification
{
    // [notification name] should always be @"refreshCanvas"
    // unless you use this method for observation of other notifications
    // as well.
    
    // TO DO: Acess data shared from canvas. Alberto J. 2019/09/10.
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // // Save beacons
        // NSDictionary *data = notification.userInfo;
        // measuresDic = [data valueForKey:@"measuresDic"];
        // locatedDic = [data valueForKey:@"locatedDic"];
        // self.canvas.measuresDic = measuresDic;
        // self.canvas.locatedDic = locatedDic;
    }
    
    [self.canvas setNeedsDisplay];
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must disable 'Travel' control buttons and ask location manager delegate to start measuring.
 */
- (IBAction)handleButtonMeasure:(id)sender
{
    // First, validate the acess to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Travel won't be started."
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:credentialsUserDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:credentialsUserDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [self.buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:credentialsUserDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure."];
        
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startMeasuring"
                                                                object:nil];
            NSLog(@"[NOTI][VCRTM] Notification \"startMeasuring\" posted.");
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:credentialsUserDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, aim the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"stopMeasuring\" posted.");
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromRHO_THETA_MODELINGToMain" sender:sender];
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
    if ([[segue identifier] isEqualToString:@"fromRHO_THETA_MODELINGToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"stopMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCRTM] Notification \"reset\" posted.");
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
        // Get the number of metamodel elements; if acess the database is imposible, warn the user.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            return [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        } else { // Type not found
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be acessed while loading items.");
        }
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
        
        // Database could not be acessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
            // Load the items
            NSMutableDictionary * regionDic = [
                                               [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                               objectAtIndex:indexPath.row
                                               ];
            cell.textLabel.numberOfLines = 0; // Means any number
            
            // If it is a beacon
            if ([@"beacon" isEqualToString:regionDic[@"sort"]]) {
                
                // It representation depends on if exist its position or its type
                if (regionDic[@"x"] && regionDic[@"y"] && regionDic[@"z"]) {
                    if (regionDic[@"sort"]) {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%@, %@, %@)",
                                               regionDic[@"identifier"],
                                               regionDic[@"sort"][@"name"],
                                               regionDic[@"uuid"],
                                               regionDic[@"major"],
                                               regionDic[@"minor"],
                                               regionDic[@"x"],
                                               regionDic[@"y"],
                                               regionDic[@"z"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    } else {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%@, %@, %@)",
                                               regionDic[@"identifier"],
                                               regionDic[@"uuid"],
                                               regionDic[@"major"],
                                               regionDic[@"minor"],
                                               regionDic[@"x"],
                                               regionDic[@"y"],
                                               regionDic[@"z"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    }
                } else {
                    if (regionDic[@"sort"]) {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> UUID: %@ \nmajor: %@ ; minor: %@",
                                               regionDic[@"identifier"],
                                               regionDic[@"sort"][@"name"],
                                               regionDic[@"uuid"],
                                               regionDic[@"major"],
                                               regionDic[@"minor"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    } else  {
                        
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nmajor: %@ ; minor: %@",
                                               regionDic[@"identifier"],
                                               regionDic[@"uuid"],
                                               regionDic[@"major"],
                                               regionDic[@"minor"]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                        
                    }
                }
            }
            
            // And if it is a position
            if ([@"position" isEqualToString:regionDic[@"sort"]]) {
                // If its type is set
                if (regionDic[@"sort"]) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> \n Position: (%@, %@, %@)",
                                           regionDic[@"identifier"],
                                           regionDic[@"sort"][@"name"],
                                           regionDic[@"x"],
                                           regionDic[@"y"],
                                           regionDic[@"z"]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: (%@, %@, %@)",
                                           regionDic[@"identifier"],
                                           regionDic[@"x"],
                                           regionDic[@"y"],
                                           regionDic[@"z"]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                }
                
                // In this mode, only beacons can be aimed, and so, positions are marked
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [cell setTintColor:[UIColor redColor]];
                
            }
            
        } else { // Type not found
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be acessed while loading cells' item.");
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableItems) {
        
        // Database could not be acessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            NSMutableDictionary * itemSelected = [
                                                  [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                                  objectAtIndex:indexPath.row
                                                  ];
            
            // Only beacons can be aimed, positions were marked
            if ([@"position" isEqualToString:itemSelected[@"sort"]])
            {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                [sharedData inSessionDataSetItemChosenByUser:itemSelected
                                           toUserWithUserDic:credentialsUserDic
                                       andCredentialsUserDic:credentialsUserDic];
            }
            
        } else {
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be acessed while loading cells' item.");
        }
    }
}

@end

