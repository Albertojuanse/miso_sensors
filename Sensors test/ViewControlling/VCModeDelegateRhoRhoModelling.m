//
//  VCModeDelegateRhoRhoModelling.m
//  Sensors test
//
//  Created by Alberto J. on 21/06/2020.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "VCModeDelegateRhoRhoModelling.h"

@implementation VCModeDelegateRhoRhoModelling : NSObject

/*!
 @method initWithSharedData:userDic:andCredentialsUserDic:
 @discussion Constructor given the shared data collection, the dictionary of the user in whose name the measures are saved and the credentials of the user for access it.
 */
- (instancetype)initWithSharedData:(SharedData *)initSharedData
                           userDic:(NSMutableDictionary *)initUserDic
             andCredentialsUserDic:(NSMutableDictionary *)initCredentialsUserDic
{
    self = [super init];
    if (self) {
        sharedData = initSharedData;
        credentialsUserDic = initCredentialsUserDic;
        userDic = initUserDic;
        deviceUUID = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

#pragma mark - General VCModeDelegate methods
/*!
@method getErrorDescription
@discussion This method returns the description for errors that ViewControllerEditing must use when in RhoRhoModelling mode.
*/
- (NSString *)getErrorDescription
{
    return ERROR_DESCRIPTION_VCERRM;
}

/*!
@method getIdleStateMessage
@discussion This method returns the label test for Idle state in RhoRhoModelling mode.
*/
- (NSString *)getIdleStateMessage
{
    return IDLE_STATE_MESSAGE_VCERRM;
}

/*!
@method getMeasuringStateMessage
@discussion This method returns the label test for Measuring state in RhoRhoModelling mode.
*/
- (NSString *)getMeasuringStateMessage
{
    return MEASURING_STATE_MESSAGE_VCERRM;
}

#pragma mark - Location VCModeDelegate methods
/*!
@method loadLMDelegate
@discussion This method returns the location manager with the proper location system in RhoRhoModelling mode.
*/
- (id<CLLocationManagerDelegate>)loadLMDelegate
{
    if (!rhoRhoSystem) {
        rhoRhoSystem = [[RDRhoRhoSystem alloc] initWithSharedData:sharedData
                                                              userDic:userDic
                                                andCredentialsUserDic:credentialsUserDic];
    }
    if (!location) {
        // Load the location manager and its delegate, the component which device uses to handle location events.
        location = [[LMDelegateRhoRhoModelling alloc] initWithSharedData:sharedData
                                                                 userDic:userDic
                                                            rhoRhoSystem:rhoRhoSystem
                                                   andCredentialsUserDic:credentialsUserDic];
    }
    return location;
}

/*!
@method loadLMRanging
@discussion This method returns the ranger in RhoRhoModelling mode.
*/
- (LMRanging *)loadLMRanging
{
    if (!rhoRhoSystem) {
        rhoRhoSystem = [[RDRhoRhoSystem alloc] initWithSharedData:sharedData
                                                          userDic:userDic
                                            andCredentialsUserDic:credentialsUserDic];
    }
    if (!ranger) {
        ranger = [[LMRanging alloc] initWithSharedData:sharedData
                                          rhoRhoSystem:rhoRhoSystem
                                               userDic:userDic
                                 andCredentialsUserDic:credentialsUserDic];
    }
    return ranger;
}

#pragma mark - Motion VCModeDelegate methods
/*!
@method loadMotion
@discussion This method returns the motion manager in RhoRhoModelling mode.
*/
- (MotionManager *)loadMotion
{
    return nil;
}

#pragma mark - Selecting VCModeDelegate methods
/*!
@method whileSelectingHandleButtonGo:fromViewController:
@discussion This method returns the behaviour when user taps 'Go' button in SelectPosition view RhoRhoModelling mode.
*/
- (void)whileSelectingHandleButtonGo:(id)sender
                  fromViewController:(UIViewController *)viewController
{
    NSLog(@"[INFO]%@ Button 'go' handled from delegate.", ERROR_DESCRIPTION_VCERRM);
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
    // In RhoRhoModelling, only if the item have a position can be selected.
    // Also, models can be selected to add its items all of them together.
    
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
            
            // Its description depends on if exist its position or its type
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
                NSLog(@"[ERROR]%@ No RDPosition found in item of sort position.", ERROR_DESCRIPTION_VCERRM);
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
                NSLog(@"[ERROR]%@ No name found in intem of sort model.", ERROR_DESCRIPTION_VCERRM);
            }
            cell.textLabel.text = modelDescription;
            
        }
        
    } else {
        // The itemDic variable is null or NO
        NSLog(@"[ERROR]%@ No items found for showing.", ERROR_DESCRIPTION_VCERRM);
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
    // In RhoRhoModelling, only iBeacon devices can be positioned.
    // Also, models can be selected to add its items all of them together.
     
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
                NSLog(@"[ERROR]%@ While selecting, an item with no position found without AccesoryDetail in red.", ERROR_DESCRIPTION_VCERRM);
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
                            NSLog(@"[ERROR]%@ Saved item %@ could not be retrieved from shared data.", eachComponent[@"identifier"], ERROR_DESCRIPTION_VCERRM);
                            break;
                        } else {
                            if (itemDics.count > 1) {
                                NSLog(@"[ERROR]%@ More than one saved item with identifier %@.", eachComponent[@"identifier"], ERROR_DESCRIPTION_VCERRM);
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
                        NSLog(@"[INFO]%@ Item saved in device memory.", ERROR_DESCRIPTION_VCERRM);
                        // END PERSISTENT: SAVE ITEM
                    } else {
                        NSLog(@"[ERROR]%@ Item from model %@ could not be stored as an item.", ERROR_DESCRIPTION_VCERRM, eachComponent[@"position"]);
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
                NSLog(@"[ERROR]%@ While selecting, an item with no position found without AccesoryDetail in red.", ERROR_DESCRIPTION_VCERRM);
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
    // In RhoRhoModelling, only iBeacon devices can be positioned from a known position.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // In this mode, only iBeacon devices can be positioned.
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
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading items.", ERROR_DESCRIPTION_VCERRM);
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
    // In RhoRhoModelling, only iBeacon devices can be positioned from a known position.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // Configure individual cells
    // Database could be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        // Select the source of items
        NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                                                            andCredentialsUserDic:credentialsUserDic]
                                         objectAtIndex:indexPath.row
                                         ];
        cell.textLabel.numberOfLines = 0; // Means any number
        
        // If it is a beacon
        if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
            
            [cell.imageView setImage:[VCDrawings imageForBeaconInNormalThemeColor]];
            
            // Its description depends on if exist its position or its type
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
                  ERROR_DESCRIPTION_VCERRM,
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
        NSLog(@"[ERROR]%@ Shared data could not be accessed while loading cells' item.", ERROR_DESCRIPTION_VCERRM);
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
    // In RhoRhoModelling, only iBeacon devices can be positioned from a known position.
    // If one of these items have already got a position assigned, that position must be transferred to another item
    
    // Database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        // First, verify that the user did choose a position to measure from.
        if ([self processItemChosenByUser]) {
            
            UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            // Load the item depending and set as selected
            NSMutableDictionary * itemDic = [[sharedData fromItemDataGetItemsWithSort:@"beacon"
                               andCredentialsUserDic:credentialsUserDic]
            objectAtIndex:indexPath.row
            ];
            
            // The beacons with positions have got a detailMark
            if ([selectedCell accessoryType] == UITableViewCellAccessoryDetailButton) { // If detailed
                
                // Ask user to transfer the position
                [self askUserToTransferPositionFromItemDic:itemDic
                                              ofTableItems:tableView
                                          inViewController:viewController];
                
                
            } else {  // If not detailed
                           
               // Dismiss the add view.
               [viewController dismissViewControllerAnimated:NO completion:^(void)
               {
                   // Ask view to start the measure interface; send the item chosen to measure.
                   NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
                   dataDic[@"itemDic"] = itemDic;
                   [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"vcEditing/presentMeasureView"
                    object:self
                    userInfo:dataDic];
                   NSLog(@"[NOTI]%@ Notification \"vcEditing/presentMeasureView\" posted.", ERROR_DESCRIPTION_VCERRM);
               }
                ];
               
           }
            
        } else {
            [self alertUserWithTitle:@"No device position chosen."
                             message:[NSString stringWithFormat:@"The user did not choose a position as device's position. Please, choose one in the model."]
                          andHandler:^(UIAlertAction * action) {
                [viewController dismissViewControllerAnimated:YES completion:nil];
            }
                    inViewController:viewController
             ];
        }
        
    } else {
        [self alertUserWithTitle:@"Items won't be loaded."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TODO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
                inViewController:viewController
         ];
        NSLog(@"[ERROR]%@ Shared data could not be accessed while selecting a cell.", ERROR_DESCRIPTION_VCERRM);
    }
}

/*!
@method processItemChosenByUser
@discussion This method verifies that user did choose the position to measure from and process it.
*/
-(BOOL)processItemChosenByUser
{
    NSMutableDictionary * itemChosenByUser = [sharedData
                                              fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                              andCredentialsUserDic:credentialsUserDic
                                              ];
    if (itemChosenByUser) {
        RDPosition * position = itemChosenByUser[@"position"];
        if (!position) {
            NSLog(@"[ERROR]%@ No position was found in the item chosen by user as device position; (0,0,0) is set.", ERROR_DESCRIPTION_VCERRM);
            position = [[RDPosition alloc] init];
            position.x = [NSNumber numberWithFloat:0.0];
            position.y = [NSNumber numberWithFloat:0.0];
            position.z = [NSNumber numberWithFloat:0.0];
            itemChosenByUser[@"position"] = position;
        }
        NSString * uuid = itemChosenByUser[@"uuid"];
        if (!uuid) {
            NSLog(@"[ERROR]%@ No UUID was found in the item chosen by user as device position; a random one set.", ERROR_DESCRIPTION_VCERRM);
            itemChosenByUser[@"uuid"] = [[NSUUID UUID] UUIDString];
        }
        
        return YES;
    } else {
        return NO;
    }
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
                                             message:@"This device has already a position assigned. Do you want to transfer it into a single position object?"
                                             preferredStyle:UIAlertControllerStyleAlert
                                             ];
    
    UIAlertAction * yesButton = [UIAlertAction
                                 actionWithTitle:@"yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     
                                     // Transfer the position
                                     [self transferPositionFromItemDic:itemDic
                                                          ofTableItems:tableView];
        
                                     // Ask location delegate to remove all measures
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"lmd/reset"
                                                                                         object:nil];
                                     NSLog(@"[NOTI][VCM] Notification \"lmd/reset\" posted.");
                                    
                                     // Dismiss the view to force reload the table
                                     [viewController dismissViewControllerAnimated:NO completion:nil];
        
                                     // Set the item chosen by user as nil to force new selecting
                                     [sharedData
                                      inSessionDataSetItemChosenByUser:nil
                                      toUserWithUserDic:userDic
                                      andCredentialsUserDic:credentialsUserDic
                                      ];
                                     
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
    NSString * itemIdentifier = [@"position" stringByAppendingString:[newUUID substringFromIndex:31]];
    itemIdentifier = [itemIdentifier stringByAppendingString:@"@miso.uam.es"];
    infoDic[@"identifier"] = itemIdentifier;
    

    BOOL savedItem = [sharedData inItemDataAddItemOfSort:@"position"
                                                withUUID:newUUID
                                             withInfoDic:infoDic
                               andWithCredentialsUserDic:credentialsUserDic];
    if (savedItem) {
        // Set the new item as chosen and the old one as no chosen
        NSMutableArray * savedItemDics = [sharedData fromItemDataGetItemsWithIdentifier:itemIdentifier
                                                                  andCredentialsUserDic:credentialsUserDic];
        NSMutableDictionary * savedItemDic;
        if ([savedItemDics count] > 0) {
            savedItemDic = [savedItemDics objectAtIndex:0];
        }
        if (savedItemDic) {
            [sharedData inSessionDataSetAsChosenItem:savedItemDic
                                   toUserWithUserDic:userDic
                              withCredentialsUserDic:credentialsUserDic];
        } else {
            NSLog(@"[ERROR]%@ New position %@ could not be stored as an item.", infoDic[@"position"], ERROR_DESCRIPTION_VCERRM);
        }
        [sharedData inSessionDataSetAsNotChosenItem:itemDic
                                  toUserWithUserDic:userDic
                             withCredentialsUserDic:credentialsUserDic];
    } else {
        NSLog(@"[ERROR]%@ Located position %@ could not be stored as an item.", infoDic[@"position"], ERROR_DESCRIPTION_VCERRM);
    }
    
    // Upload table
    [tableView reloadData];
    // Aks canvas to refresh.
    NSLog(@"[NOTI]%@ Notification \"canvas/refresh\" posted.", ERROR_DESCRIPTION_VCERRM);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"canvas/refresh"
     object:nil];
}

#pragma mark - Adding VCModeDelegate methods
/*!
@method imageForMeasureIcon
@discussion This method returns the image for measuring interface in RhoRhoModelling mode to measure the selected item.
*/
- (UIImage *)imageForMeasureIcon
{
    return [UIImage imageNamed:@"Measure rhoRho.png"];
}

/*!
@method whileAddingUserDidTapMeasure:toMeasureItemDic:
@discussion This method returns the behaviour when user taps 'Measure' button in Add view in RhoRhoModelling mode to measure the selected item.
*/
- (void)whileAddingUserDidTapMeasure:(UIButton *)measureButton
                    toMeasureItemDic:(NSMutableDictionary *)itemDic
{
    // In every state the button performs different behaviours
    if (
        [sharedData fromSessionDataIsIdleUserWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic]
        )
    {
        // If idle, user can measuring; if 'Measuring' is tapped, user asks start measuring.
        if (itemDic) {
            
            // Update current state
            [sharedData inSessionDataSetMeasuringUserWithUserDic:userDic
                                       andWithCredentialsUserDic:credentialsUserDic];

            
            // Change button layout
            UIImage * startMeasureIcon = [VCDrawings imageForMeasureInDisabledThemeColor];
            [measureButton setImage:startMeasureIcon forState:UIControlStateNormal];
            
            // And send the notification to start measure
            NSMutableDictionary * dataDic = [[NSMutableDictionary alloc] init];
            dataDic[@"itemDic"] = itemDic;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoRhoModelling/start"
                                                                object:nil
                                                              userInfo:dataDic];
            NSLog(@"[NOTI]%@ Notification \"lmdRhoRhoModelling/start\" posted.", ERROR_DESCRIPTION_VCERRM);
            return;
        } else {
            NSLog(@"[ERROR]%@ No item chosen to be measured.", ERROR_DESCRIPTION_VCERRM);
            return;
        }
    }
    if (
        [sharedData fromSessionDataIsMeasuringUserWithUserDic:userDic
                                        andCredentialsUserDic:credentialsUserDic]
        )
    {
        // If measuring, user can go idle; if 'Measuring' is tapped, user asks stop measuring.
        
        // Update current state
        [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                              andWithCredentialsUserDic:credentialsUserDic];
        
        // Change button layout
        UIImage * startMeasureIcon = [VCDrawings imageForMeasureInNormalThemeColor];
        [measureButton setImage:startMeasureIcon forState:UIControlStateNormal];
        
        // And send the notification to stop measure
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoRhoModelling/stop"
                                                            object:nil];
        NSLog(@"[NOTI]%@ Notification \"lmdRhoRhoModelling/stop\" posted.",ERROR_DESCRIPTION_VCERRM);
        return;
    }
}

/*!
@method whileAddingRangingMeasureFinishedInViewController:withMeasureButton:
@discussion This method returns the behaviour when the notification "rangingMeasureFinished" is recived in Add view in RhoRhoModelling mode to measure the selected item.
*/
- (void)whileAddingRangingMeasureFinishedInViewController:(UIViewController *)viewController
                                        withMeasureButton:(UIButton *)measureButton
{
    // Update current state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Change button layout
    UIImage * startMeasureIcon = [VCDrawings imageForMeasureInNormalThemeColor];
    [measureButton setImage:startMeasureIcon forState:UIControlStateNormal];
    
    // And send the notification to stop measure
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lmdRhoRhoModelling/stop"
                                                        object:nil];
    NSLog(@"[NOTI]%@ Notification \"lmdRhoRhoModelling/stop\" posted.", ERROR_DESCRIPTION_VCERRM);
    
    // Notify user
    [self alertUserWithTitle:@"Measure finished"
                    message:[NSString stringWithFormat:@""]
                 andHandler:^(UIAlertAction * action) {}
           inViewController:viewController
    ];
    return;
}

/*!
@method whileAddingRangingMeasureFinishedWithErrorsInViewController:notification:withMeasureButton:
@discussion This method returns the behaviour when the notification "rangingMeasureFinishedWithErrors" is recived in Add view in RhoRhoModelling mode to measure the selected item.
*/
- (void)whileAddingRangingMeasureFinishedWithErrorsInViewController:(UIViewController *)viewController
                                                       notification:(NSNotification *)notification
                                                  withMeasureButton:(UIButton *)measureButton
{
    // Update current state
    [sharedData inSessionDataSetIdleUserWithUserDic:userDic
                          andWithCredentialsUserDic:credentialsUserDic];
    
    // Change button layout
    UIImage * startMeasureIcon = [VCDrawings imageForMeasureInNormalThemeColor];
    [measureButton setImage:startMeasureIcon forState:UIControlStateNormal];
    
    // And send the notification to stop measure and notify user
    NSDictionary * data = notification.userInfo;
    NSString * consecutiveInvalidMeasuresError = data[@"consecutiveInvalidMeasures"];
    if (consecutiveInvalidMeasuresError) {
        if ([consecutiveInvalidMeasuresError isEqualToString:@"consecutiveInvalidMeasures"]) {
            
            // Notify
            NSLog(@"[NOTI]%@ Notification \"lmd/rangingMeasureFinishedWithErrors\" posted.", ERROR_DESCRIPTION_VCERRM);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"lmd/rangingMeasureFinishedWithErrors"
             object:nil
             userInfo:data];
            
            // Alert the user
            [self alertUserWithTitle:@"Measure error"
                             message:@"Measure process failed in its first step due to too many measures were invalid. Please, try again."
                          andHandler:^(UIAlertAction * action) {}
                    inViewController:viewController
             ];
        }
    } else {
        
        // Notify
        NSLog(@"[NOTI]%@ Notification \"lmd/rangingMeasureFinishedWithErrors\" posted.", ERROR_DESCRIPTION_VCERRM);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"lmd/rangingMeasureFinishedWithErrors"
         object:nil];
        
        // Alert the user
        [self alertUserWithTitle:@"Measure error"
                         message:@"Measure process failed in its first step due an unknown error. Please, try again."
                      andHandler:^(UIAlertAction * action) {}
                inViewController:viewController
         ];
    }
    
    return;
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
