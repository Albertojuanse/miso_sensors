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
    
    // Search for 'areItems' boolean and if so, load the items' NSMutableDictionary array
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
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
        }
        
    }
}

@end
