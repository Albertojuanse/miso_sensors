//
//  ViewControllerAddPositions.m
//  Sensors test
//
//  Created by Alberto J. on 11/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerAddPositions.h"

@implementation ViewControllerAddPositions

#pragma marks - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visualization
    self.textX.placeholder = @"0.0";
    self.textY.placeholder = @"0.0";
    self.textZ.placeholder = @"0.0";
    
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

/*!
 @method setChosenMode:
 @discussion This method sets the NSString variable 'chosenMode'.
 */
- (void) setChosenMode:(NSString *)newChosenMode {
    chosenMode = newChosenMode;
}

#pragma marks - Buttons event handles

/*!
 @method handleButtonSet:
 @discussion This method handles the Set button action and sets the cartesian coordinates of the beacon.
 */
- (IBAction)handleButtonSet:(id)sender {
    
    // Validate data
    NSString * floatRegex = @"[+-]?([0-9]*[.])?[0-9]+";
    NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
    if ([floatTest evaluateWithObject:[self.textX text]]){
        //Matches
    } else {
        return;
    }
    if ([floatTest evaluateWithObject:[self.textY text]]){
        //Matches
    } else {
        return;
    }
    if ([floatTest evaluateWithObject:[self.textZ text]]){
        //Matches
    } else {
        return;
    }
    
    // Search for it and set the coordinates
    // If the user chose in the table a beacon for set the coordinates
    if (uuidChosenByUser) {
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            if ([@"beacon" isEqualToString:regionDic[@"type"]]) {
                if ([regionDic[@"uuid"] isEqualToString:uuidChosenByUser]) {
                    regionDic[@"x"] = [self.textX text];
                    regionDic[@"y"] = [self.textY text];
                    regionDic[@"y"] = [self.textZ text];
                    
                    self.textX.text = @"";
                    self.textY.text = @"";
                    self.textZ.text = @"";
                }
            }
        }
        return;
    } else {
        return;
    }
}

/*!
 @method handleButtonBack:
 @discussion This method handles the Back button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender {
    [self performSegueWithIdentifier:@"fromAddPositionsToMain" sender:sender];
}

/*!
 @method handleButtonGo:
 @discussion This method handles the 'Go' button action and segue to theta theta system locating view; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonGo:(id)sender {
    
    // This button can segue with different views depending on the mode chosen by the user in the main menu
    if ([chosenMode isEqualToString:@"RHO_RHO_LOCATING"]) {
        // [self performSegueWithIdentifier:@"fromAddPositionsToRHO_RHO_LOCATING" sender:sender];
        return;
    }
    if ([chosenMode isEqualToString:@"RHO_THETA_LOCATING"]) {
        // [self performSegueWithIdentifier:@"fromAddPositionsToRHO_THETA_LOCATING" sender:sender];
        return;
    }
    if ([chosenMode isEqualToString:@"THETA_THETA_LOCATING"]) {
        [self performSegueWithIdentifier:@"fromAddPositionsToTHETA_THETA_LOCATING" sender:sender];
    }
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCAB] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu

    /*
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToRHO_RHO_LOCATING"]) {
     
        // Get destination view
        ViewControllerRhoRhoLocating * viewControllerRhoRhoLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoRhoLocating setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
     
    }
     return;
     */
        
    /*
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToRHO_THETA_LOCATING"]) {
     
        // Get destination view
        ViewControllerRhoThetaLocating * viewControllerRhoThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaLocating setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
     
    }
     return;
    */
        
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerThetaThetaLocating * viewControllerThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerThetaThetaLocating setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        
    }
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
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

