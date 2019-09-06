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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Other components; only inizialated if they didn't be so
    // Init the shared data collection with the credentials of the device user.
    if (!sharedData) {
        sharedData = [[SharedData alloc] initWithCredentialsUserDic:credentialsUserDic];
    }
    
    // Init the motion manager, given the shared data component and the credentials of the device user.
    if(!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                     andCredentialsUserDic:credentialsUserDic];
        
        motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
    }
    
    // Init the location manager, given the shared data component and the credentials of the device user.
    if (!location) {
        location = [[LocationManagerDelegate alloc] initWithSharedData:sharedData
                                             andCredentialsUserDic:credentialsUserDic];
    }
    
    // Variables; only inizialated if they didn't be so.
    if (!modes) {
        modes = [[NSMutableArray alloc] init];
        [modes addObject:@"RHO_RHO_MODELING"];
        [modes addObject:@"RHO_THETA_MODELING"];
        [modes addObject:@"THETA_THETA_MODELING"];
        [modes addObject:@"RHO_RHO_LOCATING"];
        [modes addObject:@"RHO_THETA_LOCATING"];
        [modes addObject:@"THETA_THETA_LOCATING"];
    }
    
    // The schema of the beaconsAndPositionsRegistered object is:
    //
    //  [{ "sort": @"beacon" | @"position";                             //  regionDic
    //     "identifier": (NSString *)identifier1;
    //
    //     "uuid": (NSString *)uuid1;
    //
    //     "major": (NSString *)major1;
    //     "minor": (NSString *)minor1;
    //
    //     "position": (RDPosition *)position1;
    //     "x": (NSString *)x1;
    //     "y": (NSString *)y1;
    //     "z": (NSString *)z1;
    //
    //     "sort": (NSMutableDictionary *)typeDic1;                    //  typeDic
    //
    //   },
    //   { "sort": @"beacon" | @"position";
    //     "identifier": (NSString *)identifier2;
    //     "uuid": (NSString *)uuid2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    // The schema of typesRegistered is
    //
    //  [{ "name": name1                                               //  typeDic
    //   },
    //   { "name": name2
    //   },
    //   (···)
    //  ]
    //
    // The schema of modelsGenerated is
    //
    //  [{ "name": name1;                                              //  modelDic
    //     "components": (NSMutableArray *)modelComponents1            //  modelComponents
    //   },
    //   { "name": name2;
    //     "components": (NSMutableArray *)modelComponents2
    //   },
    //   (···)
    //  ]
    //
    // The schema of modelComponents is
    //
    //  [{ "sort": @"beacon" | @"position";                            //  modelDic
    //     "sort": (NSMutableDictionary *)typeDic1;                    //  typeDic
    //     "regionDic": (NSMutableDictionary *)regionDic1              //  regionDic
    //   },
    //   { "sort": @"beacon" | @"position";
    //     "sort": (NSMutableDictionary *)typeDic2;
    //     "regionDic": (NSMutableDictionary *)regionDic2
    //   },
    //   (···)
    //  ]
    //
    
    if (!beaconsAndPositionsRegistered) {
        beaconsAndPositionsRegistered = [[NSMutableArray alloc] init];
        // Pre-registered regions
        NSMutableDictionary * typeDic = [[NSMutableDictionary alloc] init];
        [typeDic setValue:@"Corner" forKey:@"name"];
        NSMutableDictionary * regionPos1Dic = [[NSMutableDictionary alloc] init];
        [regionPos1Dic setValue:@"position" forKey:@"sort"];
        [regionPos1Dic setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [regionPos1Dic setValue:@"0.0" forKey:@"x"];
        [regionPos1Dic setValue:@"0.0" forKey:@"y"];
        [regionPos1Dic setValue:@"0.0" forKey:@"z"];
        RDPosition * position1 = [[RDPosition alloc] init];
        position1.x = [NSNumber numberWithFloat:0.0];
        position1.y = [NSNumber numberWithFloat:0.0];
        position1.z = [NSNumber numberWithFloat:0.0];
        [regionPos1Dic setValue:position1 forKey:@"position"];
        [regionPos1Dic setValue:typeDic forKey:@"sort"];
        [regionPos1Dic setValue:@"position1@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionPos1Dic];
        NSMutableDictionary * regionPos2Dic = [[NSMutableDictionary alloc] init];
        [regionPos2Dic setValue:@"position" forKey:@"sort"];
        [regionPos2Dic setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [regionPos2Dic setValue:@"3.5" forKey:@"x"];
        [regionPos2Dic setValue:@"0.0" forKey:@"y"];
        [regionPos2Dic setValue:@"0.0" forKey:@"z"];
        RDPosition * position2 = [[RDPosition alloc] init];
        position2.x = [NSNumber numberWithFloat:3.5];
        position2.y = [NSNumber numberWithFloat:0.0];
        position2.z = [NSNumber numberWithFloat:0.0];
        [regionPos2Dic setValue:position2 forKey:@"position"];
        [regionPos2Dic setValue:typeDic forKey:@"sort"];
        [regionPos2Dic setValue:@"position2@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionPos2Dic];
        NSMutableDictionary * regionPos3Dic = [[NSMutableDictionary alloc] init];
        [regionPos3Dic setValue:@"position" forKey:@"sort"];
        [regionPos3Dic setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [regionPos3Dic setValue:@"3.5" forKey:@"x"];
        [regionPos3Dic setValue:@"-13.0" forKey:@"y"];
        [regionPos3Dic setValue:@"0.0" forKey:@"z"];
        RDPosition * position3 = [[RDPosition alloc] init];
        position3.x = [NSNumber numberWithFloat:3.5];
        position3.y = [NSNumber numberWithFloat:-13.0];
        position3.z = [NSNumber numberWithFloat:0.0];
        [regionPos3Dic setValue:position3 forKey:@"position"];
        [regionPos3Dic setValue:typeDic forKey:@"sort"];
        [regionPos3Dic setValue:@"position3@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionPos3Dic];
        NSMutableDictionary * regionPos4Dic = [[NSMutableDictionary alloc] init];
        [regionPos4Dic setValue:@"position" forKey:@"sort"];
        [regionPos4Dic setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [regionPos4Dic setValue:@"0.0" forKey:@"x"];
        [regionPos4Dic setValue:@"-13.0" forKey:@"y"];
        [regionPos4Dic setValue:@"0.0" forKey:@"z"];
        RDPosition * position4 = [[RDPosition alloc] init];
        position4.x = [NSNumber numberWithFloat:0.0];
        position4.y = [NSNumber numberWithFloat:-13.0];
        position4.z = [NSNumber numberWithFloat:0.0];
        [regionPos4Dic setValue:position4 forKey:@"position"];
        [regionPos4Dic setValue:typeDic forKey:@"sort"];
        [regionPos4Dic setValue:@"position4@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionPos4Dic];
        
        NSMutableDictionary * regionRaspiDic = [[NSMutableDictionary alloc] init];
        [regionRaspiDic setValue:@"beacon" forKey:@"sort"];
        [regionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
        [regionRaspiDic setValue:@"1" forKey:@"major"];
        [regionRaspiDic setValue:@"0" forKey:@"minor"];
        [regionRaspiDic setValue:@"raspi@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionRaspiDic];
        NSMutableDictionary * regionBeacon1Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon1Dic setValue:@"beacon" forKey:@"sort"];
        [regionBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
        [regionBeacon1Dic setValue:@"1" forKey:@"major"];
        [regionBeacon1Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon1Dic setValue:@"beacon1@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon1Dic];
        NSMutableDictionary * regionBeacon2Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon2Dic setValue:@"beacon" forKey:@"sort"];
        [regionBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
        [regionBeacon2Dic setValue:@"1" forKey:@"major"];
        [regionBeacon2Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon2Dic setValue:@"beacon2@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon2Dic];
        NSMutableDictionary * regionBeacon3Dic = [[NSMutableDictionary alloc] init];
        [regionBeacon3Dic setValue:@"beacon" forKey:@"sort"];
        [regionBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
        [regionBeacon3Dic setValue:@"1" forKey:@"major"];
        [regionBeacon3Dic setValue:@"1" forKey:@"minor"];
        [regionBeacon3Dic setValue:@"beacon3@miso.uam.es" forKey:@"identifier"];
        [beaconsAndPositionsRegistered addObject:regionBeacon3Dic];
    }
    
    if (!typesRegistered) {
        typesRegistered = [[NSMutableArray alloc] init];
        // Pre-registered types
        NSMutableDictionary * typeRemoveDic = [[NSMutableDictionary alloc] init];
        [typeRemoveDic setValue:@"<No type>" forKey:@"name"];
        [typesRegistered addObject:typeRemoveDic];
        NSMutableDictionary * type1Dic = [[NSMutableDictionary alloc] init];
        [type1Dic setValue:@"Corner" forKey:@"name"];
        [typesRegistered addObject:type1Dic];
        NSMutableDictionary * type2Dic = [[NSMutableDictionary alloc] init];
        [type2Dic setValue:@"Device" forKey:@"name"];
        [typesRegistered addObject:type2Dic];
    }
    
    if (!modelsGenerated) {
        modelsGenerated = [[NSMutableArray alloc] init];
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
 @method setBeaconsAndPositionsRegistered:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setBeaconsAndPositionsRegistered:(NSMutableArray *)newBeaconsAndPositionsRegistered
{
    beaconsAndPositionsRegistered = newBeaconsAndPositionsRegistered;
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

/*!
 @method setTypesRegistered:
 @discussion This method sets the NSMutableArray variable 'typesRegistered'.
 */
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered
{
    typesRegistered = newTypesRegistered;
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

- (IBAction)handleButonStart:(id)sender
{
    // If user did select a row in the table
    if (chosenMode) {
        
        if ([chosenMode isEqualToString:[modes objectAtIndex:0]]) { // RHO_RHO_MODELING
            [self performSegueWithIdentifier:@"fromMainToRHO_RHO_MODELING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:1]]) { // RHO_THETA_MODELING
            [self performSegueWithIdentifier:@"fromMainToRHO_THETA_MODELING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:2]]) { // RHO_THETA_MODELING
            return;
            // [self performSegueWithIdentifier:@"fromMainToTHETA_THETA_MODELING" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:3]]) { // RHO_RHO_LOCATING
            return;
            // [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:4]]) { // RHO_THETA_LOCATING
            return;
            // [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
        }
        if ([chosenMode isEqualToString:[modes objectAtIndex:5]]) { // THETA_THETA_LOCATING
            [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
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
        // Set the variables
        [viewControllerAddBeaconMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerAddBeaconMenu setSharedData:sharedData];
        [viewControllerAddBeaconMenu setMotionManager:motion];
        [viewControllerAddBeaconMenu setLocationManager:location];
        
        [viewControllerAddBeaconMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerAddBeaconMenu setTypesRegistered:typesRegistered];
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
    
    // If Rho Rho Syetem based Modeling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_RHO_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoRhoModeling *viewControllerRhoRhoModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoRhoModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoRhoModeling setSharedData:sharedData];
        [viewControllerRhoRhoModeling setMotionManager:motion];
        [viewControllerRhoRhoModeling setLocationManager:location];
        
        [viewControllerRhoRhoModeling setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerRhoRhoModeling setTypesRegistered:typesRegistered];
        
    }
    
    // If Rho Theta Syetem based Modeling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_THETA_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModeling *viewControllerRhoThetaModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoThetaModeling setSharedData:sharedData];
        [viewControllerRhoThetaModeling setMotionManager:motion];
        [viewControllerRhoThetaModeling setLocationManager:location];
        
        [viewControllerRhoThetaModeling setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerRhoThetaModeling setTypesRegistered:typesRegistered];
        
    }
    
    // If Theta Theta Syetem based Modeling is going to be displayed, there is no need of the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToTHETA_THETA_MODELING"]) {
        
        // TO DO. Alberto J. 2019/09/06.
        
    }
    
    // If Rho Theta Syetem or Rho Rho Sytem based Locating is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToSelectPositions"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setMotionManager:motion];
        [viewControllerSelectPositions setLocationManager:location];
        
        [viewControllerSelectPositions setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerSelectPositions setTypesRegistered:typesRegistered];
        [viewControllerSelectPositions setChosenMode:chosenMode];
        
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
    if (tableView == self.tableModes) {
        cell.textLabel.text = [modes objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableBeaconsAndPositions) {
        
        // Reset
        uuidChosenByUser = nil;
        positionChosenByUser = nil;
        
        // Depending on type, get the UUID or RDPosition object
        NSString * type = [beaconsAndPositionsRegistered objectAtIndex:indexPath.row][@"sort"];
        
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
