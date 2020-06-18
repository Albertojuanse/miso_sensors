//
//  VCModeDelegateRhoThetaModelling.m
//  Sensors test
//
//  Created by MISO on 13/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCModeDelegateRhoThetaModelling.h"

@implementation VCModeDelegateRhoThetaModelling : NSObject

/*!
 @method initWithSharedData:userDic:deviceUUID:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved, the device's UUID and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
                        deviceUUID:(NSString *)initDeviceUUID
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [super init];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = initDeviceUUID;
    }
    
    return self;
}

#pragma mark - General VCModeDelegate methods
/*!
@method getErrorDescription
@discussion This method returns the description for errors that ViewControllerEditing must use when in RhoThetaModelling mode.
*/
- (NSString *)getErrorDescription
{
    return ERROR_DESCRIPTION_VCERTM;
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in RhoThetaModelling mode.
*/
- (NSString *)getIdleStateMessage
{
    return IDLE_STATE_MESSAGE_VCERTM;
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in RhoThetaModelling mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return MEASURING_STATE_MESSAGE_VCERTM;
}

#pragma mark - Location VCModeDelegate methods
/*!
@method loadLMDelegate
@discussion This method returns the location manager with the proper location system in RhoThetaModelling mode.
*/
- (id<CLLocationManagerDelegate>)loadLMDelegate
{
    if (!rhoThetaSystem) {
        rhoThetaSystem = [[RDRhoThetaSystem alloc] initWithSharedData:sharedData
                                                              userDic:userDic
                                                           deviceUUID:deviceUUID
                                                andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        // Load the location manager and its delegate, the component which device uses to handle location events.
        location = [[LMDelegateRhoThetaModelling alloc] initWithSharedData:sharedData
                                                                    userDic:userDic
                                                            rhoThetaSystem:rhoThetaSystem
                                                                deviceUUID:deviceUUID
                                                     andCredentialsUserDic:credentialsUserDic];
    }
    NSMutableArray * itemsChosenByUser = [sharedData fromSessionDataGetItemsChosenByUserDic:userDic
                                                                      andCredentialsUserDic:credentialsUserDic];
    NSMutableDictionary * itemChosenByUserAsDevicePosition;
    if (itemsChosenByUser.count == 0) {
        NSLog(@"[ERROR]%@ The collection with the items chosen by user is empty; no device position provided.", ERROR_DESCRIPTION_VCERTM);
    } else {
        itemChosenByUserAsDevicePosition = [itemsChosenByUser objectAtIndex:0];
        if (itemsChosenByUser.count > 1) {
            NSLog(@"[ERROR]%@ The collection with the items chosen by user have more than one item; the first one is set as device position.", ERROR_DESCRIPTION_VCERTM);
        }
    }
    if (itemChosenByUserAsDevicePosition) {
        RDPosition * position = itemChosenByUserAsDevicePosition[@"position"];
        if (!position) {
            NSLog(@"[ERROR]%@ No position was found in the item chosen by user as device position; (0,0,0) is set.", ERROR_DESCRIPTION_VCERTM);
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
        }
        if (!deviceUUID) {
            if (!itemChosenByUserAsDevicePosition[@"uuid"]) {
                NSLog(@"[ERROR]%@ No UUID was found in the item chosen by user as device position; a random one set.", ERROR_DESCRIPTION_VCERTM);
                deviceUUID = [[NSUUID UUID] UUIDString];
            } else {
                deviceUUID = itemChosenByUserAsDevicePosition[@"uuid"];
            }
        }
        [rhoThetaSystem setDeviceUUID:deviceUUID];
        [location setPosition:position];
        [location setDeviceUUID:deviceUUID];
    }
    return location;
}

#pragma mark - Motion VCModeDelegate methods
/*!
@method loadMotion
@discussion This method returns the motion manager in RhoThetaModelling mode.
*/
- (MotionManager *)loadMotion
{
    if (!motion) {
        motion = [[MotionManager alloc] initWithSharedData:sharedData
                                                   userDic:credentialsUserDic
                                            rhoThetaSystem:rhoThetaSystem
                                                deviceUUID:deviceUUID
                                     andCredentialsUserDic:credentialsUserDic];
        
        // TODO: make this configurable or properties. Alberto J. 2019/09/13.
        motion.acce_sensitivity_threshold = [NSNumber numberWithFloat:0.01];
        motion.gyro_sensitivity_threshold = [NSNumber numberWithFloat:0.015];
        motion.acce_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.acce_biasBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_measuresBuffer_capacity = [NSNumber numberWithInt:500];
        motion.gyro_biasBuffer_capacity = [NSNumber numberWithInt:500];
    }
    return motion;
}

#pragma mark - Selecting VCModeDelegate methods
/*!
@method whileSelectingHandleButtonGo:fromViewController:
@discussion This method returns the behaviour when user taps 'Go' button in SelectPosition view RhoThetaModelling mode.
*/
- (void)whileSelectingHandleButtonGo:(id)sender
                  fromViewController:(UIViewController *)viewController
{
    NSLog(@"[INFO]%@ Button 'go' handled from delegate.", ERROR_DESCRIPTION_VCERTM);
    [viewController performSegueWithIdentifier:@"fromSelectPositionsToEDITING" sender:sender];
    return;
}

/*!
 @method whileSelectingNumberOfSectionsInTableItems:inViewController:
 @discussion Handles the upload of table items; returns the number of sections in them.
 */
- (NSInteger)whileSelectingNumberOfSectionsInTableItems:(UITableView *)tableView
                                       inViewController:(UIViewController *)viewController
{
    // Return the number of sections.
    return 1;
}

/*!
 @method whileSelectingTableItems:inViewController:numberOfRowsInSection:
 @discussion Handles the upload of table items; returns the number of items in them.
 */
- (NSInteger)whileSelectingTableItems:(UITableView *)tableView
                   inViewController:(UIViewController *)viewController
                numberOfRowsInSection:(NSInteger)section
{
    NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
    NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
    return itemsCount + modelCount;
}

/*!
 @method whileSelectingTableItems:inViewController:cell:forRowAtIndexPath:
 @discussion Handles the upload of table items; returns each cell.
 */
- (UITableViewCell *)whileSelectingTableItems:(UITableView *)tableView
                             inViewController:(UIViewController *)viewController
                                         cell:(UITableViewCell *)cell
                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In RhoThetaModelling, only if the item have a position can be selected.
    // Also, models can be selected to add its items all of them toguether.
    
    // Select the source of items; both items and models are shown
    NSMutableDictionary * itemDic = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                inTableItems:tableView];
    
    // The itemDic variable can be null or NO if access is not granted or there are not items stored.
    if (itemDic) {
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // Check if the item is already selected; when in a routine it happens
        BOOL selected = [sharedData fromSessionDataIsChosenItemByUser:itemDic
                                                    byUserWithUserDic:userDic
                                                andCredentialsUserDic:userDic];
        if (selected) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
        // Prevent selecting others than positioned items unless models.
        if (!itemDic[@"position"]) {
            if (![@"model" isEqualToString:itemDic[@"sort"]]) {
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [cell setTintColor:[UIColor redColor]];
            }
        }
        
        // If it is a beacon
        if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
            
            [cell.imageView setImage:[VCDrawings imageForBeaconInNormalThemeColor]];
            
            // It representation depends on if exist its position or its type
            // Compose the description
            NSString * beaconDescription = [[NSString alloc] init];
            beaconDescription = [beaconDescription stringByAppendingString:itemDic[@"identifier"]];;
            beaconDescription = [beaconDescription stringByAppendingString:@" "];
            // If its type is set
            MDType * type = itemDic[@"type"];
            if (type) {
                beaconDescription = [beaconDescription stringByAppendingString:[type description]];
            }
            beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
            RDPosition * position = itemDic[@"position"];
            if (position) {
                beaconDescription = [beaconDescription stringByAppendingString:[position description]];
                beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
            }
            NSString * itemUUID = [itemDic[@"uuid"] substringFromIndex:24];
            NSString * itemMajor = itemDic[@"major"];
            NSString * itemMinor = itemDic[@"minor"];
            beaconDescription = [beaconDescription stringByAppendingFormat:@"UUID: %@ Major: %@ Minor: %@ ",
                                 itemUUID,
                                 itemMajor,
                                 itemMinor];
            cell.textLabel.text = beaconDescription;
            
        }
        
        // If it is a position
        if ([@"position" isEqualToString:itemDic[@"sort"]]) {
            
            // Set its icon
            [cell.imageView setImage:[VCDrawings imageForPositionInNormalThemeColor]];
            
            // Compose the description
            NSString * positionDescription = [[NSString alloc] init];
            positionDescription = [positionDescription stringByAppendingString:itemDic[@"identifier"]];;
            positionDescription = [positionDescription stringByAppendingString:@" "];
            // If its type is set
            MDType * type = itemDic[@"type"];
            if (type) {
                positionDescription = [positionDescription stringByAppendingString:[type description]];
            }
            positionDescription = [positionDescription stringByAppendingString:@"\n"];
            // Must have a position
            RDPosition * position = itemDic[@"position"];
            if (position) {
                positionDescription = [positionDescription stringByAppendingString:[position description]];
            } else {
                positionDescription = [positionDescription stringByAppendingString:@"( - , - , - )"];
                NSLog(@"[ERROR]%@ No RDPosition found in item of sort position.", ERROR_DESCRIPTION_VCERTM);
            }
            cell.textLabel.text = positionDescription;
            
        }
        
        // If it is a model
        if ([@"model" isEqualToString:itemDic[@"sort"]]) {
            
            // Set its icon
            [cell.imageView setImage:[VCDrawings imageForModelInNormalThemeColor]];
            
            NSString * modelDescription = itemDic[@"name"];
            if (!modelDescription) {
                modelDescription = @"Unknown model";
                NSLog(@"[ERROR]%@ No name found in intem of sort model.", ERROR_DESCRIPTION_VCERTM);
            }
            cell.textLabel.text = modelDescription;
            
        }
        
    } else {
        // The itemDic variable is null or NO
        NSLog(@"[ERROR]%@ No items found for showing.", ERROR_DESCRIPTION_VCERTM);
        if (indexPath.row == 0) {
            cell.textLabel.text = @"No items found.";
            cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        } else {
            cell.textLabel.text = @"Error loading item";
            cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        }
    }
    
    return cell;
}

/*!
 @method whileSelectingTtableItems:inViewController:didSelectRowAtIndexPath:
 @discussion Handles the upload of table items; handles the 'select a cell' action.
 */
- (void)whileSelectingTableItems:(UITableView *)tableView
                inViewController:(UIViewController *)viewController
         didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // In RhoThetaModelling, only if the item have a position can be selected.
    // Also, models can be selected to add its items all of them toguether.
     
    // The table was set in 'viewDidLoad' as multiple-selecting
    // Manage multi-selection
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary * itemDic = [self fromSharedDataGetItemWithIndexPath:indexPath
                                                                inTableItems:tableView];
    
    if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If not checkmark
        
        // Only models and items with position can be selected
        if (![@"model" isEqualToString:itemDic[@"sort"]]) { // if item
            if (itemDic[@"position"]) {
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [sharedData  inSessionDataSetAsChosenItem:itemDic
                                        toUserWithUserDic:userDic
                                   withCredentialsUserDic:credentialsUserDic];
            } else {
                NSLog(@"[ERROR]%@ While selecting, an item with no position found without AccesoryDetail in red.", ERROR_DESCRIPTION_VCERTM);
                [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [selectedCell setTintColor:[UIColor redColor]];
            }
            
        } else { // if model
            
            [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            // Retrieve the components, verify if they exists as items, and if not, add them
            NSMutableArray * components = itemDic[@"components"];
            for (NSMutableDictionary * eachComponent in components) {
                if ([sharedData fromItemDataIsItemWithInfoDic:eachComponent andCredentialsUserDic:credentialsUserDic]) {
                    [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                            toUserWithUserDic:userDic
                                       withCredentialsUserDic:credentialsUserDic];
                } else { // If it does not exist, just add it and set as chosen
                    BOOL savedItem = [sharedData inItemDataAddItemDic:eachComponent withCredentialsUserDic:credentialsUserDic];
                    [sharedData  inSessionDataSetAsChosenItem:eachComponent
                                            toUserWithUserDic:userDic
                                       withCredentialsUserDic:credentialsUserDic];
                    if (savedItem) {
                        // PERSISTENT: SAVE ITEM
                        // Save them in persistent memory
                        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                        // TODO: Assign items by user. Alberto J. 15/11/2019.
                        // Now there are items
                        NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
                        if (areItemsData) {
                            [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
                        }
                        areItemsData = nil; // ARC disposing
                        areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
                        [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
                        
                        // Get the index in which names of items are saved for retrieve them later
                        NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
                        NSMutableArray * itemsIndex;
                        if (itemsIndexData) {
                            itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
                            [userDefaults removeObjectForKey:@"es.uam.miso/data/items/index"];
                        } else {
                            itemsIndex = [[NSMutableArray alloc] init];
                        }
                        
                        // Get the item as it was saved in shared data
                        NSMutableArray * itemDics = [sharedData fromItemDataGetItemsWithIdentifier:eachComponent[@"identifier"]
                                                                             andCredentialsUserDic:credentialsUserDic];
                        if (itemDics.count == 0) {
                            NSLog(@"[ERROR]%@ Saved item %@ could not be retrieved from shared data.", eachComponent[@"identifier"], ERROR_DESCRIPTION_VCERTM);
                            break;
                        } else {
                            if (itemDics.count > 1) {
                                NSLog(@"[ERROR]%@ More than one saved item with identifier %@.", eachComponent[@"identifier"], ERROR_DESCRIPTION_VCERTM);
                                break;
                            }
                        }
                        NSMutableDictionary * itemDic = [itemDics objectAtIndex:0];
                        
                        // Create a NSData for the item and save it using its name
                        // Item's name
                        NSString * itemIdentifier = itemDic[@"identifier"];
                        // Save the name in the index
                        [itemsIndex addObject:itemIdentifier];
                        // Create the item's data and archive it
                        NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:itemDic];
                        NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
                        [userDefaults setObject:itemData forKey:itemKey];
                        // And save the new index
                        itemsIndexData = nil; // ARC disposing
                        itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
                        [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
                        NSLog(@"[INFO]%@ Item saved in device memory.", ERROR_DESCRIPTION_VCERTM);
                        // END PERSISTENT: SAVE ITEM
                    } else {
                        NSLog(@"[ERROR]%@ Item from model %@ could not be stored as an item.", ERROR_DESCRIPTION_VCERTM, eachComponent[@"position"]);
                    }
                }
            }
            
        }
        
    } else { // If checkmark or detail mark
        
        // Only models and items with position can be selected
        if (![@"model" isEqualToString:itemDic[@"sort"]]) {
            if (itemDic[@"position"]) {
                // Deselect
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                [sharedData  inSessionDataSetAsNotChosenItem:itemDic
                                           toUserWithUserDic:userDic
                                      withCredentialsUserDic:credentialsUserDic];
            } else {
                NSLog(@"[ERROR]%@ While selecting, an item with no position found without AccesoryDetail in red.", ERROR_DESCRIPTION_VCERTM);
                [selectedCell setAccessoryType:UITableViewCellAccessoryDetailButton];
                [selectedCell setTintColor:[UIColor redColor]];
            }
        
        } else { // if model
            
            [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
            // Retrieve the components
            NSMutableArray * components = itemDic[@"components"];
            for (NSMutableDictionary * eachComponent in components) {
                [sharedData  inSessionDataSetAsNotChosenItem:eachComponent
                                           toUserWithUserDic:userDic
                                      withCredentialsUserDic:credentialsUserDic];
            }
            
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*!
@method fromSharedDataGetItemWithIndexPath::inTableItems;
@discussion This method returns the item asked or selected by user in the item's table view.
*/
- (NSMutableDictionary *)fromSharedDataGetItemWithIndexPath:(NSIndexPath *)indexPath
                                               inTableItems:(UITableView *)tableView
{
    // Select the source of items; both items are models shown
    NSInteger itemsCount = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic] count];
    NSInteger modelCount = [[sharedData getModelDataWithCredentialsUserDic:credentialsUserDic] count];
    
    // Load the item depending of the source
    NSMutableDictionary * itemDic = nil;
    if (indexPath.row < itemsCount) {
        itemDic = [[sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic]
                   objectAtIndex:indexPath.row
                   ];
    }
    if (indexPath.row >= itemsCount && indexPath.row < itemsCount + modelCount) {
        itemDic = [
                   [sharedData getModelDataWithCredentialsUserDic:credentialsUserDic]
                   objectAtIndex:indexPath.row - itemsCount
                   ];
    }
    if (indexPath.row >= itemsCount + modelCount) {
        // Empty cell
    }
    
    return itemDic;
}

#pragma mark - Editing VCModeDelegate methods
/*!
@method whileEditingUserDidTapButtonMeasure:whenInState:andWithLabelStatus:
@discussion This method returns the behaviour when user taps 'Measure' button in Editing view in RhoThetaModelling mode.
*/
- (void)whileEditingUserDidTapButtonMeasure:(UIButton *)buttonMeasure
                                whenInState:(NSString *)state
                         andWithLabelStatus:(UILabel *)labelStatus
{
    if ([state isEqualToString:@"IDLE"]) { // If idle, user can measuring; if 'Measuring' is tapped, ask start measuring.
        if ([sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                        andCredentialsUserDic:credentialsUserDic]) {
            [buttonMeasure setEnabled:YES];
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];
            [labelStatus setText:MEASURING_STATE_MESSAGE_VCERTM];
        
            // And send the notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/start"
                                                                object:nil];
            NSLog(@"[NOTI]%@ Notification \"lmdRhoThetaModelling/start\" posted.", ERROR_DESCRIPTION_VCERTM);
            return;
        } else {
            return;
        }
    }
    if ([state isEqualToString:@"MEASURING"]) { // If measuring, user can travel or measuring; if 'Measuring' is tapped, ask stop measuring.
        [buttonMeasure setEnabled:YES];
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        [labelStatus setText:IDLE_STATE_MESSAGE_VCERTM];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoThetaModelling/stop"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmdRhoThetaModelling/stop\" posted.", ERROR_DESCRIPTION_VCERTM);
        return;
    }
}

/*!
 @method whileEditingNumberOfSectionsInTableItems:inViewController:
 @discussion Handles the upload of table items; returns the number of sections in them.
 */
- (NSInteger)whileEditingNumberOfSectionsInTableItems:(UITableView *)tableView
                           inViewController:(UIViewController *)viewController
{
    // Return the number of sections.
    return 1;
}

/*!
 @method whileEditingTableItems:inViewController:numberOfRowsInSection:
 @discussion Handles the upload of table items; returns the number of items in them.
 */
- (NSInteger)whileEditingTableItems:(UITableView *)tableView
                   inViewController:(UIViewController *)viewController
              numberOfRowsInSection:(NSInteger)section
{
    // In RhoThetaModelling, only iBeacon devices can be positioned.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // In this mode, only iBeacon devices can be positioned;
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        return [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                                   andCredentialsUserDic:credentialsUserDic] count];
    } else { // Type not found
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading items.", ERROR_DESCRIPTION_VCERTM);
    }
    
    return 0;
}

/*!
 @method whileEditingTableItems:inViewController:cell:forRowAtIndexPath:
 @discussion Handles the upload of table items; returns each cell.
 */
- (UITableViewCell *)whileEditingTableItems:(UITableView *)tableView
                           inViewController:(UIViewController *)viewController
                                       cell:(UITableViewCell *)cell
                          forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In RhoThetaModelling, only iBeacon devices can be positioned.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // Configure individual cells
    // Database could be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        // No item chosen by user
        [sharedData inSessionDataSetItemChosenByUser:nil
                                   toUserWithUserDic:userDic
                               andCredentialsUserDic:credentialsUserDic];
        
        // Select the source of items
        NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                                                            andCredentialsUserDic:credentialsUserDic]
                                         objectAtIndex:indexPath.row
                                         ];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // If it is a beacon
        if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
            
                        [cell.imageView setImage:[VCDrawings imageForBeaconInNormalThemeColor]];
            
            // It representation depends on if exist its position or its type
            // Compose the description
            NSString * beaconDescription = [[NSString alloc] init];
            beaconDescription = [beaconDescription stringByAppendingString:itemDic[@"identifier"]];;
            beaconDescription = [beaconDescription stringByAppendingString:@" "];
            // If its type is set
            MDType * type = itemDic[@"type"];
            if (type) {
                beaconDescription = [beaconDescription stringByAppendingString:[type description]];
            }
            beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
            RDPosition * position = itemDic[@"position"];
            if (position) {
                beaconDescription = [beaconDescription stringByAppendingString:[position description]];
                beaconDescription = [beaconDescription stringByAppendingString:@"\n"];
                
                // Inform that this item has a position
                [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
            }
            NSString * itemUUID = [itemDic[@"uuid"] substringFromIndex:24];
            NSString * itemMajor = itemDic[@"major"];
            NSString * itemMinor = itemDic[@"minor"];
            beaconDescription = [beaconDescription stringByAppendingFormat:@"UUID: %@ Major: %@ Minor: %@ ",
                                 itemUUID,
                                 itemMajor,
                                 itemMinor];
            cell.textLabel.text = beaconDescription;

        } else {
            NSLog(@"[ERROR]%@ An item of sort %@ loaded as a beacon.",
                  ERROR_DESCRIPTION_VCERTM,
                  itemDic[@"sort"]);
        }
        
    } else { // Type not found
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading cells' item.", ERROR_DESCRIPTION_VCERTM);
    }
    
    return cell;
}

/*!
 @method whileEditingTableItems:inViewController:didSelectRowAtIndexPath:
 @discussion Handles the upload of table items; handles the 'select a cell' action.
 */
- (void)whileEditingTableItems:(UITableView *)tableView
              inViewController:(UIViewController *)viewController
       didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In RhoThetaModelling, only iBeacon devices can be positioned.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Load the item depending and set as selected
        NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                           andCredentialsUserDic:credentialsUserDic]
        objectAtIndex:indexPath.row
        ];
        
        // The beacons with positions have got a detailMark
        if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) { // If detailed
            
            // Ask user to transfer the position
            [self askUserToTransferPositionFromItemDic:itemDic
                                          ofTableItems:tableView
                                      inViewController:viewController];
            
            
        } else {  // If not detailed
            // Set as chosen
            [sharedData inSessionDataSetItemChosenByUser:itemDic
                                       toUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic];
        }
        
        // Inform canvas about changes
        NSLog(@"[NOTI]%@ Notification \"canvas/refresh\" posted.", ERROR_DESCRIPTION_VCERTM);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"canvas/refresh"
         object:nil];
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while selecting a cell.", ERROR_DESCRIPTION_VCERTM);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*!
 @method askUserToTransferPosition
 @discussion This method ask the user if the position of the selected beacon has to be transferred to a new item.
 */
- (void) askUserToTransferPositionFromItemDic:(NSMutableDictionary *)itemDic
                                 ofTableItems:(UITableView *)tableView
                             inViewController:(UIViewController *)viewController
{
    UIAlertController * alertTransferPosition = [UIAlertController
                                                 alertControllerWithTitle:@"Position found"
                                             message:@"This iBeacon device has already a position assigned. Do you want to transfer it into a single position object?"
                                             preferredStyle:UIAlertControllerStyleAlert
                                             ];
    
    UIAlertAction * yesButton = [UIAlertAction
                                 actionWithTitle:@"yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     
                                     // Transfer the position
                                     [self transferPositionFromItemDic:itemDic
                                                          ofTableItems:tableView];
                                     
                                 }
                                 ];
    
    UIAlertAction * cancelButton = [UIAlertAction
                                    actionWithTitle:@"No"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        
                                        // Do nothing
                                        
                                    }
                                    ];
    
    [alertTransferPosition addAction:yesButton];
    [alertTransferPosition addAction:cancelButton];
    [viewController presentViewController:alertTransferPosition animated:YES completion:nil];
}

/*!
 @method transferPositionFromItemDic:ofTableItems:
 @discussion This method transfer the position of the selected beacon to a new item; also, the measures of the beacon must be deleted.
 */
-(void) transferPositionFromItemDic:(NSMutableDictionary *)itemDic
                       ofTableItems:(UITableView *)tableView
{
    // Get position and remove it
    RDPosition * itemPosition = itemDic[@"position"];
    itemDic[@"position"] = nil;
    // Not remove the type since it can be assigned to the beacon to create positions of that type
    MDType * itemType = itemDic[@"type"];
    NSString * locatedItem = itemDic[@"located"];
    itemDic[@"located"] = @"NO";
    
    // Create a new item with it
    NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
    infoDic[@"sort"] = @"position";
    NSString * newUUID = [[NSUUID UUID] UUIDString];
    infoDic[@"position"] = itemPosition;
    if (locatedItem) {
        infoDic[@"located"] = locatedItem;
    }
    if(itemType) {
        infoDic[@"type"] = itemType;
    }
    
    NSNumber * itemPositionIdNumber = [sharedData fromSessionDataGetItemPositionIdNumberOfUserDic:userDic
    withCredentialsUserName:credentialsUserDic];
    NSString * positionId = [@"position" stringByAppendingString:[itemPositionIdNumber stringValue]];
    itemPositionIdNumber = [NSNumber numberWithInteger:[itemPositionIdNumber integerValue] + 1];
    positionId = [positionId stringByAppendingString:@"@miso.uam.es"];
    infoDic[@"identifier"] = positionId;
    

    BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                withUUID:newUUID
                                             withInfoDic:infoDic
                               andWithCredentialsUserDic:credentialsUserDic];
    if (savedItem) {
        
    } else {
        NSLog(@"[ERROR][LMTTL] Located position %@ could not be stored as an item.", infoDic[@"position"]);
    }
    
    // Save variables in device memory
    // TODO: Session control to prevent data loss. Alberto J. 2020/02/17.
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/areIdNumbers"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    [userDefaults removeObjectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    // Update information
    NSData * areIdNumbersData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:areIdNumbersData forKey:@"es.uam.miso/variables/areIdNumbers"];
    // itemBeaconIdNumber
    NSNumber * itemBeaconIdNumber = [sharedData fromSessionDataGetItemBeaconIdNumberOfUserDic:userDic
                                                                      withCredentialsUserName:credentialsUserDic];
    NSData * itemBeaconIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemBeaconIdNumber];
    [userDefaults setObject:itemBeaconIdNumberData forKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
    // itemPositionIdNumber
    itemPositionIdNumber = [sharedData fromSessionDataGetItemPositionIdNumberOfUserDic:userDic
                                                               withCredentialsUserName:credentialsUserDic];
    NSData * itemPositionIdNumberData = [NSKeyedArchiver archivedDataWithRootObject:itemPositionIdNumber];
    [userDefaults setObject:itemPositionIdNumberData forKey:@"es.uam.miso/variables/itemPositionIdNumber"];
    
    // Upload table
    [tableView reloadData];
}

#pragma mark - Other methods
/*!
 @method alertUserWithTitle:message:andHandler:inViewController:
 @discussion This method alerts the user with a pop up window with a single "Ok" button given its message and title and lambda funcion handler.
 */
- (void) alertUserWithTitle:(NSString *)title
                    message:(NSString *)message
                 andHandler:(void (^)(UIAlertAction *action))handler
           inViewController:(UIViewController *)viewController
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
    [viewController presentViewController:alertUsersNotFound animated:YES completion:nil];
    return;
}
@end