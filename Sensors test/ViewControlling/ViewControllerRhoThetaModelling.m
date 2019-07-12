//
//  ViewControllerRhoThetaModelling.m
//  Sensors test
//
//  Created by Alberto J. on 10/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerRhoThetaModelling.h"

@implementation ViewControllerRhoThetaModelling

#pragma marks - UIViewController delegated methods

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
    [self.labelStatus setText:@"IDLE; please, aid the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableBeacons.delegate = self;
    self.tableBeacons.dataSource = self;
    
    [self.tableBeacons reloadData];
}

/*!
 @method didReceiveMemoryWarning
 @discussion This method dispose of any resources that can be recreated id a memory warning is recived.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marks - Instance methods

/*!
 @method setbeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered {
    beaconsAndPositionsRegistered = newbeaconsAndPositionsRegistered;
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

#pragma marks - Buttons event handles

/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must disable 'Travel' control buttons and ask location manager delegate to start measuring.
 */
- (IBAction)handleButtonMeasure:(id)sender {
    
    // In every state the button performs different behaviours
    if (idle) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        if (uuidChosenByUser) {
            [self.buttonMeasure setEnabled:YES];
            idle = NO;
            measuring = YES;
            [self.labelStatus setText:@"MEASURING; please, do not move the device. Tap 'Measure' again for finishing measure."];
        
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            // Create a copy of beacons for sending it; concurrence issues prevented
            NSMutableArray * beaconsAndPositionsRegisteredToSend = [[NSMutableArray alloc] init];
            for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
                [beaconsAndPositionsRegisteredToSend addObject:regionDic];
            }
            [data setObject:beaconsAndPositionsRegisteredToSend forKey:@"beaconsAndPositionsRegistered"];
            [data setObject:uuidChosenByUser forKey:@"uuidChosenByUser"];
            [data setObject:@"RHO_THETA_MODELLING" forKey:@"mode"];
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
    if (measuring) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonMeasure setEnabled:YES];
        idle = YES;
        measuring = NO;
        [self.labelStatus setText:@"IDLE; please, aid the iBEacon device and tap 'Measure' for starting. Tap back for finishing."];
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
    [self performSegueWithIdentifier:@"fromRHO_THETA_MODELLINGToMain" sender:sender];
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCRTM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromRHO_THETA_MODELLINGToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        
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
    if (tableView == self.tableBeacons) {
        return [beaconsAndPositionsRegistered count];
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
    if (tableView == self.tableBeacons) {
        NSMutableDictionary * regionDic = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
            if (regionDic[@"x"] && regionDic[@"y"] && regionDic[@"z"]) {
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
            } else {
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
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableBeacons) {
        uuidChosenByUser = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"uuid"];
    }
}

@end

