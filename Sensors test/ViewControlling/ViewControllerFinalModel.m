//
//  ViewControllerFinalModel.m
//  Sensors test
//
//  Created by Alberto J. on 8/10/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerFinalModel.h"

@implementation ViewControllerFinalModel

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        NSLog(@"[INFO][VCFM] User credentials have been validated.");
    } else {
        [self alertUserWithTitle:@"User not allowed."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCFM] Shared data could not be accessed after view loading.");
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
 @method handleButtonSubmit:
 @discussion This method handles the Submit button action and shows the final model; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonSubmit:(id)sender
{
    // TO DO: Model must be a COPY of the items and the references must be removed. Alberto J. 2019/10/18
    
    // Check if name exists
    NSString * name = [self.nameText text];
    if ([sharedData fromMetamodelDataIsTypeWithName:name andWithCredentialsUserDic:credentialsUserDic]) {
        
        if (userDidTrySubmit) { // If it es the second try
            self.statusLabel.text = [NSString stringWithFormat:@"The components of new model have been merged in %@@miso.uam.es", name];
        } else { // If it es the first try
            self.statusLabel.text = [NSString stringWithFormat:@"A model with that name already exists; models will be merged. Press 'submit' again or change the name"];
            userDidTrySubmit = true;
            return;
        }
    } else {
        // the user might chage the name because a collision
        userDidTrySubmit = false;
    }
    
    // Display configurations
    [[self.modelText layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.modelText layer] setBorderWidth:.4];
    [[self.modelText layer] setCornerRadius:8.0f];
    
    // Retrieve the model components
    NSMutableArray * components = [[NSMutableArray alloc] init];
    NSMutableArray * items = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                          andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * itemDic in items) {
        [components addObject:itemDic];
    }
    NSMutableArray * locations = [sharedData fromItemDataGetLocatedItemsByUser:userDic
                                                         andCredentialsUserDic:credentialsUserDic];
    for (NSMutableDictionary * locatedDic in locations) {
        [components addObject:locatedDic];
    }
    
    // Make a new name for saving
    NSString * savingName = [NSString stringWithFormat:@"%@@miso.uam.es", name];
    
    // Save the model
    [sharedData inModelDataAddModelWithName:savingName
                                 components:components
                  andWithCredentialsUserDic:credentialsUserDic];
    
    // Show the model
    NSMutableArray * model = [sharedData fromModelDataGetModelDicWithName:savingName
                                                   withCredentialsUserDic:credentialsUserDic];
    NSString * modelString = [NSString stringWithFormat:@"%@", [model objectAtIndex:0]];
    self.modelText.text = modelString;
}

/*!
 @method handleButtonFinish:
 @discussion This method handles the Finish button action and saves the model before segue to main manu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButonFinish:(id)sender
{
    [self performSegueWithIdentifier:@"fromFinalModelToMain" sender:sender];
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
    NSLog(@"[INFO][VCFM] Asked segue %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"fromFinalModelToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables and components
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        [viewControllerMainMenu setLocationManager:location];
        
        [viewControllerMainMenu setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerMainMenu setItemPositionIdNumber:itemPositionIdNumber];
        
    }
}

@end

