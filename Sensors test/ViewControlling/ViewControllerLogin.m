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
    
    credentialsUserDicArray = [[NSMutableArray alloc] init];
    
}

/*!
 @method viewDidAppear:
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated {
    // TO DO: Check for stored user data. Alberto J. 2019/09/05.
    
    // Alert the user that must create an user if no other is found
    if (credentialsUserDicArray.count == 0){
        UIAlertController * alertUsersNotFound = [UIAlertController
                                                  alertControllerWithTitle:@"No user found"
                                                  message:@"No user credentials were found. Please, sign in as a new user."
                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self.buttonLogin setEnabled:NO];
                                    }];
        
        [alertUsersNotFound addAction:okButton];
        [self presentViewController:alertUsersNotFound animated:YES completion:nil];
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

#pragma mark - Button events handlers

/*!
 @method handleButtonLogin:
 @discussion This method handles the 'Log in' button action and creates it a session and credentials dictionaries if its access is granted.
 */
- (IBAction)handleButtonLogin:(id)sender
{
    // Validate the user entries
    NSString * userRegex = @"^[a-zA-Z0-9_-ñç]+$";
    NSPredicate * userTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", userRegex];
    if ([userTest evaluateWithObject:[self.userText text]]){
        //Matches
    } else {
        self.labelStatus.text = @"Error. User not valid. Please, only accepted a-z, A-Z, 0-9, \"_\" and \"-\".";
        return;
    }
    
    NSString * passRegex = @"^[a-zA-Z0-9_-ñç]{4,}$";
    NSPredicate * passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", passRegex];
    if ([passTest evaluateWithObject:[self.passText text]]){
        //Matches
    } else {
        self.labelStatus.text = @"Error. Password not valid; minimum length 8 characters: a-z, A-Z, 0-9, \"_\" and \"-\".";
        return;
    }
    
    // Wrap the user name and password in the user's credetials dictionary
    //  { "name": (NSString *)name1;                  // userDic
    //    "pass": (NSString *)pass1;
    //    "role": (NSString *)role1;
    //  }
    if(!credentialsUserDic) {
        credentialsUserDic = [[NSMutableDictionary alloc] init];
    }
    credentialsUserDic[@"name"] = [self.userText text];
    credentialsUserDic[@"pass"] = [self.passText text];
    
    // Validate if the user have access granted.
    if ([self validateCredentialsUserDic:credentialsUserDic]) {
        [self performSegueWithIdentifier:@"loginFromLoginToMain" sender:sender];
    } else {
        self.labelStatus.text = @"Error. Invalid user name or password.";
        return;
    }
    
    return;
}

/*!
 @method handleButtonSignin:
 @discussion This method handles the 'Sign in' button action, registers the user as a new one and creates it a session and credentials dictionaries if its access is granted.
 */
- (IBAction)handleButtonSignin:(id)sender
{
    // Validate the user entries
    NSString * userRegex = @"^[a-zA-Z0-9_-ñç]+$";
    NSPredicate * userTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", userRegex];
    if ([userTest evaluateWithObject:[self.userText text]]){
        //Matches
    } else {
        self.labelStatus.text = @"Error. User not valid. Please, only accepted a-z, A-Z, 0-9, \"_\" and \"-\".";
        return;
    }
    
    NSString * passRegex = @"^[a-zA-Z0-9_-ñç]{4,}$";
    NSPredicate * passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", passRegex];
    if ([passTest evaluateWithObject:[self.passText text]]){
        //Matches
    } else {
        self.labelStatus.text = @"Error. Password not valid; minimum length 8 characters: a-z, A-Z, 0-9, \"_\" and \"-\".";
        return;
    }
    
    // Wrap the user name and password in the user's credetials dictionary
    //  { "name": (NSString *)name1;                  // userDic
    //    "pass": (NSString *)pass1;
    //    "role": (NSString *)role1;
    //  }
    // The first credentials dictionary is for security purposes and its proprietary is the one who logs-in in the device; the second one is used for identifying purposes; in multiuser context, the first one is used in the device for accessing data, etc. while the second one is shared to the rest of users when a measure is taken or something is changed to indicate who did it.
    if(!credentialsUserDic) {
        credentialsUserDic = [[NSMutableDictionary alloc] init];
    }
    credentialsUserDic[@"name"] = [self.userText text];
    credentialsUserDic[@"pass"] = [self.passText text];
    
    if(!userDic) {
        userDic = [[NSMutableDictionary alloc] init];
    }
    userDic[@"name"] = [self.userText text];
    userDic[@"pass"] = [self.passText text];
    
    // Validate if the user have access granted.
    if ([self validateNewCredentialsUserDic:credentialsUserDic]) {
        
        if ([self registerNewUserWithCredentialsUserDic:credentialsUserDic]) {
            [self performSegueWithIdentifier:@"loginFromLoginToMain" sender:sender];
        } else {
            self.labelStatus.text = @"Error. An error occurred while registering. Please, wait a moment and try again.";
            return;
        }
        
    } else {
        self.labelStatus.text = @"Error. Invalid user name or password.";
        return;
    }
    
    return;
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)validateCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // TO DO: Validation. Alberto J. 2019/09/05.
    return YES;
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies if the name and password of the user already exist or are not valid.
 */
- (BOOL)validateNewCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // TO DO: Validation. Alberto J. 2019/09/05.
    return YES;
}

/*!
 @method registerNewUserWithCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)registerNewUserWithCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // TO DO: Registration. Alberto J. 2019/09/05.
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
        [viewControllerMainMenu setUserDic:userDic];
    }
}

@end
