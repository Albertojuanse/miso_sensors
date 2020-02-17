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
    
    // Visualization
    [self showUser];
    
    // Other components; only inizialated if they didn't be so
    // Init the shared data collection with the credentials of the device user.
    if (!sharedData) {
        sharedData = [[SharedData alloc] initWithCredentialsUserDic:credentialsUserDic];
        userDidLogIn = YES; // Used for some routines to be executed just one time
    }
    // Shared data scheme; for information porpuses
    //
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
    //     "modes": (NSMutableArray *)modes;
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
    //               // TYPES DATA //
    //
    // The schema of typesData collection is
    //
    //  [ (MDType *)type1,
    //    (···)
    //  ]
    //
    //            // METAMODEL DATA //
    //
    // The schema of metamodelsData collection is
    //
    //  [ (MDMetamodel *)metamodel1,
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
    
    // Variables; only inizialated if they didn't be so.
    // TO DO: Pass this in every view and call the modes by index, not by string. Alberto J. 2020/01/14.
    
    // Load any saved component or model in device's persistent memory or create the demo ones if is the first time that user logs in.
    [self loadRoutine];
    [self loadModels];
    
    // Load the saved variables
    [self loadVariables];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrationFinished:)
                                                 name:@"calibrationFinished"
                                               object:nil];
    
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

/*!
 @method showUser
 @discussion This method defines how user name is shown once logged.
 */
- (void)showUser
{
    self.loginText.text = [self.loginText.text stringByAppendingString:@" "];
    self.loginText.text = [self.loginText.text stringByAppendingString:userDic[@"name"]];
}

/*!
 @method loadVariables
 @discussion This method loads any saved variable in device's persistent memory
 */
- (void)loadVariables
{
    // Variables for naming porpuses; each new component created increases this counters to generate unique names.
    // TO DO: These variables to session dic in shared data. Alberto J. 2020/01/20.
    if (!itemBeaconIdNumber) {
        // Search for variables from device memory
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSData * areIdNumbersData = [userDefaults objectForKey:@"es.uam.miso/variables/areIdNumbers"];
        NSString * areIdNumbers;
        if (areIdNumbersData) {
            areIdNumbers = [NSKeyedUnarchiver unarchiveObjectWithData:areIdNumbersData];
        }
        if (areIdNumbersData && areIdNumbers && [areIdNumbers isEqualToString:@"YES"]) {
            
            // Existing saved data
            // Retrieve the items using the index
            
            // Retrieve the variables
            NSData * itemBeaconIdNumberData = [userDefaults objectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
            // ...and retrieve each item
            itemBeaconIdNumber = [NSKeyedUnarchiver unarchiveObjectWithData:itemBeaconIdNumberData];
            
            NSLog(@"[INFO][VCMM] Variable itemBeaconIdNumber found in device.");
            
        }
    }
    
    if (!itemPositionIdNumber) {
        // Search for variables from device memory
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSData * areIdNumbersData = [userDefaults objectForKey:@"es.uam.miso/variables/areIdNumbers"];
        NSString * areIdNumbers;
        if (areIdNumbersData) {
            areIdNumbers = [NSKeyedUnarchiver unarchiveObjectWithData:areIdNumbersData];
        }
        if (areIdNumbersData && areIdNumbers && [areIdNumbers isEqualToString:@"YES"]) {
            
            // Existing saved data
            // Retrieve the items using the index
            
            // Retrieve the variables
            NSData * itemPositionIdNumberData = [userDefaults objectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
            // ...and retrieve each item
            itemPositionIdNumber = [NSKeyedUnarchiver unarchiveObjectWithData:itemPositionIdNumberData];
            
            NSLog(@"[INFO][VCMM] Variable itemPositionIdNumber found in device.");
            
        }
    }
}

/*!
 @method loadRoutine
 @discussion This method loads any saved component or model in device's persistent memory or create the demo ones if is the first time that user logs in
 */
- (void)loadRoutine
{
    if (userDidLogIn) {
        // Search for current information saved in system; if not, register them as first time
        BOOL registerCorrect = YES;
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Load the MDRoutine object
        NSData * isRoutineData = [userDefaults objectForKey:@"es.uam.miso/data/routines/isRoutine"];
        NSString * isRoutine;
        MDRoutine * routine;
        if (isRoutineData) {
            isRoutine = [NSKeyedUnarchiver unarchiveObjectWithData:isRoutineData];
        }
        if (isRoutineData && isRoutine && [isRoutine isEqualToString:@"YES"]) {
            NSData * routineData = [userDefaults objectForKey:@"es.uam.miso/data/routines/routine"];
            routine = [NSKeyedUnarchiver unarchiveObjectWithData:routineData];
        } else {
            NSLog(@"[ERROR][VCMM] No routine found in device.");
            return;
        }
        
        if (routine) {
            // Routine found
            NSLog(@"[INFO][VCMM] Loading routine from device.");
            
            NSMutableArray * types = [routine getTypes];
            NSMutableArray * metamodels = [routine getMetamodels];
            NSMutableArray * items = [routine getItems];
            
            
            // Set items in data shared
            for (MDType * eachType in types) {
                registerCorrect = registerCorrect && [sharedData inTypesDataAddType:eachType withCredentialsUserDic:credentialsUserDic];
            }
            NSLog(@"[INFO][VCMM] -> %tu ontological types found in routine.", types.count);
            
            // Metamodels
            for (MDMetamodel * eachMetamodel in metamodels) {
                registerCorrect = registerCorrect && [sharedData inMetamodelsDataAddMetamodel:eachMetamodel                                                                        withCredentialsUserDic:credentialsUserDic];
            }
            NSLog(@"[INFO][VCMM] -> %tu metamodels found in routine.", metamodels.count);
            
            // Modes; from each metamodel, get the modes
            NSMutableArray * modes = [[NSMutableArray alloc] init];
            for  (MDMetamodel * eachMetamodel in metamodels) {
                
                NSMutableArray * eachModes = [eachMetamodel getModes];
                
                // Search them and only save the non repeating ones
                for (MDMode * eachMode in eachModes) {
                    
                    BOOL modeFound = NO;
                    for (MDMode * existingMode in modes) {
                        if ([existingMode isEqualToMDMode:eachMode]) {
                            modeFound = YES;
                        }
                    }
                    if (!modeFound) {
                        [modes addObject:eachMode];
                    }
                    
                }
                
            }
            registerCorrect = registerCorrect && [sharedData inSessionDataSetModes:modes
                                                                 toUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
            
            // Set items data in data shared
            registerCorrect = registerCorrect && [sharedData setItemsData:items
                                                   withCredentialsUserDic:credentialsUserDic];
            NSLog(@"[INFO][VCMM] -> %tu items found in routine.", items.count);
            
        }
        
        if (!registerCorrect) {
            NSLog(@"[ERROR][VCMM] Register of items incorrect; user credentials granted?.");
        }
        
        // That way, when a logged in user returns to main manu this routine is not repited.
        userDidLogIn = NO;
    }
}

/*!
 @method loadModels
 @discussion This method loads any saved model in device's persistent memory.
 */
- (void)loadModels
{
    // Existing models
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * areModelsData = [userDefaults objectForKey:@"es.uam.miso/data/models/areModels"];
    NSString * areModels;
    if (areModelsData) {
        areModels = [NSKeyedUnarchiver unarchiveObjectWithData:areModelsData];
    }
    if (areModelsData && areModels && [areModels isEqualToString:@"YES"]) {
        // Existing saved data
        // Retrieve the models using the index and save them in shared data
        
        // Get the index...
        NSData * modelsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/models/index"];
        NSMutableArray * modelsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:modelsIndexData];
        // ...and retrieve each model
        NSMutableArray * models = [[NSMutableArray alloc] init];
        for (NSString * modelIdentifier in modelsIndex) {
            NSString * modelKey = [@"es.uam.miso/data/models/models/" stringByAppendingString:modelIdentifier];
            NSData * modelData = [userDefaults objectForKey:modelKey];
            NSMutableDictionary * modelDic = [NSKeyedUnarchiver unarchiveObjectWithData:modelData];
            [models addObject:modelDic];
        }
        
        // Set them as items data in data shared
        [sharedData setModelsData:models withCredentialsUserDic:credentialsUserDic];
        
        NSLog(@"[INFO][VCMM] %tu models found in device.", models.count);
    } else {
        // No saved data
        
        NSLog(@"[INFO][VCMM] No model found in device.");
    }
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
 @method handleButtonSingOut:
 @discussion This method handles the 'sing out' button action and ask Login View to delete user; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonSingOut:(id)sender {
    userDidAskSignOut = YES;
    
    // Save variables in device memory
    // TO DO: Session control to prevent data loss. Alberto J. 2020/02/17.
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/areIdNumbers"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    
    // Save information
    NSData * areIdNumbersData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areIdNumbersData forKey:@"es.uam.miso/variables/areIdNumbers"];
    NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
    NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
    [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    [userDefaults setObject:itemPositionIdNumberData forKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    
    [self performSegueWithIdentifier:@"fromMainToLogin" sender:sender];
}

/*!
 @method handleButtonLogOut:
 @discussion This method handles the 'log out' button action and ask Login View to delete credentials dictionaries; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonLogOut:(id)sender {
    userDidAskLogOut = YES;
    
    // Save variables in device memory
    // TO DO: Session control to prevent data loss. Alberto J. 2020/02/17.
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/areIdNumbers"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    
    // Save information
    NSData * areIdNumbersData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areIdNumbersData forKey:@"es.uam.miso/variables/areIdNumbers"];
    NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
    NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
    [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    [userDefaults setObject:itemPositionIdNumberData forKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    
    [self performSegueWithIdentifier:@"fromMainToLogin" sender:sender];
}

/*!
 @method handleButtonAdd:
 @discussion This method handles the 'add' button action and ask the add view to show; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonAdd:(id)sender
{
    [self performSegueWithIdentifier:@"fromMainToAdd" sender:sender];
}

/*!
 @method handleButtonCalibrate:
 @discussion This method handles the 'calibrate' button action and ask the Location Manager to do so.
 */
- (IBAction)handleButonCalibrate:(id)sender
{
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TO DO: Create a location manager for this. Alberto J. 2020/01/20.
        // Get the item chosen by user; only beacons can be calibrated
        NSMutableDictionary * itemChosenByUser = [sharedData
                                                  fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                  andCredentialsUserDic:credentialsUserDic
                                                  ];
        if (itemChosenByUser) {
            
            NSString * sort = itemChosenByUser[@"sort"];
            if([sort isEqualToString:@"beacon"]) {
                // Ask Location manager to calibrate the beacon
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                // Create a copy of the current position for sending it; concurrence issues prevented
                NSString * uuidToCalibrate = itemChosenByUser[@"uuid"];
                [data setObject:uuidToCalibrate forKey:@"uuid"];
                // And send the notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"calibration"
                                                                    object:nil
                                                                  userInfo:data];
                NSLog(@"[NOTI][VCMM] Notification \"calibration\" posted.");
                [self.calibrateButton setEnabled:NO];
            }
            
        } else {
            return;
        }
        
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
}

/*!
 @method calibrationFinished
 @discussion This method handles the event that notifies that the calibration is done; sets the calibration button enabled.
 */
- (void)calibrationFinished:(NSNotification *) notification {
    [self.calibrateButton setEnabled:YES];
}

/*!
 @method handleButonStart:
 @discussion This method handles the 'start' button action and asks to segue to the user's mode selection.
 */
- (IBAction)handleButonStart:(id)sender
{
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // If user did select a row in the table
        if (chosenMode) {
            
            if ([chosenMode isModeKey:kModeMonitoring]) { // MONITORING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeRhoRhoModelling]) { // RHO_RHO_MODELING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                return;
                // [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeRhoThetaModelling]) { // RHO_THETA_MODELING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeThetaThetaModelling]) { // THETA_THETA_MODELING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeRhoRhoLocating]) { // RHO_RHO_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                // [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
                return;
            }
            if ([chosenMode isModeKey:kModeRhoThetaLocating]) { // RHO_THETA_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                // [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
                return;
            }
            if ([chosenMode isModeKey:kModeThetaThetaLocating]) { // THETA_THETA_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            // TO DO: A view for this. Alberto J. 2020/01/20
            if ([chosenMode isModeKey:kModeGPSSelfLocating]) { // GPS_SELF_LOCATING
                MDMode * currentMode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                                         andCredentialsUserDic:credentialsUserDic];
                if (currentMode) {
                    if ([chosenMode isModeKey:kModeGPSSelfLocating]) {
                        [sharedData inSessionDataSetMode:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopUpdatingLocation"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"stopUpdatingLocation\" posted.");
                        // Let user know that the measure is done
                        [self alertUserWithTitle:@"Geoposition acquiered."
                                         message:[NSString stringWithFormat:@"A geolocated position has been acquired; it will be used as an attribute of the model."]
                                      andHandler:^(UIAlertAction * action) {
                                          // Nothing to do.
                                      }
                         ];
                    } else {
                        [sharedData inSessionDataSetMode:chosenMode
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdatingLocation"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"startUpdatingLocation\" posted.");
                    }
                } else {
                    [sharedData inSessionDataSetMode:chosenMode
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdatingLocation"
                                                                        object:nil];
                    NSLog(@"[NOTI][VCMM] Notification \"startUpdatingLocation\" posted.");
                }
                
            }
            // TO DO: A view for this. Alberto J. 2020/01/20
            if ([chosenMode isModeKey:kModeCompassSelfLocating]) { // COMPASS_SELF_LOCATING
                MDMode * currentMode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                                       andCredentialsUserDic:credentialsUserDic];
                if (currentMode) {
                    if ([chosenMode isModeKey:kModeCompassSelfLocating]) {
                        [sharedData inSessionDataSetMode:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopUpdatingHeading"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"stopUpdatingHeading\" posted.");
                        // Let user know that the measure is done
                        [self alertUserWithTitle:@"Heading measure acquiered."
                                         message:[NSString stringWithFormat:@"A heading measure has been acquired; it will be used as an attribute of the model."]
                                      andHandler:^(UIAlertAction * action) {
                                          // Nothing to do.
                                      }
                         ];
                    } else {
                        [sharedData inSessionDataSetMode:chosenMode
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdatingHeading"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"startUpdatingHeading\" posted.");
                    }
                } else {
                    [sharedData inSessionDataSetMode:chosenMode
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUpdatingHeading"
                                                                        object:nil];
                    NSLog(@"[NOTI][VCMM] Notification \"startUpdatingHeading\" posted.");
                }
                
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
    
    if ([[segue identifier] isEqualToString:@"fromMainToLogin"]) {
        
        // Get destination view
        ViewControllerLogin * viewControllerLogin = [segue destinationViewController];
        // Set the variables and components
        [viewControllerLogin setCredentialsUserDic:credentialsUserDic];
        [viewControllerLogin setUserDic:userDic];
        if (userDidAskSignOut) {
            [viewControllerLogin setUserDidAskSignOut:YES];
        }
        if (userDidAskLogOut) {
            [viewControllerLogin setUserDidAskLogOut:YES];
        } else {
            NSLog(@"[ERROR][VCMM] Asked log in view to show without log out or sign out.");
        }
        
    }
    
    // If add menu is going to be displayed, pass it the beaconsAndPositionsRegistered array
    if ([[segue identifier] isEqualToString:@"fromMainToAdd"]) {
        
        // Get destination view
        ViewControllerAddBeaconMenu * viewControllerAddBeaconMenu = [segue destinationViewController];
        // Set the variables and components
        [viewControllerAddBeaconMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerAddBeaconMenu setUserDic:userDic];
        [viewControllerAddBeaconMenu setSharedData:sharedData];
        [viewControllerAddBeaconMenu setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerAddBeaconMenu setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    
    // If Rho Theta Syetem or Rho Rho Sytem based Locating is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToSelectPositions"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerSelectPositions setItemPositionIdNumber:itemPositionIdNumber];
        
    }
}

#pragma mark - UItableView delegate methods

/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableItems) {
        NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
        NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
        return itemsCount + modelCount;
    }
    if (tableView == self.tableModes) {
        return kModesCount;
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
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
                NSLog(@"[VCMM][ERROR] No items found for showing.");
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"No items found.";
                    cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
                }
            }
        }
    }
    if (tableView == self.tableModes) {
        MDMode * mode = [[MDMode alloc] initWithModeKey:(int)indexPath.row];
        cell.textLabel.text = [mode description];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
    }
    return cell;
}

/*!
 @method tableView:didSelectRowAtIndexPath:
 @discussion Handles the upload of tables; handles the 'select a cell' action.
 */
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
        chosenMode = [[MDMode alloc] initWithModeKey:(int)indexPath.row];
    }
}

@end
