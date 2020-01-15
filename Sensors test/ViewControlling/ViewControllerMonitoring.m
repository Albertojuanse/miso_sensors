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
    
    // Register the current mode
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        [sharedData inSessionDataSetMode:@"MONITORING"
                       toUserWithUserDic:userDic
                   andCredentialsUserDic:credentialsUserDic];
    } else {
        // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
    }
    
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
        [motion setPosition:position];
        [location setPosition:position];
    }
    
    // Ask canvas to initialize
    [self.canvas prepareCanvasWithSharedData:sharedData userDic:userDic andCredentialsUserDic:credentialsUserDic];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableRegister.delegate = self;
    self.tableRegister.dataSource = self;
    
    [self.tableRegister reloadData];
    
    // Initial state measuring and init measures
    [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                               andWithCredentialsUserDic:credentialsUserDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startLocationMeasuring" object:nil];
    NSLog(@"[NOTI][VCM] Notification \"startLocationMeasuring\" posted.");
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
        // Stop measuring
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                                   andWithCredentialsUserDic:credentialsUserDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring" object:nil];
        NSLog(@"[NOTI][VCM] Notification \"stopLocationMeasuring\" posted.");
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
    NSLog(@"[INFO][VCTTL] Asked segue %@", [segue identifier]);
    
    // If main menu is going to be displayed, any variable can be returned here
    if ([[segue identifier] isEqualToString:@"fromMONITORINGToSelectPosition"]) {
        
        // Get destination view
        ViewControllerSelectPositions * viewControllerSelectPositions = [segue destinationViewController];
        // Set the variables
        [viewControllerSelectPositions setCredentialsUserDic:credentialsUserDic];
        [viewControllerSelectPositions setUserDic:userDic];
        [viewControllerSelectPositions setSharedData:sharedData];
        [viewControllerSelectPositions setMotionManager:motion];
        [viewControllerSelectPositions setLocationManager:location];
        
        // Ask Location manager to clean the measures taken and reset its position.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocationMeasuring"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"stopLocationMeasuring\" posted.");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLocationAndMeasures"
                                                            object:nil];
        NSLog(@"[NOTI][VCTTL] Notification \"resetLocationAndMeasures\" posted.");
        return;
    }
    
    if ([[segue identifier] isEqualToString:@"fromMONITORINGToModelingMONITORING"]) {
        
        // Get destination view
        //ViewControllerModelingThetaThetaLocating * viewControllerModelingThetaThetaLocating = [segue destinationViewController];
        // Set the variables
        //[viewControllerModelingThetaThetaLocating setCredentialsUserDic:credentialsUserDic];
        //[viewControllerModelingThetaThetaLocating setUserDic:userDic];
        //[viewControllerModelingThetaThetaLocating setSharedData:sharedData];
        //[viewControllerModelingThetaThetaLocating setMotionManager:motion];
        //[viewControllerModelingThetaThetaLocating setLocationManager:location];
        return;
    }
}

#pragma mark - UItableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableRegister) {
        NSMutableArray * rangedUUID = [sharedData fromMeasuresDataGetItemUUIDsOfUserDic:userDic
                                                                 withCredentialsUserDic:credentialsUserDic];
        return rangedUUID.count;
    }
    return 0;
}

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
            NSLog(@"[ERROR][VCTTL] Shared data could not be accessed while loading cells' item.");
        }
    }
    
    return cell;
}
@end
