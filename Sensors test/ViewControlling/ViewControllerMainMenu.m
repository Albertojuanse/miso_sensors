//
//  ViewControllerMainMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMainMenu.h"

@implementation ViewControllerMainMenu

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
//     "mode": (MDMode *)mode1;
//     "delegate": (id<VCModeDelegate>)delegate1
//     "routine": (BOOL)routine;
//     "routineModel": (NSMutableDictionary *)routineModelDic;
//     "state": (NSString *)state1;
//     "itemChosenByUser": (NSMutableDictionary *)item1;     //  itemDic
//     "itemsChosenByUser": (NSMutableArray *)items1;
//     "typeChosenByUser": (MDType *)type1;
//     "referencesByUser": (NSMutableArray *)references1
//     "currentModelNorth": (NSNumber *)currentModelNorth1
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
//  [{ "sort": @"beacon" | @"position" | @"empty_position";  //  itemDic
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
//     "measure": (id)measure1
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
    [self loadLayout];
    
    // Components
    [self loadComponents];
    
    // Load any saved component or model in device's persistent memory and routine.
    [self loadRoutine];
    [self loadModels];
    
    // Load variables
    // The mode chosen by user each time must be nil in each load
    chosenMode = nil;
    
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
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCMM] Shared data could not be accessed after view loading.");
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Load the model's north or ask the user to measure it; this is needed if any theta theta calculus must be performed, and 'northNeeded' is onlyset true in the
    if (northNeeded) {
        NSLog(@"[INFO][VCMM] The model's north must be measured by user");
        
        NSNumber * north = [sharedData fromSessionDataGetCurrentModelNorthWithUserDic:userDic
                                                               withCredentialsUserDic:credentialsUserDic];
        
        if (!north) {
            
            // Alloc and init the location manager
            if (!locationHeading) {
                locationHeading = [[LMDelegateHeading alloc] initWithSharedData:sharedData
                                                                        userDic:credentialsUserDic
                                                          andCredentialsUserDic:credentialsUserDic];
            }
            
            [sharedData inSessionDataSetMode:chosenMode
                           toUserWithUserDic:userDic
                       andCredentialsUserDic:credentialsUserDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdHeading/start"
                                                                object:nil];
            NSLog(@"[NOTI][VCMM] Notification \"lmdHeading/start\" posted.");
            
            // Ask the user to take the measure
            [self alertUserWithTitle:@"Model's north not found."
                             message:[NSString stringWithFormat:@"Please, aim the device to the direction that will be the model's north."]
                          andHandler:^(UIAlertAction * action) {
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdHeading/stop"
                                                                                  object:nil];
                              NSLog(@"[NOTI][VCMM] Notification \"lmdHeading/stop\" posted.");
                              // Dealloc location manager
                              locationHeading = nil;
                          }
             ];
            
            
        } else {
            NSLog(@"[ERROR][VCMM] North exists in shared data when is needed to measure it.");
        }
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
 @method loadLayout
 @discussion This method loads the layout configurations.
 */
- (void)loadLayout
{
    // Toolbar layout
    UIColor * normalThemeColor = [VCDrawings getNormalThemeColor];
    
    self.toolbar.backgroundColor = normalThemeColor;
    [self.goButton setTitleColor:normalThemeColor
                        forState:UIControlStateNormal];
    [self.startButton setTitleColor:normalThemeColor
                           forState:UIControlStateNormal];
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
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
@method loadComponents
@discussion This method loads the location and motion components if they don't exist.
*/
- (void)loadComponents
{
    // Initialize them only if they don't be so.
    
    // Init the shared data collection with the credentials of the device user.
    if (!sharedData) {
        sharedData = [[SharedData alloc] initWithCredentialsUserDic:credentialsUserDic];
        userDidLogIn = YES; // Used for some routines to be executed just one time
    }
    
    // Create a session for the current user; if it joins another one later, this will be remplaced or deleted.
    // Check if a session with this user is created before
    if ([sharedData fromSessionDataGetSessionWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic]) {
    } else {
        NSMutableDictionary * sessionDic = [[NSMutableDictionary alloc] init];
        sessionDic [@"user"] = userDic;
        [[sharedData getSessionDataWithCredentialsUserDic:credentialsUserDic] addObject:sessionDic];
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
            
            // The model's north is needed if any theta theta calculus must be performed
            northNeeded = NO;
            
            NSMutableArray * types = [routine getTypes];
            NSMutableArray * metamodels = [routine getMetamodels];
            NSMutableArray * items = [routine getItems];
                        
            // Set items in data shared
            for (MDType * eachType in types) {
                registerCorrect = registerCorrect && [sharedData inTypesDataAddType:eachType
                                                             withCredentialsUserDic:credentialsUserDic];
            }
            NSLog(@"[INFO][VCMM] -> %tu ontological types found in routine.", types.count);
            
            // Metamodels
            for (MDMetamodel * eachMetamodel in metamodels) {
                registerCorrect = registerCorrect && [sharedData inMetamodelsDataAddMetamodel:eachMetamodel
                                                                       withCredentialsUserDic:credentialsUserDic];
            }
            NSLog(@"[INFO][VCMM] -> %tu metamodels found in routine.", metamodels.count);
            
            // Modes; from each metamodel, get the modes
            NSMutableArray * modes = [[NSMutableArray alloc] init];
            for  (MDMetamodel * eachMetamodel in metamodels) {
                
                NSMutableArray * eachModes = [eachMetamodel getModes];
                
                // Search them and only save the non repeating ones
                // In metamodels, modes are saved like NSNumbers, since primitives cannot be coded; here an MDMode class is instanciated when needed
                for (NSNumber * eachMode in eachModes) {
                    
                    BOOL modeFound = NO;
                    for (MDMode * existingMode in modes) {
                        if ([existingMode getMode] == [eachMode intValue]) {
                            modeFound = YES;
                        }
                    }
                    if (!modeFound) {
                        MDMode * newMode = [[MDMode alloc] initWithModeKey:[eachMode intValue]];
                        [modes addObject:newMode];
                        // North need checking
                        if ([newMode isModeKey:kModeThetaThetaLocating] ||
                            [newMode isModeKey:kModeThetaThetaLocating]) {
                            northNeeded = YES;
                        }
                    }
                    
                }
                
            }
            registerCorrect = registerCorrect && [sharedData inSessionDataSetModes:modes
                                                                 toUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
            NSLog(@"[INFO][VCMM] -> %tu modes found in routine.", modes.count);
            
            // Set items data in data shared
            registerCorrect = registerCorrect && [sharedData setItemsData:items
                                                   withCredentialsUserDic:credentialsUserDic];
            NSLog(@"[INFO][VCMM] -> %tu items found in routine.", items.count);
            
            // Set routine mode in shared data
            [sharedData inSessionDataSetIsRoutine:@"YES"
                                toUserWithUserDic:userDic
                            andCredentialsUserDic:credentialsUserDic];
            
        } else {
            // Routine not found
            NSLog(@"[INFO][VCMM] Routine not found");
            [sharedData inSessionDataSetIsRoutine:@"NO"
                                toUserWithUserDic:userDic
                            andCredentialsUserDic:credentialsUserDic];
        }
        
        if (!registerCorrect) {
            NSLog(@"[ERROR][VCMM] Register of items incorrect; check user credentials.");
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

#pragma mark - Butons event handle
/*!
 @method handleButtonSingOut:
 @discussion This method handles the 'sing out' button action and ask Login View to delete user; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonSingOut:(id)sender {
    userDidAskSignOut = YES;
    [self performSegueWithIdentifier:@"fromMainToLogin" sender:sender];
}

/*!
 @method handleButtonLogOut:
 @discussion This method handles the 'log out' button action and ask Login View to delete credentials dictionaries; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonLogOut:(id)sender {
    userDidAskLogOut = YES;
    [self performSegueWithIdentifier:@"fromMainToLogin" sender:sender];
}

/*!
 @method handleButonStart:
 @discussion This method handles the 'start' button action and start routine.
 */
- (IBAction)handleButonStart:(id)sender
{
    // Check if in routine
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find the mode that is not finished
            MDMode * foundMode;
            NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
            for (MDMode * mode in modes) {
                if (![mode isFinished]) {
                    NSLog(@"[INFO][CVMM] Evaluating next mode in routine \"%@\".", [mode description]);
                    foundMode = mode;
                    break;
                }
            }
            
            if (foundMode) {
                NSLog(@"[INFO][CVMM] Next mode in routine \"%@\".", [foundMode description]);
                chosenMode = foundMode;
                
                // Once found, segue to the mode
                [self handleButonGo:nil];
                
            } else {
                NSLog(@"[INFO][CVMM] Routine finished.");
                [self alertUserWithTitle:@"Routine finished"
                                 message:@"The defined modelling routine has finished."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                }];
            }
            
        } else {
            NSLog(@"[INFO][VCMM] Not in a routine.");
            return;
        }
        
    } else {
        NSLog(@"[ERROR][VCMM] No data about if in routine found.");
    }
    return;
}

/*!
 @method handleButonGo:
 @discussion This method handles the 'go' button action and asks to segue to the user's mode selection.
 */
- (IBAction)handleButonGo:(id)sender
{
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // If user did select a row in the table
        if (chosenMode) {
            
            // For each mode, set it in shared data and instantiate the proper delegate
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
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateRhoRhoModelling alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeRhoThetaModelling]) { // RHO_THETA_MODELING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateRhoThetaModelling alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeThetaThetaModelling]) { // THETA_THETA_MODELING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateThetaThetaModelling alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            if ([chosenMode isModeKey:kModeRhoRhoLocating]) { // RHO_RHO_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateRhoRhoLocating alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
                return;
            }
            if ([chosenMode isModeKey:kModeRhoThetaLocating]) { // RHO_THETA_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:userDic];
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateRhoThetaLocating alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
                return;
            }
            if ([chosenMode isModeKey:kModeThetaThetaLocating]) { // THETA_THETA_LOCATING
                [sharedData inSessionDataSetMode:chosenMode
                               toUserWithUserDic:userDic
                           andCredentialsUserDic:credentialsUserDic];
                [sharedData inSessionDataSetDelegate:[[VCModeDelegateThetaThetaLocating alloc]
                                                      initWithSharedData:sharedData
                                                      userDic:userDic
                                                      andCredentialsUserDic:credentialsUserDic]
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                [self performSegueWithIdentifier:@"fromMainToSelectPositions" sender:sender];
            }
            // TODO: Move this to final model view. Alberto J. 2020/01/20
            if ([chosenMode isModeKey:kModeGPSSelfLocating]) { // GPS_SELF_LOCATING
                
                // Mode is only set in shared data when GPS is started, to use it as orchestration variable
                MDMode * currentMode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                                         andCredentialsUserDic:credentialsUserDic];
                if (currentMode) {
                    if ([chosenMode isModeKey:kModeGPSSelfLocating]) {
                        [sharedData inSessionDataSetMode:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdGPS/stop"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"lmdGPS/stop\" posted.");
                        // Let user know that the measure is done
                        [self alertUserWithTitle:@"Geoposition acquiered."
                                         message:[NSString stringWithFormat:@"A geolocated position has been acquired; it will be used as an attribute of the model."]
                                      andHandler:^(UIAlertAction * action) {
                                          // Nothing to do.
                                      }
                         ];
                         
                         // Dealloc location manager
                         locationGPS = nil;
                    } else {
                        
                        // Alloc and init the location manager
                        if (!locationGPS) {
                            locationGPS = [[LMDelegateGPS alloc] initWithSharedData:sharedData
                                                                            userDic:credentialsUserDic
                                                              andCredentialsUserDic:credentialsUserDic];
                        }
                        
                        [sharedData inSessionDataSetMode:chosenMode
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdGPS/start"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"lmdGPS/start\" posted.");
                    }
                } else {
                    
                    // Alloc and init the location manager
                    if (!locationGPS) {
                        locationGPS = [[LMDelegateGPS alloc] initWithSharedData:sharedData
                                                                        userDic:credentialsUserDic
                                                          andCredentialsUserDic:credentialsUserDic];
                    }
                    
                    [sharedData inSessionDataSetMode:chosenMode
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdGPS/start"
                                                                        object:nil];
                    NSLog(@"[NOTI][VCMM] Notification \"lmdGPS/start\" posted.");
                }
                
            }
            // TODO: Move this to final model view. Alberto J. 2020/01/20
            if ([chosenMode isModeKey:kModeCompassSelfLocating]) { // COMPASS_SELF_LOCATING
                
                // Mode is only set in shared data when GPS is started, to use it as orchestration variable
                MDMode * currentMode = [sharedData fromSessionDataGetModeFromUserWithUserDic:userDic
                                                                       andCredentialsUserDic:credentialsUserDic];
                if (currentMode) {
                    if ([chosenMode isModeKey:kModeCompassSelfLocating]) {
                        [sharedData inSessionDataSetMode:nil
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdHeading/stop"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"lmdHeading/stop\" posted.");
                        // Let user know that the measure is done
                        [self alertUserWithTitle:@"Heading measure acquiered."
                                         message:[NSString stringWithFormat:@"A heading measure has been acquired; it will be used as an attribute of the model."]
                                      andHandler:^(UIAlertAction * action) {
                                          // Nothing to do.
                                      }
                         ];
                        
                        // Dealloc location manager
                        locationHeading = nil;
                    } else {
                        
                        // Alloc and init the location manager
                        if (!locationHeading) {
                            locationHeading = [[LMDelegateHeading alloc] initWithSharedData:sharedData
                                                                                    userDic:credentialsUserDic
                                                                      andCredentialsUserDic:credentialsUserDic];
                        }
                        
                        [sharedData inSessionDataSetMode:chosenMode
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdHeading/start"
                                                                            object:nil];
                        NSLog(@"[NOTI][VCMM] Notification \"lmdHeading/start\" posted.");
                    }
                } else {
                    
                    // Alloc and init the location manager
                    if (!locationHeading) {
                        locationHeading = [[LMDelegateHeading alloc] initWithSharedData:sharedData
                                                                                userDic:credentialsUserDic
                                                                  andCredentialsUserDic:credentialsUserDic];
                    }
                    
                    [sharedData inSessionDataSetMode:chosenMode
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdHeading/start"
                                                                        object:nil];
                    NSLog(@"[NOTI][VCMM] Notification \"lmdHeading/start\" posted.");
                }
                
            }
            return;
        } else {
            return;
        }
    } else {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
    }
}

/*!
 @method alertUserWithTitle:message:andHandler:
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
    
    // If Rho Theta Syetem or Rho Rho Sytem based Locating is going to be displayed, pass it the beaconsAndPositionsRegistered array.
    if ([[segue identifier] isEqualToString:@"fromMainToSelectPositions"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        
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
        NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                  andCredentialsUserDic:credentialsUserDic];
        return modes.count;
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = [@"Cell" stringByAppendingString:[indexPath description]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableItems) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
        
            NSMutableDictionary * itemDic = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                        inTableItems:tableView];
            
            // The itemDic variable can be null or NO if access is not granted or there are not items stored.
            if (itemDic) {
                cell.textLabel.numberOfLines = 0; // Means any number
                
                // If it is a beacon
                if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                    
                    [cell.imageView setImage:[VCDrawings imageForBeaconInNormalThemeColor]];
                    
                    // Its description depends on if exist its position or its type
                    // Compose the description
                    NSString * beaconDescription = [[NSString alloc] init];
                    beaconDescription = [beaconDescription stringByAppendingString:itemDic[@"identifier"]];;
                    beaconDescription = [beaconDescription stringByAppendingString:@" "];
                    // If its type is set
                    MDType * type = itemDic[@"type"];
                    if (type) {
                        beaconDescription = [beaconDescription stringByAppendingString:[type description]];
                    }
                    beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
                    // Must have a position
                    RDPosition * position = itemDic[@"position"];
                    if (position) {
                        beaconDescription = [beaconDescription stringByAppendingString:[position description]];
                        beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
                    }
                    NSString * itemUUID = [itemDic[@"uuid"] substringFromIndex:24];
                    NSString * itemMajor = itemDic[@"major"];
                    NSString * itemMinor = itemDic[@"minor"];
                    beaconDescription = [beaconDescription stringByAppendingFormat:@"UUID: %@ Major: %@ Minor: %@ ",
                                         itemUUID,
                                         itemMajor,
                                         itemMinor];
                    cell.textLabel.text = beaconDescription;
                    
                }
            
                // If it is a position
                if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                    
                    // Set its icon
                    [cell.imageView setImage:[VCDrawings imageForPositionInNormalThemeColor]];
                    
                    // Compose the description
                    NSString * positionDescription = [[NSString alloc] init];
                    positionDescription = [positionDescription stringByAppendingString:itemDic[@"identifier"]];;
                    positionDescription = [positionDescription stringByAppendingString:@" "];
                    // If its type is set
                    MDType * type = itemDic[@"type"];
                    if (type) {
                        positionDescription = [positionDescription stringByAppendingString:[type description]];
                    }
                    positionDescription = [positionDescription stringByAppendingString:@"\n"];
                    // Must have a position
                    RDPosition * position = itemDic[@"position"];
                    if (position) {
                        positionDescription = [positionDescription stringByAppendingString:[position description]];
                    } else {
                        positionDescription = [positionDescription stringByAppendingString:@"( - , - , - )"];
                        NSLog(@"[ERROR][VCMM] No RDPosition found in item of sort position.");
                    }
                    cell.textLabel.text = positionDescription;
                    
                }
                
                // If it is a model
                if ([@"model" isEqualToString:itemDic[@"sort"]]) {
                    
                    // Set its icon
                    [cell.imageView setImage:[VCDrawings imageForModelInNormalThemeColor]];
                    
                    NSString * modelDescription = itemDic[@"name"];
                    if (!modelDescription) {
                        modelDescription = @"Unknown model";
                        NSLog(@"[ERROR][VCMM] No name found in intem of sort model.");
                    }
                    cell.textLabel.text = modelDescription;
                    
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
        NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                  andCredentialsUserDic:credentialsUserDic];
        
        MDMode * mode = [modes objectAtIndex:indexPath.row];
        cell.textLabel.text = [mode description];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        
        if ([mode isFinished]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
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
        
        NSMutableDictionary * itemChosenByUser = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                             inTableItems:tableView];
        
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
        NSMutableArray * modes = [sharedData fromSessionDataGetModesFromUserWithUserDic:userDic
                                                                  andCredentialsUserDic:credentialsUserDic];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
            return;
        } else {
            chosenMode = [modes objectAtIndex:indexPath.row];
        }
        
    }
}

#pragma mark - UItableView swipe cells methods
/*!
 @method tableView:canEditRowAtIndexPath:
 @discussion This method sets every cell as editable.
 */
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableModes) { // No actions here
        
        return NO;
        
    }
    if (tableView == self.tableItems) {
        
        NSMutableDictionary * itemDic = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                    inTableItems:tableView];
        
        // Get its sort.
        // Can be null if credentials are not allowed.
        if (itemDic) {
            
            // If it is a beacon
            if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                return YES;
            } else {
                return NO;
            }
            
        } else {
            return NO;
        }
        
    }
    return NO;
}

/*!
@method tableView:canEditRowAtIndexPath:
@discussion This method defines the actions avalible when user swipe a cell.
*/
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableModes) { // No actions here
        
        return nil;
        
    }
    if (tableView == self.tableItems) {
        
        NSMutableDictionary * itemDic = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                    inTableItems:tableView];
        
        // Get its sort.
        // Can be null if credentials are not allowed.
        if (itemDic) {
            
            // If it is a beacon
            if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                
                // Definition of the handler to be set in the action.
                void (^handler)(UIContextualAction*, UIView*, void(^)(BOOL)) = ^(UIContextualAction *action, UIView *source, void(^completionHandler)(BOOL)) {
                    
                    
                    
                    // Can be null if credentials are not allowed.
                    NSString * itemUUID;
                    if (itemDic) {
                        
                        // If it is a beacon
                        if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                            itemUUID = itemDic[@"uuid"];
                            NSLog(@"[INFO][VCMM] User asked to edit settings of beacon %@.", itemUUID);
                            
                            // Present the view as a pop up
                            //[self performSegueWithIdentifier:@"fromTHETA_THETA_LOCATINGToEditComponent" sender:nil];
                            ViewControllerItemSettings * viewControllerItemSettings = [[[NSBundle mainBundle]
                                                                                        loadNibNamed:@"ViewItemSettings"
                                                                                        owner:self
                                                                                        options:nil]
                                                                                       objectAtIndex:0];
                            [viewControllerItemSettings setModalPresentationStyle:UIModalPresentationPopover];
                            // Set the variables
                            [viewControllerItemSettings setCredentialsUserDic:credentialsUserDic];
                            [viewControllerItemSettings setUserDic:userDic];
                            [viewControllerItemSettings setSharedData:sharedData];
                            [viewControllerItemSettings setItemChosenByUser:itemDic];
                            // Configure popover layout
                            UIPopoverPresentationController * popoverItemSettings =  viewControllerItemSettings.popoverPresentationController;
                            [popoverItemSettings setDelegate:viewControllerItemSettings];
                            [popoverItemSettings setSourceView:self.view];
                            [popoverItemSettings setSourceRect:CGRectMake(CGRectGetMidX(self.view.bounds),
                                                                          CGRectGetMidY(self.view.bounds),
                                                                          0,
                                                                          0)];
                            [popoverItemSettings setPermittedArrowDirections:0];
                            // Show the view
                            [self presentViewController:viewControllerItemSettings animated:YES completion:nil];                            
                            
                            completionHandler(YES);
                        } else {
                            NSLog(@"[ERROR][VCMM] User asked to edit settings of an item of sort %@.", itemDic[@"sort"]);
                            completionHandler(NO);
                        }
                        
                    }
                };
                
                // Init the action with the handler.
                UIContextualAction * calibrateAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                               title:@"⚙️"
                                                                                             handler:handler];
                [calibrateAction setBackgroundColor:[UIColor whiteColor]];
                UISwipeActionsConfiguration * swipeActionsConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[calibrateAction]];
                [swipeActionsConfiguration setPerformsFirstActionWithFullSwipe:NO];
                return swipeActionsConfiguration;
                
            } else {
                return nil;
            }
            
        } else {
            return nil;
        }
        
    }
    return nil;
}

#pragma mark - Other methods
/*!
@method fromSharedDataGetItemWithIndexPath::inTableItems;
@discussion This method returns the item asked or selected by user in the item's table view.
*/
- (NSMutableDictionary *)fromSharedDataGetItemWithIndexPath:(NSIndexPath *)indexPath
                                               inTableItems:(UITableView *)tableView
{
    // Select the source of items; both items are models shown
    NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
    NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
    
    // Load the item depending of the source
    NSMutableDictionary * itemDic = nil;
    if (indexPath.row < itemsCount) {
        itemDic = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                   objectAtIndex:indexPath.row
                   ];
    }
    if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
        itemDic = [
                   [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                   objectAtIndex:indexPath.row - itemsCount
                   ];
    }
    if (indexPath.row >= itemsCount + modelCount) {
        // Empty cell
    }
    
    return itemDic;
}

@end
