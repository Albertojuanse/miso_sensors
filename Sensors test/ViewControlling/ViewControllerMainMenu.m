//
//  ViewControllerMainMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMainMenu.h"

@implementation ViewControllerMainMenu

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

    if (!beaconsRegistered) {
        beaconsRegistered = [[NSMutableArray alloc] init];
        // Pre-registered regions
        NSMutableDictionary * regionRaspiDic = [[NSMutableDictionary alloc] init];
        [regionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
        [regionRaspiDic setValue:@"1" forKey:@"major"];
        [regionRaspiDic setValue:@"0" forKey:@"minor"];
        [regionRaspiDic setValue:@"raspi@miso.uam.es" forKey:@"identifier"];
        [beaconsRegistered addObject:regionRaspiDic];
        NSMutableDictionary * regionBeacon1Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
        [regionBeacon1Dic setValue:@"1" forKey:@"major"];
        [regionBeacon1Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon1Dic setValue:@"beacon1@miso.uam.es" forKey:@"identifier"];
        [beaconsRegistered addObject:regionBeacon1Dic];
        NSMutableDictionary * regionBeacon2Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
        [regionBeacon2Dic setValue:@"1" forKey:@"major"];
        [regionBeacon2Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon2Dic setValue:@"beacon2@miso.uam.es" forKey:@"identifier"];
        [beaconsRegistered addObject:regionBeacon2Dic];
        NSMutableDictionary * regionBeacon3Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
        [regionBeacon3Dic setValue:@"1" forKey:@"major"];
        [regionBeacon3Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon3Dic setValue:@"beacon3@miso.uam.es" forKey:@"identifier"];
        [beaconsRegistered addObject:regionBeacon3Dic];
    }
    
    if (!regionIdNumber) {
        regionIdNumber = [NSNumber numberWithInteger:3];
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableModes.delegate = self;
    self.tableModes.dataSource = self;
    self.tableBeacons.delegate = self;
    self.tableBeacons.dataSource = self;
    
    [self.tableModes reloadData];
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

/*!
 @method setBeaconsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsRegistered'.
 */
- (void) setBeaconsRegistered:(NSMutableArray *)newBeaconsRegistered {
    beaconsRegistered = newBeaconsRegistered;
}

/*!
 @method setRegionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsRegistered'.
 */
- (void) setRegionIdNumber:(NSNumber *)newRegionIdNumber {
    regionIdNumber = newRegionIdNumber;
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
        } else {
            return;
        }
        
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
    
    // If add menu is going to be displayed, pass it the beaconsRegistered array
    if ([[segue identifier] isEqualToString:@"fromMainToAdd"]) {
        
        // Get destination view
        ViewControllerAddBeaconMenu *viewControllerAddBeaconMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerAddBeaconMenu setBeaconsRegistered:beaconsRegistered];
        [viewControllerAddBeaconMenu setRegionIdNumber:regionIdNumber];
        
    }
    
    // If Rho Rho Syetem based Modelling is going to be displayed, pass it the beaconsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_RHO_MODELLING"]) {
        
        // Get destination view
        ViewControllerRhoRhoModelling *viewControllerRhoRhoModelling = [segue destinationViewController];
        // Set the variable
        [viewControllerRhoRhoModelling setBeaconsRegistered:beaconsRegistered];
        
    }
    
    // If Rho Theta Syetem based Modelling is going to be displayed, pass it the beaconsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_THETA_MODELLING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModelling *viewControllerRhoThetaModelling = [segue destinationViewController];
        // Set the variable
        [viewControllerRhoThetaModelling setBeaconsRegistered:beaconsRegistered];
        
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
        return [beaconsRegistered count];
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
    if (tableView == self.tableBeacons) {
        NSMutableDictionary * regionDic = [beaconsRegistered objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ ; major: %@ ; minor: %@",
                               regionDic[@"identifier"],
                               regionDic[@"uuid"],
                               regionDic[@"major"],
                               regionDic[@"minor"]
                               ];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    if (tableView == self.tableModes) {
        cell.textLabel.text = [modes objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableBeacons) {
        
    }
    if (tableView == self.tableModes) {
        chosenMode = [modes objectAtIndex:indexPath.row];
    }
}

@end
