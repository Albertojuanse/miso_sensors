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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instance variables
    beaconsAndPositionsChosen = [[NSMutableArray alloc] init];
    beaconsAndPositionsChosenIndexes = [[NSMutableArray alloc] init];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableBeaconsAndPositions.delegate = self;
    self.tableBeaconsAndPositions.dataSource = self;
    // Allow multiple selection
    self.tableBeaconsAndPositions.allowsMultipleSelection = true;
    
    [self.tableBeaconsAndPositions reloadData];
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
 @method setChosenMode:
 @discussion This method sets the NSString variable 'chosenMode'.
 */
- (void) setChosenMode:(NSString *)newChosenMode {
    chosenMode = newChosenMode;
}

/*!
 @method setTypesRegistered:
 @discussion This method sets the NSMutableArray variable 'typesRegistered'.
 */
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered {
    typesRegistered = newTypesRegistered;
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonBack:
 @discussion This method handles the Back button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender {
    [self performSegueWithIdentifier:@"fromSelectPositionsToMain" sender:sender];
}

/*!
 @method handleButtonGo:
 @discussion This method handles the 'Go' button action and segue to theta theta system locating view; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonGo:(id)sender {
    
    NSLog(@"[INFO][VCSP]: Button GO pressed.");
    
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
        // Go is only allowed if the user did choose at least one position in the table
        NSLog(@"[INFO][VCSP]: Chosen mode is THETA_THETA_LOCATING.");
        if (beaconsAndPositionsChosen.count > 0) {
            NSLog(@"[INFO][VCSP]: beaconsAndPositionsChosen is not empty.");
            [self performSegueWithIdentifier:@"fromSelectPositionsToTHETA_THETA_LOCATING" sender:sender];
        }
    }
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCSP] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu

    /*
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToRHO_RHO_LOCATING"]) {
     
        // Get destination view
        ViewControllerRhoRhoLocating * viewControllerRhoRhoLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoRhoLocating setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
     
    }
     return;
     */
        
    /*
    if ([[segue identifier] isEqualToString:@"fromAddPositionsToRHO_THETA_LOCATING"]) {
     
        // Get destination view
        ViewControllerRhoThetaLocating * viewControllerRhoThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaLocating setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
     
    }
     return;
    */
        
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerThetaThetaLocating * viewControllerThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerThetaThetaLocating setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerThetaThetaLocating setBeaconsAndPositionsChosen:beaconsAndPositionsChosen];
        [viewControllerThetaThetaLocating setBeaconsAndPositionsChosenIndexes:beaconsAndPositionsChosenIndexes];
        [viewControllerThetaThetaLocating setTypesRegistered:typesRegistered];
        
    }
    if ([[segue identifier] isEqualToString:@"fromSelectPositionsToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setTypesRegistered:typesRegistered];
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
    if (tableView == self.tableBeaconsAndPositions) {
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
    if (tableView == self.tableBeaconsAndPositions) {
        NSMutableDictionary * regionDic = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // Only if the item have a position can be selected
        if (!regionDic[@"position"]) {
            [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
            [cell setTintColor:[UIColor redColor]];
        }
        
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
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableBeaconsAndPositions) {
        
        // The table was set in 'viewDidLoad' as multiple-selecting
        // Manage multi-selection
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If not checkmark
            
            // Only if the item have a position can be selected
            if ([beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"position"]) {
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                // Save the index
                [beaconsAndPositionsChosenIndexes addObject:[NSNumber numberWithInteger:indexPath.row]];
            } else {
                [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [selectedCell setTintColor:[UIColor redColor]];
            }
            
        } else { // If checkmark or detail mark
            
            // Only if the item have a position can be selected; if not is done again, the simbol disapears when deselecting
            if ([beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"position"]) {
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                // Remove the index
                [beaconsAndPositionsChosenIndexes removeObject:[NSNumber numberWithInteger:indexPath.row]];;
            } else {
                [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [selectedCell setTintColor:[UIColor redColor]];
            }
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        // Build the array with the selected beacons and positions each time
        beaconsAndPositionsChosen = [[NSMutableArray alloc] init];
        for (NSNumber * index in beaconsAndPositionsChosenIndexes) {
            [beaconsAndPositionsChosen addObject:
             [beaconsAndPositionsRegistered objectAtIndex:[index integerValue]]
             ];
        }
    }
    return;
}

@end

