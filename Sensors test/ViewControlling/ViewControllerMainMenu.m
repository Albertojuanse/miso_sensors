//
//  ViewControllerMainMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMainMenu.h"

@implementation ViewControllerMainMenu

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Variables; only inizialated if they didn't be so.
    if (!modes) {
        modes = [[NSMutableArray alloc] init];
        [modes addObject:@"RHO_RHO_MODELLING"];
        [modes addObject:@"RHO_THETA_MODELLING"];
        [modes addObject:@"THETA_THETA_MODELLING"];
        [modes addObject:@"RHO_RHO_LOCATING"];
        [modes addObject:@"RHO_THETA_LOCATING"];
        [modes addObject:@"THETA_THETA_LOCATING"];
    }

    // The schema of the beaconsAndPositionsRegistered object is:
    //
    //  [{ "type": @"beacon" | @"position";                             //  regionDic
    //     "identifier": (NSString *)identifier1;
    //     "uuid": (NSString *)uuid1;
    //     "major": (NSString *)major1;
    //     "minor": (NSString *)minor1;
    //     "position": (RDPosition *)position1;
    //     "x": (NSString *)x1;
    //     "y": (NSString *)y1;
    //     "z": (NSString *)z1
    //   },
    //  [{ "type": @"beacon" | @"position";                             //  regionDic
    //     "identifier": (NSString *)identifier2;
    //     "uuid": (NSString *)uuid2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    
    if (!beaconsAndPositionsRegistered) {
        beaconsAndPositionsRegistered = [[NSMutableArray alloc] init];
        // Pre-registered regions
        NSMutableDictionary * regionRaspiDic = [[NSMutableDictionary alloc] init];
        [regionRaspiDic setValue:@"beacon" forKey:@"type"];
        [regionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
        [regionRaspiDic setValue:@"1" forKey:@"major"];
        [regionRaspiDic setValue:@"0" forKey:@"minor"];
        [regionRaspiDic setValue:@"raspi@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionRaspiDic];
        NSMutableDictionary * regionBeacon1Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon1Dic setValue:@"beacon" forKey:@"type"];
        [regionBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
        [regionBeacon1Dic setValue:@"1" forKey:@"major"];
        [regionBeacon1Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon1Dic setValue:@"beacon1@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon1Dic];
        NSMutableDictionary * regionBeacon2Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon2Dic setValue:@"beacon" forKey:@"type"];
        [regionBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
        [regionBeacon2Dic setValue:@"1" forKey:@"major"];
        [regionBeacon2Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon2Dic setValue:@"beacon2@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon2Dic];
        NSMutableDictionary * regionBeacon3Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon3Dic setValue:@"beacon" forKey:@"type"];
        [regionBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
        [regionBeacon3Dic setValue:@"1" forKey:@"major"];
        [regionBeacon3Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon3Dic setValue:@"beacon3@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon3Dic];
    }
    
    if (!entitiesRegistered) {
        entitiesRegistered = [[NSMutableArray alloc] init];
        // Pre-registered entities
        NSMutableDictionary * entity1Dic = [[NSMutableDictionary alloc] init];
        [entity1Dic setValue:@"Entity 1" forKey:@"name"];
        [entitiesRegistered addObject:entity1Dic];
        NSMutableDictionary * entity2Dic = [[NSMutableDictionary alloc] init];
        [entity2Dic setValue:@"Entity 2" forKey:@"name"];
        [entitiesRegistered addObject:entity2Dic];
    }
    
    if (!regionBeaconIdNumber) {
        regionBeaconIdNumber = [NSNumber numberWithInteger:3];
    }
    
    if (!regionPositionIdNumber) {
        regionPositionIdNumber = [NSNumber numberWithInteger:0];
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableModes.delegate = self;
    self.tableModes.dataSource = self;
    self.tableBeaconsAndPositions.delegate = self;
    self.tableBeaconsAndPositions.dataSource = self;
    
    [self.tableModes reloadData];
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
 @method setbeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setbeaconsAndPositionsRegistered:(NSMutableArray *)newbeaconsAndPositionsRegistered {
    beaconsAndPositionsRegistered = newbeaconsAndPositionsRegistered;
}

/*!
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)newRegionBeaconIdNumber {
    regionBeaconIdNumber = newRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)newRegionPositionIdNumber {
    regionPositionIdNumber = newRegionPositionIdNumber;
}

/*!
 @method setEntitiesRegistered:
 @discussion This method sets the NSMutableArray variable 'entitiesRegistered'.
 */
- (void) setEntitiesRegistered:(NSMutableArray *)newEntitiesRegistered {
    entitiesRegistered = newEntitiesRegistered;
}

#pragma mark - Butons event handle

/*!
 @method handleButtonAdd:
 @discussion This method handles the Add button action and ask the add view to show; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonAdd:(id)sender
{
    [self performSegueWithIdentifier:@"fromMainToAdd" sender:sender];
}

- (IBAction)handleButonStart:(id)sender {
    // If user did select a row in the table
    if (chosenMode) {
        
        if ([chosenMode isEqualToString:[modes objectAtIndex:0]]) { // RHO_RHO_MODELLING
            [self performSegueWithIdentifier:@"fromMainToRHO_RHO_MODELLING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:1]]) { // RHO_THETA_MODELLING
            [self performSegueWithIdentifier:@"fromMainToRHO_THETA_MODELLING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:2]]) { // RHO_THETA_MODELLING
            return;
            // [self performSegueWithIdentifier:@"fromMainToTHETA_THETA_MODELLING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:3]]) { // RHO_RHO_LOCATING
            return;
            // [self performSegueWithIdentifier:@"fromMainToAddPositions" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:4]]) { // RHO_THETA_LOCATING
            return;
            // [self performSegueWithIdentifier:@"fromMainToAddPositions" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:5]]) { // THETA_THETA_LOCATING
            [self performSegueWithIdentifier:@"fromMainToAddPositions" sender:sender];
        }
        
        return;
    } else {
        return;
    }
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCMM] Asked segue %@", [segue identifier]);
    
    // If add menu is going to be displayed, pass it the beaconsAndPositionsRegistered array
    if ([[segue identifier] isEqualToString:@"fromMainToAdd"]) {
        
        // Get destination view
        ViewControllerAddBeaconMenu *viewControllerAddBeaconMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerAddBeaconMenu setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerAddBeaconMenu setEntitiesRegistered:entitiesRegistered];
        [viewControllerAddBeaconMenu setRegionBeaconIdNumber:regionBeaconIdNumber];
        [viewControllerAddBeaconMenu setRegionPositionIdNumber:regionPositionIdNumber];
        
        // When user selects a cell in the table, sets one of the following with a value and the other one with null.
        if (uuidChosenByUser) {
            [viewControllerAddBeaconMenu setUuidChosenByUser:uuidChosenByUser];
        }
        if (positionChosenByUser) {
            [viewControllerAddBeaconMenu setPositionChosenByUser:positionChosenByUser];
        }
        
    }
    
    // If Rho Rho Syetem based Modelling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_RHO_MODELLING"]) {
        
        // Get destination view
        ViewControllerRhoRhoModelling *viewControllerRhoRhoModelling = [segue destinationViewController];
        // Set the variable
        [viewControllerRhoRhoModelling setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerRhoRhoModelling setEntitiesRegistered:entitiesRegistered];
        
    }
    
    // If Rho Theta Syetem based Modelling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_THETA_MODELLING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModelling *viewControllerRhoThetaModelling = [segue destinationViewController];
        // Set the variable
        [viewControllerRhoThetaModelling setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerRhoThetaModelling setEntitiesRegistered:entitiesRegistered];
        
    }
    
    // If Theta Theta Syetem based Modelling is going to be displayed, there is no need of the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToTHETA_THETA_MODELLING"]) {
        // Do nothing
    }
    
    // If Rho Theta Syetem or Rho Rho Sytem based Locating is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToAddPositions"]) {
        
        // Get destination view
        ViewControllerAddPositions * viewControllerAddPositions = [segue destinationViewController];
        // Set the variable
        [viewControllerAddPositions setbeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerAddPositions setEntitiesRegistered:entitiesRegistered];
        
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
    if (tableView == self.tableModes) {
        return [modes count];
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
        if ([@"position" isEqualToString:regionDic[@"type"]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: (%@, %@, %@)",
                                   regionDic[@"identifier"],
                                   regionDic[@"x"],
                                   regionDic[@"y"],
                                   regionDic[@"z"]
                                   ];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        }
    }
    if (tableView == self.tableModes) {
        cell.textLabel.text = [modes objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableBeaconsAndPositions) {
        
        // Reset
        uuidChosenByUser = nil;
        positionChosenByUser = nil;
        
        // Depending on type, get the UUID or RDPosition object
        NSString * type = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"type"];
        
        if ([type isEqualToString:@"beacon"]) {
            uuidChosenByUser = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"uuid"];
        }
        if ([type isEqualToString:@"position"]) {
            positionChosenByUser = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"position"];
        }
        
    }
    if (tableView == self.tableModes) {
        chosenMode = [modes objectAtIndex:indexPath.row];
    }
}

@end
