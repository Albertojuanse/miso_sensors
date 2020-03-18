//
//  ViewControllerRhoRhoModeling.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerRhoRhoModeling.h"

@implementation ViewControllerRhoRhoModeling

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
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ];
    
    [self.buttonMeasure setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.buttonMeasure setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.buttonTravel setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.buttonTravel setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    
    // Register the current mode
    mode = [[MDMode alloc] initWithModeKey:kModeRhoRhoModelling];
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:mode
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TODO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Initial state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Variables    
    // Load metamodels for this mode
    modeMetamodels = [[NSMutableArray alloc] init];
    modeTypes = [[NSMutableArray alloc] init];
    [self loadModeMetamodels];
    [self loadModeTypes];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
    // Visualization
    [self.buttonTravel setEnabled:YES];
    [self.buttonMeasure setEnabled:YES];
    [self.labelStatus setText:@"IDLE; please, tap 'Measure' ot 'Travel' for starting. Tap back for finishing."];
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
@method loadModeMetamodels
@discussion This method loads the metamodels for this mode.
*/
- (void)loadModeMetamodels
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Get all metamodels
            NSMutableArray * metamodels = [sharedData fromMetamodelsDataGetMetamodelsWithCredentialsUserDic:credentialsUserDic];
            
            // Find the metamodels used in this mode
            for (MDMetamodel * eachMetamodel in metamodels) {
                
                NSMutableArray * eachMetamodelModes = [eachMetamodel getModes];
                
                // Modes are saved as NSNumbers with each key
                for (NSNumber * eachModeKey in eachMetamodelModes){
                    
                    MDMode * eachMode = [[MDMode alloc] initWithModeKey:[eachModeKey intValue]];
                    
                    if ([eachMode isEqualToMDMode:mode]) {
                        [modeMetamodels addObject:eachMetamodel];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO][VCTTL] Loaded %tu metamodels for this mode.", modeMetamodels.count);
}

/*!
@method loadModeTypes
@discussion This method loads the types for this mode from the metamodels.
*/
- (void)loadModeTypes
{
    NSString * isRoutine = [sharedData fromSessionDataIsRoutineFromUserWithUserDic:userDic
                                                             andCredentialsUserDic:credentialsUserDic];
    if (isRoutine) {
        if ([isRoutine isEqualToString:@"YES"]) {
            
            // Find in the metamodels the types used
            for (MDMetamodel * eachMetamodel in modeMetamodels) {
                
                NSMutableArray * eachMetamodelTypes = [eachMetamodel getTypes];
                
                // Get the types of the metamodel and check if they are already got.
                for (MDType * eachMetamodelType in eachMetamodelTypes){
                    
                    BOOL typeFound = NO;
                    for (MDType * eachType in modeTypes){
                        if ([eachType isEqualToMDType:eachMetamodelType]) {
                            typeFound = YES;
                        }
                    }
                    if (!typeFound) {
                        [modeTypes addObject:eachMetamodelType];
                    }
                    
                }
                
            }
            
        }
    } else {
        return;
    }
    NSLog(@"[INFO][VCTTL] Loaded %tu ontologycal types for this mode.", modeTypes.count);
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

#pragma mark - Buttons event handlers

/*!
 @method handleButtonTravel:
 @discussion This method handles the action in which the Travel button is pressed; it must disable both control buttons and ask motion manager to start traveling.
 */
- (IBAction)handleButtonTravel:(id)sender
{
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Travel won't be started."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRM] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can travel or measuring; if 'Travel' is tapped, ask start traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:NO];
        [sharedData inSessionDataSetTravelingUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"TRAVELING; please, tap 'Travel' again for finishing travel."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startTraveling"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"startTraveling\" posted.");
        return;
        
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Travel' is tapped while measure an error ocurred and nothing must happen.
        NSLog(@"[ERROR][VCRRM] Measuring button were tapped while in TRAVELING state.");
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:NO];
        [sharedData inSessionDataSetTravelingUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"TRAVELING; please, tap 'Travel' again for finishing travel."];
        return;
    }
    if ([state isEqualToString:@"TRAVELING"]) { // If traveling, user can finish the travel; if 'Travel' is tapped, ask stop traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, tap 'Measure' ot 'Travel' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTraveling"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopTraveling\" posted.");
        return;
    }
}

/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must disable 'Travel' control buttons and ask location manager delegate to start measuring.
 */
- (IBAction)handleButtonMeasure:(id)sender
{
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Travel won't be started."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRM] Shared data could not be accessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can travel or measuring; if 'Measuring' is tapped, ask start measuring.
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"MEASURING; please, tap 'Measure' again for finishing measure."];
        
        // And send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"startLocationMeasuring\" posted.");
        return;
        
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, tap 'Measure' or 'Travel' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopLocationMeasuring\" posted.");
        return;
        
    }
    if ([state isEqualToString:@"TRAVELING"]) { // If traveling, user can finish the travel; if 'Measuring' is tapped while measure an error ocurred and nothing must happen.
        NSLog(@"[ERROR][VCRRM] Measuring button were tapped while in TRAVELING state.");
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"MEASURING; please, tap 'Measure' again for finishing measure."];
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender
{
    [self performSegueWithIdentifier:@"fromRHO_RHO_MODELINGToMain" sender:sender];
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
    NSLog(@"[INFO][VCRRM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromRHO_RHO_MODELINGToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopLocationMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTraveling"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopTraveling\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLocationAndMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"resetLocationAndMeasures\" posted.");
        return;        
    }
}

@end
