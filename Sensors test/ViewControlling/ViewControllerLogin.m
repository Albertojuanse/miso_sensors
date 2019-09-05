//
//  ViewControllerLogin.m
//  Sensors test
//
//  Created by Alberto J. on 5/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerLogin.h"

@implementation ViewControllerLogin

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    
    // TO DO: Check for stored user data. Alberto J. 2019/09/05.
    // Alert the user that the next log in will be the administration one
    UIAlertController * alertUsersNotFound = [UIAlertController
                                              alertControllerWithTitle:@"No user found"
                                              message:@"No user credentials were found. Please, sign in as a new user."
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.loginButton setEnabled:NO];
                               }];
    
    [alertUsersNotFound addAction:okButton];
    [self presentViewController:alertUsersNotFound animated:YES completion:nil];
    
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
 @discussion This method sets the NSMutableArray variable 'beaconsAndPositionsRegistered'.
 */
- (void) setCredentialsUserDic:(NSMutableDictionary *)newCredentialsUserDic
{
    credentialsUserDic = newCredentialsUserDic;
}

#pragma mark - Button events handlers

/*!
 @method handleButtonLogin:
 @discussion This method handles the 'Log in' button action and creates it a session and credentials dictionaries if its access is granted.
 */
- (IBAction)handleButtonLogin:(id)sender
{
    
    return;
}

/*!
 @method handleButtonSignin:
 @discussion This method handles the 'Sign in' button action, registers the user as a new one and creates it a session and credentials dictionaries if its access is granted.
 */
- (IBAction)handleButtonSignin:(id)sender
{
    
    return;
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)validateCredentialsUserDic:(NSMutableDictionary*)userDic
{
    // TO DO: Validation. Alberto J. 2019/09/05.
    return YES;
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies if the name and password of the user already exist or are not valid.
 */
- (BOOL)validateNewCredentialsUserDic:(NSMutableDictionary*)userDic
{
    // TO DO: Validation. Alberto J. 2019/09/05.
    return YES;
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCAB] Asked segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"loginFromLoginToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
    }
}

@end
