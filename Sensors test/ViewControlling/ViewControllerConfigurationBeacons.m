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
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
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
    [self changeView];
    
    // Search for variables from device memory
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * areIdNumbersData = [userDefaults objectForKey:@"es.uam.miso/variables/areIdNumbers"];
    NSString * areIdNumbers;
    if (areIdNumbersData) {
        areIdNumbers = [NSKeyedUnarchiver unarchiveObjectWithData:areIdNumbersData];
    }
    if (areIdNumbersData && areIdNumbers && [areIdNumbers isEqualToString:@"YES"]) {
        
        // Existing saved data
        // Retrieve the items using the index
        
        // Retrieve the variables
       NSData * itemBeaconIdNumberData = [userDefaults objectForKey:@"es.uam.miso/variables/itemBeaconIdNumber"];
        NSData * itemPositionIdNumberData = [userDefaults objectForKey:@"es.uam.miso/variables/itemPositionIdNumber"];
        // ...and retrieve each item
        itemBeaconIdNumber = [NSKeyedUnarchiver unarchiveObjectWithData:itemBeaconIdNumberData];
        itemPositionIdNumber = [NSKeyedUnarchiver unarchiveObjectWithData:itemPositionIdNumberData];
        
        NSLog(@"[INFO][VCCB] Variable itemBeaconIdNumber found in device.");
        NSLog(@"[INFO][VCCB] Variable itemPositionIdNumber found in device.");
        
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
    [tabBar performSegueWithIdentifier:@"fromConfigurationToLogin" sender:sender];
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
        infoDic[@"uuid"] = [[NSUUID UUID] UUIDString];
        NSString * positionId = [@"position" stringByAppendingString:[itemPositionIdNumber stringValue]];
        itemPositionIdNumber = [NSNumber numberWithInteger:[itemPositionIdNumber integerValue] + 1];
        positionId = [positionId stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = positionId;
    }
    if (selectedSegmentIndex == 1) { // iBeacon mode
        infoDic[@"sort"] = @"beacon";
        infoDic[@"uuid"] = [self.textUUID text];
        infoDic[@"major"] = [self.textMajor text];
        infoDic[@"minor"] = [self.textMinor text];
        NSString * beaconId = [@"beacon" stringByAppendingString:[itemBeaconIdNumber stringValue]];
        itemBeaconIdNumber = [NSNumber numberWithInteger:[itemBeaconIdNumber integerValue] + 1];
        beaconId = [beaconId stringByAppendingString:@"@miso.uam.es"];
        infoDic[@"identifier"] = beaconId;
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
                                 message:@"Please, submit three (x, y, z) values or push \"Back\"."
                              andHandler:^(UIAlertAction * action) {
                                  // Do nothing
                              }
                 ];
                return;
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
    
    // Add the item
    [items addObject:infoDic];
    
    // Save in device
    [self updatePersistentItems];
    
    // Upload layout
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Common to all cells
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
            //NSLog(@"[INFO][VCCB] User did select item: %@", chosenItem);
        }
        
    }
}

@end
