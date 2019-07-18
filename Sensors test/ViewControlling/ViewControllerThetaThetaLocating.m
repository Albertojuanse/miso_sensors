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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Variables
    idle = YES;
    measuring = NO;
    
    // Ask canvas to initialize
    [self.canvas prepareCanvas];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
    // Visualization
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, aim the reference position and tap 'Measure' for starting. Tap back for finishing."];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableBeaconsAndPositionsChosen.delegate = self;
    self.tableEntities.delegate = self;
    self.tableBeaconsAndPositionsChosen.dataSource = self;
    self.tableEntities.dataSource = self;
    
    [self.tableBeaconsAndPositionsChosen reloadData];
    [self.tableEntities reloadData];
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance methods

/*!
 @method setBeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered {
    beaconsAndPositionsRegistered = newBeaconsAndPositionsRegistered;
}

/*!
 @method setBeaconsAndPositionsChosen:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsChosen', the positions and beacons selected by user in the previus view.
 */
- (void) setBeaconsAndPositionsChosen:(NSMutableArray *)newBeaconsAndPositionsChosen {
    beaconsAndPositionsChosen = newBeaconsAndPositionsChosen;
}


/*!
 @method setBeaconsAndPositionsChosenIndexes:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsChosenIndexes', the indexes the positions and beacons selected by user in the previus view.
 */
- (void) setBeaconsAndPositionsChosenIndexes:(NSMutableArray *)newBeaconsAndPositionsChosenIndexes {
    beaconsAndPositionsChosenIndexes = newBeaconsAndPositionsChosenIndexes;
}

/*!
 @method setEntitiesRegistered:
 @discussion This method sets the NSMutableArray variable 'entitiesRegistered'.
 */
- (void) setEntitiesRegistered:(NSMutableArray *)newEntitiesRegistered {
    entitiesRegistered = newEntitiesRegistered;
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
- (IBAction)handleButtonMeasure:(id)sender {
    
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
            [data setObject:uuidChosenByUser forKey:@"uuidChosenByUser"];
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
- (IBAction)handleBackButton:(id)sender {
    [self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToMain" sender:sender];
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
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setEntitiesRegistered:entitiesRegistered];
        
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
    if (tableView == self.tableBeaconsAndPositionsChosen) {
        return [beaconsAndPositionsChosen count];
    }
    if (tableView == self.tableEntities) {
        return [entitiesRegistered count];
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
    if (tableView == self.tableBeaconsAndPositionsChosen) {
        NSMutableDictionary * regionDic = [beaconsAndPositionsChosen objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // If it is a beacon
        if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
            
            // It representation depends on if exist its position or its entity
            if (regionDic[@"x"] && regionDic[@"y"] && regionDic[@"z"]) {
                if (regionDic[@"entity"]) {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%@, %@, %@)",
                                           regionDic[@"identifier"],
                                           regionDic[@"entity"][@"name"],
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
                if (regionDic[@"entity"]) {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> UUID: %@ \nmajor: %@ ; minor: %@",
                                           regionDic[@"identifier"],
                                           regionDic[@"entity"][@"name"],
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
        if ([@"position" isEqualToString:regionDic[@"type"]]) {
            // If its entity is set
            if (regionDic[@"entity"]) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ <%@> \n Position: (%@, %@, %@)",
                                       regionDic[@"identifier"],
                                       regionDic[@"entity"][@"name"],
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
    if (tableView == self.tableEntities) {
        NSMutableDictionary * entityDic = [entitiesRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", entityDic[@"name"]];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableBeaconsAndPositionsChosen) {
        
        // Only positions can be aimed, positions were marked
        if ([@"position" isEqualToString:
             [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"type"]
             ])
        {
            positionChosenByUser = [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"position"];
            uuidChosenByUser = [beaconsAndPositionsChosen objectAtIndex:indexPath.row][@"uuid"];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    if (tableView == self.tableEntities) {
        // Get the chosen entity name
        entityChosenByUser = [entitiesRegistered objectAtIndex:indexPath.row][@"name"];
    }
}

@end
