//
//  ViewControllerMonitoring.h
//  Sensors test
//
//  Created by Alberto J. on 18/12/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerMonitoring.h"

@implementation ViewControllerMonitoring

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    [self showUser];
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ];
    [self.buttonFinish setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.buttonFinish setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.backButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ]
                          forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.3
                                    ]
                          forState:UIControlStateDisabled];
    [self.signOutButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [self.logOutButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.loginText setTextColor:[UIColor whiteColor]];
    
    // Register the current mode
    mode = [[MDMode alloc] initWithModeKey:kModeMonitoring];
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:mode
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
    // Components
    // TO DO: Use UUID from component 'device'. Alberto J. 2020/01/20.
    NSString * deviceUUID = [[NSUUID UUID] UUIDString];
    location = [[LMDelegateMonitoring alloc] initWithSharedData:sharedData
                                                        userDic:userDic
                                                     deviceUUID:deviceUUID
                                          andCredentialsUserDic:credentialsUserDic];
    [location setItemBeaconIdNumber:itemBeaconIdNumber];
    [location setItemPositionIdNumber:itemPositionIdNumber];
    
    // Get chosen item and set as device position
    NSMutableArray * itemsChosenByUser = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
    if (itemsChosenByUser.count == 0) {
        NSLog(@"[ERROR][VCM] The collection with the items chosen by user is empty; no device position provided.");
    } else {
        itemChosenByUserAsDevicePosition = [itemsChosenByUser objectAtIndex:0];
        if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR][VCM] The collection with the items chosen by user have more than one item; the first one is set as device position.");
        }
    }
    if (itemChosenByUserAsDevicePosition) {
        RDPosition * position = itemChosenByUserAsDevicePosition[@"position"];
        if (!position) {
            NSLog(@"[ERROR][VCM] No position was found in the item chosen by user as device position; (0,0,0) is set.");
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
        }
        [location setPosition:position];
    }
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
    // This object must listen to this events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshRegisterTable:)
                                                 name:@"refreshRegisterTable"
                                               object:nil];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableRegister.delegate = self;
    self.tableRegister.dataSource = self;
    
    [self.tableRegister reloadData];
    
    // Initial state measuring and init measures
    [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startMonitoringMeasures" object:nil];
    NSLog(@"[NOTI][VCM] Notification \"startMonitoringMeasures\" posted.");
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
 @method showUser
 @discussion This method defines how user name is shown once logged.
 */
- (void)showUser
{
    self.loginText.text = [self.loginText.text stringByAppendingString:@" "];
    self.loginText.text = [self.loginText.text stringByAppendingString:userDic[@"name"]];
}

#pragma mark - Notifications events handlers
/*!
 @method refreshRegisterTable:
 @discussion This method uploads the table with the ranged iBeacons; this method is called when someone submits the 'refreshCanvas' notification.
 */
- (void) refreshRegisterTable:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshRegisterTable"]){
        NSLog(@"[NOTI][VC] Notification \"refreshRegisterTable\" recived.");
    }
    [self.tableRegister reloadData];
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

#pragma mark - Buttons event handles

/*!
 @method handleButtonFinish:
 @discussion This method handles the action in which the 'Finish' button is pressed.
 */
- (IBAction)handleButtonFinish:(id)sender
{
    // First, validate the access to the data shared collection
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // TO DO: Alert user that measures will be disposed. Alberto J. 2020/01/20.
        
        // Stop measuring
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMonitoringMeasures" object:nil];
        NSLog(@"[NOTI][VCM] Notification \"stopMonitoringMeasures\" posted.");
        
        // Set registered items as located and reference with the registering item
        MDType * type = [[MDType alloc] initWithName:@"Register"];
        NSMutableArray * rangedUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                 withCredentialsUserDic:credentialsUserDic];
        for (NSString * uuid in rangedUUID) {
            NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithUUID:uuid
                                                                andCredentialsUserDic:credentialsUserDic] objectAtIndex:0];
            itemDic[@"located"] = @"YES";
            
            // Reference
            MDReference * reference = [[MDReference alloc] initWithType:type
                                                           sourceItemId:itemChosenByUserAsDevicePosition[@"identifier"]
                                                        andTargetItemId:itemDic[@"identifier"]
                                       ];
            NSLog(@"[INFO][VCM] Created reference %@", reference);
            [sharedData inSessionDataAddReference:reference
                                toUserWithUserDic:userDic
                           withCredentialsUserDic:credentialsUserDic];
        }
        location = nil;
        [self performSegueWithIdentifier:@"fromMONITORINGToFinalModel" sender:sender];
    } else {
        
    }
    return;
}

/*!
 @method handleButtonBack:
 @discussion This method dismiss this view and ask main menu view to be displayed; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"fromMONITORINGToSelectPosition" sender:sender];
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
    NSLog(@"[INFO][VCM] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromMONITORINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerSelectPositions setItemPositionIdNumber:itemPositionIdNumber];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopMonitoringMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCM] Notification \"stopMonitoringMeasures\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLocationAndMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCM] Notification \"resetLocationAndMeasures\" posted.");
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"fromMONITORINGToFinalModel"]) {
        
        // Get destination view
        ViewControllerFinalModel * viewControllerFinalModel = [segue destinationViewController];
        // Set the variables
        [viewControllerFinalModel setCredentialsUserDic:credentialsUserDic];
        [viewControllerFinalModel setUserDic:userDic];
        [viewControllerFinalModel setSharedData:sharedData];
        [viewControllerFinalModel setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerFinalModel setItemPositionIdNumber:itemPositionIdNumber];
        return;
    }
}

#pragma mark - UItableView delegate methods

/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableRegister) {
        NSMutableArray * rangedUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                 withCredentialsUserDic:credentialsUserDic];
        return rangedUUID.count;
    }
    return 0;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure individual cells
    if (tableView == self.tableRegister) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
            // Get the index ranged UUID...
            NSMutableArray * rangedUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                     withCredentialsUserDic:credentialsUserDic];
            NSString * uuid = [rangedUUID objectAtIndex:indexPath.row];
            NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithUUID:uuid
                                                                andCredentialsUserDic:credentialsUserDic] objectAtIndex:0];
            
            // and show it...
            if (itemDic) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ UUID: %@ \nmajor: %@ ; minor: %@",
                                       itemDic[@"identifier"],
                                       itemDic[@"type"],
                                       itemDic[@"uuid"],
                                       itemDic[@"major"],
                                       itemDic[@"minor"]
                                       ];
                cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            } else {
                NSLog(@"[ERROR][VCM] Regioned and ranged item not found: %@.", uuid);
            }
            
        } else { // Database not acessible
            [self alertUserWithTitle:@"Items won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCM] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    return cell;
}
@end
