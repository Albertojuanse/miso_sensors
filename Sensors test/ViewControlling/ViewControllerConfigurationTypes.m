//
//  ViewControllerConfigurationTypes.m
//  Sensors test
//
//  Created by Alberto J. on 4/2/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationTypes.h"

@implementation ViewControllerConfigurationTypes

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Preventing previous view variables' values due to tab controller lifecycle
    types = nil;
    chosenType = nil;
    
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
    // View layout
    [self.textName setPlaceholder:@"Type's name"];
    [self.textAttributes setPlaceholder:@"List of attributes' names"];
    [self.textModel setText:@""];
    [[self.textModel layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.textModel layer] setBorderWidth:.4];
    [[self.textModel layer] setCornerRadius:8.0f];
    
    // Variables
    userWantsToSetRoutine = NO;    
    // Get types if they exist
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
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
        types = [NSKeyedUnarchiver unarchiveObjectWithData:typesData];
        
        NSLog(@"[INFO][VCCT] %tu ontologycal types found in device.", types.count);
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableTypes.delegate = self;
    self.tableTypes.dataSource = self;
    [self.tableTypes reloadData];
    
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
    // Only edit if user did select a type
    if (chosenType) {
        
        // Set name
        [self.textName setText:[chosenType getName]];
        
        // Set attributes
        NSString * attributesString = @"";
        NSMutableArray * attributes = [chosenType getAttributes];
        for (MDAttribute * eachAtribute in attributes) {
            attributesString = [attributesString stringByAppendingString:[eachAtribute getName]];
            attributesString = [attributesString stringByAppendingString:@", "];
        }
        [self.textAttributes setText:attributesString];
        
        // Upload layout
        [self.textModel setText:@""];
        
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
    // If user did not select a type, is a new one
    NSString * nameSet = [self.textName text];
    if (!chosenType) {
        
        // Check if it existed or not
        BOOL nameFound = NO;
        MDType * typeFound;
        for (MDType * eachType in types) {
            NSString * eachName = [eachType getName];
            if ([eachName isEqualToString:nameSet]) {
                nameFound = YES;
                typeFound = eachType;
            }
        }
        // Create it if not
        if (!nameFound) {
            MDType * newType = [[MDType alloc] initWithName:nameSet];
            chosenType = newType;
            [types addObject:newType];
        } else {
            chosenType = typeFound;
        }
        
    }
    
    // Set attributes if exists
    NSString * attributesString = [self.textAttributes text];
    if (attributesString && ![attributesString isEqualToString:@""]) {
        NSMutableArray * attributes = [chosenType getAttributes];
        NSArray * attributesNames = [attributesString componentsSeparatedByString:@", "];
        for (NSString * eachAttributeNames in attributesNames) {
            
            if (![eachAttributeNames isEqualToString:@""]) {
                // Check if it existed or not
                BOOL nameFound = NO;
                for (MDAttribute * eachAttribute in attributes) {
                    NSString * eachName = [eachAttribute getName];
                    if ([eachName isEqualToString:eachAttributeNames]) {
                        nameFound = YES;
                    }
                }
                // Create it if not
                if (!nameFound) {
                    MDAttribute * newAttribute = [[MDAttribute alloc] initWithName:eachAttributeNames];
                    [attributes addObject:newAttribute];
                }
            }
            
        }
        [chosenType setAttributes:attributes];
    }
    
    // Generate a model representation
    NSMutableDictionary * typeDic = [[NSMutableDictionary alloc] init];
    [typeDic setObject:[chosenType getName] forKey:@"name"];
    [typeDic setObject:[chosenType getAttributes] forKey:@"attributes"];
    NSString * typeDicString = [NSString stringWithFormat:@"%@", typeDic];
    [self.textModel setText:typeDicString];
    
    // Save in device
    [self updatePersistentTypes];

    // Upload layout
    [self.textName setText:@""];
    [self.textAttributes setText:@""];
    NSArray * selectedRows = [self.tableTypes indexPathsForSelectedRows];
    for (NSIndexPath * eachIndexPath in selectedRows) {
        [self.tableTypes deselectRowAtIndexPath:eachIndexPath animated:nil];
    }
    [self.tableTypes reloadData];
    
}

/*!
 @method updatePersistentTypes
 @discussion This method is called when user changes types collection in orther to upload it.
 */
- (BOOL)updatePersistentTypes
{
    // Remove previous collection
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/types"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areTypes"];
    
    // Check if there is any type
    NSData * areTypesData;
    if (types.count > 0) {
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    } else {
        areTypesData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    }
    
    // Save information
    [userDefaults setObject:areTypesData forKey:@"es.uam.miso/data/metamodels/areTypes"];
    NSData * typesData = [NSKeyedArchiver archivedDataWithRootObject:types];
    [userDefaults setObject:typesData forKey:@"es.uam.miso/data/metamodels/types"];
    
    return YES;
}

/*!
 @method createAndSaveConfigurations
 @discussion This method is called when user wants to finish the configuration procces and creates the routine MDRoutine object in device.
 */
- (void)createAndSaveConfigurations
{

    // Get all the information saved in device
    NSLog(@"[INFO][VCCT] Creating routine after configuration.");
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
    // TO DO: Is another way? Alberto J. 2020/02/17.
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
    
    // Create the routine ans save it
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
    if (tableView == self.tableTypes) {
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
    if (tableView == self.tableTypes) {
        return types.count;
    }
    return 0;
}

/*!
 @method tableView:titleForHeaderInSection:
 @discussion Handles the upload of tables; returns each section title.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableTypes) {
        // No sections for types
        return @"All types";
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
    if (tableView == self.tableTypes) {
        
        MDType * eachType = [types objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", eachType];
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
    if (tableView == self.tableTypes) {
        
        if (indexPath.row <= types.count) {
            chosenType = [types objectAtIndex:indexPath.row];
        }
        
    }
}

@end
