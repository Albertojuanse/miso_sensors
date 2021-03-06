//
//  ViewControllerConfigurationBeacons.m
//  Sensors test
//
//  Created by Alberto J. on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationBeacons.h"

@implementation ViewControllerConfigurationBeacons

#pragma mark - UIViewController delegated methods
/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Preventing previous view variables' values due to tab controller lifecycle
    items = nil;
    chosenItem = nil;
    selectedSegmentIndex = 0;
    
    // Toolbar layout
    self.toolbar.backgroundColor = [VCDrawings getNormalThemeColor];
    
    // View layout
    [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
    [self.textX setPlaceholder:@"0.0"];
    [self.textX setText:@""];
    [self.textY setPlaceholder:@"0.0"];
    [self.textY setText:@""];
    [self.textZ setPlaceholder:@"0.0"];
    [self.textZ setText:@""];
    [self.textUUID setPlaceholder:@"12345678-1234-1234-1234-123456789012"];
    [self.textUUID setText:@""];
    [self.textMajor setPlaceholder:@"0"];
    [self.textMajor setText:@""];
    [self.textMinor setPlaceholder:@"0"];
    [self.textMinor setText:@""];
    [self.buttonSave setTitleColor:[VCDrawings getNormalThemeColor]
                          forState:UIControlStateNormal];
    [self.buttonEdit setTitleColor:[VCDrawings getNormalThemeColor]
                          forState:UIControlStateNormal];
    [self.segmentedControl setTintColor:[VCDrawings getNormalThemeColor]];
    [self.buttonBack setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    [self changeView];
    
    // Variables
    userWantsToSetRoutine = NO;
    // Search for variables from device memory
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Search for 'areItems' boolean and if so, load the items' NSMutableDictionary array
    NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
    NSString * areItems;
    if (areItemsData) {
        areItems = [NSKeyedUnarchiver unarchiveObjectWithData:areItemsData];
    }
    // Retrieve or create each category of information
    if (areItemsData && areItems && [areItems isEqualToString:@"YES"]) {
        // Existing saved data
        // Retrieve the items using the index
        
        // Get the index...
        NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
        NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
        // ...and retrieve each item
        items = [[NSMutableArray alloc] init];
        for (NSString * itemIdentifier in itemsIndex) {
            NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
            NSData * itemData = [userDefaults objectForKey:itemKey];
            NSMutableDictionary * itemDic = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
            [items addObject:itemDic];
        }
        
        NSLog(@"[INFO][VCCB] %tu items found in device.", items.count);
    }
    
    // This object must listen to this events
    [self.segmentedControl addTarget:self
                              action:@selector(uploadSegmentIndex:)
                    forControlEvents:UIControlEventValueChanged];
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableItems.delegate = self;
    self.tableItems.dataSource = self;
    [self.tableItems reloadData];
}

/*!
 @method viewDidAppear:
 @discussion This method notifies the view controller that its view was added to a view hierarchy.
 */
- (void)viewDidAppear:(BOOL)animated
{
    
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
    [self.textX setText:@""];
    [self.textY setText:@""];
    [self.textZ setText:@""];
    [self.textUUID setText:@""];
    [self.textMajor setText:@""];
    [self.textMinor setText:@""];
    
    // Different behaviour if position or beacon
    switch (selectedSegmentIndex) {
        case 0: {// position mode
            
            // Visualization
            // Disable position elements
            [self.textUUID setEnabled:NO];
            [self.textMajor setEnabled:NO];
            [self.textMinor setEnabled:NO];
            [self.labelBeaconUUID setEnabled:NO];
            [self.labelBeaconMajor setEnabled:NO];
            [self.labelBeaconMinor setEnabled:NO];
            [self.textUUID setText:@""];
            [self.textMajor setText:@""];
            [self.textMinor setText:@""];
            
            break;
        }
            
        case 1: { // iBeacon mode
            
            // Visualization
            // Enable beacon elements
            [self.textUUID setEnabled:YES];
            [self.textMajor setEnabled:YES];
            [self.textMinor setEnabled:YES];
            [self.labelBeaconUUID setEnabled:YES];
            [self.labelBeaconMajor setEnabled:YES];
            [self.labelBeaconMinor setEnabled:YES];
            
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
 @method setTabBar:
 @discussion This method sets the UITabBarController for switching porpuses.
 */
- (void) setTabBar:(UITabBarController *)givenTabBar
{
    tabBar = givenTabBar;
}

#pragma mark - Butons event handle
/*!
 @method handleBackButton:
 @discussion This method handles the 'edit' button action and ask the selected MDType to load on textfields.
 */
- (IBAction)handleBackButton:(id)sender
{
    // Ask user if a routine must be created
    [self askUserToCreateRoutine];
}

/*!
 @method handleEditButton:
 @discussion This method handles the 'edit' button action and ask the selected MDType to load on textfields.
 */
- (IBAction)handleEditButton:(id)sender
{
    //NSLog(@"[INFO][VCCB] User wants to edit item: %@", chosenItem);
    // Only edit if user did select a type
    if (chosenItem) {
        
        // Get type
        NSString * itemSort = chosenItem[@"sort"];
        if ([itemSort isEqualToString:@"position"]) {
            [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            // Set position
            RDPosition * itemPosition = chosenItem[@"position"];
            if (itemPosition) {
                [self.textX setText:[NSString stringWithFormat:@"%.2f", [itemPosition.x floatValue]]];
                [self.textY setText:[NSString stringWithFormat:@"%.2f", [itemPosition.y floatValue]]];
                [self.textZ setText:[NSString stringWithFormat:@"%.2f", [itemPosition.z floatValue]]];
            } else {
                NSLog(@"[ERROR][VCCB] No position found in position %@", chosenItem[@"identifier"]);
            }
            
        }
        if ([itemSort isEqualToString:@"beacon"]) {
            [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
            selectedSegmentIndex = 1;
            [self.segmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
            [self changeView];
            
            // Set position
            RDPosition * itemPosition = chosenItem[@"position"];
            if (itemPosition) {
                [self.textX setText:[NSString stringWithFormat:@"%.2f", [itemPosition.x floatValue]]];
                [self.textY setText:[NSString stringWithFormat:@"%.2f", [itemPosition.y floatValue]]];
                [self.textZ setText:[NSString stringWithFormat:@"%.2f", [itemPosition.z floatValue]]];
            } else {
                NSLog(@"[INFO][VCCB] No position found in item %@", chosenItem[@"identifier"]);
            }
            
            // Set UUID, minor and major
            NSString * uuid = chosenItem[@"uuid"];
            NSString * major = chosenItem[@"major"];
            NSString * minor = chosenItem[@"minor"];
            
            if (uuid && major && minor) {
                [self.textUUID setText:uuid];
                [self.textMajor setText:major];
                [self.textMinor setText:minor];
            } else {
                NSLog(@"[INFO][VCCB] No UUID, major or minor found in iBeacon %@", chosenItem[@"identifier"]);
            }
            
        }
        
    } else {
        return;
    }
    
}

/*!
 @method handleSaveButton:
 @discussion This method handles the 'save' button action and ask the selected MDType to be saved with the information in the textfields.
 */
- (IBAction)handleSaveButton:(id)sender
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
    
    if (selectedSegmentIndex == 0) { // position mode
        infoDic[@"sort"] = @"position";
        NSString * itemUUID = [[NSUUID UUID] UUIDString];
        infoDic[@"uuid"] = itemUUID;
        NSString * itemIdentifier = [@"position" stringByAppendingString:[itemUUID substringFromIndex:31]];
        itemIdentifier = [itemIdentifier stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = itemIdentifier;
    }
    if (selectedSegmentIndex == 1) { // iBeacon mode
        infoDic[@"sort"] = @"beacon";
        NSString * itemUUID = [self.textUUID text];
        infoDic[@"uuid"] = itemUUID;
        infoDic[@"major"] = [self.textMajor text];
        infoDic[@"minor"] = [self.textMinor text];
        NSString * itemIdentifier = [@"beacon" stringByAppendingString:[itemUUID substringFromIndex:31]];
        itemIdentifier = [itemIdentifier stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = itemIdentifier;
    }
    
    // Position
    if (selectedSegmentIndex == 0) { // position mode
        // If the three coordinate values had been submitted
        if (
            ![[self.textX text] isEqualToString:@""] &&
            ![[self.textY text] isEqualToString:@""] &&
            ![[self.textZ text] isEqualToString:@""]
            )
        {
            
            RDPosition * positionToAdd = [[RDPosition alloc] init];
            positionToAdd.x = [NSNumber numberWithFloat:[[self.textX text] floatValue]];
            positionToAdd.y = [NSNumber numberWithFloat:[[self.textY text] floatValue]];
            positionToAdd.z = [NSNumber numberWithFloat:[[self.textZ text] floatValue]];
            infoDic[@"position"] = positionToAdd;
        } else {
            
            // If all coordinate values missing the user tries to register a no located position but set its type.
            if (
                [[self.textX text] isEqualToString:@""] &&
                [[self.textY text] isEqualToString:@""] &&
                [[self.textZ text] isEqualToString:@""]
                )
            {
                // This code is reached also when an type was set or uploaded, so check it
                [self alertUserWithTitle:@"Warning."
                                 message:@"Please, submit three (x, y, z) values."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                
                // Upload layout
                [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
                [self changeView];
                NSArray * selectedRows = [self.tableItems indexPathsForSelectedRows];
                for (NSIndexPath * eachIndexPath in selectedRows) {
                    [self.tableItems deselectRowAtIndexPath:eachIndexPath animated:nil];
                }
                [self.tableItems reloadData];
                
                return;
            } else {
                // If ths code is reached means that there is only some coordinate values but not all of them
                [self alertUserWithTitle:@"Some coordinate values missing."
                                 message:@"Please, submit three (x, y, z) values."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                
                return;
            }
        }
    }
    if (selectedSegmentIndex == 1) { // iBeacon mode
        // If the three coordinate values had been submitted
        if (
            ![[self.textX text] isEqualToString:@""] &&
            ![[self.textY text] isEqualToString:@""] &&
            ![[self.textZ text] isEqualToString:@""]
            )
        {
            
            RDPosition * positionToAdd = [[RDPosition alloc] init];
            positionToAdd.x = [NSNumber numberWithFloat:[[self.textX text] floatValue]];
            positionToAdd.y = [NSNumber numberWithFloat:[[self.textY text] floatValue]];
            positionToAdd.z = [NSNumber numberWithFloat:[[self.textZ text] floatValue]];
            infoDic[@"position"] = positionToAdd;
        } else {
            
            // If all coordinate values missing the user tries to re-register a beacon, unless the user wanted to set its type
            if (
                [[self.textX text] isEqualToString:@""] &&
                [[self.textY text] isEqualToString:@""] &&
                [[self.textZ text] isEqualToString:@""]
                )
            {
                
                // This code is reached also when an type was set or uploaded, so check it
                [self alertUserWithTitle:@"Warning."
                                 message:@"As no coordinate values were introduced, the item's position is null."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                infoDic[@"position"] = nil;
                
            } else {
                // If ths code is reached means that there is only some coordinate values but not all of them
                [self alertUserWithTitle:@"Some coordinate values missing."
                                 message:@"Please, submit three (x, y, z) values or push \"Back\"."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                return;
            }
        }
    }
    
    // Validate registration to prevent duplications
    if ([self isDuplicatedItem:infoDic]) {
        
        // If it is duplicate, alert the user and ask if item has to be modified
        NSString * itemSort = infoDic[@"sort"];
        if ([itemSort isEqualToString:@"position"]) {
            
            [self alertUserWithTitle:@"This position already exists."
                             message:@"Please, submit different (x, y, z) values."
                          andHandler:^(UIAlertAction * action) {
                              // Do nothing
                          }
             ];
            [self changeView];
            return;
            
        }
        if ([itemSort isEqualToString:@"beacon"]) {
            
            [self askUserToModifyItem:infoDic];
            [self changeView];
            return;
            
        }
        
    }
    
    // Add the item
    [items addObject:infoDic];
    
    // Save in device
    [self updatePersistentItems];
    
    // Upload layout
    [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
    [self changeView];
    NSArray * selectedRows = [self.tableItems indexPathsForSelectedRows];
    for (NSIndexPath * eachIndexPath in selectedRows) {
        [self.tableItems deselectRowAtIndexPath:eachIndexPath animated:nil];
    }
    [self.tableItems reloadData];
    
}

/*!
 @method validateUserEntries
 @discussion This method is called before any segue and it is used for pass other views variables.
 */
- (BOOL) validateUserEntries {
    
    NSString * floatRegex = @"^$|[+-]?([0-9]*[.])?[0-9]+";
    NSPredicate * floatTest = [NSPredicate predicateWithFormat:@"SELF MATCHES [c] %@", floatRegex];
    if ([floatTest evaluateWithObject:[self.textX text]]){
        //Matches
    } else {
        [self alertUserWithTitle:@"X value not valid."
                         message:@"Please, use decimal dot: 0.01"
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return NO;
    }
    if ([floatTest evaluateWithObject:[self.textY text]]){
        //Matches
    } else {
        [self alertUserWithTitle:@"Y value not valid."
                         message:@"Please, use decimal dot: 0.01"
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return NO;
    }
    if ([floatTest evaluateWithObject:[self.textZ text]]){
        //Matches
    } else {
        [self alertUserWithTitle:@"Z value not valid."
                         message:@"Please, use decimal dot: 0.01"
                      andHandler:^(UIAlertAction * action) {
                          // Do nothing
                      }
         ];
        return NO;
    }
    
    // Validate beacon data only if avalible
    if (selectedSegmentIndex == 1) { // iBeacon mode
        
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
            return NO;
        }
    }
    
    return YES;
}

/*!
 @method isDuplicatedItem
 @discussion This method is called when user wants to create a new item and prevents duplicated items.
 */
- (BOOL)isDuplicatedItem:(NSMutableDictionary *)itemDic
{
    BOOL isDuplicated = NO;
    
    // The beacons cannot be registered twice with different ID because Location Manager will fail their initialization; because of coherence, two equals positions cannot be registered. Thus, the data of every item must be searched and not only its identifier.
    // Different behaviour if position or beacon
    NSString * itemSort = itemDic[@"sort"];
    if ([itemSort isEqualToString:@"position"]) {
        
        // Check position
        RDPosition * itemPosition = itemDic[@"position"];
        for (NSMutableDictionary * eachItemDic in items) {
            
            // Check only positions
            NSString * eachItemSort = eachItemDic[@"sort"];
            if ([eachItemSort isEqualToString:@"position"]) {
                RDPosition * eachItemPosition = eachItemDic[@"position"];
                if ([eachItemPosition isEqualToRDPosition:itemPosition]) {
                    isDuplicated = YES;
                }
            }
            
        }
        
    }
    if ([itemSort isEqualToString:@"beacon"]) {
        
        // Check UUID
        NSString * itemUUID = itemDic[@"uuid"];
        for (NSMutableDictionary * eachItemDic in items) {
            
            // Check only beacons
            NSString * eachItemSort = eachItemDic[@"sort"];
            if ([eachItemSort isEqualToString:@"beacon"]) {
                NSString * eachItemUUID = eachItemDic[@"uuid"];
                if ([eachItemUUID isEqualToString:itemUUID]) {
                    isDuplicated = YES;
                }
            }
            
        }
        
    }
    
    return isDuplicated;
}

/*!
 @method updatePersistentItems
 @discussion This method is called when user changes types collection in orther to upload it.
 */
- (BOOL)updatePersistentItems
{
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/items/areItems"];
    // Get the index...
    NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
    NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
    // ...and remove each item
    for (NSString * itemIdentifier in itemsIndex) {
        [userDefaults removeObjectForKey:itemIdentifier];
    }
         
    // Check if there is any item
    NSData * areItemsData;
    if (items.count > 0) {
        areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    } else {
        areItemsData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    }
    
    // Save information
    [userDefaults setObject:areItemsData forKey:@"es.uam.miso/data/items/areItems"];
    itemsIndex = nil; // ARC disposal
    itemsIndex = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * item in items) {
        // Item's name
        NSString * itemIdentifier = item[@"identifier"];
        // Save the name in the index
        [itemsIndex addObject:itemIdentifier];
        // Create the item's data and archive it
        NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
        NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
        [userDefaults setObject:itemData forKey:itemKey];
    }
    // ...and save the key
    itemsIndexData = nil; // ARC disposal
    itemsIndexData = [NSKeyedArchiver archivedDataWithRootObject:itemsIndex];
    [userDefaults setObject:itemsIndexData forKey:@"es.uam.miso/data/items/index"];
    
    return YES;
}

/*!
 @method createAndSaveConfigurations
 @discussion This method is called when user wants to finish the configuration procces and creates the routine MDRoutine object in device.
 */
- (void)createAndSaveConfigurations
{
    
    // Get all the information saved in device
    NSLog(@"[INFO][VCCB] Creating routine after configuration.");
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * routineTypes;
    NSMutableArray * routineMetamodels;
    NSMutableArray * routineModes;
    NSMutableArray * routineItems;
    
    // Search for 'areTypes' boolean and if so, load the MDType array
    NSData * areTypesData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areTypes"];
    NSString * areTypes;
    if (areTypesData) {
        areTypes = [NSKeyedUnarchiver unarchiveObjectWithData:areTypesData];
    }
    if (areTypesData && areTypes && [areTypes isEqualToString:@"YES"]) {
        // Existing saved types
        
        // Retrieve the types MDType array
        NSData * typesData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/types"];
        routineTypes = [NSKeyedUnarchiver unarchiveObjectWithData:typesData];
        
        NSLog(@"[INFO][VCCT] -> Added %tu ontologycal types found.", routineTypes.count);
    } else {
        routineTypes = nil;
    }
    
    // Modes in metamodels
    routineModes = nil;
    
    // Search for 'areMetamodels' boolean and if so, load the MDMetamodel array
    NSData * areMetamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSString * areMetamodels;
    if (areMetamodelsData) {
        areMetamodels = [NSKeyedUnarchiver unarchiveObjectWithData:areMetamodelsData];
    }
    if (areMetamodelsData && areMetamodels && [areMetamodels isEqualToString:@"YES"]) {
        // Existing saved metamodsels
        
        // Retrieve the metamodels array
        NSData * metamodelsData = [userDefaults objectForKey:@"es.uam.miso/data/metamodels/metamodels"];
        routineMetamodels = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelsData];
        
        NSLog(@"[INFO][VCCT] -> Added %tu metamodels found.", routineMetamodels.count);
    } else {
        routineMetamodels = nil;
    }
    
    // Search for 'areItems' boolean and if so, load the items' NSMutableDictionary array
    NSData * areItemsData = [userDefaults objectForKey:@"es.uam.miso/data/items/areItems"];
    NSString * areItems;
    if (areItemsData) {
        areItems = [NSKeyedUnarchiver unarchiveObjectWithData:areItemsData];
    }
    // Retrieve or create each category of information
    if (areItemsData && areItems && [areItems isEqualToString:@"YES"]) {
        // Existing saved data
        // Retrieve the items using the index
        
        // Get the index...
        NSData * itemsIndexData = [userDefaults objectForKey:@"es.uam.miso/data/items/index"];
        NSMutableArray * itemsIndex = [NSKeyedUnarchiver unarchiveObjectWithData:itemsIndexData];
        // ...and retrieve each item
        routineItems = [[NSMutableArray alloc] init];
        for (NSString * itemIdentifier in itemsIndex) {
            NSString * itemKey = [@"es.uam.miso/data/items/items/" stringByAppendingString:itemIdentifier];
            NSData * itemData = [userDefaults objectForKey:itemKey];
            NSMutableDictionary * itemDic = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
            [routineItems addObject:itemDic];
        }
        
        NSLog(@"[INFO][VCCT] -> Added %tu items found.", routineItems.count);
    } else {
        routineItems = nil;
        
    }
    
    // Create the routine and save it
    MDRoutine * routine = [[MDRoutine alloc] initWithName:@"Routine"
                                              description:@"Modelling routine"
                                                    modes:routineModes
                                               metamodels:routineMetamodels
                                                    types:routineTypes
                                                 andItems:routineItems];
    // Remove previous MDRoutine
    [userDefaults removeObjectForKey:@"es.uam.miso/data/routines/routine"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/routines/isRoutine"];
    
    // Save information
    NSData * isRoutineData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    [userDefaults setObject:isRoutineData forKey:@"es.uam.miso/data/routines/isRoutine"];
    NSData * routineData = [NSKeyedArchiver archivedDataWithRootObject:routine];
    [userDefaults setObject:routineData forKey:@"es.uam.miso/data/routines/routine"];
    
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

/*!
 @method askUserToModifyItem:
 @discussion This method ask the user if the submited item must midify the selected one; this method is called when a duplicate UUID is found.
 */
- (void) askUserToModifyItem:(NSMutableDictionary *)itemDic
{
    UIAlertController * alertAddMetamodel = [UIAlertController
                                             alertControllerWithTitle:@"This iBeacon already exists."
                                             message:@"Please, use a different UUID or tap 'modify' to replace the existing iBeacon attributes with the new ones."
                                             preferredStyle:UIAlertControllerStyleAlert
                                             ];
    
    UIAlertAction * modifyButton = [UIAlertAction
                                    actionWithTitle:@"Modify"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                     
                                        // Get all information except UUID from itemDic and set it in chosenItem
                                        NSArray * itemDicKeys = [itemDic allKeys];
                                        for (NSString * key in itemDicKeys) {
                                            if (
                                                ![key isEqualToString:@"uuid"] ||
                                                ![key isEqualToString:@"major"] ||
                                                ![key isEqualToString:@"minor"]
                                                ) {
                                                chosenItem[key] = nil;
                                                chosenItem[key] = itemDic[key];
                                            }
                                        }
                                        NSLog(@"[INFO][VCCB] User did modify the item %@", chosenItem);
                                        
                                 }
                                 ];
    
    UIAlertAction * cancelButton = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleCancel
                                    handler:nil
                                    ];
    
    [alertAddMetamodel addAction:modifyButton];
    [alertAddMetamodel addAction:cancelButton];
    [self presentViewController:alertAddMetamodel animated:YES completion:nil];
    return;
}

/*!
 @method askUserToCreateRoutine
 @discussion This method ask the user if the submited data must be the routine informatio to the main execution.
 */
- (BOOL) askUserToCreateRoutine
{
    UIAlertController * alertAddMetamodel = [UIAlertController
                                             alertControllerWithTitle:@"Set configurations as main routine?"
                                             message:@"The submitted information is saved for future use, but is not set as main modelling routine. ¿Must this configurations be the main modelling routine?"
                                             preferredStyle:UIAlertControllerStyleAlert
                                             ];
    userWantsToSetRoutine = NO;
    UIAlertAction * yesButton = [UIAlertAction
                                 actionWithTitle:@"yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     
                                     // Create and save the configurations
                                     [self createAndSaveConfigurations];
                                     [tabBar performSegueWithIdentifier:@"fromConfigurationToLogin" sender:nil];
                                     
                                 }
                                 ];
    
    UIAlertAction * cancelButton = [UIAlertAction
                                    actionWithTitle:@"No"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        
                                        // No create and save the configurations
                                        [tabBar performSegueWithIdentifier:@"fromConfigurationToLogin" sender:nil];
                                        
                                    }
                                    ];
    
    [alertAddMetamodel addAction:yesButton];
    [alertAddMetamodel addAction:cancelButton];
    [self presentViewController:alertAddMetamodel animated:YES completion:nil];
    return userWantsToSetRoutine;
}

#pragma mark - UItableView data delegate methods
/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableItems) {
        // No sections
        return 1;
    }
    return 0;
}

/*!
 @method tableView:numberOfRowsInSection:
 @discussion Handles the upload of tables; returns the number of items in them.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableItems) {
        return items.count;
    }
    return 0;
}

/*!
 @method tableView:titleForHeaderInSection:
 @discussion Handles the upload of tables; returns each section title.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableItems) {
        // No sections for types
        return @"All location items";
    }
    return nil;
}

/*!
 @method tableView:cellForRowAtIndexPath:
 @discussion Handles the upload of tables; returns each cell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = [@"Cell" stringByAppendingString:[indexPath description]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (tableView == self.tableItems) {
        
        NSMutableDictionary * eachItem = [items objectAtIndex:indexPath.row];
        NSString * itemIdentifier = eachItem[@"identifier"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", itemIdentifier];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

/*!
 @method tableView:didSelectRowAtIndexPath:
 @discussion Handles the upload of tables; handles the 'select a cell' action.
 */
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableItems) {
        
        if (indexPath.row <= items.count) {
            chosenItem = [items objectAtIndex:indexPath.row];
            NSLog(@"[INFO][VCCB] User did select item: %@", chosenItem);
        }
        
    }
}

@end
