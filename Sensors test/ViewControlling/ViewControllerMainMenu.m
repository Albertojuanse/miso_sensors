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
    //                // USER DATA //
    //
    // The schema of the userData collection is:
    //
    //  [{ "name": (NSString *)name1;                  // userDic
    //     "pass": (NSString *)pass1;
    //     "role": (NSString *)role1;
    //   },
    //   { "name": (NSString *)name2;                  // userDic
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //              // SESSION DATA //
    //
    // The schema of the sessionData collection is:
    //
    //  [{ "user": { "name": (NSString *)name1;                  // sessionDic; userDic
    //               "pass": (NSString *)pass1;
    //               "role": (NSString *)role1;
    //             }
    //     "mode": (NSString *)mode1;
    //     "state": (NSString *)state1;
    //     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
    //     "itemsChosenByUser": (NSMutableArray *)items1;
    //     "typeChosenByUser": (MDType *)type1;
    //     "referencesByUser": (NSMutableArray *)references1
    //   },
    //   { "user": { "name": (NSString *)name2;                  // sessionDic; userDic
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //             // ITEMS DATA //
    //
    // The schema of the itemsData collection is:
    //
    //  [{ "sort": @"beacon" | @"position";                      //  itemDic
    //     "identifier": (NSString *)identifier1;
    //
    //     "uuid": (NSString *)uuid1;
    //
    //     "major": (NSString *)major1;
    //     "minor": (NSString *)minor1;
    //
    //     "position": (RDPosition *)position1;
    //
    //     "located": @"YES" | @"NO";
    //
    //     "type": (MDType *)type1
    //   },
    //   { "sort": @"beacon" | @"position";
    //     "identifier": (NSString *)identifier2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //            // MEASURES DATA //
    //
    //  [{ "user": { "name": (NSString *)name1;                  // measureDic; userDic
    //               "pass": (NSString *)pass1;
    //               "role": (NSString *)role1;
    //             }
    //     "position": (RDPosition *)position1;
    //     "itemUUID": (NSString *)itemUUID1;
    //     "deviceUUID": (NSString *)deviceUUID1;
    //     "sort" : (NSString *)type1;
    //     "measure": (NSNumber *)measure1
    //   },
    //   { "user": { "name": (NSString *)name2;                  // measureDic; userDic
    //               "pass": (NSString *)pass2;
    //               "role": (NSString *)role2;
    //             }
    //     "position": (RDPosition *)position2;
    //     (···)
    //   },
    //   (···)
    //  ]
    //
    //            // METAMODEL DATA //
    //
    // The schema of typesData collection is
    //
    //  [ (MDType *)type1,
    //    (···)
    //  ]
    //
    //              // MODEL DATA //
    //
    // The schema of modelData collection is is
    //
    //  [{ "name": name1;                                        //  modelDic
    //     "components": [
    //         { "position": (RDPosition *)position1;            //  componentDic
    //           "type": (MDType *)type1;
    //           "sourceItem": (NSMutableDictionary *)itemDic1;  //  itemDic
    //         { "position": (RDPosition *)positionB;
    //           (···)
    //         },
    //         (···)
    //     ];
    //     "references": [
    //         (MDReference *)reference1,
    //         (···)
    //     ]
    //   },
    //   { "name": name2;                                        //  modelDic
    //     (···)
    //   },
    //  ]
    //
    
    // Create a session for the current user; if it joins another one later, this will be remplaced or deleted.
    // Check if a session with this user is created before
    if ([sharedData fromSessionDataGetSessionWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic]) {
        // Do nothing
    } else {
        NSMutableDictionary * sessionDic = [[NSMutableDictionary alloc] init];
        sessionDic [@"user"] = userDic;
        [[sharedData getSessionDataWithCredentialsUserDic:credentialsUserDic] addObject:sessionDic];
    }
    
    
    // Init the radiodetermination components
    NSString * deviceUUID = [[NSUUID UUID] UUIDString];
    if (!rhoRhoSystem) {
        rhoRhoSystem = [[RDRhoRhoSystem alloc] initWithSharedData:sharedData
                                                          userDic:userDic
                                                       deviceUUID:deviceUUID
                                            andCredentialsUserDic:credentialsUserDic];
    }
    if (!rhoThetaSystem) {
        rhoThetaSystem = [[RDRhoThetaSystem alloc] initWithSharedData:sharedData
                                                              userDic:userDic
                                                           deviceUUID:deviceUUID
                                                andCredentialsUserDic:credentialsUserDic];
    }
    if (!thetaThetaSystem) {
        thetaThetaSystem = [[RDThetaThetaSystem alloc] initWithSharedData:sharedData
                                                                  userDic:userDic
                                                               deviceUUID:deviceUUID
                                                    andCredentialsUserDic:credentialsUserDic];
    }
    
    // Init the motion manager, given the shared data component and the credentials of the device user; if it is the first time the view loads this components won't exist but if not these had been created and set as others views' atributes.
    if(!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                                   userDic:credentialsUserDic
                                              rhoRhoSystem:rhoRhoSystem
                                            rhoThetaSystem:rhoThetaSystem
                                          thetaThetaSystem:thetaThetaSystem
                                                deviceUUID:deviceUUID
                                     andCredentialsUserDic:credentialsUserDic];
        
        // TO DO: make this configurable or properties. Alberto J. 2019/09/13.
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
                                                               userDic:credentialsUserDic
                                                          rhoRhoSystem:rhoRhoSystem
                                                        rhoThetaSystem:rhoThetaSystem
                                                      thetaThetaSystem:thetaThetaSystem
                                                            deviceUUID:deviceUUID
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
        // TO DO: BASIC, ROUTING AND TRACKING modes. Alberto J. 2019/09/13.
    }
    
    // Register something in the shared data collection if it is empty for exampling and showing porpuses
    BOOL registerCorrect = YES;
    // Register some types
    MDType * noType = [[MDType alloc] initWithName:@"<No type>"];
    MDType * cornerType = [[MDType alloc] initWithName:@"Corner"];
    MDType * deviceType = [[MDType alloc] initWithName:@"Device"];
    MDType * wallType = [[MDType alloc] initWithName:@"Wall"];
    if ([sharedData isMetamodelDataEmptyWithCredentialsUserDic:credentialsUserDic]) {
        registerCorrect = registerCorrect && [sharedData inMetamodelDataAddType:noType withCredentialsUserDic:credentialsUserDic];
        registerCorrect = registerCorrect && [sharedData inMetamodelDataAddType:cornerType withCredentialsUserDic:credentialsUserDic];
        registerCorrect = registerCorrect && [sharedData inMetamodelDataAddType:deviceType withCredentialsUserDic:credentialsUserDic];
        registerCorrect = registerCorrect && [sharedData inMetamodelDataAddType:wallType withCredentialsUserDic:credentialsUserDic];
    }
    
    // Register some items
    if ([sharedData isItemsDataEmptyWithCredentialsUserDic:credentialsUserDic]) {
        
        // The item's setter ask for identifier and sort but the copies everything else from a NSMutableDitionary with the same values and keys.
        NSMutableDictionary * infoDic0 = [[NSMutableDictionary alloc] init];
        RDPosition * position0 = [[RDPosition alloc] init];
        position0.x = [NSNumber numberWithFloat:0.0];
        position0.y = [NSNumber numberWithFloat:0.0];
        position0.z = [NSNumber numberWithFloat:0.0];
        [infoDic0 setValue:position0 forKey:@"position"];
        [infoDic0 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic0 setValue:deviceType forKey:@"type"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"position"
                                                                  withIdentifier:@"device@miso.uam.es"
                                                                     withInfoDic:infoDic0
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoDic1 = [[NSMutableDictionary alloc] init];
        RDPosition * position1 = [[RDPosition alloc] init];
        position1.x = [NSNumber numberWithFloat:0.0];
        position1.y = [NSNumber numberWithFloat:0.0];
        position1.z = [NSNumber numberWithFloat:0.0];
        [infoDic1 setValue:position1 forKey:@"position"];
        [infoDic1 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic1 setValue:cornerType forKey:@"type"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"position"
                                                                  withIdentifier:@"position1@miso.uam.es"
                                                                     withInfoDic:infoDic1
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoDic2 = [[NSMutableDictionary alloc] init];
        RDPosition * position2 = [[RDPosition alloc] init];
        position2.x = [NSNumber numberWithFloat:3.5];
        position2.y = [NSNumber numberWithFloat:0.0];
        position2.z = [NSNumber numberWithFloat:0.0];
        [infoDic2 setValue:position2 forKey:@"position"];
        [infoDic2 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic2 setValue:cornerType forKey:@"type"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"position"
                                                                  withIdentifier:@"position2@miso.uam.es"
                                                                     withInfoDic:infoDic2
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoDic3 = [[NSMutableDictionary alloc] init];
        RDPosition * position3 = [[RDPosition alloc] init];
        position3.x = [NSNumber numberWithFloat:3.5];
        position3.y = [NSNumber numberWithFloat:-13.0];
        position3.z = [NSNumber numberWithFloat:0.0];
        [infoDic3 setValue:position3 forKey:@"position"];
        [infoDic3 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic3 setValue:cornerType forKey:@"type"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"position"
                                                                  withIdentifier:@"position3@miso.uam.es"
                                                                     withInfoDic:infoDic3
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoDic4 = [[NSMutableDictionary alloc] init];
        RDPosition * position4 = [[RDPosition alloc] init];
        position4.x = [NSNumber numberWithFloat:0.0];
        position4.y = [NSNumber numberWithFloat:-13.0];
        position4.z = [NSNumber numberWithFloat:0.0];
        [infoDic4 setValue:position4 forKey:@"position"];
        [infoDic4 setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        [infoDic4 setValue:cornerType forKey:@"type"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"position"
                                                                  withIdentifier:@"position4@miso.uam.es"
                                                                     withInfoDic:infoDic4
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoRegionRaspiDic = [[NSMutableDictionary alloc] init];
        [infoRegionRaspiDic setValue:@"25DC8A73-F3C9-4111-A7DD-C39CD4B828C7" forKey:@"uuid"];
        [infoRegionRaspiDic setValue:@"1" forKey:@"major"];
        [infoRegionRaspiDic setValue:@"0" forKey:@"minor"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"beacon"
                                                                  withIdentifier:@"raspi@miso.uam.es"
                                                                     withInfoDic:infoRegionRaspiDic
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoItemBeacon1Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon1Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825" forKey:@"uuid"];
        [infoItemBeacon1Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon1Dic setValue:@"1" forKey:@"minor"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"beacon"
                                                                  withIdentifier:@"beacon1@miso.uam.es"
                                                                     withInfoDic:infoItemBeacon1Dic
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoItemBeacon2Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon2Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647824" forKey:@"uuid"];
        [infoItemBeacon2Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon2Dic setValue:@"1" forKey:@"minor"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"beacon"
                                                                  withIdentifier:@"beacon2@miso.uam.es"
                                                                     withInfoDic:infoItemBeacon2Dic
                                                       andWithCredentialsUserDic:credentialsUserDic];
        
        NSMutableDictionary * infoItemBeacon3Dic = [[NSMutableDictionary alloc] init];
        [infoItemBeacon3Dic setValue:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647823" forKey:@"uuid"];
        [infoItemBeacon3Dic setValue:@"1" forKey:@"major"];
        [infoItemBeacon3Dic setValue:@"1" forKey:@"minor"];
        
        registerCorrect = registerCorrect && [sharedData inItemDataAddItemOfSort:@"beacon"
                                                                  withIdentifier:@"beacon3@miso.uam.es"
                                                                     withInfoDic:infoItemBeacon3Dic
                                                       andWithCredentialsUserDic:credentialsUserDic];
    }
    
    if (!registerCorrect) {
        NSLog(@"[ERROR][VCMM] Register of items incorrect; user credentials granted?");
    }
    
    // Variables
    if (!itemBeaconIdNumber) {
        itemBeaconIdNumber = [NSNumber numberWithInteger:5];
    }
    
    if (!itemPositionIdNumber) {
        itemPositionIdNumber = [NSNumber numberWithInteger:5];
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableModes.delegate = self;
    self.tableModes.dataSource = self;
    self.tableItems.delegate = self;
    self.tableItems.dataSource = self;
    
    [self.tableModes reloadData];
    [self.tableItems reloadData];
}

/*!
 @method viewDidAppear
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated {
    // Verify that credentials grant user to shared data
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        NSLog(@"[INFO][VCMM] User credentials have been validated.");
    } else {
        [self alertUserWithTitle:@"User not allowed."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMM] Shared data could not be accessed after view loading.");
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
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
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // If user did select a row in the table
        if (chosenMode) {
            
            if ([chosenMode isEqualToString:[modes objectAtIndex:0]]) { // RHO_RHO_MODELING
                [sharedData inSessionDataSetMode:@"RHO_RHO_MODELING"
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [self performSegueWithIdentifier:@"fromMainToRHO_RHO_MODELING" sender:sender];
            }
            if ([chosenMode isEqualToString:[modes objectAtIndex:1]]) { // RHO_THETA_MODELING
                [sharedData inSessionDataSetMode:@"RHO_THETA_MODELING"
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
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
                [sharedData inSessionDataSetMode:@"THETA_THETA_LOCATING"
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            
            return;
        } else {
            return;
        }
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
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
    NSLog(@"[INFO][VCMM] Asked segue %@", [segue identifier]);
    
    // If add menu is going to be displayed, pass it the beaconsAndPositionsRegistered array
    if ([[segue identifier] isEqualToString:@"fromMainToAdd"]) {
        
        // Get destination view
        ViewControllerAddBeaconMenu * viewControllerAddBeaconMenu = [segue destinationViewController];
        // Set the variables and components
        [viewControllerAddBeaconMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerAddBeaconMenu setUserDic:userDic];
        [viewControllerAddBeaconMenu setSharedData:sharedData];
        [viewControllerAddBeaconMenu setMotionManager:motion];
        [viewControllerAddBeaconMenu setLocationManager:location];
        
        [viewControllerAddBeaconMenu setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerAddBeaconMenu setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    
    // If Rho Rho Syetem based Modeling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_RHO_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoRhoModeling * viewControllerRhoRhoModeling = [segue destinationViewController];
        // Set the variables and components
        [viewControllerRhoRhoModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoRhoModeling setUserDic:userDic];
        [viewControllerRhoRhoModeling setSharedData:sharedData];
        [viewControllerRhoRhoModeling setMotionManager:motion];
        [viewControllerRhoRhoModeling setLocationManager:location];
        
    }
    
    // If Rho Theta Syetem based Modeling is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToRHO_THETA_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModeling * viewControllerRhoThetaModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoThetaModeling setUserDic:userDic];
        [viewControllerRhoThetaModeling setSharedData:sharedData];
        [viewControllerRhoThetaModeling setMotionManager:motion];
        [viewControllerRhoThetaModeling setLocationManager:location];
        
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
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setMotionManager:motion];
        [viewControllerSelectPositions setLocationManager:location];
        
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
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        return itemsCount + modelCount;
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
    if (tableView == self.tableItems) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
        
            // Select the source of items; both items and models are shown
            NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
            NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
            
            // Load the item depending of the source
            NSMutableDictionary * itemDic = nil;
            if (indexPath.row < itemsCount) {
                itemDic = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row];
            }
            if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
                itemDic = [
                           [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                           objectAtIndex:indexPath.row - itemsCount
                           ];
            }
            
            // The itemDic variable can be null or NO if access is not granted or there are not items stored.
            if (itemDic) {
                cell.textLabel.numberOfLines = 0; // Means any number
                
                // If it is a beacon
                if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                    
                    // It representation depends on if exist its position or its type
                    if (itemDic[@"position"]) {
                        if (itemDic[@"type"]) {
                            
                            RDPosition * position = itemDic[@"position"];
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%.2f, %.2f, %.2f)",
                                                   itemDic[@"identifier"],
                                                   itemDic[@"type"],
                                                   itemDic[@"uuid"],
                                                   itemDic[@"major"],
                                                   itemDic[@"minor"],
                                                   [position.x floatValue],
                                                   [position.y floatValue],
                                                   [position.z floatValue]
                                                   ];
                            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                            
                        } else {
                            
                            RDPosition * position = itemDic[@"position"];
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ UUID: %@ \nMajor: %@ ; Minor: %@; Position: (%.2f, %.2f, %.2f)",
                                                   itemDic[@"identifier"],
                                                   itemDic[@"uuid"],
                                                   itemDic[@"major"],
                                                   itemDic[@"minor"],
                                                   [position.x floatValue],
                                                   [position.y floatValue],
                                                   [position.z floatValue]
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
            
                // If it is a position
                if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                    // If its type is set
                    RDPosition * position = itemDic[@"position"];
                    if (itemDic[@"type"]) {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ \n Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               itemDic[@"type"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    } else {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ \n Position: (%.2f, %.2f, %.2f)",
                                               itemDic[@"identifier"],
                                               [position.x floatValue],
                                               [position.y floatValue],
                                               [position.z floatValue]
                                               ];
                        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                    }
                }
                
                // If it is a model
                if ([@"model" isEqualToString:itemDic[@"sort"]]) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",
                                           itemDic[@"name"]
                                           ];
                    cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                }
            } else {
                // The itemDic variable is null or NO
                NSLog(@"[VCMM][ERROR] No items found for showing");
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"No items found.";
                    cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
                }
            }
        }
    }
    if (tableView == self.tableModes) {
        NSString * mode = [modes objectAtIndex:indexPath.row];
        NSString * modeToShow;
        if([@"RHO_RHO_MODELING" isEqualToString:mode]) {
            modeToShow = @"Locate others using iBeacon";
        }
        if([@"RHO_THETA_MODELING" isEqualToString:mode]) {
            modeToShow = @"Locate others using iBeacon and brújula";
        }
        if([@"THETA_THETA_MODELING" isEqualToString:mode]) {
            modeToShow = @"Locate others using compass";
        }
        if([@"RHO_RHO_LOCATING" isEqualToString:mode]) {
            modeToShow = @"Self locate using iBeacon";
        }
        if([@"RHO_THETA_LOCATING" isEqualToString:mode]) {
            modeToShow = @"Self locate using iBeacon and brújula";
        }
        if([@"THETA_THETA_LOCATING" isEqualToString:mode]) {
            modeToShow = @"Self locate using compass";
        }
        if (modeToShow) {
            cell.textLabel.text = modeToShow;
        } else{
            cell.textLabel.text = @"MODE_NAME_NOT_AVALIBLE";
        }
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableItems) {
        
        // Reset
        // CredentialsUserDic is the current device's user.
        [sharedData inSessionDataSetItemChosenByUser:nil
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
        // Select the source of items; both items are models shown
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        
        // Load the item depending of the source
        NSMutableDictionary * itemChosenByUser = nil;
        if (indexPath.row < itemsCount) {
            itemChosenByUser = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                                objectAtIndex:indexPath.row
                                ];
        }
        if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
            itemChosenByUser = [
                       [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                                objectAtIndex:indexPath.row - itemsCount
                                ];
        }
        
        // Update
        // Can be null if credentials are not allowed.
        if (itemChosenByUser) {
            [sharedData inSessionDataSetItemChosenByUser:itemChosenByUser
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
        } else {
            NSLog(@"[VCMM][ERROR] User did choose an inexisting item.");
        }
        
    }
    if (tableView == self.tableModes) {
        chosenMode = [modes objectAtIndex:indexPath.row];
    }
}

@end
