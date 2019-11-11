//
//  ViewControllerLogin.m
//  Sensors test
//
//  Created by Alberto J. on 5/9/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerLogin.h"
#import "ViewControllerModelingThetaThetaLocating.h"

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
- (void)viewDidAppear:(BOOL)animated
{
    // Check if in this device exists any user
    BOOL areUsers = [self isAnyUserRegistered];
    
    // Alert the user that must create an user if no other is found
    if (!areUsers){
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
 @method isAnyUserRegistered
 @discussion This method checks if there is any user registered.
 */
- (BOOL)isAnyUserRegistered
{
    // Checks the saved data
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [userDefaults objectForKey:@"security/credentials/areUsers"];
    NSString * areUsers = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (areUsers) {
        if ([areUsers isEqualToString:@"NO"]) {
            NSLog(@"[INFO][VCL] No users saved found.");
            return NO;
        } else {
            NSLog(@"[INFO][VCL] Users saved found.");
            return YES;
        }
    } else {
        NSLog(@"[INFO][VCL] No users saved found.");
        return NO;
    }
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)validateCredentialsUserDic:(NSMutableDictionary *)userDic
{
    if ([self isAnyUserRegistered]) {
        // Generate the key in which this user is saved
        NSLog(@"[INFO][VCL] Validating user named %@", userDic[@"user"]);
        // Retrieve its data
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * key = [@"security/credentials/users/" stringByAppendingString:userDic[@"user"]];
        NSData * loadedUserData = [userDefaults objectForKey:key];
        if (loadedUserData) {
            NSMutableDictionary * loadedUserDic = [NSKeyedUnarchiver unarchiveObjectWithData:loadedUserData];
            if ([userDic isEqualToDictionary:loadedUserDic]) {
                NSLog(@"[INFO][VCL] Entry granted to user named %@", userDic[@"user"]);
                return YES;
            } else { // Pass not correct
                NSLog(@"[INFO][VCL] Entry not granted to user named %@", userDic[@"user"]);
                return NO;
            }
        } else { // User does not exists
            NSLog(@"[INFO][VCL] Unknown user named %@", userDic[@"user"]);
            return NO;
        }
    } else {
        return NO;
    }
}



/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies if the name and password of the user already exist or are not valid.
 */
- (BOOL)validateNewCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // Check if it exists
    // Generate the key in which this user is saved
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"[INFO][VCL] Validating new user named %@", userDic[@"user"]);
    // Retrieve its data
    NSString * key = [@"security/credentials/users/" stringByAppendingString:userDic[@"user"]];
    NSData * loadedUserData = [userDefaults objectForKey:key];
    if (loadedUserData) {
        // It exists
        NSLog(@"[INFO][VCL] Already exists a user named %@", userDic[@"user"]);
        return NO;
    } else {
        // It does not exist
        return YES;
    }
}

/*!
 @method registerNewUserWithCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)registerNewUserWithCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // User name was validated before
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * key = [@"security/credentials/users/" stringByAppendingString:userDic[@"user"]];
    NSMutableDictionary * saveDic = [[NSMutableDictionary alloc] init];
    saveDic[@"name"] = userDic[@"name"];
    saveDic[@"pass"] = userDic[@"pass"];
    NSData * dataSave = [NSKeyedArchiver archivedDataWithRootObject:saveDic];
    [userDefaults setObject:dataSave forKey:key];
    // And set users avalible
    dataSave = nil;
    dataSave = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:dataSave forKey:@"security/credentials/areUsers"];
    return YES;
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[INFO][VCL] Asked segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"loginFromLoginToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variable
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
    }
}

@end
