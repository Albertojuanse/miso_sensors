//
//  ViewControllerConfiguration.m
//  Sensors test
//
//  Created by Alberto J. on 23/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationModes.h"

@implementation ViewControllerConfigurationModes

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Preventing previous view variables' values due to tab controller lifecycle
    metamodels = nil;
    
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:1.0
                                    ];
    
    // View layout
    [self.buttonBack setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    
    // Variables
    userWantsToSetRoutine = NO;    
    // Submit demo metamodel if it does not exist
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
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
        metamodels = [NSKeyedUnarchiver unarchiveObjectWithData:metamodelsData];
        
        NSLog(@"[INFO][VCCM] %tu metamodels found in device.", metamodels.count);
    } else {
        NSLog(@"[ERROR][VCCM] No metamodels found in device; demo metamodel saved.");
    }
    
    // Table delegates; the delegate methods for attending these tables are part of this class.
    self.tableMetamodels.delegate = self;
    self.tableMetamodels.dataSource = self;
    self.tableModes.delegate = self;
    self.tableModes.dataSource = self;
    
    [self.tableMetamodels reloadData];
    [self.tableModes reloadData];
    
    // Table gestures for drag and drop
    self.tableMetamodels.dragDelegate = self;
    self.tableModes.dragDelegate = self;
    self.tableMetamodels.dropDelegate = self;
    self.tableModes.dropDelegate = self;
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
 @method createAndSaveConfigurations
 @discussion This method is called when user wants to finish the configuration procces and creates the routine MDRoutine object in device.
 */
- (void)createAndSaveConfigurations
{
    // Ask user if a routine must be created
    if([self askUserToCreateRoutine]) {
        
        // Get all the information saved in device
        NSLog(@"[INFO][VCCM] Creating routine after configuration.");
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
            
            NSLog(@"[INFO][VCCM] -> Added %tu ontologycal types found.", routineTypes.count);
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
            
            NSLog(@"[INFO][VCCM] -> Added %tu metamodels found.", routineMetamodels.count);
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
            
            NSLog(@"[INFO][VCCM] -> Added %tu items found.", routineItems.count);
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
    if (tableView == self.tableMetamodels) {
        // A section for each metamodel
        return metamodels.count;
    }
    if (tableView == self.tableModes) {
        // A section for all modes
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
    if (tableView == self.tableMetamodels) {
        
        // Get each metamodel and return the number of modes used
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
        NSMutableArray * eachModes = [eachMetamodel getModes];
        if (eachModes.count == 0) {
            
            // If the metamodel is empty, create a dummy cell...
            // ...unless the dummy cell itself is being deleted; iOS needs consistency to delete cells)
            if (!removingFirstCell) {
                return 1;
            } else {
                return 0;
            }
            
        } else {
           return eachModes.count;
        }
        
    }
    if (tableView == self.tableModes) {
        // A cell for each mode
        return kModesCount;
    }
    return 0;
}

/*!
 @method tableView:titleForHeaderInSection:
 @discussion Handles the upload of tables; returns each section title.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableMetamodels) {
        // Get the name of each metamodel
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
        return [eachMetamodel getName];
    }
    if (tableView == self.tableModes) {
        // No sections for modes
        return @"All modes";
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
    
    // Configure individual cells
    if (tableView == self.tableMetamodels) {
        
        
        // Get the metamodel that shows this section...
        MDMetamodel * eachMetamodel = [metamodels objectAtIndex:indexPath.section];
        
        // ...and get each of its modes.
        NSMutableArray * eachModes = [eachMetamodel getModes];
        if (eachModes.count == 0) {
            // If the metamodel is empty, create a dummy cell.
            cell.textLabel.text = [NSString stringWithFormat:@"⇥"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            NSNumber * eachMode = [[eachMetamodel getModes] objectAtIndex:indexPath.row];
            MDMode * mode = [[MDMode alloc] initWithModeKey:[eachMode floatValue]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", mode];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        
    }
    if (tableView == self.tableModes) {
        MDMode * mode = [[MDMode alloc] initWithModeKey:(int)indexPath.row];
        cell.textLabel.text = [mode description];
        cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

#pragma mark - UItableView drag and drop delegate methods
/*!
 @method tableView:itemsForBeginningDragSession:atIndexPath:
 @discussion Handles drag and drop gestures between tables; returns the initial set of items for a drag and drop session.
 */
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView
        itemsForBeginningDragSession:(id<UIDragSession>)session
                         atIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableMetamodels) {
        // Return an empety array since these ones cannot be dragged
        NSLog(@"[INFO][VCCM] User did try to start drag and drop, but this table is not allowed to do so.");
        return [[NSArray alloc] init];
        
    }
    if (tableView == self.tableModes) {
        
        // Return the array with the initial set of items to drag
        MDMode * cellsMode = [[MDMode alloc] initWithModeKey:(int)indexPath.row];
        NSItemProvider * modeItemProvider = [[NSItemProvider alloc] initWithObject:cellsMode];
        UIDragItem * modeDragItem = [[UIDragItem alloc] initWithItemProvider:modeItemProvider];
        NSLog(@"[INFO][VCCM] User did start drag and drop; a MDMode object provided.");
        return [[NSArray alloc] initWithObjects:modeDragItem,nil];
        
    }
    return [[NSArray alloc] init];
}

/*!
 @method tableView:canHandleDropSession:
 @discussion Handles drag and drop gestures between tables; cheks if the destination table can handle a drag and drop session.
 */
- (BOOL)tableView:(UITableView *)tableView
canHandleDropSession:(id<UIDragSession>)session
{
    if (tableView == self.tableMetamodels) {
        
        // This table can only handle drops of MDMode classes.
        if (session.items.count == 1) {
            if([session canLoadObjectsOfClass:MDMode.class]) {
                NSLog(@"[INFO][VCCM] Allowed to drop provided item in this table.");
                return YES;
            } else {
                NSLog(@"[INFO][VCCM] Only MDMode class intances can be dropped in this cell.");
                return NO;
            }
        } else {
            NSLog(@"[INFO][VCCM] Only one provided item can be dropped in this cell.");
            return NO;
        }
        
    }
    if (tableView == self.tableModes) {
        // This table cannot be target of any drag and drop
        NSLog(@"[INFO][VCCM] Not allowed to drop provided item in this table.");
        return NO;
    }
    return NO;
}

/*!
 @method tableView:dropSessionDidUpdate:withDestinationIndexPath:
 @discussion Handles drag and drop gestures between tables; propose how the destination table handles a drag and drop session.
 */
- (UITableViewDropProposal *)tableView:(UITableView *)tableView
                  dropSessionDidUpdate:(id<UIDropSession>)session
              withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    //NSLog(@"[INFO][VCCM] User wants to drop in section %td", destinationIndexPath.section);
    //NSLog(@"[INFO][VCCM] User wants to drop in row %td", destinationIndexPath.row);
    
    UITableViewDropProposal * proposal;
    if (tableView == self.tableMetamodels) {
        
        // This table can only handle drops of MDMode classes.
        if (session.items.count == 1) {
            
            // Manage empty cells
            UITableViewCell * destinationCell = [self.tableMetamodels cellForRowAtIndexPath:destinationIndexPath];
            if ( !destinationCell.textLabel.text || [@"" isEqualToString:destinationCell.textLabel.text]) {
                // Return a forbidden proposal
                // NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                           intent:UITableViewDropIntentUnspecified];
            } else {
                // Return a copy and insert proposal
                // NSLog(@"[INFO][VCCM] Proposed allow user to drop (copy and insert) provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy
                                                                           intent:UITableViewDropIntentAutomatic];
            }
            
        } else {
            return nil;
        }
        
    }
    if (tableView == self.tableModes) {
        
        // This table cannot be target of any drag and drop
        // Return a forbidden proposal
        //NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this table.");
        proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                   intent:UITableViewDropIntentUnspecified];
    }
    return proposal;
}

/*!
 @method tableView:performDropWithCoordinator:
 @discussion Handles drag and drop gestures between tables; handles the drop of the dragged items' collection.
 */
- (void)tableView:(UITableView *)tableView
performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator
{
    if (tableView == self.tableMetamodels) {
        // Decide an indexPath for the new cell depending on user's droping selection
        NSIndexPath * destinationIndexPath = coordinator.destinationIndexPath;
        NSInteger section = destinationIndexPath.section;
        NSLog(@"[INFO][VCCM] User did droppped the provided item in section %td.", section);
        
        // Different behaviour depending on dropping proposal
        switch (coordinator.proposal.operation) {
            case UIDropOperationCancel:
                break;
            case UIDropOperationForbidden:
                break;
            case UIDropOperationMove:
                break;
            case UIDropOperationCopy:
                
                NSLog(@"[INFO][VCCM] Droppped provided item being copied.");
                [self.tableMetamodels performBatchUpdates:^{
                    [coordinator.session loadObjectsOfClass:MDMode.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
                        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                            MDMode * cellMode = object;
                            NSLog(@"[INFO][VCCM] Droppped and copied a MDMode item.");
                            
                            // Update metamodel
                            // As there is a dummy cell if the meta model is empty, different behaviour is needed
                            MDMetamodel * userDropMetamodel = [metamodels objectAtIndex:section];
                            NSMutableArray * userDropMetamodelModes = [userDropMetamodel getModes];
                            
                            if (userDropMetamodelModes.count == 0) {
                                
                                removingFirstCell = YES;
                                
                                // Remove the dummy cell
                                NSIndexPath * currentCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                                [tableView deleteRowsAtIndexPaths:@[currentCellIndexPath]
                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                
                                // TO DO: Not Working. Alberto J. 2020/02/06.
                                removingFirstCell = NO;
                                // Add new mode
                                BOOL newMode = [userDropMetamodel addModeKey:[cellMode getMode]];
                                if (newMode) {
                                    [self updatePersistentMetamodels];
                                    
                                    // Update table
                                    [tableView insertRowsAtIndexPaths:@[currentCellIndexPath]
                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                                
                            } else { // Not empty metamodel
                                
                                BOOL newMode = [userDropMetamodel addModeKey:[cellMode getMode]];
                                if (newMode) {
                                    [self updatePersistentMetamodels];
                                    
                                    // Update table
                                    NSInteger addRow = userDropMetamodelModes.count - 1;
                                    NSIndexPath * addIndexPath = [NSIndexPath indexPathForRow:addRow
                                                                                    inSection:section];
                                    [tableView insertRowsAtIndexPaths:@[addIndexPath]
                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                                
                            }
                            
                        }];
                    }];
                }
                                               completion:^(BOOL finished) {
                                                   if (finished) {
                                                       // Update device metamodel
                                                       [self updatePersistentMetamodels];
                                                   }
                                               }
                 ];
                break;
        }
        // Reload data
        [self.tableMetamodels reloadData];
    }
}

#pragma mark - Save metamodels
/*!
 @method updatePersistentMetamodels
 @discussion This method is called when user changes metamodels collection in orther to upload it.
 */
- (BOOL)updatePersistentMetamodels
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/metamodels"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    
    // Check if there is any metamodel
    NSData * areMetamodelsData;
    if (metamodels.count > 0) {
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"YES"];
    } else {
        areMetamodelsData = [NSKeyedArchiver archivedDataWithRootObject:@"NO"];
    }
    
    // Save information
    [userDefaults setObject:areMetamodelsData forKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    NSData * metamodelsData = [NSKeyedArchiver archivedDataWithRootObject:metamodels];
    [userDefaults setObject:metamodelsData forKey:@"es.uam.miso/data/metamodels/metamodels"];
    
    return YES;
}

@end
