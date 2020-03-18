//
//  ViewControllerEditComponent.m
//  Sensors test
//
//  Created by MISO on 17/03/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerEditComponent.h"

@implementation ViewControllerEditComponent

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                         andCredentialsUserDic:credentialsUserDic];
    NSLog(@"[HOLA][VCEC] The user is editing %@", itemChosenByUser[@"uuid"]);
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
 @method handleButtonBack:
 @discussion This method handles the 'back' button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
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
    NSLog(@"[INFO][VCSP] Asked segue %@", [segue identifier]);
    
    // This view can segue with different views depending on the mode chosen by the user in the main menu
    
    if ([[segue identifier] isEqualToString:@"fromEditComponentToRHO_RHO_LOCATING"]) {
        
        // Get destination view
        ViewControllerRhoRhoLocating * viewControllerRhoRhoLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoRhoLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoRhoLocating setUserDic:userDic];
        [viewControllerRhoRhoLocating setSharedData:sharedData];
        [viewControllerRhoRhoLocating setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerRhoRhoLocating setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"fromEditComponentToTHETA_THETA_LOCATING"]) {
        
        // Get destination view
        ViewControllerThetaThetaLocating * viewControllerThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        [viewControllerThetaThetaLocating setCredentialsUserDic:credentialsUserDic];
        [viewControllerThetaThetaLocating setUserDic:userDic];
        [viewControllerThetaThetaLocating setSharedData:sharedData];
        [viewControllerThetaThetaLocating setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerThetaThetaLocating setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"fromEditComponentToRHO_THETA_MODELING"]) {
        
        // Get destination view
        ViewControllerRhoThetaModeling * viewControllerRhoThetaModeling = [segue destinationViewController];
        // Set the variables
        [viewControllerRhoThetaModeling setCredentialsUserDic:credentialsUserDic];
        [viewControllerRhoThetaModeling setUserDic:userDic];
        [viewControllerRhoThetaModeling setSharedData:sharedData];
        [viewControllerRhoThetaModeling setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerRhoThetaModeling setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    return;
}

#pragma mark - UIPopoverPresentationControllerDelegate mwthods
/*!
@method adaptivePresentationStyleForPresentationController:
@discussion This method is called by the UIPopoverPresentationControllerDelegate protocol.
*/
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

@end
