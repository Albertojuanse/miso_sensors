//
//  ViewControllerAddBeaconMenu.m
//  Sensors test
//
//  Created by Alberto J. on 8/7/19.
//  Copyright © 2019 MISO. All rights reserved.
//

#import "ViewControllerAddBeaconMenu.h"

@implementation ViewControllerAddBeaconMenu

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Visualization
    // Sets if the user wants to modify a beacon device or a position, or nothing
    NSDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                  andCredentialsUserDic:credentialsUserDic];
    if (
        ![@"beacon" isEqualToString:itemChosenByUser[@"sort"]] &&
        ![@"position" isEqualToString:itemChosenByUser[@"sort"]] &&
        ![@"model" isEqualToString:itemChosenByUser[@"sort"]]
        )
    { // Add new one
        selectedSegmentIndex = 0;
    } else {
        if ([@"beacon" isEqualToString:itemChosenByUser[@"sort"]]) {
            selectedSegmentIndex = 0;
        }
        if ([@"position" isEqualToString:itemChosenByUser[@"sort"]]) {
            selectedSegmentIndex = 1;
        }
         if (
             [@"beacon" isEqualToString:itemChosenByUser[@"sort"]] &&
             [@"position" isEqualToString:itemChosenByUser[@"sort"]]
             )
         {
             NSLog(@"[ERROR][VCAB] User did choose both Beacon and Position to change; UUID by default.");
             selectedSegmentIndex = 0;
         }
    }
    
    [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
    [self changeView];
    
    // This object must listen to this events
    [self.segmentedControl addTarget:self
                              action:@selector(uploadSegmentIndex:)
                    forControlEvents:UIControlEventValueChanged];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableTypes.delegate = self;
    self.tableTypes.dataSource = self;
    
    [self.tableTypes reloadData];
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
 @method uploadSegmentIndex:
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
- (void) uploadSegmentIndex:(id)sender
{
    // Upload global variable value
    selectedSegmentIndex = [self.segmentedControl selectedSegmentIndex];
    [self changeView];
    return;
}
     

/*!
 @method changeView
 @discussion This method is called when the segmented control is tapped and changes the enable and view values of the forms to alternate between them.
 */
 - (void) changeView
{
     
     // Empty text boxes
     self.textUUID.text = @"";
     self.textMinor.text = @"";
     self.textMajor.text = @"";
     self.textBeaconX.text = @"";
     self.textBeaconY.text = @"";
     self.textBeaconZ.text = @"";
     self.textPositionX.text = @"";
     self.textPositionY.text = @"";
     self.textPositionZ.text = @"";
     
     // Different behaviour if position or beacon
     switch (selectedSegmentIndex) {
         case 0: {// iBeacon mode
             
             // Visualization
             // Enable beacon elements
             [self.labelBeacon1 setEnabled:YES];
             [self.labelBeaconUUID setEnabled:YES];
             [self.labelBeaconMajor setEnabled:YES];
             [self.labelBeaconMinor setEnabled:YES];
             [self.textUUID setEnabled:YES];
             [self.textMajor setEnabled:YES];
             [self.textMinor setEnabled:YES];
             [self.labelBeacon2 setEnabled:YES];
             [self.labelBeaconX setEnabled:YES];
             [self.labelBeaconY setEnabled:YES];
             [self.labelBeaconZ setEnabled:YES];
             [self.textBeaconX setEnabled:YES];
             [self.textBeaconY setEnabled:YES];
             [self.textBeaconZ setEnabled:YES];
             [self.labelBeaconError setEnabled:YES];
             [self.buttonBeaconDelete setEnabled:YES];
             [self.buttonBeaconBack setEnabled:YES];
             [self.buttonBeaconAdd setEnabled:YES];
             // Disable position elements
             [self.labelPosition1 setEnabled:NO];
             [self.labelPositionX setEnabled:NO];
             [self.labelPositionY setEnabled:NO];
             [self.labelPositionZ setEnabled:NO];
             [self.textPositionX setEnabled:NO];
             [self.textPositionY setEnabled:NO];
             [self.textPositionZ setEnabled:NO];
             [self.labelPositionError setEnabled:NO];
             [self.buttonPositionDelete setEnabled:NO];
             [self.buttonPositionBack setEnabled:NO];
             [self.buttonPositionAdd setEnabled:NO];
             
             // Hints
             self.textUUID.placeholder = @"12345678-1234-1234-1234-123456789012";
             self.textMajor.placeholder = @"0";
             self.textMinor.placeholder = @"0";
             self.textBeaconX.placeholder = @"0.0";
             self.textBeaconY.placeholder = @"0.0";
             self.textBeaconZ.placeholder = @"0.0";
             self.textPositionX.placeholder = @"";
             self.textPositionY.placeholder = @"";
             self.textPositionZ.placeholder = @"";
             
             // If user did select an object to modify, search for it and display it on texts.
             NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                                  andCredentialsUserDic:credentialsUserDic];
             NSMutableArray * itemsData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
             if ([@"beacon" isEqualToString:itemChosenByUser[@"sort"]]) {
                 for (NSMutableDictionary * itemDic in itemsData) {
                     if ([@"beacon" isEqualToString:itemDic[@"sort"]]) {
                         if ([itemDic[@"uuid"] isEqualToString:itemChosenByUser[@"uuid"]]) {
                             self.textUUID.text = itemDic[@"uuid"];
                             self.textMajor.text = itemDic[@"major"];
                             self.textMinor.text = itemDic[@"minor"];
                             
                             if (itemDic[@"type"]){
                                 self.textType.text = [NSString stringWithFormat:@"%@", [itemDic[@"type"] stringValue]];
                             }
                             
                             if (itemDic[@"position"]) {
                                 RDPosition * position = itemDic[@"position"];
                                 self.textBeaconX.text = [NSString stringWithFormat:@"%.2f", [position.x floatValue]];
                                 self.textBeaconY.text = [NSString stringWithFormat:@"%.2f", [position.y floatValue]];
                                 self.textBeaconZ.text = [NSString stringWithFormat:@"%.2f", [position.z floatValue]];
                             }
                         }
                     }
                 }
                 
             }
             
             break;
         }
             
         case 1: { // position mode
             
             // Visualization
             // Enable beacon elements
             [self.labelBeacon1 setEnabled:NO];
             [self.labelBeaconUUID setEnabled:NO];
             [self.labelBeaconMajor setEnabled:NO];
             [self.labelBeaconMinor setEnabled:NO];
             [self.textUUID setEnabled:NO];
             [self.textMajor setEnabled:NO];
             [self.textMinor setEnabled:NO];
             [self.labelBeacon2 setEnabled:NO];
             [self.labelBeaconX setEnabled:NO];
             [self.labelBeaconY setEnabled:NO];
             [self.labelBeaconZ setEnabled:NO];
             [self.textBeaconX setEnabled:NO];
             [self.textBeaconY setEnabled:NO];
             [self.textBeaconZ setEnabled:NO];
             [self.labelBeaconError setEnabled:NO];
             [self.buttonBeaconDelete setEnabled:NO];
             [self.buttonBeaconBack setEnabled:NO];
             [self.buttonBeaconAdd setEnabled:NO];
             // Disable position elements
             [self.labelPosition1 setEnabled:YES];
             [self.labelPositionX setEnabled:YES];
             [self.labelPositionY setEnabled:YES];
             [self.labelPositionZ setEnabled:YES];
             [self.textPositionX setEnabled:YES];
             [self.textPositionY setEnabled:YES];
             [self.textPositionZ setEnabled:YES];
             [self.labelPositionError setEnabled:YES];
             [self.buttonPositionDelete setEnabled:YES];
             [self.buttonPositionBack setEnabled:YES];
             [self.buttonPositionAdd setEnabled:YES];
             
             // Hints
             self.textUUID.placeholder = @"";
             self.textMajor.placeholder = @"";
             self.textMinor.placeholder = @"";
             self.textBeaconX.placeholder = @"";
             self.textBeaconY.placeholder = @"";
             self.textBeaconZ.placeholder = @"";
             self.textPositionX.placeholder = @"0.0";
             self.textPositionY.placeholder = @"0.0";
             self.textPositionZ.placeholder = @"0.0";
             
             // If user did select an object to modify, search for it and display it on texts.
             NSMutableDictionary * itemChosenByUser = [sharedData fromSessionDataGetItemChosenByUserFromUserWithUserDic:userDic
                                                                                                  andCredentialsUserDic:credentialsUserDic];
             NSMutableArray * itemsData = [sharedData getItemsDataWithCredentialsUserDic:credentialsUserDic];
             if ([@"position" isEqualToString:itemChosenByUser[@"sort"]]) {
                 
                 for (NSMutableDictionary * itemDic in itemsData) {
                     if ([@"position" isEqualToString:itemDic[@"sort"]]) {
                         if ([itemDic[@"uuid"] isEqualToString:itemChosenByUser[@"uuid"]]) {
                         
                             if (itemDic[@"type"]){
                                 self.textType.text = [NSString stringWithFormat:@"%@", [itemDic[@"type"] stringValue]];
                             }
                             
                             if (itemDic[@"position"]) {
                                 RDPosition * position = itemDic[@"position"];
                                 self.textPositionX.text = [NSString stringWithFormat:@"%.2f", [position.x floatValue]];
                                 self.textPositionY.text = [NSString stringWithFormat:@"%.2f", [position.y floatValue]];
                                 self.textPositionZ.text = [NSString stringWithFormat:@"%.2f", [position.z floatValue]];
                             }
                         }
                     }
                 }
                 
             }
             
             break;
         }
         default:
             break;
     }

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
 @method handleButtonDelete:
 @discussion This method handles the 'Delete' button action and ask the main menu to delete the beacon submitted by the user.
 */
- (IBAction)handleButtonDelete:(id)sender
{
    // Validate data
    if (![self validateUserEntries]) {
        return;
    }
    
    // Compose a dictionary with the information provided
    NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
    
    // Different behaviour if position or beacon
    if (selectedSegmentIndex == 0) { // iBeacon mode
        infoDic[@"sort"] = @"beacon";
    }
    if (selectedSegmentIndex == 1) { // position mode
        infoDic[@"sort"] = @"position";
    }
    infoDic[@"uuid"] = [self.textUUID text];
    infoDic[@"major"] = [self.textMajor text];
    infoDic[@"minor"] = [self.textMinor text];
    
    // Ask shared data to remove it; database could not be accessed.
    if (
        [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        
        // It can be not found
        NSMutableDictionary * itemToRemove = [sharedData inItemDataRemoveItemWithInfoDic:infoDic
                                                                  withCredentialsUserDic:credentialsUserDic];
        if (itemToRemove) {
            
            // PERSISTENT: REMOVE ITEM
            // Remove it from the persistent memory
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            // TO DO: Assign items by user. Alberto J. 15/11/2019.
            
            // Create a NSData for the item and save it using its name
            // Item's name
            NSString * itemIdentifier = itemToRemove[@"identifier"];
            // Create the item's data tu unarchive it
            NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
            [userDefaults removeObjectForKey:itemKey];
            
            // And upload index and 'areItems'
            // Get the index in which names of items are saved for retrieve them later
            NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
            NSMutableArray * itemsIndex;
            if (itemsIndexData) {
                itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
                [userDefaults removeObjectForKey:@"es.uam.miso/data/items/index"];
            } else {
                NSLog(@"[ERROR][VCAB] The index in persistent memory is empty; removed from shared data only.");
            }
            [itemsIndex removeObject:itemKey];
            itemsIndexData = nil; // ARC disposing
            itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
            [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
            
            NSUInteger savedIntemsNumber = itemsIndex.count;
            NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
            if (areItemsData) {
                [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
            }
            areItemsData = nil; // ARC disposing
            if (savedIntemsNumber == 0) {
                areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
            } else {
                areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
            }
            [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
            NSLog(@"[INFO][VCAB] Item removed from device memory");
            // END PERSISTENT: REMOVE ITEM
            
            [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
        } else { // Not found
            [self alertUserWithTitle:@"Item won't be removed."
                             message:[NSString stringWithFormat:@"Type could not be found; please, try again or check for multiuser interferences."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Item could not be removed.");
        }
        
    } else { // Type not found
        [self alertUserWithTitle:@"Type won't be removed."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCAB] Shared data could not be accessed while removing a type.");
    }
    return;
}

/*!
 @method handleButtonAdd:
 @discussion This method handles the Add button action and ask the main menu to add the new beacon submitted by the user.
 */
- (IBAction)handleButtonAdd:(id)sender
{
    
    // The beacons cannot be registered twice with different ID because Location Manager will fail their initialization; because of coherence, two equals positions cannot be registered. Thus, the data of every item must be searched and not only its identifier.
    
    // Different behaviour if position or beacon
    // Validate data
    if (![self validateUserEntries]) {
        return;
    }
    
    // Compose a dictionary with the information provided
    NSMutableDictionary * infoDic = [[NSMutableDictionary alloc] init];
    // Different behaviour if position or beacon
    if (selectedSegmentIndex == 0) { // iBeacon mode
        infoDic[@"sort"] = @"beacon";
        infoDic[@"uuid"] = [self.textUUID text];
        infoDic[@"major"] = [self.textMajor text];
        infoDic[@"minor"] = [self.textMinor text];
        NSString * beaconId = [@"beacon" stringByAppendingString:[itemBeaconIdNumber stringValue]];
        itemBeaconIdNumber = [NSNumber numberWithInteger:[itemBeaconIdNumber integerValue] + 1];
        beaconId = [beaconId stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = beaconId;
    }
    if (selectedSegmentIndex == 1) { // position mode
        infoDic[@"sort"] = @"position";
        infoDic[@"uuid"] = [[NSUUID UUID] UUIDString];
        NSString * positionId = [@"position" stringByAppendingString:[itemPositionIdNumber stringValue]];
        itemPositionIdNumber = [NSNumber numberWithInteger:[itemPositionIdNumber integerValue] + 1];
        positionId = [positionId stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = positionId;
    }
    if ([sharedData fromSessionDataGetSessionWithUserDic:userDic
                                   andCredentialsUserDic:credentialsUserDic]) {
        MDType * type = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                    andCredentialsUserDic:credentialsUserDic];
        infoDic[@"type"] = type;
        
    }
    
    // Position
    if (selectedSegmentIndex == 0) { // iBeacon mode
        // If the three coordinate values had been submitted
        if (
            ![[self.textBeaconX text] isEqualToString:@""] &&
            ![[self.textBeaconY text] isEqualToString:@""] &&
            ![[self.textBeaconZ text] isEqualToString:@""]
            )
        {
            
            RDPosition * positionToAdd = [[RDPosition alloc] init];
            positionToAdd.x = [NSNumber numberWithFloat:[[self.textBeaconX text] floatValue]];
            positionToAdd.y = [NSNumber numberWithFloat:[[self.textBeaconY text] floatValue]];
            positionToAdd.z = [NSNumber numberWithFloat:[[self.textBeaconZ text] floatValue]];
            infoDic[@"position"] = positionToAdd;
        } else {
            
            // If all coordinate values missing the user tries to re-register a beacon, unless the user wanted to set its type
            if (
                [[self.textBeaconX text] isEqualToString:@""] &&
                [[self.textBeaconY text] isEqualToString:@""] &&
                [[self.textBeaconZ text] isEqualToString:@""]
                )
            {
                // This code is reached also when an type was set or uploaded, so check it
                if (![sharedData fromSessionDataGetSessionWithUserDic:userDic
                                                andCredentialsUserDic:credentialsUserDic]) {
                    [self alertUserWithTitle:@"Warning."
                                     message:@"As no coordinate values were introduced, the item's position is null."
                                  andHandler:^(UIAlertAction * action) {
                                      // Do nothing
                                  }
                     ];
                    self.labelPositionError.text = @"Warning. As no coordinate values were introduced, the item's position is null.";
                    infoDic[@"position"] = nil;
                }
            } else {
                // If ths code is reached means that there is only some coordinate values but not all of them
                [self alertUserWithTitle:@"Some coordinate values missing."
                                 message:@"Please, submit three (x, y, z) values or push \"Back\"."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                self.labelBeaconError.text = @"Error. Some coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                return;
            }
        }
    }
    if (selectedSegmentIndex == 1) { // position mode
        // If the three coordinate values had been submitted
        if (
            ![[self.textPositionX text] isEqualToString:@""] &&
            ![[self.textPositionY text] isEqualToString:@""] &&
            ![[self.textPositionZ text] isEqualToString:@""]
            )
        {
            
            RDPosition * positionToAdd = [[RDPosition alloc] init];
            positionToAdd.x = [NSNumber numberWithFloat:[[self.textPositionX text] floatValue]];
            positionToAdd.y = [NSNumber numberWithFloat:[[self.textPositionY text] floatValue]];
            positionToAdd.z = [NSNumber numberWithFloat:[[self.textPositionZ text] floatValue]];
            infoDic[@"position"] = positionToAdd;
        } else {
            
            // If all coordinate values missing the user tries to register a no located position but set its type.
            if (
                [[self.textPositionX text] isEqualToString:@""] &&
                [[self.textPositionY text] isEqualToString:@""] &&
                [[self.textPositionZ text] isEqualToString:@""]
                )
            {
                // This code is reached also when an type was set or uploaded, so check it
                [self alertUserWithTitle:@"Warning."
                                 message:@"Please, submit three (x, y, z) values or push \"Back\"."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                self.labelPositionError.text = @"Error. Coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                return;
            } else {
                // If ths code is reached means that there is only some coordinate values but not all of them
                [self alertUserWithTitle:@"Some coordinate values missing."
                                 message:@"Please, submit three (x, y, z) values or push \"Back\"."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                self.labelBeaconError.text = @"Error. Some coordinate values missing. Please, submit three (x, y, z) values or push \"Back\".";
                return;
            }
        }
    }
    
    // Add the item
    BOOL savedItem = [sharedData inItemDataAddItemOfSort:infoDic[@"sort"]
                                                withUUID:infoDic[@"uuid"]
                                             withInfoDic:infoDic
                               andWithCredentialsUserDic:credentialsUserDic];
    if (savedItem) {
        // PERSISTENT: SAVE ITEM
        // Retrieve the item; saved data could be different from the request
        NSMutableArray * savedItems = [sharedData fromItemDataGetItemsWithUUID:infoDic[@"uuid"]
                                                         andCredentialsUserDic:credentialsUserDic];
        if (savedItems.count == 0) {
            NSLog(@"[ERROR][VCAB] No saved item found with identifier %@.", infoDic[@"uuid"]);
        } else {
            if (savedItems.count > 1) {
                NSLog(@"[ERROR][VCAB] More than one saved items found with identifier %@.", infoDic[@"uuid"]);
            }
            NSMutableDictionary * itemDic = [savedItems objectAtIndex:0];
            
            // Save them in persistent memory
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            // TO DO: Assign items by user. Alberto J. 15/11/2019.
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
            NSLog(@"[INFO][VCAB] Item saved in device memory.");
        }
        // END PERSISTENT: SAVE ITEM
    } else {
        NSLog(@"[ERROR][VCAB] Item %@ could not be saved in device memory.", infoDic[@"UUID"]);
    }

    [self performSegueWithIdentifier:@"submitFromAddToMain" sender:sender];
}

/*!
 @method handleButtonBack:
 @discussion This method handles the 'Back' button action and segue back to the main menu; 'prepareForSegue:sender:' method is called before.
 */
- (IBAction)handleButtonBack:(id)sender
{
    [self performSegueWithIdentifier:@"backFromAddToMain" sender:sender];
}

/*!
 @method handleButtonAddType:
 @discussion This method handles the 'Add type' button action and register the user type if it does not exit.
 */
- (IBAction)handleButtonAddType:(id)sender
{
    // The user tries to register the type called
    NSString * newTypeName = [self.textType text];
    
    // Search if the MDType with this name is not already registered and submit it; if it is so, alert the user.
    if (![sharedData fromMetamodelDataIsTypeWithName:newTypeName andWithCredentialsUserDic:credentialsUserDic]) {
        MDType * newType = [[MDType alloc] initWithName:newTypeName];
        
        // If the remove transaction is succesful it returns YES
        if (
            [sharedData inMetamodelDataAddType:newType withCredentialsUserDic:credentialsUserDic]
            )
        {
            
            // Once registered in shared data, save it in the device persistent memory
            // Upload 'areMetamodel'
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSData * areMetamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            if (areMetamodelData) {
                [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            }
            areMetamodelData = nil; // ARC disposing
            areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
            [userDefaults setObject:areMetamodelData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            // Save the type
            NSData * metamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodel"];
            NSMutableArray * types;
            if (metamodelData) {
                types = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelData];
                NSLog(@"[INFO][VCAB] Metamodel types were found in the device.");
            } else {
                NSLog(@"[INFO][VCAB] No metamodel type was found in the device.");
                types = [[NSMutableArray alloc] init];
            }
            [types addObject:newType];
            metamodelData = nil;  // ARC disposing
            NSData * newMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:types];
            [userDefaults setObject:newMetamodelData forKey:@"es.uam.miso/data/metamodels/metamodel"];
            
            self.textType.text = @"";
            NSLog(@"[INFO][VCAB] Type created, added to shared data collections and saved in device.");
        } else { // Shared data not acessible
            [self alertUserWithTitle:@"Type won't be registered."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be accessed while registering type.");
        }
        
    } else {
        [self alertUserWithTitle:@"Invalid type name."
                         message:[NSString stringWithFormat:@"The type <%@> already exists. Please, use a different one or reuse the type <%@>", newTypeName, newTypeName]
                      andHandler:^(UIAlertAction * action) {
                          self.textType.text = @"";
                      }
         ];
    }
    
    // Reload visualization
    [self.tableTypes reloadData];
    return;
}


/*!
 @method handleButtonRemoveType:
 @discussion This method handles the 'Remove type' button action and unregister the user type if it exits.
 */
- (IBAction)handleButtonRemoveType:(id)sender
{
    // The user tries to remove a type; the user must select it in the table, not write it
    MDType * typeToRemove;
    if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
        )
    {
        typeToRemove = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                            andCredentialsUserDic:credentialsUserDic];
        self.textType.text = @"";
    } else { // Type not found
        [self alertUserWithTitle:@"Type won't be removed."
                         message:[NSString stringWithFormat:@"Database could not be accessed; please, try again."]
                      andHandler:^(UIAlertAction * action) {
                          // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                      }
         ];
        NSLog(@"[ERROR][VCAB] Shared data could not be accessed while removing type.");
        return;
    }
    
    // Search it and remove it.
    NSString * typeToRemoveName = [typeToRemove getName];
    if ([sharedData fromMetamodelDataIsTypeWithName:typeToRemoveName andWithCredentialsUserDic:credentialsUserDic]) {
        
        // If the remove transaction is succesful it returns YES
        if (
            [sharedData inMetamodelDataRemoveItemWithName:typeToRemoveName andCredentialsUserDic:credentialsUserDic]
            )
        {
            // Once removed in shared data, remove it from the device persistent memory
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSData * metamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodel"];
            NSMutableArray * types;
            if (metamodelData) {
                types = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelData];
                NSLog(@"[INFO][VCAB] Metamodel types were found in the device.");
            } else {
                NSLog(@"[ERROR][VCAB] No metamodel type was found in the device.");
            }
            
            // [1] Upload 'areMetamodel'
            NSData * areMetamodelData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            if (areMetamodelData) {
                [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            }
            // [2] Remove old metamodel and save the new one
            areMetamodelData = nil; // ARC disposing
            if (types) {
                // [2] Remove old metamodel and save the new one
                [types removeObject:typeToRemove];
                metamodelData = nil;  // ARC disposing
                NSData * newMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:types];
                [userDefaults setObject:newMetamodelData forKey:@"es.uam.miso/data/metamodels/metamodel"];
                
                // [1] Upload 'areMetamodel'
                if (types.count == 0) {
                    areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
                } else {
                    areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
                }
            } else {
                // [1] Upload 'areMetamodel'
                areMetamodelData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
            }
            // [1] Upload 'areMetamodel'
            [userDefaults setObject:areMetamodelData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
            
            
            
            self.textType.text = @"";
            NSLog(@"[INFO][VCAB] Type removed from shared data collections and from device.");
        } else { // Type not found
            [self alertUserWithTitle:@"Type won't be removed."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be accessed while removing type.");
        }
    } else {
        [self alertUserWithTitle:@"Invalid type selected."
                         message:[NSString stringWithFormat:@"The type <%@> does not exist. Please, try again", typeToRemoveName]
                      andHandler:^(UIAlertAction * action) {
                          
                      }
         ];
    }
    
    // Reload visualization
    [self.tableTypes reloadData];
    return;
}

/*!
 @method prepareForSegue:sender:
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (BOOL) validateUserEntries {
    
    // Validate data
    if (selectedSegmentIndex == 0) { // iBeacon mode
        
        NSString * uuidRegex = @"[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}";
        NSPredicate * uuidTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", uuidRegex];
        if ([uuidTest evaluateWithObject:[self.textUUID text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"UUID not valid."
                             message:@"Please, submit a valid UUID."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. UUID not valid. Please, submit a valid UUID.";
            return NO;
        }
        
        NSString * majorAndMinorRegex = @"[0-9]{1}|[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}|[0-9]{1}[0-9]{1}[0-9]{1}[0-9]{1}";
        NSPredicate * majorAndMinorTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", majorAndMinorRegex];
        if ([majorAndMinorTest evaluateWithObject:[self.textMajor text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"Major value not valid."
                             message:@"Please, submit a valid major value."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. Major value not valid. Please, submit a valid major value.";
            return NO;
        }
        if ([majorAndMinorTest evaluateWithObject:[self.textMinor text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"Minor value not valid."
                             message:@"Please, submit a valid minor value."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. Minor value not valid. Please, submit a valid minor value.";
            return NO;
        }
        
        NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
        NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
        if ([floatTest evaluateWithObject:[self.textBeaconX text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"X value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. X value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
        if ([floatTest evaluateWithObject:[self.textBeaconY text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"Y value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. Y value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
        if ([floatTest evaluateWithObject:[self.textBeaconZ text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"X value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelBeaconError.text = @"Error. Z value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
    }
    
    if (selectedSegmentIndex == 1) { // position mode
        
        NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
        NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
        if ([floatTest evaluateWithObject:[self.textPositionX text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"X value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelPositionError.text = @"Error. X value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
        if ([floatTest evaluateWithObject:[self.textPositionY text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"Y value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelPositionError.text = @"Error. Y value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
        if ([floatTest evaluateWithObject:[self.textPositionZ text]]){
            //Matches
        } else {
            [self alertUserWithTitle:@"Z value not valid."
                             message:@"Please, use decimal dot: 0.01"
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            self.labelPositionError.text = @"Error. Z value not valid. Please, use decimal dot: 0.01";
            return NO;
        }
    }
    
    return YES;
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
    NSLog(@"[INFO][VCAB] Asked segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"submitFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        
        [viewControllerMainMenu setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerMainMenu setItemPositionIdNumber:itemPositionIdNumber];
        
    }
    if ([[segue identifier] isEqualToString:@"backFromAddToMain"]) {
        
        // Get destination view
        ViewControllerMainMenu * viewControllerMainMenu = [segue destinationViewController];
        // Set the variables
        [viewControllerMainMenu setCredentialsUserDic:credentialsUserDic];
        [viewControllerMainMenu setUserDic:userDic];
        [viewControllerMainMenu setSharedData:sharedData];
        [viewControllerMainMenu setMotionManager:motion];
        
        [viewControllerMainMenu setItemBeaconIdNumber:itemBeaconIdNumber];
        [viewControllerMainMenu setItemPositionIdNumber:itemPositionIdNumber];
        
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
    if (tableView == self.tableTypes) {
        // Get the number of metamodel elements; if access the database is imposible, warn the user.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            return [[sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic] count];
        } else { // Type not found
            [self alertUserWithTitle:@"Types won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be accessed while loading types.");
        }
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
    if (tableView == self.tableTypes) {
        
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            MDType * type = [
                             [sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic]
                             objectAtIndex:indexPath.row
                             ];
            cell.textLabel.numberOfLines = 0; // Means any number
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [type getName]];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        } else { // Type not found
            [self alertUserWithTitle:@"Types won't be loaded."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be accessed while loading cells' type.");
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableTypes) {
        
        // Get the chosen type name
        // Database could not be accessed.
        if (
            [sharedData validateCredentialsUserDic:credentialsUserDic]
            )
        {
            
            MDType * typeChosenByUser = [
                                         [sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic]
                                         objectAtIndex:indexPath.row
                                         ];
            
            // If the already chosen type is the same, the user wants to deselect it; if not, could be that a type is already selected or not
            
            // If a type is already selected
            MDType * typeChosenByUserStored = [sharedData fromSessionDataGetTypeChosenByUserFromUserWithUserDic:userDic
                                                                                          andCredentialsUserDic:credentialsUserDic];
            if (typeChosenByUserStored) { // Already one type selected
                if ([typeChosenByUser isEqualToMDType:typeChosenByUserStored]) { // Deselect
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    [sharedData inSessionDataSetTypeChosenByUser:nil
                                               toUserWithUserDic:userDic
                                           andCredentialsUserDic:credentialsUserDic];
                } else { // Deselect the old one and select the new one
                    
                    NSInteger oldIndex = [
                                          [sharedData getMetamodelDataWithCredentialsUserDic:credentialsUserDic]
                                          indexOfObject:typeChosenByUserStored
                                          ];
                    // Deselect
                    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:indexPath.section]
                                             animated:NO
                     ];
                    // Select
                    [sharedData inSessionDataSetTypeChosenByUser:typeChosenByUser
                                               toUserWithUserDic:userDic
                                           andCredentialsUserDic:credentialsUserDic];
                    
                }
            } else { // No type selected; select
                [sharedData inSessionDataSetTypeChosenByUser:typeChosenByUser
                                           toUserWithUserDic:userDic
                                       andCredentialsUserDic:credentialsUserDic];
            }
            
        } else { // Type not found
            [self alertUserWithTitle:@"Types won't be selected."
                             message:[NSString stringWithFormat:@"Database could not be accessed; please, try again later."]
                          andHandler:^(UIAlertAction * action) {
                              // TO DO: handle intrusion situations. Alberto J. 2019/09/10.
                          }
             ];
            NSLog(@"[ERROR][VCAB] Shared data could not be accessed while selecting a cells' type.");
        }
    }
    return;
}

@end

