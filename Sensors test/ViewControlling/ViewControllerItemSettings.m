//
//  ViewControllerItemSettings.m
//  Sensors test
//
//  Created by Alberto J. on 30/04/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerItemSettings.h"

@implementation ViewControllerItemSettings

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"itemDic viewDidLoad: %@", itemChosenByUser);
    
    // Visualization
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                        green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:1.0
                                         ]
                               forState:UIControlStateNormal];
    [self.calibrateButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                         blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                        alpha:0.3
                                    ]
                               forState:UIControlStateDisabled];
    [self.calibrateButton setEnabled:YES];
    [self.firstButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:1.0
                                     ]
                           forState:UIControlStateNormal];
    [self.firstButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                    green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                    alpha:0.3
                                     ]
                           forState:UIControlStateDisabled];
    [self.firstButton setEnabled:NO];
    [self.secondButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                     blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:1.0
                                      ]
                            forState:UIControlStateNormal];
    [self.secondButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                     green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                      blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                     alpha:0.3
                                      ]
                            forState:UIControlStateDisabled];
    [self.secondButton setEnabled:NO];
}

/*!
@method viewDidLoad
@discussion This method is called when the view is going to be shown.
*/
- (void)viewWillAppear:(BOOL)animated
{
    // Retrieve and show information from item
    if (itemChosenByUser) {
        
        // General information
        NSString * sort = itemChosenByUser[@"sort"];
        NSString * itemUUID = itemChosenByUser[@"uuid"];
        NSString * major = itemChosenByUser[@"major"];
        NSString * minor = itemChosenByUser[@"minor"];
        if (sort) {
            [self.sortLabel setText:sort];
        } else {
            [self.sortLabel setText:@"(null)"];
        }
        if (itemUUID) {
            [self.uuidLabel setText:itemUUID];
        } else {
            [self.uuidLabel setText:@"(null)"];
        }
        
        if (major) {
            [self.majorLabel setText:major];
        } else {
            [self.majorLabel setText:@"(null)"];
        }
        
        if (minor) {
            [self.minorLabel setText:minor];
        } else {
            [self.minorLabel setText:@"(null)"];
        }
        
        // Calibration information
        
    } else {
        NSLog(@"[ERROR][VCIS] View will appear without itemChosenByUser variable.");
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

/*!
 @method setItemChosenByUser:
 @discussion This method sets the NSMutableDictionary variable 'itemChosenByUser'.
 */
- (void) setItemChosenByUser:(NSMutableDictionary *)givenItemChosenByUser
{
    itemChosenByUser = givenItemChosenByUser;
}

#pragma mark - Buttons event handlers

/*!
 @method handleButtonCancel:
 @discussion This method handles the 'cancel' button action and segues back.
 */
- (IBAction)handleButtonCancel:(id)sender
{
    // Dismiss the popover view
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*!
@method handleButtonCancel:
@discussion This method handles the 'edit' button action, save the changes, and segues back.
*/
- (IBAction)handleButtonEdit:(id)sender
{
    // Dismiss the popover view
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

#pragma mark - UIPopoverPresentationControllerDelegate methods
/*!
@method adaptivePresentationStyleForPresentationController:
@discussion This method is called by the UIPopoverPresentationControllerDelegate protocol.
*/
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

@end
