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
    
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:@"RHO_RHO_MODELING"
                       toUserWithUserDic:credentialsUserDic
                   andCredentialsUserDic:credentialsUserDic];        
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithMode:@"RHO_RHO_MODELING"];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
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

#pragma mark - Instance methods

/*!
 @method setCredentialsUserDic
 @discussion This method sets the credentials of the user for accessing data shared.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)givenCredentialsUserDic
{
    credentialsUserDic = givenCredentialsUserDic;
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
 @method setRegionBeaconIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionBeaconIdNumber:(NSNumber *)givenRegionBeaconIdNumber
{
    regionBeaconIdNumber = givenRegionBeaconIdNumber;
}

/*!
 @method setRegionPositionIdNumber:
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setRegionPositionIdNumber:(NSNumber *)givenRegionPositionIdNumber
{
    regionPositionIdNumber = givenRegionPositionIdNumber;
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
    
    // TO DO: Acess data shared from canvas. Alberto J. 2019/09/10.
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // // Save beacons
        // NSDictionary *data = notification.userInfo;
        // measuresDic = [data valueForKey:@"measuresDic"];
        // locatedDic = [data valueForKey:@"locatedDic"];
        // self.canvas.measuresDic = measuresDic;
        // self.canvas.locatedDic = locatedDic;
        
    }
    [self.canvas setNeedsDisplay];
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonTravel:
 @discussion This method handles the action in which the Travel button is pressed; it must disable both control buttons and ask motion manager to start traveling.
 */
- (IBAction)handleButtonTravel:(id)sender
{
    // First, validate the acess to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Travel won't be started."
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:credentialsUserDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can travel or measuring; if 'Travel' is tapped, ask start traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:NO];
        [sharedData inSessionDataSetTravelingUserWithUserDic:credentialsUserDic
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
        [sharedData inSessionDataSetTravelingUserWithUserDic:credentialsUserDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"TRAVELING; please, tap 'Travel' again for finishing travel."];
        return;
    }
    if ([state isEqualToString:@"TRAVELING"]) { // If traveling, user can finish the travel; if 'Travel' is tapped, ask stop traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:credentialsUserDic
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
    // First, validate the acess to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
    } else {
        [self alertUserWithTitle:@"Travel won't be started."
                         message:[NSString stringWithFormat:@"Database could not be acessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCRRM] Shared data could not be acessed while starting travel.");
        return;
    }
    
    // In every state the button performs different behaviours
    NSString * state = [sharedData fromSessionDataGetStateFromUserWithUserDic:credentialsUserDic
                                                        andCredentialsUserDic:credentialsUserDic];
    
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can travel or measuring; if 'Measuring' is tapped, ask start measuring.
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetMeasuringUserWithUserDic:credentialsUserDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"MEASURING; please, tap 'Measure' again for finishing measure."];
        
        // And send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"startMeasuring\" posted.");
        return;
        
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:credentialsUserDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [self.labelStatus setText:@"IDLE; please, tap 'Measure' or 'Travel' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopMeasuring\" posted.");
        return;
        
    }
    if ([state isEqualToString:@"TRAVELING"]) { // If traveling, user can finish the travel; if 'Measuring' is tapped while measure an error ocurred and nothing must happen.
        NSLog(@"[ERROR][VCRRM] Measuring button were tapped while in TRAVELING state.");
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetMeasuringUserWithUserDic:credentialsUserDic
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
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTraveling"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopTraveling\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reset"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"reset\" posted.");
        return;        
    }
}

@end
