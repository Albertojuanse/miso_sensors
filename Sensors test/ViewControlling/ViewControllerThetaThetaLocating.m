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
    
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:@"THETA_THETA_LOCATING"
                       toUserWithUserDic:credentialsUserDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Variables
    idle = YES;
    measuring = NO;
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithMode:@"THETA_THETA_LOCATING"];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
    // Visualization
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing."];
    
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

#pragma mark - Instance methods

/*!
 @method setCredentialsUserDic
 @discussion This method sets the credentials of the user for accessing data shared.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic {
    credentialsUserDic = givenCredentialsUserDic;
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
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)givenRegionBeaconIdNumber
{
    regionBeaconIdNumber = givenRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)givenRegionPositionIdNumber
{
    regionPositionIdNumber = givenRegionPositionIdNumber;
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
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
        measuresDic = [data valueForKey:@"measuresDic"];
        locatedDic = [data valueForKey:@"locatedDic"];
        self.canvas.measuresDic = measuresDic;
        self.canvas.locatedDic = locatedDic;
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
    
    // In every state the button performs different behaviours
    if (idle) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        // If user did chose a position to aim
        if (positionChosenByUser) {
            [self.buttonMeasure setEnabled:YES];
            idle = NO;
            measuring = YES;
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure."];
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            // Create a copy of beacons and positions for sending it; concurrence issues prevented
            NSMutableArray * beaconsAndPositionsChosenToSend = [[NSMutableArray alloc] init];
            for (NSMutableDictionary * regionDic in beaconsAndPositionsChosen) {
                [beaconsAndPositionsChosenToSend addObject:regionDic];
            }
            [data setObject:beaconsAndPositionsChosenToSend forKey:@"beaconsAndPositions"];
            [data setObject:positionChosenByUser forKey:@"positionChosenByUser"];
            -> [data setObject:uuidChosenByUser forKey:@"uuidChosenByUser"];
            [data setObject:locatedPositionUUID forKey:@"locatedPositionUUID"];
            [data setObject:@"THETA_THETA_LOCATING" forKey:@"mode"];
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startMeasuring"
                                                                object:nil
                                                              userInfo:data];
            NSLog(@"[NOTI][VCRTM] Notification \"startMeasuring\" posted.");
            return;
        } else {
            return;
        }
    }
    if (measuring) { // If 'Measuring' is tapped, ask stop measuring.
        [self.buttonMeasure setEnabled:YES];
        idle = YES;
        measuring = NO;
        [self.labelStatus setText:@"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing."];
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
    [self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToMain" sender:sender];
}

/*!
 @method handleButtonNext:
 @discussion This method is called one the user wnats to locate a new position and thus a new UUID is generated for it.
 */
- (IBAction)handleButtonNext:(id)sender
{
    // New UUID
    locatedPositionUUID = [[NSUUID UUID] UUIDString];
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCRTM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromTHETA_THETA_LOCATINGToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setTypesRegistered:typesRegistered];
        
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
    if (tableView == self.tableItemsChosen) {
        return [beaconsAndPositionsChosen count];
    }
    if (tableView == self.tableTypes) {
        return [typesRegistered count];
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
        NSMutableDictionary * regionDic = [beaconsAndPositionsChosen objectAtIndex:indexPath.row];
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
            
            // In this mode, only positions can be aimed, and so, beacons are marked
            [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
            [cell setTintColor:[UIColor redColor]];
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
            
        }
    }
    // Configure individual cells
    if (tableView == self.tableTypes) {
        NSMutableDictionary * typeDic = [typesRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", typeDic[@"name"]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableItemsChosen) {
        
        // Only positions can be aimed, positions were marked
        if ([@"position" isEqualToString:
             [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"sort"]
             ])
        {
            positionChosenByUser = [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"position"];
            -> uuidChosenByUser = [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"uuid"];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    if (tableView == self.tableTypes) {
        // Get the chosen type name
        typeChosenByUser = [typesRegistered objectAtIndex:indexPath.row][@"name"];
    }
}

@end
