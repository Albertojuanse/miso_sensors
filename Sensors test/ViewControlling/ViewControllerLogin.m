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
    // Toolbar layout
    self.toolbar.backgroundColor = [VCDrawings getNormalThemeColor];
    [self.buttonLogin setTitleColor:[VCDrawings getNormalThemeColor]
                           forState:UIControlStateNormal];
    [self.buttonLogin setTitleColor:[VCDrawings getDisabledThemeColor]
                           forState:UIControlStateDisabled];
    [self.buttonSignin setTitleColor:[VCDrawings getNormalThemeColor]
                            forState:UIControlStateNormal];
    [self.buttonSignin setTitleColor:[VCDrawings getDisabledThemeColor]
                            forState:UIControlStateDisabled];
    [self.buttonConfiguration setTitleColor:[VCDrawings getNormalThemeColor]
                                   forState:UIControlStateNormal];
    
    if (userDidAskSignOut) {
        NSLog(@"[INFO][VCL] User did asked to sign out.");
        if ([self deleteUserWithCredentialsUserDic:userDic]) {
            NSLog(@"[INFO][VCL] User did sign out.");
        } else {
            NSLog(@"[ERROR][VCL] User could not sign out.");
        }
        userDic = nil;
        credentialsUserDic = nil;
        [self alertUserWithTitle:@"User deleted."
                         message:@""
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
    }
    if (userDidAskLogOut) {
        NSLog(@"[INFO][VCL] User did log out.");
        userDic = nil;
        credentialsUserDic = nil;
        [self alertUserWithTitle:@"User logged out."
                         message:@""
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
    }
    credentialsUserDicArray = [[NSMutableArray alloc] init];
}

/*!
 @method viewDidAppear:
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated
{
    // Check if in this device exists any routine
    BOOL isRoutine = [self isAnyRoutine];
    
    // Alert the user that must create an user if no other is found
    if (!isRoutine){
        UIAlertController * alertUsersNotFound = [UIAlertController
                                                  alertControllerWithTitle:@"No routine found"
                                                  message:@"Software producer did not create a routine for this app. Please, configure a routine in 'configuration' menu."
                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self.buttonLogin setEnabled:NO];
                                        [self.buttonSignin setEnabled:NO];
                                    }];
        
        [alertUsersNotFound addAction:okButton];
        [self presentViewController:alertUsersNotFound animated:YES completion:nil];
    } else {
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
                                            [self.buttonSignin setEnabled:YES];
                                        }];
            
            [alertUsersNotFound addAction:okButton];
            [self presentViewController:alertUsersNotFound animated:YES completion:nil];
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
 @method setUserDidAskLogOut:
 @discussion This method sets the BOOL flag 'didUserAskLogOut'.
 */
- (void) setUserDidAskLogOut:(BOOL)givenUserDidAskLogOut
{
    userDidAskLogOut = givenUserDidAskLogOut;
}

/*!
 @method setUserDidAskSignOut:
 @discussion This method sets the BOOL flag 'didUserAskSignOut'.
 */
- (void) setUserDidAskSignOut:(BOOL)givenUserDidAskSignOut
{
    userDidAskSignOut = givenUserDidAskSignOut;
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
        [self alertUserWithTitle:@"Invalid user."
                         message:@"Please, only accepted a-z, A-Z, 0-9, \"_\" and \"-\"."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return;
    }
    
    NSString * passRegex = @"^[a-zA-Z0-9_-ñç]{4,}$";
    NSPredicate * passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", passRegex];
    if ([passTest evaluateWithObject:[self.passText text]]){
        //Matches
    } else {
        [self alertUserWithTitle:@"Invalid password."
                         message:@"Minimum length 8 characters: a-z, A-Z, 0-9, \"_\" and \"-\"."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
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
    
    if(!userDic) {
        userDic = [[NSMutableDictionary alloc] init];
    }
    userDic[@"name"] = [self.userText text];
    userDic[@"pass"] = [self.passText text];
    
    // Validate if the user have access granted.
    if ([self validateCredentialsUserDic:credentialsUserDic]) {
        [self performSegueWithIdentifier:@"loginFromLoginToMain" sender:sender];
    } else {
        [self alertUserWithTitle:@"Invalid user name or password."
                         message:@"Please, try again."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
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
        [self alertUserWithTitle:@"Invalid user."
                         message:@"Please, only accepted a-z, A-Z, 0-9, \"_\" and \"-\"."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return;
    }
    
    NSString * passRegex = @"^[a-zA-Z0-9_-ñç]{4,}$";
    NSPredicate * passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", passRegex];
    if ([passTest evaluateWithObject:[self.passText text]]){
        //Matches
    } else {
        [self alertUserWithTitle:@"Invalid password."
                         message:@"Minimum length 8 characters: a-z, A-Z, 0-9, \"_\" and \"-\"."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
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
            [self alertUserWithTitle:@"An error occurred while registering."
                             message:@"Please, wait a moment and try again."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            return;
        }
        
    } else {
        [self alertUserWithTitle:@"Error"
                         message:@"Invalid user name or password, or existing name."
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return;
    }
    
    return;
}

/*!
 @method handleButtonConfiguration:
 @discussion This method handles the 'configuration' button action and segues to that view.
 */
- (IBAction)handleButtonConfiguration:(id)sender {
    [self performSegueWithIdentifier:@"fromLoginToConfiguration" sender:sender];
}

/*!
 @method isAnyUserRegistered
 @discussion This method checks if there is any user registered.
 */
- (BOOL)isAnyUserRegistered
{
    // Checks the saved data
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [userDefaults objectForKey:@"es.uam.miso/security/credentials/areUsers"];
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
 @method numberOfUserRegistered
 @discussion This method returns the number of users registered.
 */
- (NSInteger)numberOfUserRegistered
{
    // Checks the saved data
    NSInteger numberOfUsers = 0;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * loadedUserData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/numberOfUsers"];
    if (loadedUserData) {
        NSString * numberOfUsersString = [NSKeyedUnarchiver unarchiveObjectWithData:loadedUserData];
        numberOfUsers = [numberOfUsersString integerValue];
    } else {
        NSLog(@"[INFO][VCL] No users saved found.");
    }
    return numberOfUsers;
}

/*!
 @method validateCredentialsUserDic:
 @discussion This method verifies the name and password of the user.
 */
- (BOOL)validateCredentialsUserDic:(NSMutableDictionary *)userDic
{
    if ([self isAnyUserRegistered]) {
        // Generate the key in which this user is saved
        NSLog(@"[INFO][VCL] Validating user named %@", userDic[@"name"]);
        // Retrieve its data
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * key = [@"es.uam.miso/security/credentials/users/" stringByAppendingString:userDic[@"name"]];
        NSData * loadedUserData = [userDefaults objectForKey:key];
        if (loadedUserData) {
            NSMutableDictionary * loadedUserDic = [NSKeyedUnarchiver unarchiveObjectWithData:loadedUserData];
            if ([userDic isEqualToDictionary:loadedUserDic]) {
                NSLog(@"[INFO][VCL] Entry granted to user named %@", userDic[@"name"]);
                return YES;
            } else { // Pass not correct
                NSLog(@"[INFO][VCL] Entry not granted to user named %@", userDic[@"name"]);
                return NO;
            }
        } else { // User does not exists
            NSLog(@"[INFO][VCL] Unknown user named %@", userDic[@"name"]);
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
    NSLog(@"[INFO][VCL] Validating new user named %@", userDic[@"name"]);
    // Retrieve its data
    NSString * key = [@"es.uam.miso/security/credentials/users/" stringByAppendingString:userDic[@"name"]];
    NSData * loadedUserData = [userDefaults objectForKey:key];
    if (loadedUserData) {
        // It exists
        NSLog(@"[INFO][VCL] Already exists a user named %@", userDic[@"name"]);
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
    // User name was validated before and registration is allowed
    // Prepare the data to save...
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * key = [@"es.uam.miso/security/credentials/users/" stringByAppendingString:userDic[@"name"]];
    NSMutableDictionary * saveDic = [[NSMutableDictionary alloc] init];
    saveDic[@"name"] = userDic[@"name"];
    saveDic[@"pass"] = userDic[@"pass"];
    NSData * dataSaveDic = [NSKeyedArchiver archivedDataWithRootObject:saveDic];
    // ...save it...
    [userDefaults setObject:dataSaveDic forKey:key];
    // ...and set users available and the number of them
    NSData * areUsersData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/areUsers"];
    if (areUsersData) {
        [userDefaults removeObjectForKey:@"es.uam.miso/security/credentials/areUsers"];
        
    }
    NSData * areUsersDataNew = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areUsersDataNew forKey:@"es.uam.miso/security/credentials/areUsers"];
    
    NSData * numberOfUsersData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/numberOfUsers"];
    NSString * numberOfUsersString;
    if (numberOfUsersData) {
        numberOfUsersString = [NSKeyedUnarchiver unarchiveObjectWithData:numberOfUsersData];
        NSInteger  numberOfUsers = [numberOfUsersString integerValue];
        numberOfUsers++;
        numberOfUsersString = [[NSNumber numberWithInteger:numberOfUsers] stringValue];
    } else {
        numberOfUsersString = [[NSNumber numberWithInteger:1] stringValue];
    }
    NSData * numberOfUsersDataNew = [NSKeyedArchiver archivedDataWithRootObject:numberOfUsersString];
    [userDefaults setObject:numberOfUsersDataNew forKey:@"es.uam.miso/security/credentials/numberOfUsers"];
    
    NSLog(@"[INFO][VCL] New user registered.");
    return YES;
}

/*!
 @method deleteUserWithCredentialsUserDic:
 @discussion This method deletes the name and password of the user if it exists.
 */
- (BOOL)deleteUserWithCredentialsUserDic:(NSMutableDictionary *)userDic
{
    // Search for data to delete...
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * key = [@"es.uam.miso/security/credentials/users/" stringByAppendingString:userDic[@"name"]];
    NSData * dataSaveDic = [userDefaults objectForKey:key];
    if (dataSaveDic) {
        // It exists, delete it
        
        [userDefaults removeObjectForKey:key];
        
        // ...and set users available and the number of them
        
        NSData * numberOfUsersData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/numberOfUsers"];
        NSString * numberOfUsersString;
        NSInteger numberOfUsers;
        if (numberOfUsersData) {
            numberOfUsersString = [NSKeyedUnarchiver unarchiveObjectWithData:numberOfUsersData];
            numberOfUsers = [numberOfUsersString integerValue];
            numberOfUsers--;
            numberOfUsersString = [[NSNumber numberWithInteger:numberOfUsers] stringValue];
        } else {
            numberOfUsersString = [[NSNumber numberWithInteger:0] stringValue];
            numberOfUsers = 0;
        }
        NSData * numberOfUsersDataNew = [NSKeyedArchiver archivedDataWithRootObject:numberOfUsersString];
        [userDefaults setObject:numberOfUsersDataNew forKey:@"es.uam.miso/security/credentials/numberOfUsers"];
        
        if (numberOfUsers == 0) {
            NSData * areUsersData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/areUsers"];
            if (areUsersData) {
                [userDefaults removeObjectForKey:@"es.uam.miso/security/credentials/areUsers"];
            }
            NSData * areUsersDataNew = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
            [userDefaults setObject:areUsersDataNew forKey:@"es.uam.miso/security/credentials/areUsers"];
            NSLog(@"[INFO][VCL] User deleted; no users left in the system.");
        } else {
            NSData * areUsersData = [userDefaults objectForKey:@"es.uam.miso/security/credentials/areUsers"];
            if (areUsersData) {
                [userDefaults removeObjectForKey:@"es.uam.miso/security/credentials/areUsers"];
            }
            NSData * areUsersDataNew = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
            [userDefaults setObject:areUsersDataNew forKey:@"es.uam.miso/security/credentials/areUsers"];
            NSLog(@"[INFO][VCL] User deleted; there are some users left in the system.");
        }
        return YES;
        
    } else {
        // It does not exists
        NSLog(@"[INFO][VCL] User %@ not found when deleting it.", userDic[@"name"]);
        return NO;
    }
}

/*!
 @method isAnyRoutine
 @discussion This method checks if there is any routine configured.
 */
- (BOOL)isAnyRoutine
{
    // Checks the saved data
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [userDefaults objectForKey:@"es.uam.miso/data/routines/isRoutine"];
    if (data) {
        NSString * isRoutine = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (isRoutine) {
            if ([isRoutine isEqualToString:@"NO"]) {
                NSLog(@"[INFO][VCL] No configured routine found.");
                return NO;
            } else {
                NSLog(@"[INFO][VCL] Configured routine found.");
                return YES;
            }
        } else {
            NSLog(@"[INFO][VCL] No configured routine found.");
            return NO;
        }
    } else {
        return NO;
    }
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
    if ([[segue identifier] isEqualToString:@"fromLoginToConfiguration"]) {
        
        // Get destination view
        TabBarConfiguration * tabBarConfiguration = [segue destinationViewController];
        // Set the variable
        [tabBarConfiguration setCredentialsUserDic:credentialsUserDic];
        [tabBarConfiguration setUserDic:userDic];
    }
}

@end
