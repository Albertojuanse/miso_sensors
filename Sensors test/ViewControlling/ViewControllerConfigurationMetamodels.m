//
//  ViewControllerConfigurationMetamodels.m
//  Sensors test
//
//  Created by Alberto J. on 24/1/20.
//  Copyright © 2020 MISO. All rights reserved.
//

#import "ViewControllerConfigurationMetamodels.h"
#import "MDMetamodel.h"
#import "MDType.h"

@implementation ViewControllerConfigurationMetamodels

#pragma mark - UIViewController delegated methods

/*!
 @method viewDidLoad
 @discussion This method initializes some properties once the object has been loaded.
 */
- (void)viewDidLoad
{
    // Preventing previous view variables' values due to tab controller lifecycle
    types = nil;
    metamodels = nil;
    typeTextField = nil;
    metamodelTextField = nil;
    removingFirstCell = nil;
    nameTypeToRemove = nil;
    
    // Toolbar layout
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PListLayout" ofType:@"plist"];
    NSDictionary * layoutDic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.toolbar.backgroundColor = [UIColor colorWithRed:[layoutDic[@"navbar/red"] floatValue]/255.0
                                                   green:[layoutDic[@"navbar/green"] floatValue]/255.0
                                                    blue:[layoutDic[@"navbar/blue"] floatValue]/255.0
                                                   alpha:0.5
                                    ];
    
    // Submit demo metamodel if it does not exist
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
        
        NSLog(@"[INFO][VCCM] %tu ontologycal types found in device.", types.count);
    }
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
    self.tableTypes.delegate = self;
    self.tableTypes.dataSource = self;
    
    [self.tableMetamodels reloadData];
    [self.tableTypes reloadData];

    // Table gestures for drag and drop
    self.tableMetamodels.dragInteractionEnabled = true;
    self.tableTypes.dragInteractionEnabled = true;
    self.tableMetamodels.dragDelegate = self;
    self.tableTypes.dragDelegate = self;
    self.tableMetamodels.dropDelegate = self;
    self.tableTypes.dropDelegate = self;
    
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
    // Create and save the configurations
    [self createAndSaveConfigurations];
    [tabBar performSegueWithIdentifier:@"fromConfigurationToLogin" sender:sender];
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

#pragma mark - UItableView data delegate methods
/*!
 @method numberOfSectionsInTableView:
 @discussion Handles the upload of tables; returns the number of sections in them.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableMetamodels) {
	// A section for each metamodel
        // One extra for "new item" row
        return metamodels.count + 1;
    }
    if (tableView == self.tableTypes) {
	// No sections for types
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
	// Get the types in each metamodel and count its types
        
        // Check if this section is the extra one for "new item"
        if (section > metamodels.count - 1) {
            return 1;
        } else {
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
            NSMutableArray * eachTypes = [eachMetamodel getTypes];
            if (eachTypes.count == 0) {
                
                // If the metamodel is empty, create a dummy cell...
                // ...unless the dummy cell itself is being deleted; iOS needs consistency to delete cells)
                if (!removingFirstCell) {
                    return 1;
                } else {
                    return 0;
                }
                
            } else {
                return eachTypes.count;
            }
        }
    }
    if (tableView == self.tableTypes) {
        // Show a cell for each type
        // One extra for "new item" row
        return types.count + 1;
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

        // Check if this section is the extra one for "new item"
        if (section > metamodels.count - 1) {
            return @"New metamodel";
        } else {
            // Get the name of each metamodel
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:section];
            return [eachMetamodel getName];
        }
    }
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
    
    // Configure individual cells
    if (tableView == self.tableMetamodels) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.section > metamodels.count - 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"+"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            // Get the metamodel that shows this section...
            MDMetamodel * eachMetamodel = [metamodels objectAtIndex:indexPath.section];
        
            // ...and get each of its types.
            NSMutableArray * eachTypes = [eachMetamodel getTypes];
            if (eachTypes.count == 0) {
                // If the metamodel is empty, create a dummy cell.
                cell.textLabel.text = [NSString stringWithFormat:@"⇤"];
                cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            } else {
                MDType * eachType = [[eachMetamodel getTypes] objectAtIndex:indexPath.row];
                cell.textLabel.text = [NSString stringWithFormat:@"%@", eachType];
                cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
            }
        }
        
    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count - 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"+"];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            MDType * eachType = [types objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", eachType];
            cell.textLabel.textColor = [UIColor colorWithWhite: 0.0 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
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
    if (tableView == self.tableMetamodels) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.section > metamodels.count - 1) {
            // Show the alert
            [self askUserNewMetamodel];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self updatePersistentMetamodels];
        }

    }
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count - 1) {
            // Switch to types tab
            [tabBar setSelectedIndex:0];
            
        } else {
            // Nothing to do
        }

    }
}

/*!
 @method askUserNewMetamodel:
 @discussion This method ask the user a new metamodel using a pop up view.
 */
- (void) askUserNewMetamodel
{
    UIAlertController * alertAddMetamodel = [UIAlertController
                                        alertControllerWithTitle:@"New metamodel"
                                        message:@"Please, write the name of the new metamodel."
                                        preferredStyle:UIAlertControllerStyleAlert
                                        ];
    
    [alertAddMetamodel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        metamodelTextField = textField;
    }];
    
    UIAlertAction * addButton = [UIAlertAction
                                 actionWithTitle:@"Add"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * _Nonnull action) {
                                     
                                     NSString * userInput = metamodelTextField.text;
                                     // Regex verification to avoid empty names.
                                     if ([userInput isEqualToString:@""]){
                                         NSLog(@"[ERROR] User tried to create a metamodel with no name.");
                                     } else {
                                         [self newMetamodelWithName:userInput andDescription:userInput];
                                         [self updatePersistentMetamodels];
                                         [self.tableMetamodels reloadData];
                                     }
                                 }
                                 ];
    
    UIAlertAction * cancelButton = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleDefault
                                    handler:nil
                                    ];
    
    [alertAddMetamodel addAction:addButton];
    [alertAddMetamodel addAction:cancelButton];
    [self presentViewController:alertAddMetamodel animated:YES completion:nil];
    return;
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
    if (tableView == self.tableTypes) {
        
        // Check if this section is the extra one for "new item"
        if (indexPath.row > types.count - 1) {
            // Return an empty array since this one cannot be dragged
            NSLog(@"[INFO][VCCM] User did try to start drag and drop, but 'new item' row is not allowed to do so.");
            return [[NSArray alloc] init];

        } else {
            // Return the array with the initial set of items to drag
            MDType * cellsType = [types objectAtIndex:indexPath.row];
            NSItemProvider * typeItemProvider = [[NSItemProvider alloc] initWithObject:cellsType];
            UIDragItem * typeDragItem = [[UIDragItem alloc] initWithItemProvider:typeItemProvider];
            NSLog(@"[INFO][VCCM] User did start drag and drop; item %@ provided", cellsType);
            return [[NSArray alloc] initWithObjects:typeDragItem,nil];
        }

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
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {
            if([session canLoadObjectsOfClass:MDType.class]) {
                NSLog(@"[INFO][VCCM] Allowed to drop provided item in this table.");
                return YES;
            } else {
                NSLog(@"[INFO][VCCM] Only MDType class intances can be dropped in this cell.");
                return NO;
            }
        } else {
            NSLog(@"[INFO][VCCM] Only one provided item can be dropped in this cell.");
            return NO;
        }

    }
    if (tableView == self.tableTypes) {     
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
                
        // This table can only handle drops of MDType classes.
        if (session.items.count == 1) {

            // Check if this section is the extra one for "new item"
            if (destinationIndexPath.section > metamodels.count - 1) {
                // Return a forbidden proposal
                // NSLog(@"[INFO][VCCM] Proposed not to allow user to drop provided item in this cell.");
                proposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden
                                                                           intent:UITableViewDropIntentUnspecified];
            } else {
                
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
            }
            
	} else { 
            return nil;   
	}

    }
    if (tableView == self.tableTypes) {
        
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
        if (section > metamodels.count - 1) {
            NSLog(@"[INFO][VCCM] User did droppped in the 'new item' cell.");
            return;
        } else {
            NSLog(@"[INFO][VCCM] User did droppped the provided item in section %td.", section);
        }

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
                    [coordinator.session loadObjectsOfClass:MDType.class completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
                        [objects enumerateObjectsUsingBlock:^(__kindof id<NSItemProviderReading>  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
                            MDType * cellType = object;
                            NSLog(@"[INFO][VCCM] Droppped and copied a NSType %@ item.", cellType);
                            
                            // Update metamodel
                            // As there is a dummy cell if the meta model is empty, different behaviour is needed
                            MDMetamodel * userDropMetamodel = [metamodels objectAtIndex:section];
                            NSMutableArray * userDropMetamodelTypes = [userDropMetamodel getTypes];
                            
                            if (userDropMetamodelTypes.count == 0) {
                                
                                removingFirstCell = YES;
                                
                                // Remove the dummy cell
                                NSIndexPath * currentCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                                [self.tableMetamodels deleteRowsAtIndexPaths:@[currentCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                
                                // Add new type
                                BOOL newType = [userDropMetamodel addType:cellType];
                                if (newType) {
                                    [self updatePersistentMetamodels];
                                    
                                    // Update table
                                    [tableView insertRowsAtIndexPaths:@[currentCellIndexPath]
                                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                                removingFirstCell = NO;
                                
                            } else { // Not empty metamodel
                                
                                BOOL newType = [userDropMetamodel addType:cellType];
                                if (newType) {
                                    [self updatePersistentMetamodels];
                                    
                                    // Update table
                                    NSInteger addRow = userDropMetamodelTypes.count - 1;
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
                
                /* Another way retrieving each UIDragItem
                NSArray * itemsProvided = coordinator.session.items;
                UIDragItem * typeDragItem = [itemsProvided objectAtIndex:0];  // Only one item was dragged
                NSItemProvider * typeItemProvider = typeDragItem.itemProvider;
                [typeItemProvider loadObjectOfClass:[MDType class]
                                  completionHandler:^(id<NSItemProviderReading> _Nullable __strong object,
                                                      NSError * _Nullable __strong error) {
                                      if (object) {
                                          MDType * cellType = object;
                                          NSLog(@"[INFO][VCCM] Droppped and copied a NSType %@ item.", cellType);
                 
                                          // Update metamodel
                                          MDMetamodel * userDropMetamodel = [metamodels objectAtIndex:section];
                                          BOOL newType =[userDropMetamodel addType:cellType];
                                          
                                          // Update table
                                          if (newType) {
                                              NSMutableArray * userDropMetamodelTypes = [userDropMetamodel getTypes];
                                              NSInteger addRow = userDropMetamodelTypes.count - 1;
                                              NSIndexPath * addIndexPath = [NSIndexPath indexPathForRow:addRow inSection:section];
                                              [self.tableMetamodels insertRowsAtIndexPaths:@[addIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                          }
                 
                                      } else {
                                          NSLog(@"[INFO][VCCM] No payload in dropped provided item.");
                                      }
                                  }
                 ];
                 */
                
                break;
        }
        // Reload data
        [self.tableMetamodels reloadData];
    }
}

#pragma mark - UItableView swip cells methods
/*!
 @method tableView:canEditRowAtIndexPath:
 @discussion This method sets every cell as editable.
 */
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableMetamodels) {
        // Only types' cells can be edited; not the extra one for create metamodels.
        if (indexPath.section > metamodels.count - 1) {
            return NO;
        } else {
            return YES;
        }
    }
    if (tableView == self.tableTypes) {
        // Only types' cells can be edited; not the extra one for create types.
        if (indexPath.row > types.count - 1) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

/*!
 @method tableView:commitEditingStyle:forRowAtIndexPath:
 @discussion This method is called when user edits a row.
 */
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableMetamodels) {
        // If deleted
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            // Remove the type in metamodel and update
            MDMetamodel * metamodelToModify = [metamodels objectAtIndex:indexPath.section];
            NSMutableArray * typesToModify = [metamodelToModify getTypes];
            MDType * typeToRemove = [typesToModify objectAtIndex:indexPath.row];
            NSLog(@"[INFO][VCCM] User wants to remove the type %@ from metamodel %@.", typeToRemove, metamodelToModify);
            
            // If the metamodels get empty, the dummy cell must be placed there
            if (typesToModify.count < 2) {
                
                // TO DO: Not wotking. Alberto J. 2020/02/06
                removingFirstCell = YES;
                // Remove the cell's type
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [typesToModify removeObjectAtIndex:indexPath.row];
                removingFirstCell = NO;
                
                // Insert the dummy cell
                [tableView insertRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                
            } else {
                
                [typesToModify removeObjectAtIndex:indexPath.row];
                // Remove the cell's type
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
            [self updatePersistentMetamodels];
            
        } else {
            NSLog(@"[VCCM][ERROR] Unhandled editing style in metamodels table: %td", editingStyle);
        }
    }
    if (tableView == self.tableTypes) {
        // If deleted
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            MDType * typeToRemove = [types objectAtIndex:indexPath.row];
            NSLog(@"[INFO][VCCM] User wants to remove type %@.", typeToRemove);
            
            // Remove the type from metamodels that use it
            NSMutableArray * metamodelsIndexPaths = [self fromMetamodelsGetIndexPathsOfTypeWithName:[typeToRemove getName]];
            for (NSIndexPath * eachMetamodelIndexPath in metamodelsIndexPaths) {
                
                MDMetamodel * metamodelToModify = [metamodels objectAtIndex:eachMetamodelIndexPath.section];
                NSLog(@"[INFO][VCCM] User wants to remove the type %@ from metamodel %@.", typeToRemove, metamodelToModify);
                NSMutableArray * typesToModify = [metamodelToModify getTypes];
                
                // If the metamodels get empty, the dummy cell must be placed there
                if (typesToModify.count < 2) {
                    
                    // Remove the types cell
                    removingFirstCell = YES;
                    [typesToModify removeObjectAtIndex:eachMetamodelIndexPath.row];
                    // Remove the cells of these types in metamodels
                    NSLog(@"[INFO][VCCM] Removing cells of type %@ from metamodels table.", typeToRemove);
                    [self.tableMetamodels deleteRowsAtIndexPaths:@[eachMetamodelIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    removingFirstCell = NO;
                    
                    [tableView insertRowsAtIndexPaths:@[eachMetamodelIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                    
                } else { // Not empty metamodel
                    
                    [typesToModify removeObjectAtIndex:eachMetamodelIndexPath.row];
                    // Remove the cells of these types in metamodels
                    NSLog(@"[INFO][VCCM] Removing cells of type %@ from metamodels table.", typeToRemove);
                    [self.tableMetamodels deleteRowsAtIndexPaths:@[eachMetamodelIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                }
            }
            
            // Upload the metamodels in device
            [self updatePersistentMetamodels];
            
            // Remove the type itself and update
            [self removeTypeWithName:[typeToRemove getName]];
            [self updatePersistentTypes];
            // Remove the cell's type
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } else {
            NSLog(@"[VCCM][ERROR] Unhandled editing style in types table: %td", editingStyle);
        }
    }
}

#pragma mark - New types and metamodels
/*!
 @method newMetamodelWithName:andDescription:
 @discussion This method is called when user wants to create a new metamodel.
 */
- (BOOL)newMetamodelWithName:(NSString *)name
              andDescription:(NSString *)description
{
    MDMetamodel * newMetamodel = [[MDMetamodel alloc] initWithName:name
                                                    andDescription:description];
    [metamodels addObject:newMetamodel];
    return YES;
}

/*!
 @method removeMetamodelWithName:
 @discussion This method is called when user wants to remove a metamodel.
 */
- (BOOL)removeMetamodelWithName:(NSString *)name
{
    MDMetamodel * foundMetamodel;
    for (MDMetamodel * eachMetadmodel in metamodels) {
        if ([name isEqualToString:[eachMetadmodel getName]]) {
            foundMetamodel = eachMetadmodel;
        }
    }
    if (foundMetamodel) {
        [metamodels removeObject:foundMetamodel];
        return YES;
    }
    return NO;
}

/*!
 @method updatePersistentMetamodels
 @discussion This method is called when user changes metamodels collection in orther to upload it.
 */
- (BOOL)updatePersistentMetamodels
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/metamodels"];
    [userDefaults removeObjectForKey:@"es.uam.miso/data/metamodels/areMetamodels"];
    
    // Check if there is any type
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

/*!
 @method fromMetamodelsGetIndexPathsOfTypeWithName:
 @discussion This method is called when user deletes a type and returns the index paths of that type in metamodels to remove them too.
 */
- (NSMutableArray *)fromMetamodelsGetIndexPathsOfTypeWithName:(NSString *)name
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] init];
    NSInteger metamodelIndex = 0;
    // Search for the type in metamodels
    for (MDMetamodel * eachMetamodel in metamodels) {
        
        NSInteger typeIndex = 0;
        NSMutableArray * eachTypes = [eachMetamodel getTypes];
        for (MDType * eachType in eachTypes) {
            
            if ([name isEqualToString:[eachType getName]]) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:typeIndex inSection:metamodelIndex]];
            }
            typeIndex = typeIndex + 1;
        }
        
        metamodelIndex = metamodelIndex + 1;
    }
    
    return indexPaths;
}

/*!
 @method newTypeWithName:
 @discussion This method is called when user wants to create a new type.
 */
- (BOOL)newTypeWithName:(NSString *)name
{
    MDType * newType = [[MDType alloc] initWithName:name];
    [types addObject:newType];
    return YES;
}

/*!
 @method removeTypeWithName:
 @discussion This method is called when user wants to remove a type.
 */
- (BOOL)removeTypeWithName:(NSString *)name
{
    // Remove the type itself
    MDType * foundType;
    for (MDType * eachType in types) {
        if ([name isEqualToString:[eachType getName]]) {
            foundType = eachType;
        }
    }
    if (foundType) {
        [types removeObject:foundType];
        return YES;
    } else {
    }
    return NO;
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

@end
