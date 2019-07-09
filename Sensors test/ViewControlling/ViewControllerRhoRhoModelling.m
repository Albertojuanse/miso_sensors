//
//  ViewControllerRhoRhoModelling.m
//  Sensors test
//
//  Created by Alberto J. on 25/4/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerRhoRhoModelling.h"

@implementation ViewControllerRhoRhoModelling

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ask canvas to initialize
    [self.canvas prepareCanvas];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCanvas:)
                                                 name:@"refreshCanvas"
                                               object:nil];
    
    // Visualization
    [self.buttonTravel setEnabled:YES];
    [self.buttonMeasure setEnabled:YES];
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
        
        // Inspect dictionary for UUID names.
        // Declare the inner dictionaries.
        NSMutableDictionary * uuidDic;
        NSMutableDictionary * uuidDicDic;
        NSMutableDictionary * positionDic;
        
        // For every position where measures were taken
        NSArray *positionKeys = [measuresDic allKeys];
        for (id positionKey in positionKeys) {
            // ...get the dictionary for this position.
            positionDic = [measuresDic objectForKey:positionKey];
            
            // Get the the dictionary with the UUID's dictionaries...
            uuidDicDic = positionDic[@"positionRangeMeasures"];
            // ...and for every UUID...
            NSArray *uuidKeys = [uuidDicDic allKeys];
            BOOL found = NO;
            for (id uuidKey in uuidKeys) {
                // ...get the dictionary...
                uuidDic = [uuidDicDic objectForKey:uuidKey];
                // ...and get the uuid.
                NSString * uuidNew = [NSString stringWithString:uuidDic[@"uuid"]];
                
                // TO DO: ¿Needed? Alberto J. 2019/07/08.
                
                }
            }
        }

    [self.canvas setNeedsDisplay];
}

#pragma marks - Butons event handle

/*!
 @method handleButtonTravel:
 @discussion This method handles the action in which the Travel button is pressed; it must notify the orchestrator that the user wants to move the device.
 */
- (IBAction)handleButtonTravel:(id)sender {
    // Empty data array for use the 'postNotificationName:object:userInfo:' method.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleButtonTravel"
                                                        object:nil];
}

/*!
 @method handleButtonMeasure:
 @discussion This method handles the action in which the Measure button is pressed; it must notify the orchestrator that the user wants to make a measure.
 */
- (IBAction)handleButtonMeasure:(id)sender {
    // Empty data array for use the 'postNotificationName:object:userInfo:' method.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleButtonMeasure"
                                                        object:nil];
}

/*!
 @method handleBackButton:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleBackButton:(id)sender {
    [self performSegueWithIdentifier:@"fromRHO_RHO_MODELLINGToMain" sender:sender];
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCRRM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromRHO_RHO_MODELLINGToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu *viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setBeaconsRegistered:beaconsRegistered];
        
    }
}

@end
