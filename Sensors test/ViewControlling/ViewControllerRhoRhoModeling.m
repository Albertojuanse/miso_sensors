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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Variables
    idle = YES;
    measuring = NO;
    traveling = NO;
    
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
 @method setTypesRegistered:
 @discussion This method sets the NSMutableArray variable 'typesRegistered'.
 */
- (void) setTypesRegistered:(NSMutableArray *)newTypesRegistered {
    typesRegistered = newTypesRegistered;
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
    
    if ([[notification name] isEqualToString:@"refreshCanvas"]){
        NSLog(@"[NOTI][VC] Notification \"refreshCanvas\" recived");
        
        // Save beacons
        NSDictionary *data = notification.userInfo;
        measuresDic = [data valueForKey:@"measuresDic"];
        locatedDic = [data valueForKey:@"locatedDic"];
        self.canvas.measuresDic = measuresDic;
        self.canvas.locatedDic = locatedDic;
        
    }
    [self.canvas setNeedsDisplay];
}

#pragma mark - Buttons event handles

/*!
 @method handleButtonTravel:
 @discussion This method handles the action in which the Travel button is pressed; it must disable both control buttons and ask motion manager to start traveling.
 */
- (IBAction)handleButtonTravel:(id)sender {
    
    // In every state the button performs different behaviours
    if (idle) { // If idle, user can travel or measuring; if 'Travel' is tapped, ask start traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:NO];
        idle = NO;
        measuring = NO;
        traveling = YES;
        [self.labelStatus setText:@"TRAVELING; please, tap 'Travel' again for finishing travel."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startTraveling"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"startTraveling\" posted.");
        return;
        
    }
    if (measuring) { // If measuring, user can travel or measuring; if 'Travel' is tapped while measure an error ocurred and nothing must happen.
        NSLog(@"[ERROR][VCRRM] Measuring button were tapped while in TRAVELING state.");
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:NO];
        idle = NO;
        measuring = NO;
        traveling = YES;
        [self.labelStatus setText:@"TRAVELING; please, tap 'Travel' again for finishing travel."];
        return;
    }
    if (traveling) { // If traveling, user can finish the travel; if 'Travel' is tapped, ask stop traveling.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        idle = YES;
        measuring = NO;
        traveling = NO;
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
- (IBAction)handleButtonMeasure:(id)sender {
    
    // In every state the button performs different behaviours
    if (idle) { // If idle, user can travel or measuring; if 'Measuring' is tapped, ask start measuring.
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        idle = NO;
        measuring = YES;
        traveling = NO;
        [self.labelStatus setText:@"MEASURING; please, tap 'Measure' again for finishing measure."];
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        // Create a copy of beacons for sending it; concurrence issues prevented
        NSMutableArray * beaconsAndPositionsRegisteredToSend = [[NSMutableArray alloc] init];
        for (NSMutableDictionary * regionDic in beaconsAndPositionsRegistered) {
            [beaconsAndPositionsRegisteredToSend addObject:regionDic];
        }
        [data setObject:beaconsAndPositionsRegisteredToSend forKey:@"beaconsAndPositionsRegistered"];
        [data setObject:@"RHO_RHO_MODELING" forKey:@"mode"];
        // And send the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startMeasuring"
                                                            object:nil
                                                          userInfo:data];
        NSLog(@"[NOTI][VCRRM] Notification \"startMeasuring\" posted.");
        return;
        
    }
    if (measuring) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [self.buttonTravel setEnabled:YES];
        [self.buttonMeasure setEnabled:YES];
        idle = YES;
        measuring = NO;
        traveling = NO;
        [self.labelStatus setText:@"IDLE; please, tap 'Measure' or 'Travel' for starting. Tap back for finishing."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCRRM] Notification \"stopMeasuring\" posted.");
        return;
        
    }
    if (traveling) { // If traveling, user can finish the travel; if 'Measuring' is tapped while measure an error ocurred and nothing must happen.
        NSLog(@"[ERROR][VCRRM] Measuring button were tapped while in TRAVELING state.");
        [self.buttonTravel setEnabled:NO];
        [self.buttonMeasure setEnabled:YES];
        idle = NO;
        measuring = YES;
        traveling = NO;
        [self.labelStatus setText:@"MEASURING; please, tap 'Measure' again for finishing measure."];
        return;
    }
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender {
    [self performSegueWithIdentifier:@"fromRHO_RHO_MODELINGToMain" sender:sender];
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
        [viewControllerMainMenu setBeaconsAndPositionsRegistered:beaconsAndPositionsRegistered];
        [viewControllerMainMenu setTypesRegistered:typesRegistered];
        
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
